#--------------------------------------------------------------
# Module: aws/api_gateway_account
# Purpose: Account-level API Gateway settings (singleton per AWS account).
#          Configures CloudWatch Logs role for REST API access logging.
#--------------------------------------------------------------
data "aws_region" "current" {}

#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  region = coalesce(var.region, data.aws_region.current.region)
}

#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "apigateway.amazonaws.com"
      }
    }]
  })
  name = "${var.name_prefix}api-gateway-cloudwatch"

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  role       = aws_iam_role.this.name
}

#--------------------------------------------------------------
# Provides an IAM role policy for KMS access.
# Required when the CloudWatch Logs log groups used by API Gateway access logging are encrypted with a customer managed key.
#--------------------------------------------------------------
data "aws_iam_policy_document" "kms" {
  count = var.kms_key_arn != null ? 1 : 0

  statement {
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey",
    ]
    effect    = "Allow"
    resources = [var.kms_key_arn]
    sid       = "KMS"
  }
}

resource "aws_iam_role_policy" "kms" {
  count = var.kms_key_arn != null ? 1 : 0

  name   = "${var.name_prefix}api-gateway-cloudwatch-kms"
  policy = data.aws_iam_policy_document.kms[0].json
  role   = aws_iam_role.this.id
}

resource "aws_api_gateway_account" "this" {
  region              = local.region
  cloudwatch_role_arn = aws_iam_role.this.arn

  depends_on = [
    aws_iam_role_policy.kms,
    aws_iam_role_policy_attachment.this,
  ]
}
