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

resource "awscc_iam_role" "this" {
  role_name = var.role_name

  assume_role_policy_document = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      },
    ]
  })
  # このロールにアタッチする管理ポリシーのARN
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess",
  ]
  tags = local.tags
}
