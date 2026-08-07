#--------------------------------------------------------------
# Module: aws/jit_access
# Purpose: JIT (Just-In-Time) privileged access system with Slack integration.
#          Manages temporary IAM Identity Center Permission Set assignments
#          with approval workflow, time-bound access, and automatic revocation.
# Notes: Lambda zip files are built in a separate repository and placed in
#        lambda/outputs/. This module references them via local_existing_package.
#--------------------------------------------------------------
data "aws_region" "current" {}
data "aws_ssoadmin_instances" "this" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
  # Data: IAM Identity Center instance (one per account)
  identity_center_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id   = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

#--------------------------------------------------------------
# DynamoDB Table: jit-access-requests
# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest
#--------------------------------------------------------------
module "dynamodb_table_requests" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "5.5.1"

  region = local.region

  name                = "${var.name_prefix}jit-access-requests"
  autoscaling_enabled = false
  attributes = [
    {
      name = "request_id"
      type = "S"
    },
    {
      name = "slack_user_id"
      type = "S"
    },
    {
      name = "created_at"
      type = "S"
    },
    {
      name = "status"
      type = "S"
    },
    {
      name = "start_at"
      type = "S"
    },
  ]
  billing_mode = "PAY_PER_REQUEST"
  global_secondary_indexes = [
    {
      name            = "gsi-user"
      hash_key        = "slack_user_id"
      range_key       = "created_at"
      projection_type = "ALL"
    },
    {
      name            = "gsi-status"
      hash_key        = "status"
      range_key       = "start_at"
      projection_type = "ALL"
    },
  ]
  deletion_protection_enabled        = true
  hash_key                           = "request_id"
  point_in_time_recovery_enabled     = true
  server_side_encryption_enabled     = var.kms_key_arn != null
  server_side_encryption_kms_key_arn = var.kms_key_arn
  table_class                        = "STANDARD"
  ttl_attribute_name                 = "expires_at"
  ttl_enabled                        = true

  tags = var.tags
}

#--------------------------------------------------------------
# SSM Parameter Store: profiles configuration
#--------------------------------------------------------------
resource "aws_ssm_parameter" "approver_channel" {
  region = local.region
  name   = "${var.ssm_parameter_prefix}/config/approver-channel"
  type   = "String"
  value  = var.slack.approver_channel_id

  tags = var.tags
}

resource "aws_ssm_parameter" "state_machine_arn" {
  region = local.region
  name   = "${var.ssm_parameter_prefix}/config/state-machine-arn"
  type   = "String"
  value  = module.step_functions.state_machine_arn

  tags = var.tags
}

resource "aws_ssm_parameter" "profiles" {
  for_each = var.profiles

  region = local.region
  name   = "${var.ssm_parameter_prefix}/config/profiles/${each.key}"
  type   = "String"
  value = jsonencode({
    account_id           = each.value.account_id
    permission_set_arn   = each.value.permission_set_arn
    max_duration_minutes = each.value.max_duration_minutes
    approvers            = each.value.approvers
    description          = each.value.description
  })

  tags = var.tags
}

resource "aws_ssm_parameter" "user_mapping" {
  for_each = var.slack.user_mappings

  region = local.region
  name   = "${var.ssm_parameter_prefix}/user-mapping/${each.key}"
  type   = "String"
  value  = each.value

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "lambda" {
  name = "${var.name_prefix}jit-access-lambda"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "lambda" {
  name = "${var.name_prefix}jit-access-lambda"
  role = aws_iam_role.lambda.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = concat([
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Sid    = "DynamoDB"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:Query",
          "dynamodb:Scan",
        ]
        Resource = [
          module.dynamodb_table_requests.dynamodb_table_arn,
          "${module.dynamodb_table_requests.dynamodb_table_arn}/index/*",
        ]
      },
      {
        Sid    = "SSMParameterStore"
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParametersByPath",
        ]
        Resource = "arn:aws:ssm:*:*:parameter${var.ssm_parameter_prefix}/*"
      },
      {
        Sid    = "IdentityCenter"
        Effect = "Allow"
        Action = [
          "sso:CreateAccountAssignment",
          "sso:DeleteAccountAssignment",
          "sso:DescribeAccountAssignmentCreationStatus",
          "sso:DescribeAccountAssignmentDeletionStatus",
        ]
        Resource = "*"
      },
      {
        Sid    = "IdentityStore"
        Effect = "Allow"
        Action = [
          "identitystore:GetUserId",
        ]
        Resource = "*"
      },
      {
        Sid    = "StepFunctions"
        Effect = "Allow"
        Action = [
          "states:StartExecution",
          "states:StopExecution",
          "states:DescribeExecution",
        ]
        Resource = module.step_functions.state_machine_arn
      },
      {
        Sid      = "LambdaInvoke"
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = module.lambda_jit_access.lambda_function_arn
      },
      ], var.kms_key_arn != null ? [{
        Sid    = "KMS"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey",
        ]
        Resource = var.kms_key_arn
    }] : [])
  })
}

resource "aws_iam_role_policy_attachment" "lambda_vpc" {
  count = var.vpc_config != null ? 1 : 0

  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

#--------------------------------------------------------------
# Lambda: jit-access (single function, action-based routing)
#--------------------------------------------------------------
module "lambda_jit_access" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.8.0"

  region = local.region

  architectures                     = ["arm64"]
  cloudwatch_logs_kms_key_id        = var.kms_key_arn
  cloudwatch_logs_retention_in_days = var.lambda_log_retention_days
  create_package                    = false
  create_role                       = false
  description                       = "JIT Access: Slack handler, grant/revoke access, cleanup checker"
  environment_variables = merge(
    {
      APPROVER_CHANNEL_ID  = var.slack.approver_channel_id
      DYNAMODB_TABLE_NAME  = module.dynamodb_table_requests.dynamodb_table_id
      IDENTITY_CENTER_ARN  = local.identity_center_arn
      IDENTITY_STORE_ID    = local.identity_store_id
      LOGGER_FORMATTER     = "json"
      LOGGER_LEVEL         = "info"
      LOGGER_OUT           = "stdout"
      SLACK_BOT_TOKEN      = var.slack.bot_token
      SLACK_SIGNING_SECRET = var.slack.signing_secret
      SSM_PARAMETER_PREFIX = var.ssm_parameter_prefix
      TZ                   = var.timezone
    },
    var.slack.workflow_secret != null ? { WORKFLOW_SECRET = var.slack.workflow_secret } : {},
  )
  function_name          = "${var.name_prefix}jit-access"
  handler                = "jit_access"
  lambda_role            = aws_iam_role.lambda.arn
  local_existing_package = "${var.lambda_zip_base_path}/go_jit_access.zip"
  memory_size            = var.lambda_memory_size
  publish                = false
  runtime                = "provided.al2023"
  timeout                = var.lambda_timeout
  vpc_security_group_ids = try(var.vpc_config.security_group_ids, [])
  vpc_subnet_ids         = try(var.vpc_config.subnet_ids, [])

  tags = var.tags
}

#--------------------------------------------------------------
# API Gateway: Slack webhook endpoint (REST API for WAF support)
#--------------------------------------------------------------
resource "aws_api_gateway_rest_api" "slack" {
  region      = local.region
  name        = "${var.name_prefix}jit-access-slack"
  description = "JIT Access Slack webhook endpoint"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = var.tags
}

#--- /slack resource ---
resource "aws_api_gateway_resource" "slack" {
  region      = local.region
  parent_id   = aws_api_gateway_rest_api.slack.root_resource_id
  path_part   = "slack"
  rest_api_id = aws_api_gateway_rest_api.slack.id
}

#--- /slack/commands ---
resource "aws_api_gateway_resource" "slack_commands" {
  region      = local.region
  parent_id   = aws_api_gateway_resource.slack.id
  path_part   = "commands"
  rest_api_id = aws_api_gateway_rest_api.slack.id
}

resource "aws_api_gateway_method" "slack_commands" {
  region        = local.region
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.slack_commands.id
  rest_api_id   = aws_api_gateway_rest_api.slack.id
}

resource "aws_api_gateway_integration" "slack_commands" {
  region                  = local.region
  http_method             = aws_api_gateway_method.slack_commands.http_method
  integration_http_method = "POST"
  resource_id             = aws_api_gateway_resource.slack_commands.id
  rest_api_id             = aws_api_gateway_rest_api.slack.id
  type                    = "AWS_PROXY"
  uri                     = module.lambda_jit_access.lambda_function_invoke_arn
}

#--- /slack/interactions ---
resource "aws_api_gateway_resource" "slack_interactions" {
  region      = local.region
  parent_id   = aws_api_gateway_resource.slack.id
  path_part   = "interactions"
  rest_api_id = aws_api_gateway_rest_api.slack.id
}

resource "aws_api_gateway_method" "slack_interactions" {
  region        = local.region
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.slack_interactions.id
  rest_api_id   = aws_api_gateway_rest_api.slack.id
}

resource "aws_api_gateway_integration" "slack_interactions" {
  region                  = local.region
  http_method             = aws_api_gateway_method.slack_interactions.http_method
  integration_http_method = "POST"
  resource_id             = aws_api_gateway_resource.slack_interactions.id
  rest_api_id             = aws_api_gateway_rest_api.slack.id
  type                    = "AWS_PROXY"
  uri                     = module.lambda_jit_access.lambda_function_invoke_arn
}

#--- /workflow resource ---
resource "aws_api_gateway_resource" "workflow" {
  count = var.slack.workflow_secret != null ? 1 : 0

  region      = local.region
  parent_id   = aws_api_gateway_rest_api.slack.root_resource_id
  path_part   = "workflow"
  rest_api_id = aws_api_gateway_rest_api.slack.id
}

#--- /workflow/request ---
resource "aws_api_gateway_resource" "workflow_request" {
  count = var.slack.workflow_secret != null ? 1 : 0

  region      = local.region
  parent_id   = aws_api_gateway_resource.workflow[0].id
  path_part   = "request"
  rest_api_id = aws_api_gateway_rest_api.slack.id
}

resource "aws_api_gateway_method" "workflow_request" {
  count = var.slack.workflow_secret != null ? 1 : 0

  region        = local.region
  authorization = "NONE"
  http_method   = "POST"
  resource_id   = aws_api_gateway_resource.workflow_request[0].id
  rest_api_id   = aws_api_gateway_rest_api.slack.id
}

resource "aws_api_gateway_integration" "workflow_request" {
  count = var.slack.workflow_secret != null ? 1 : 0

  region                  = local.region
  http_method             = aws_api_gateway_method.workflow_request[0].http_method
  integration_http_method = "POST"
  resource_id             = aws_api_gateway_resource.workflow_request[0].id
  rest_api_id             = aws_api_gateway_rest_api.slack.id
  type                    = "AWS_PROXY"
  uri                     = module.lambda_jit_access.lambda_function_invoke_arn
}

#--- Deployment & Stage ---
resource "aws_api_gateway_deployment" "this" {
  region      = local.region
  rest_api_id = aws_api_gateway_rest_api.slack.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.slack.id,
      aws_api_gateway_resource.slack_commands.id,
      aws_api_gateway_resource.slack_interactions.id,
      aws_api_gateway_method.slack_commands.id,
      aws_api_gateway_method.slack_interactions.id,
      aws_api_gateway_integration.slack_commands.id,
      aws_api_gateway_integration.slack_interactions.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  region        = local.region
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.slack.id
  stage_name    = "v1"

  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gateway.arn
    format = jsonencode({
      httpMethod     = "$context.httpMethod"
      ip             = "$context.identity.sourceIp"
      protocol       = "$context.protocol"
      requestId      = "$context.requestId"
      requestTime    = "$context.requestTime"
      responseLength = "$context.responseLength"
      resourcePath   = "$context.resourcePath"
      status         = "$context.status"
    })
  }

  tags = var.tags
}

resource "aws_api_gateway_method_settings" "this" {
  region      = local.region
  method_path = "*/*"
  rest_api_id = aws_api_gateway_rest_api.slack.id
  stage_name  = aws_api_gateway_stage.this.stage_name

  settings {
    throttling_burst_limit = 50
    throttling_rate_limit  = 100
  }
}

resource "aws_cloudwatch_log_group" "api_gateway" {
  region            = local.region
  name              = "/aws/apigateway/${var.name_prefix}jit-access-slack"
  kms_key_id        = var.kms_key_arn
  retention_in_days = var.lambda_log_retention_days

  tags = var.tags
}

#--- Lambda permission ---
resource "aws_lambda_permission" "api_gateway" {
  region        = local.region
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_jit_access.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.slack.execution_arn}/*/*/*"
  statement_id  = "AllowAPIGatewayInvoke"
}

#--------------------------------------------------------------
# WAFv2: Web ACL association for API Gateway
#--------------------------------------------------------------
resource "aws_wafv2_web_acl_association" "api_gateway" {
  count = var.waf_enabled ? 1 : 0

  region       = local.region
  resource_arn = aws_api_gateway_stage.this.arn
  web_acl_arn  = var.waf_web_acl_arn
}

#--------------------------------------------------------------
# Provides an IAM role.
# Step Functions: JIT Access Workflow
# https://registry.terraform.io/modules/terraform-aws-modules/step-functions/aws/latest
#--------------------------------------------------------------
resource "aws_iam_role" "sfn" {
  name = "${var.name_prefix}jit-access-sfn"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "states.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

data "aws_iam_policy_document" "sfn" {
  statement {
    sid    = "InvokeLambda"
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
    ]
    resources = [
      module.lambda_jit_access.lambda_function_arn,
    ]
  }

  statement {
    sid    = "CloudWatchLogs"
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DeleteLogDelivery",
      "logs:DescribeLogGroups",
      "logs:GetLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutLogEvents",
      "logs:UpdateLogDelivery",
    ]
    resources = [
      "*",
    ]
  }

  statement {
    sid    = "CloudWatchLogsResourcePolicy"
    effect = "Allow"
    actions = [
      "logs:DescribeResourcePolicies",
      "logs:PutResourcePolicy",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role_policy" "sfn" {
  name   = "${var.name_prefix}jit-access-sfn"
  role   = aws_iam_role.sfn.id
  policy = data.aws_iam_policy_document.sfn.json
}

module "step_functions" {
  source  = "terraform-aws-modules/step-functions/aws"
  version = "5.1.0"

  region = local.region

  cloudwatch_log_group_kms_key_id        = var.kms_key_arn
  cloudwatch_log_group_name              = "/aws/sfn/${var.name_prefix}jit-access-sfn"
  cloudwatch_log_group_retention_in_days = var.lambda_log_retention_days
  create                                 = true
  create_role                            = false
  definition = jsonencode({
    Comment = "JIT Access: Wait -> Grant -> Wait(duration) -> Revoke"
    StartAt = "WaitUntilStart"
    States = {
      WaitUntilStart = {
        Type          = "Wait"
        TimestampPath = "$.start_at"
        Next          = "GrantAccess"
      }
      GrantAccess = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = module.lambda_jit_access.lambda_function_arn
          Payload = {
            "action"       = "grant"
            "request_id.$" = "$.request_id"
          }
        }
        ResultPath = "$.grant_result"
        Next       = "WaitDuration"
        Retry = [{
          ErrorEquals     = ["States.ALL"]
          IntervalSeconds = 30
          MaxAttempts     = 3
          BackoffRate     = 2
        }]
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "GrantFailed"
          ResultPath  = "$.error"
        }]
      }
      WaitDuration = {
        Type          = "Wait"
        TimestampPath = "$.end_at"
        Next          = "RevokeAccess"
      }
      RevokeAccess = {
        Type     = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = module.lambda_jit_access.lambda_function_arn
          Payload = {
            "action"       = "revoke"
            "request_id.$" = "$.request_id"
          }
        }
        ResultPath = "$.revoke_result"
        End        = true
        Retry = [{
          ErrorEquals     = ["States.ALL"]
          IntervalSeconds = 30
          MaxAttempts     = 3
          BackoffRate     = 2
        }]
        Catch = [{
          ErrorEquals = ["States.ALL"]
          Next        = "RevokeFailed"
          ResultPath  = "$.error"
        }]
      }
      GrantFailed = {
        Type  = "Fail"
        Error = "GrantAccessFailed"
        Cause = "Failed to grant access after retries"
      }
      RevokeFailed = {
        Type  = "Fail"
        Error = "RevokeAccessFailed"
        Cause = "Failed to revoke access after retries"
      }
    }
  })
  logging_configuration = {
    include_execution_data = true
    level                  = "ERROR"
  }
  name                              = "${var.name_prefix}jit-access-sfn"
  publish                           = true
  role_arn                          = aws_iam_role.sfn.arn
  service_integrations              = {}
  sfn_state_machine_timeouts        = {}
  trusted_entities                  = []
  type                              = "STANDARD"
  use_existing_cloudwatch_log_group = false
  use_existing_role                 = true

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an IAM role.
# EventBridge Scheduler: Cleanup checker
#--------------------------------------------------------------
resource "aws_iam_role" "scheduler" {
  name = "${var.name_prefix}jit-access-scheduler"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "scheduler.amazonaws.com"
      }
    }]
  })

  tags = var.tags
}

resource "aws_iam_role_policy" "scheduler" {
  name = "${var.name_prefix}jit-access-scheduler"
  role = aws_iam_role.scheduler.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "lambda:InvokeFunction"
      Resource = module.lambda_jit_access.lambda_function_arn
    }]
  })
}

resource "aws_scheduler_schedule" "cleanup" {
  region     = local.region
  name       = "${var.name_prefix}jit-access-cleanup"
  group_name = "default"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.cleanup_schedule_expression

  target {
    arn      = module.lambda_jit_access.lambda_function_arn
    role_arn = aws_iam_role.scheduler.arn
    input    = jsonencode({ action = "cleanup" })
  }
}

#--------------------------------------------------------------
# SQS Dead Letter Queue: revoke failures
#--------------------------------------------------------------
resource "aws_sqs_queue" "dlq" {
  region                     = local.region
  name                       = "${var.name_prefix}jit-access-dlq"
  message_retention_seconds  = 1209600
  visibility_timeout_seconds = 300
  kms_master_key_id          = var.kms_key_arn

  tags = var.tags
}

#--------------------------------------------------------------
# CloudWatch Alarm: DLQ messages (revoke failure alert)
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "dlq_messages" {
  region              = local.region
  alarm_name          = "${var.name_prefix}jit-access-dlq-messages"
  alarm_description   = "JIT Access: Messages in DLQ indicate revoke failures requiring manual intervention"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = 300
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data  = "notBreaching"

  dimensions = {
    QueueName = aws_sqs_queue.dlq.name
  }

  tags = var.tags
}
