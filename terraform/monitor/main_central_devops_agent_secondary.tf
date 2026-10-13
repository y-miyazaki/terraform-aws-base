#--------------------------------------------------------------
# AWS DevOps Agent: secondary account role
# Created when devops_agent.secondary.is_enabled. The Agent Space lives in the primary account (devops_agent.secondary.primary_*);
# its ARN is only known after the primary account is applied.
#--------------------------------------------------------------
module "devops_agent_secondary" {
  source = "../../modules/aws/devops_agent_secondary"

  is_enabled = var.devops_agent.secondary.is_enabled

  region                       = var.region.primary
  account_id                   = data.aws_caller_identity.current.account_id
  additional_policy_statements = var.devops_agent.secondary.additional_policy_statements
  aws_iam_role = {
    name = local.devops_agent_secondary_role_name
  }
  # The placeholders only satisfy the module input type while the module is disabled (validation requires both when enabled).
  primary = {
    account_id      = coalesce(var.devops_agent.secondary.primary_account_id, "000000000000")
    agent_space_arn = coalesce(var.devops_agent.secondary.primary_agent_space_arn, "arn:aws:aidevops:${var.region.primary}:000000000000:agentspace/unused")
  }
  tags = var.tags
}

output "devops_agent_secondary_role_arn" {
  description = "ARN of the cross-account role for the DevOps Agent in the primary account (null unless devops_agent.secondary.is_enabled)."
  value       = module.devops_agent_secondary.role_arn
}
