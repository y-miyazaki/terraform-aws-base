#--------------------------------------------------------------
# Module: aws/iam/role/chatbot
# Purpose: Create IAM role for AWS Chatbot (Slack) with optional SecurityHub update permissions.
# Notes: Unified tagging applied; future improvement: parameterize additional managed policies.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an IAM role.
#--------------------------------------------------------------
resource "aws_iam_role" "this" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "chatbot.amazonaws.com"
        }
        Action = "sts:AssumeRole"
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
  description = "securityhub policy for AWS Q(Chatbot)."
  name        = "${var.name}-chatbot-securityhub-policy"
  policy      = data.aws_iam_policy_document.securityhub.json
}

resource "aws_iam_role_policy_attachment" "aws_resource_explorer_read_only_access" {
  policy_arn = "arn:aws:iam::aws:policy/AWSResourceExplorerReadOnlyAccess"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "securityhub" {
  policy_arn = aws_iam_policy.securityhub.arn
  role       = aws_iam_role.this.name
}
