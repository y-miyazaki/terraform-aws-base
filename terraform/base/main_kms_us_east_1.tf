#--------------------------------------------------------------
# KMS Customer Master Key using terraform-aws-modules/kms/aws
#--------------------------------------------------------------
module "kms_key_us_east_1" {
  for_each = var.kms

  source  = "terraform-aws-modules/kms/aws"
  version = "4.2.0"
  create  = local.is_enabled_us_east_1 && each.value.is_enabled
  providers = {
    aws = aws.us-east-1
  }

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
          "logs.us-east-1.amazonaws.com",
          "ses.amazonaws.com",
          "sns.us-east-1.amazonaws.com",
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
      resources = ["arn:aws:kms:us-east-1:${data.aws_caller_identity.current.account_id}:key/*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "aws:SourceAccount"
          values   = [data.aws_caller_identity.current.account_id]
        }
      ]
    },
    {
      sid = "AllowCloudTrailEncryptDecrypt"
      principals = [{
        type = "Service"
        identifiers = [
          "cloudtrail.amazonaws.com"
        ]
      }]
      actions = [
        "kms:Decrypt",
        "kms:GenerateDataKey*",
      ]
      resources = ["*"]
      conditions = [
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
          values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
        }
      ]
    },
    {
      sid = "AllowCloudTrailDescribeKey"
      principals = [{
        type        = "Service"
        identifiers = ["cloudtrail.amazonaws.com"]
      }]
      actions = [
        "kms:DescribeKey"
      ]
      resources = ["*"]
    },
    # https://docs.aws.amazon.com/ja_jp/awscloudtrail/latest/userguide/create-kms-key-policy-for-cloudtrail.html#create-kms-key-policy-for-cloudtrail-encrypt
    {
      sid = "AllowUserDecryptLogs"
      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]
      actions = [
        "kms:Decrypt",
        "kms:ReEncryptFrom"
      ]
      resources = ["arn:aws:kms:us-east-1:${data.aws_caller_identity.current.account_id}:key/*"]

      conditions = [
        {
          test     = "StringEquals"
          variable = "kms:CallerAccount"
          values   = [data.aws_caller_identity.current.account_id]
        },
        {
          test     = "StringLike"
          variable = "kms:EncryptionContext:aws:cloudtrail:arn"
          values   = ["arn:aws:cloudtrail:*:${data.aws_caller_identity.current.account_id}:trail/*"]
        }
      ]
    },
  ]
  aliases = ["${var.name_prefix}${each.key}"]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}${each.key}"
  })
}
