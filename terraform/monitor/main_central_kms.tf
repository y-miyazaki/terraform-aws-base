#--------------------------------------------------------------
# KMS Customer Master Key using terraform-aws-modules/kms/aws
# Deployed to each monitor region (primary + global when enabled).
#--------------------------------------------------------------
module "kms_key" {
  for_each = local.monitor_regions

  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.2"

  create = var.kms["monitor"].is_enabled
  region = each.value

  aliases                 = ["${var.name_prefix}monitor"]
  deletion_window_in_days = var.kms["monitor"].deletion_window_in_days
  description             = var.kms["monitor"].description
  enable_default_policy   = true
  enable_key_rotation     = true
  key_statements = [
    {
      sid = "AllowServices"
      principals = [{
        type = "Service"
        identifiers = [
          "aiops.amazonaws.com",
          "cloudwatch.amazonaws.com",
          "dynamodb.amazonaws.com",
          "events.amazonaws.com",
          "logs.${each.value}.amazonaws.com",
          "ses.amazonaws.com",
          "sns.amazonaws.com",
        ]
      }]
      actions = [
        "kms:Decrypt",
        "kms:DescribeKey",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:GetKeyPolicy",
        "kms:ReEncrypt*",
      ]
      resources = ["arn:aws:kms:${each.value}:${data.aws_caller_identity.current.account_id}:key/*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values   = [data.aws_caller_identity.current.account_id]
        }
      ]
    },
  ]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}monitor"
  })
}

#--------------------------------------------------------------
# KMS Customer Master Key for AWS DevOps Agent Space (encryption at rest)
# Dedicated key so that its lifecycle (rotation/deletion) does not affect other monitor resources.
# https://docs.aws.amazon.com/devopsagent/latest/userguide/aws-devops-agent-security-encryption-at-rest-for-devops-agent.html
# Caller access (synchronous operations) is delegated to IAM policies via the default key policy.
#--------------------------------------------------------------
module "kms_key_devops_agent" {
  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.2"

  create = local.devops_agent_is_primary && var.kms["monitor_devops_agent"].is_enabled
  region = var.region.primary

  aliases                 = ["${var.name_prefix}monitor-devops-agent"]
  deletion_window_in_days = var.kms["monitor_devops_agent"].deletion_window_in_days
  description             = var.kms["monitor_devops_agent"].description
  enable_default_policy   = true
  enable_key_rotation     = true
  key_statements = [
    {
      sid = "AllowDevOpsAgentServiceDescribeKeyAccess"
      principals = [{
        type        = "Service"
        identifiers = ["aidevops.amazonaws.com"]
      }]
      actions   = ["kms:DescribeKey"]
      resources = ["*"]
    },
    {
      sid = "AllowDevOpsAgentAccessForAgentSpace"
      principals = [{
        type        = "Service"
        identifiers = ["aidevops.amazonaws.com"]
      }]
      actions = [
        "kms:Decrypt",
        "kms:Encrypt",
        "kms:GenerateDataKey*",
        "kms:ReEncrypt*",
      ]
      resources = ["*"]
      conditions = [
        {
          test     = "ArnLike"
          variable = "aws:SourceArn"
          values   = ["arn:aws:aidevops:${var.region.primary}:${data.aws_caller_identity.current.account_id}:agentspace/*"]
        },
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws-crypto-ec:aws:aidevops:arn"
          values   = ["arn:aws:aidevops:${var.region.primary}:${data.aws_caller_identity.current.account_id}:agentspace/*"]
        },
      ]
    },
  ]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}monitor-devops-agent"
  })
}
