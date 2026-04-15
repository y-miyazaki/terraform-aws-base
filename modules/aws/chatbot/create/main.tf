#--------------------------------------------------------------
# Module: aws/chatbot/create
# Purpose: Configure AWS Chatbot (Slack) channel with IAM role and optional SecurityHub interaction permission.
# Notes: Unified tagging applied to IAM role; future improvement: parameterize additional managed policies and logging level.
#--------------------------------------------------------------
resource "aws_chatbot_slack_channel_configuration" "this" {
  configuration_name = "${var.name}-chatbot-config"
  iam_role_arn       = aws_iam_role.this.arn
  slack_channel_id   = var.slack_channel_id
  slack_team_id      = var.slack_team_id
  sns_topic_arns     = var.sns_topic_arns
  logging_level      = var.logging_level
}

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
