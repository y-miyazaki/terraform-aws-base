#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# IAM Role for EventBridge(Step Functions)
#--------------------------------------------------------------
data "aws_iam_policy_document" "eventbridge_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "eventbridge" {
  count              = var.is_enabled ? 1 : 0
  name               = "${var.name_prefix}security-securityhub-events-role"
  assume_role_policy = data.aws_iam_policy_document.eventbridge_assume_role.json
  tags = {
    Name = "${var.name_prefix}security-securityhub-events-role"
  }
}

resource "aws_iam_role_policy_attachment" "eventbridge" {
  count      = var.is_enabled ? 1 : 0
  role       = aws_iam_role.eventbridge[0].name
  policy_arn = aws_iam_policy.eventbridge[0].arn
}

resource "aws_iam_policy" "eventbridge" {
  count  = var.is_enabled ? 1 : 0
  name   = "${var.name_prefix}security-securityhub-events-policy"
  policy = data.aws_iam_policy_document.eventbridge.json
  tags = {
    Name = "${var.name_prefix}security-securityhub-events-policy"
  }
}

data "aws_iam_policy_document" "eventbridge" {
  statement {
    actions = [
      "states:StartExecution",
    ]
    resources = [
      module.step_functions[0].state_machine_arn,
    ]
  }
}

#--------------------------------------------------------------
# IAM Role for Step Functions
#--------------------------------------------------------------
data "aws_iam_policy_document" "step_functions_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["states.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "step_functions" {
  count              = var.is_enabled ? 1 : 0
  name               = "${var.name_prefix}security-securityhub-step-functions-role"
  assume_role_policy = data.aws_iam_policy_document.step_functions_assume_role.json
  tags = {
    Name = "${var.name_prefix}security-securityhub-step-functions-role"
  }
}

data "aws_iam_policy_document" "step_functions" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogDelivery",
      "logs:GetLogDelivery",
      "logs:UpdateLogDelivery",
      "logs:DeleteLogDelivery",
      "logs:ListLogDeliveries",
      "logs:PutResourcePolicy",
      "logs:DescribeResourcePolicies",
      "logs:DescribeLogGroups",
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      "*",
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "securityhub:BatchUpdateFindings",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "step_functions" {
  count  = var.is_enabled ? 1 : 0
  name   = "${var.name_prefix}security-securityhub-step-functions-policy"
  policy = data.aws_iam_policy_document.step_functions.json
  tags = {
    Name = "${var.name_prefix}security-securityhub-step-functions-policy"
  }
}
resource "aws_iam_role_policy_attachment" "step_functions" {
  count      = var.is_enabled ? 1 : 0
  role       = aws_iam_role.step_functions[0].name
  policy_arn = aws_iam_policy.step_functions[0].arn
}

#--------------------------------------------------------------
# CloudWatch event rule
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "securityhub" {
  count         = var.is_enabled ? 1 : 0
  name          = "${var.name_prefix}security-securityhub-rule"
  event_pattern = <<EOF
{
  "source": [
    "aws.securityhub"
  ],
  "detail-type": [
    "Security Hub Findings - Imported"
  ],
  "detail": {
    "findings":
      {
        "Compliance": {
          "Status": [
            {
              "anything-but": "PASSED"
            }
          ]
        },
        "Severity": {
           "Label": [
             "CRITICAL",
             "HIGH"
           ]
        },
        "Workflow": {
          "Status": [
            "NEW"
          ]
        },
        "RecordState": [
          "ACTIVE"
        ]
      }
  }
}
EOF
  description   = "This cloudwatch event used for SecurityHub."
  state         = "ENABLED"
  tags          = local.tags
}

data "aws_iam_policy_document" "sns_topic" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    actions = [
      "sns:Publish",
    ]
    resources = [
      aws_sns_topic.this[0].arn,
    ]
  }
}

resource "aws_sns_topic" "this" {
  count             = var.is_enabled ? 1 : 0
  name              = "${var.name_prefix}security-securityhub-chatbot-slack-topic"
  kms_master_key_id = var.kms_master_key_id
  tags              = var.tags
}

resource "aws_sns_topic_policy" "this" {
  count  = var.is_enabled ? 1 : 0
  arn    = aws_sns_topic.this[0].arn
  policy = data.aws_iam_policy_document.sns_topic.json
}

#--------------------------------------------------------------
# aws_cloudwatch_event_target
# - sns
# - step functions
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "sns_publish" {
  count     = var.is_enabled ? 1 : 0
  rule      = aws_cloudwatch_event_rule.securityhub[0].name
  target_id = aws_sns_topic.this[0].name
  arn       = aws_sns_topic.this[0].arn
}

resource "aws_cloudwatch_event_target" "step_functions" {
  count    = var.is_enabled ? 1 : 0
  rule     = aws_cloudwatch_event_rule.securityhub[0].name
  arn      = module.step_functions[0].state_machine_arn
  role_arn = aws_iam_role.eventbridge[0].arn
}

#--------------------------------------------------------------
# Step Functions for MA
# Terraform module which creates Step Functions on AWS
#--------------------------------------------------------------
module "step_functions" {
  source                                 = "terraform-aws-modules/step-functions/aws"
  count                                  = var.is_enabled ? 1 : 0
  version                                = "4.2.0"
  cloudwatch_log_group_kms_key_id        = var.cloudwatch_log_group_kms_key_id
  cloudwatch_log_group_name              = "/aws/sfn/${var.name_prefix}securityhub-update-findings-sfn"
  cloudwatch_log_group_retention_in_days = var.cloudwatch_log_group_retention_in_days
  create                                 = true
  create_role                            = false
  definition                             = <<EOF
{
  "Comment": "A description of my state machine",
  "StartAt": "BatchUpdateFindings",
  "States": {
    "BatchUpdateFindings": {
      "Type": "Task",
      "Parameters": {
        "FindingIdentifiers": [
          {
            "Id.$": "$.detail.findings[0].Id",
            "ProductArn.$": "$.detail.findings[0].ProductArn"
          }
        ],
        "Workflow": {
          "Status": "NOTIFIED"
        }
      },
      "Resource": "arn:aws:states:::aws-sdk:securityhub:batchUpdateFindings",
      "End": true,
      "Comment": "Update Findings \"New\" to \"NOTIFIED\"."
    }
  }
}
EOF
  logging_configuration = {
    include_execution_data = true
    level                  = "ERROR"
  }
  name                              = "${var.name_prefix}security-securityhub-update-findings-sfn"
  publish                           = true
  role_arn                          = aws_iam_role.step_functions[0].arn
  service_integrations              = {}
  sfn_state_machine_timeouts        = {}
  trusted_entities                  = []
  type                              = "STANDARD"
  use_existing_cloudwatch_log_group = false
  use_existing_role                 = true
}
