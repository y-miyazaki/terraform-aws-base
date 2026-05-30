#--------------------------------------------------------------
# Module: aws/jit_access
# Purpose: JIT (Just-In-Time) privileged access system with Slack integration.
#          Manages temporary IAM Identity Center Permission Set assignments
#          with approval workflow, time-bound access, and automatic revocation.
# Notes: Lambda zip files are built in a separate repository and placed in
#        lambda/outputs/. This module references them via local_existing_package.
#--------------------------------------------------------------

#--------------------------------------------------------------
# Data: IAM Identity Center instance (one per account)
#--------------------------------------------------------------
data "aws_ssoadmin_instances" "this" {}

locals {
  identity_center_arn = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id   = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
}

#--------------------------------------------------------------
# DynamoDB Table: jit-access-requests
# https://registry.terraform.io/modules/terraform-aws-modules/dynamodb-table/aws/latest
#--------------------------------------------------------------
module "dynamodb_table_requests" {
  source  = "terraform-aws-modules/dynamodb-table/aws"
  version = "5.5.0"

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
  name  = "${var.ssm_parameter_prefix}/config/approver-channel"
  type  = "String"
  value = var.slack.approver_channel_id

  tags = var.tags
}

resource "aws_ssm_parameter" "state_machine_arn" {
  name  = "${var.ssm_parameter_prefix}/config/state-machine-arn"
  type  = "String"
  value = module.step_functions.state_machine_arn

  tags = var.tags
}

resource "aws_ssm_parameter" "profiles" {
  for_each = var.profiles

  name = "${var.ssm_parameter_prefix}/config/profiles/${each.key}"
  type = "String"
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

  name  = "${var.ssm_parameter_prefix}/user-mapping/${each.key}"
  type  = "String"
  value = each.value

  tags = var.tags
}

#--------------------------------------------------------------
# IAM Role: Lambda execution role
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
          "identitystore:ListUsers",
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
# API Gateway: Slack webhook endpoint
#--------------------------------------------------------------
resource "aws_apigatewayv2_api" "slack" {
  name          = "${var.name_prefix}jit-access-slack"
  protocol_type = "HTTP"
  description   = "JIT Access Slack webhook endpoint"

  tags = var.tags
}

resource "aws_apigatewayv2_stage" "default" {
  api_id      = aws_apigatewayv2_api.slack.id
  name        = "$default"
  auto_deploy = true

  tags = var.tags
}

resource "aws_apigatewayv2_integration" "slack_handler" {
  api_id                 = aws_apigatewayv2_api.slack.id
  integration_type       = "AWS_PROXY"
  integration_uri        = module.lambda_jit_access.lambda_function_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "slack_commands" {
  api_id    = aws_apigatewayv2_api.slack.id
  route_key = "POST /slack/commands"
  target    = "integrations/${aws_apigatewayv2_integration.slack_handler.id}"
}

resource "aws_apigatewayv2_route" "slack_interactions" {
  api_id    = aws_apigatewayv2_api.slack.id
  route_key = "POST /slack/interactions"
  target    = "integrations/${aws_apigatewayv2_integration.slack_handler.id}"
}

resource "aws_apigatewayv2_route" "workflow_request" {
  count = var.slack.workflow_secret != null ? 1 : 0

  api_id    = aws_apigatewayv2_api.slack.id
  route_key = "POST /workflow/request"
  target    = "integrations/${aws_apigatewayv2_integration.slack_handler.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_jit_access.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.slack.execution_arn}/*/*"
}

#--------------------------------------------------------------
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

resource "aws_iam_role_policy" "sfn" {
  name = "${var.name_prefix}jit-access-sfn"
  role = aws_iam_role.sfn.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "InvokeLambda"
        Effect   = "Allow"
        Action   = "lambda:InvokeFunction"
        Resource = module.lambda_jit_access.lambda_function_arn
      },
      {
        Sid    = "CloudWatchLogs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogDelivery",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DeleteLogDelivery",
          "logs:DescribeLogGroups",
          "logs:DescribeResourcePolicies",
          "logs:GetLogDelivery",
          "logs:ListLogDeliveries",
          "logs:PutLogEvents",
          "logs:PutResourcePolicy",
          "logs:UpdateLogDelivery",
        ]
        Resource = "*"
      },
    ]
  })
}

module "step_functions" {
  source  = "terraform-aws-modules/step-functions/aws"
  version = "5.1.0"

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
