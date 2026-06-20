#--------------------------------------------------------------
# KMS Customer Master Key using terraform-aws-modules/kms/aws
# Deployed to each monitor region (primary + global when enabled).
#--------------------------------------------------------------
module "kms_key" {
  for_each = local.monitor_regions

  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.0"

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
