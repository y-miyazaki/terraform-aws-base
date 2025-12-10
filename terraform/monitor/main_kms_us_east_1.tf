#--------------------------------------------------------------
# KMS Customer Master Key using terraform-aws-modules/kms/aws
#--------------------------------------------------------------
module "kms_key_us_east_1" {
  for_each = var.kms

  source  = "terraform-aws-modules/kms/aws"
  version = "4.1.1"
  create  = !local.is_default_region_us_east_1 && each.value.is_enabled
  providers = {
    aws = aws.us-east-1
  }

  description             = try(each.value.dynamodb.description, null)
  deletion_window_in_days = try(each.value.dynamodb.deletion_window_in_days, 7)
  enable_key_rotation     = true
  enable_default_policy   = true
  #   key_owners              = var.key_owners
  #   key_administrators      = var.key_administrators
  key_statements = [
    {
      sid = "AllowCreateAlias"
      principals = [{
        type        = "AWS"
        identifiers = ["*"]
      }]
      actions   = ["kms:CreateAlias"]
      resources = ["*"]
      conditions = [
        {
          test     = "StringEquals"
          variable = "kms:CallerAccount"
          values   = [data.aws_caller_identity.current.account_id]
        }
      ]
    },
    {
      sid = "AllowServices"
      principals = [{
        type = "Service"
        identifiers = [
          "cloudwatch.amazonaws.com",
          "dynamodb.amazonaws.com",
          "logs.us-east-1.amazonaws.com",
          "ses.amazonaws.com",
          "sns.us-east-1.amazonaws.com",
        ]
      }]
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:GenerateDataKey*",
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
  ]
  aliases = ["${var.name_prefix}${each.key}"]

  tags = merge(var.tags, {
    Name = "${var.name_prefix}${each.key}"
  })
}
