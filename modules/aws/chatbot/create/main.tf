resource "awscc_chatbot_slack_channel_configuration" "this" {
  configuration_name = "${var.name_prefix}${var.name}-chatbot-config"
  iam_role_arn       = awscc_iam_role.this.arn
  slack_channel_id   = var.slack_channel_id
  slack_workspace_id = var.slack_workspace_id
  sns_topic_arns     = var.sns_topic_arns
  logging_level      = var.logging_level
}

resource "awscc_iam_role" "this" {
  role_name = "${var.name_prefix}${var.name}-chatbot-role"

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
}
