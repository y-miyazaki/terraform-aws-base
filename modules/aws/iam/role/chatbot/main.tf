#--------------------------------------------------------------
# Module: aws/iam/role/chatbot
# Purpose: Create IAM role for AWS Chatbot (Slack) with optional SecurityHub update permissions.
# Notes: Unified tagging applied; future improvement: parameterize additional managed policies.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
      }
    ]
  })

  description           = "IAM role for AWS Q(Chatbot)"
  force_detach_policies = true
  name                  = "${var.name}-chatbot-role"

  tags = var.tags
}
data "aws_iam_policy_document" "securityhub" {
  statement {
    sid    = "AllowSecurityHubBatchUpdateFindings"
    effect = "Allow"
    actions = [
      "securityhub:BatchUpdateFindings",
    ]
    resources = ["*"]
  }
}
resource "aws_iam_policy" "securityhub" {
  name        = "${var.name}-chatbot-securityhub-policy"
  description = "securityhub policy for AWS Q(Chatbot)."
  policy      = data.aws_iam_policy_document.securityhub.json
}

resource "aws_iam_role_policy_attachment" "aws_resource_explorer_read_only_access" {
  role       = aws_iam_role.this.name
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"
}
resource "aws_iam_role_policy_attachment" "securityhub" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.securityhub.arn
}
