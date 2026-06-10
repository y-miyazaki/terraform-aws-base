#--------------------------------------------------------------
# JIT Access
# Temporary privileged access system with Slack integration.
# Manages time-bound IAM Identity Center Permission Set assignments
# with approval workflow and automatic revocation.
#--------------------------------------------------------------
module "jit_access" {
  count  = var.jit_access.is_enabled ? 1 : 0
  source = "../../../modules/aws/jit_access"

  cleanup_schedule_expression = var.jit_access.cleanup_schedule_expression
  name_prefix                 = var.name_prefix
  kms_key_arn                 = module.kms_key["root"].key_arn
  lambda_log_retention_days   = coalesce(try(var.cloudwatch_log_group.override.jit_access.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  lambda_zip_base_path        = "../../../lambda/outputs"
  profiles                    = var.jit_access.profiles
  slack = {
    approver_channel_id = var.jit_access.slack.approver_channel_id
    bot_token           = var.jit_access.slack.bot_token
    signing_secret      = var.jit_access.slack.signing_secret
    user_mappings       = var.jit_access.slack.user_mappings
    workflow_secret     = try(var.jit_access.slack.workflow_secret, null)
  }
  timezone        = var.jit_access.timezone
  waf_enabled     = true
  waf_web_acl_arn = module.waf_jit_access[0].web_acl_arn

  tags = var.tags

  depends_on = [
    module.api_gateway_account
  ]
}

#--------------------------------------------------------------
# Outputs
#--------------------------------------------------------------
output "jit_access_slack_app_manifest" {
  description = "Slack App Manifest YAML for JIT Access app registration."
  value       = var.jit_access.is_enabled ? module.jit_access[0].slack_app_manifest : null
}
