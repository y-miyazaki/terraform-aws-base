#--------------------------------------------------------------
# JIT Access
# Temporary privileged access system with Slack integration.
# Manages time-bound IAM Identity Center Permission Set assignments
# with approval workflow and automatic revocation.
#--------------------------------------------------------------
module "jit_access" {
  count  = var.jit_access.is_enabled ? 1 : 0
  source = "../../../modules/aws/jit_access"

  name_prefix          = var.name_prefix
  lambda_zip_base_path = "../../../lambda/outputs"
  slack = {
    approver_channel_id = var.jit_access.slack.approver_channel_id
    bot_token           = var.jit_access.slack.bot_token
    signing_secret      = var.jit_access.slack.signing_secret
    user_mappings       = var.jit_access.slack.user_mappings
    workflow_secret     = try(var.jit_access.slack.workflow_secret, null)
  }
  profiles                    = var.jit_access.profiles
  cleanup_schedule_expression = var.jit_access.cleanup_schedule_expression
  lambda_log_retention_days   = coalesce(try(var.cloudwatch_log_group.override.jit_access.retention_in_days, null), var.cloudwatch_log_group.retention_in_days)
  kms_key_arn                 = module.kms_key["root"].key_arn

  tags = var.tags
}
