output "agents_md_asset_ids" {
  description = "Map of agent type to AGENTS.md asset ID."
  value       = { for k, v in awscc_devopsagent_asset.agents_md : k => v.asset_id }
}
output "agent_space_arn" {
  description = "ARN of the Agent Space."
  value       = try(awscc_devopsagent_agent_space.this[0].arn, null)
}
output "agent_space_id" {
  description = "ID of the Agent Space."
  value       = try(awscc_devopsagent_agent_space.this[0].agent_space_id, null)
}
output "agent_space_role_arn" {
  description = "ARN of the IAM role assumed by the Agent Space."
  value       = try(aws_iam_role.agent_space[0].arn, null)
}
output "custom_agent_asset_ids" {
  description = "Map of custom agent key to asset ID."
  value       = { for k, v in awscc_devopsagent_asset.custom_agent : k => v.asset_id }
}
output "github_association_ids" {
  description = "Map of GitHub repository key to association ID."
  value       = { for k, v in awscc_devopsagent_association.github : k => v.association_id }
}
output "mcp_server_association_ids" {
  description = "Map of MCP server key to association ID."
  value       = { for k, v in awscc_devopsagent_association.mcp_server : k => v.association_id }
}
output "monitor_association_id" {
  description = "Association ID of the monitor account."
  value       = try(awscc_devopsagent_association.aws_monitor[0].association_id, null)
}
output "operator_app_role_arn" {
  description = "ARN of the IAM role for the operator web app."
  value       = try(aws_iam_role.operator_app[0].arn, null)
}
output "secondary_association_ids" {
  description = "Map of secondary account key to association ID."
  value       = { for k, v in awscc_devopsagent_association.aws_source : k => v.association_id }
}
output "skill_asset_ids" {
  description = "Map of skill key to asset ID."
  value       = { for k, v in awscc_devopsagent_asset.skill : k => v.asset_id }
}
output "trigger_ids" {
  description = "Map of <custom agent key>.<trigger key> to trigger ID."
  value       = { for k, v in awscc_devopsagent_trigger.this : k => v.trigger_id }
}
output "webhook_association_id" {
  description = "Association ID of the generic webhook (event channel)."
  value       = try(data.external.webhook[0].result.association_id, null)
}
output "webhook_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the webhook credentials (JSON: webhook_id, webhook_secret, webhook_type, webhook_url). The secret value itself is never output."
  value       = try(aws_secretsmanager_secret.webhook[0].arn, null)
}
output "webhook_service_id" {
  description = "Service ID of the event channel (webhook) registration."
  value       = try(data.external.event_channel_service[0].result.service_id, null)
}
output "webhook_type" {
  description = "Authentication type of the generic webhook (hmac or apikey)."
  value       = try(data.external.webhook[0].result.webhook_type, null)
}
output "webhook_url" {
  description = "URL of the generic webhook. The secret is stored in the Secrets Manager secret (webhook_secret_arn)."
  value       = try(data.external.webhook[0].result.webhook_url, null)
}
