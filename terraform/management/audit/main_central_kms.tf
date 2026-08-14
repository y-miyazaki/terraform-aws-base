#--------------------------------------------------------------
# KMS Customer Master Key using terraform-aws-modules/kms/aws
#--------------------------------------------------------------
module "kms_key" {
  for_each = var.kms

  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.1"

  create = each.value.is_enabled
  region = var.region.primary

  deletion_window_in_days = each.value.deletion_window_in_days
  description             = each.value.description
  enable_default_policy   = true
  enable_key_rotation     = true
  #   key_owners              = var.key_owners
  #   key_administrators      = var.key_administrators
  key_statements = [
    {
      sid = "AllowServices"
      principals = [{
        type = "Service"
        identifiers = [
          "aiops.amazonaws.com",
          "cloudwatch.amazonaws.com",
          "events.amazonaws.com",
          "logs.${var.region.primary}.amazonaws.com",
          "ses.amazonaws.com",
          "sns.amazonaws.com",
        ]
      }]
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
        "kms:GetKeyPolicy",
        "kms:ReEncrypt*",
        "kms:DescribeKey",
      ]
      resources = ["arn:aws:kms:${var.region.primary}:${data.aws_caller_identity.current.account_id}:key/*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values   = [data.aws_caller_identity.current.account_id]
        }
      ]
    },
  ]
  aliases = ["${var.name_prefix}${each.key}"]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}${each.key}"
  })
}
