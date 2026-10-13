#--------------------------------------------------------------
# Create Lambda function
# For DevOps Agent MCP Slack Reply
# https://registry.terraform.io/modules/terraform-aws-modules/lambda/aws/latest
#--------------------------------------------------------------
locals {
  # Channels the alert Lambda functions post to
  devops_agent_mcp_slack_reply_channel_ids = distinct(compact(concat(
    [var.slack.channel_id],
    [for k, v in try(var.slack.override, {}) : try(v.channel_id, null)]
  )))
  devops_agent_mcp_slack_reply_enabled = local.devops_agent_is_primary && var.devops_agent.primary.mcp_slack_reply.is_enabled
  devops_agent_mcp_slack_reply_name    = "${var.name_prefix}devops-agent-mcp-slack-reply"
}

module "aws_lambda_devops_agent_mcp_slack_reply" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "8.9.0"

  create = local.devops_agent_mcp_slack_reply_enabled

  region = var.region.primary

  architectures                           = ["arm64"]
  authorization_type                      = "AWS_IAM"
  cloudwatch_logs_kms_key_id              = module.kms_key["primary"].key_arn
  cloudwatch_logs_retention_in_days       = var.cloudwatch_log_group.retention_in_days
  create_current_version_allowed_triggers = false
  create_lambda_function_url              = true
  create_package                          = false
  description                             = "MCP server that lets AWS DevOps Agent reply to Slack alert threads."
  environment_variables = {
    LOGGER_FORMATTER          = "json"
    LOGGER_LEVEL              = "info"
    LOGGER_OUT                = "stdout"
    SLACK_ALLOWED_CHANNEL_IDS = join(",", local.devops_agent_mcp_slack_reply_channel_ids)
    SLACK_OAUTH_ACCESS_TOKEN  = var.slack.oauth_access_token
  }
  function_name                 = local.devops_agent_mcp_slack_reply_name
  handler                       = "bootstrap"
  local_existing_package        = "../../lambda/outputs/go_mcp_slack_reply.zip"
  logging_application_log_level = "INFO"
  logging_log_format            = "JSON"
  logging_system_log_level      = "WARN"
  memory_size                   = var.devops_agent.primary.mcp_slack_reply.memory_size
  publish                       = false
  runtime                       = "provided.al2023"
  timeout                       = var.devops_agent.primary.mcp_slack_reply.timeout
  tracing_mode                  = "PassThrough"

  tags = var.tags
}

output "devops_agent_mcp_slack_reply_function_url" {
  description = "Function URL (IAM authentication) of the Slack reply MCP server; the MCP endpoint."
  value       = try(module.aws_lambda_devops_agent_mcp_slack_reply.lambda_function_url, null)
}

#--------------------------------------------------------------
# Wait for IAM propagation (the service validates the connection with the role on registration)
#--------------------------------------------------------------
resource "time_sleep" "devops_agent_mcp_slack_reply_iam_propagation" {
  count = local.devops_agent_mcp_slack_reply_enabled ? 1 : 0

  create_duration = "30s"

  depends_on = [aws_iam_role_policy.devops_agent_mcp_slack_reply_invoke]
}

#--------------------------------------------------------------
# Register MCP server (SigV4) to DevOps Agent
# https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-devopsagent-service.html
#--------------------------------------------------------------
resource "awscc_devopsagent_service" "devops_agent_mcp_slack_reply" {
  count = local.devops_agent_mcp_slack_reply_enabled ? 1 : 0

  service_details = {
    mcp_server_sig_v4 = {
      authorization_config = {
        mcp_role_arn = aws_iam_role.devops_agent_mcp_slack_reply[0].arn
        region       = var.region.primary
        service      = "lambda"
      }
      description = "Reply to Slack alert threads"
      endpoint    = module.aws_lambda_devops_agent_mcp_slack_reply.lambda_function_url
      name        = "McpSlackReply"
    }
  }
  service_type = "mcpserversigv4"
  tags         = [for k, v in var.tags : { key = k, value = tostring(v) }]

  depends_on = [time_sleep.devops_agent_mcp_slack_reply_iam_propagation]
}

output "devops_agent_mcp_slack_reply_service_id" {
  description = "Service ID of the Slack reply MCP server registered in AWS DevOps Agent."
  value       = try(awscc_devopsagent_service.devops_agent_mcp_slack_reply[0].service_id, null)
}
