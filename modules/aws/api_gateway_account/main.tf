#--------------------------------------------------------------
# Module: aws/api_gateway_account
# Purpose: Account-level API Gateway settings (singleton per AWS account).
#          Configures CloudWatch Logs role for REST API access logging.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  name = "${var.name_prefix}api-gateway-cloudwatch"
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

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "this" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
  role       = aws_iam_role.this.name
}

resource "aws_api_gateway_account" "this" {
  cloudwatch_role_arn = aws_iam_role.this.arn

  depends_on = [aws_iam_role_policy_attachment.this]
}
