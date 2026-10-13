#--------------------------------------------------------------
# AWS DevOps Agent
# One module call per Agent Space (var.devops_agent.primary.agent_spaces, keyed by the Agent Space name).
# Each Agent Space has the operator web app, monitor account association, GitHub repository associations, MCP server associations (tool allowlist),
# agent instructions (AGENTS.md), skills/custom agents/scheduled triggers, and an optional generic webhook.
# Webhook credentials (HMAC secret) are written by the AWS CLI directly to Secrets Manager
# (output devops_agent_webhook_secret_arns); the secret value never enters the Terraform state.
# KMS key (shared by all Agent Spaces): module.kms_key_devops_agent in main_central_kms.tf.
#--------------------------------------------------------------
locals {
  # This account hosts the Agent Spaces (devops_agent.primary); devops_agent.secondary only creates the cross-account role
  # (main_central_devops_agent_secondary.tf). Both can be enabled in one account.
  devops_agent_is_primary = var.devops_agent.primary.is_enabled
  # Fixed name: the primary account builds the assumable role ARN of every secondary account from it.
  devops_agent_secondary_role_name = "DevOpsAgentRole-SecondaryAccount"

  # Slack reply MCP server (main_central_lambda_devops_agent_mcp_slack_reply.tf), attached to every Agent Space
  devops_agent_mcp_slack_reply_mcp_servers = local.devops_agent_mcp_slack_reply_enabled ? {
    mcp_slack_reply = {
      description  = "Reply to Slack alert threads"
      endpoint     = module.aws_lambda_devops_agent_mcp_slack_reply.lambda_function_url
      name         = "McpSlackReply"
      service_id   = awscc_devopsagent_service.devops_agent_mcp_slack_reply[0].service_id
      service_type = "mcpserversigv4"
      tools        = ["slack_reply_to_thread"]
    }
  } : {}

  # AGENTS.md per Agent Space and agent type. When agent_spaces[*].linear.team is set, the Linear section is appended to the GENERIC AGENTS.md
  # (created when agents_md has none), so the content file itself (e.g. devops_agent/agents_md/generic.md) is never edited.
  devops_agent_agents_md = {
    for k, base in local.devops_agent_agents_md_base : k => local.devops_agent_agents_md_linear_section[k] == null ? base : merge(base, {
      GENERIC = contains(keys(base), "GENERIC") ? "${base["GENERIC"]}\n${local.devops_agent_agents_md_linear_section[k]}" : local.devops_agent_agents_md_linear_section[k]
    })
  }
  devops_agent_agents_md_base = {
    for k, a in var.devops_agent.primary.agent_spaces : k => {
      for t, v in a.agents_md : t => file("${path.module}/${v.content_file}")
    }
  }
  devops_agent_agents_md_linear_section = {
    for k, a in var.devops_agent.primary.agent_spaces : k => a.linear.team == null ? null : join("\n", [
      "## Linear",
      "",
      "- Linear team: ${a.linear.team}",
      "- Create Linear Issues only in this team. Check that it exists with `list_teams` before creating an Issue; when it does not exist, create nothing and report it.",
      "- Never create an Issue in any other team and never guess a team.",
      "",
    ])
  }
}

module "devops_agent" {
  for_each = var.devops_agent.primary.agent_spaces

  source = "../../modules/aws/devops_agent"

  is_enabled = local.devops_agent_is_primary && each.value.is_enabled
  region     = var.region.primary

  account_id = data.aws_caller_identity.current.account_id
  agent_space = {
    description              = each.value.description
    elevated_actions_enabled = each.value.elevated_actions_enabled
    is_kms_enabled           = var.kms["monitor_devops_agent"].is_enabled
    kms_key_arn              = var.kms["monitor_devops_agent"].is_enabled ? module.kms_key_devops_agent.key_arn : null
    locale                   = each.value.locale
    name                     = "${var.name_prefix}${each.key}"
  }
  agent_space_additional_policy_statements = each.value.additional_policy_statements
  agents_md                                = local.devops_agent_agents_md[each.key]
  aws_iam_role_agent_space = {
    name = "${var.name_prefix}${each.key}-agent-space-role"
  }
  aws_iam_role_operator_app = {
    name = "${var.name_prefix}${each.key}-operator-app-role"
  }
  custom_agents = {
    for k, v in each.value.custom_agents : k => {
      name          = v.name
      skills        = v.skills
      system_prompt = file("${path.module}/${v.system_prompt_file}")
      tools         = v.tools
      triggers      = v.triggers
    }
  }
  # GitHub registrations (service_id, owner) are account-level; repositories are per Agent Space.
  github_repositories = {
    for k, v in each.value.github_repositories : k => {
      owner      = var.devops_agent.primary.github_registrations[v.github_registration].owner
      owner_type = var.devops_agent.primary.github_registrations[v.github_registration].owner_type
      repo_id    = v.repo_id
      repo_name  = v.repo_name
      service_id = var.devops_agent.primary.github_registrations[v.github_registration].service_id
    }
  }
  # MCP server registrations (service_id, name, endpoint) are account-level; the tool allowlist is per Agent Space.
  mcp_servers = merge(
    {
      for k, v in each.value.mcp_servers : k => {
        description = var.devops_agent.primary.mcp_server_registrations[v.mcp_server_registration].description
        endpoint    = var.devops_agent.primary.mcp_server_registrations[v.mcp_server_registration].endpoint
        name        = var.devops_agent.primary.mcp_server_registrations[v.mcp_server_registration].name
        service_id  = var.devops_agent.primary.mcp_server_registrations[v.mcp_server_registration].service_id
        tools       = v.tools
      }
    },
    local.devops_agent_mcp_slack_reply_mcp_servers
  )
  # Secondary (source) accounts the Agent Space investigates. The cross-account role must already exist in each account.
  secondary_accounts = {
    for k, v in var.devops_agent.primary.secondary_accounts : k => {
      account_id = v.account_id
      role_name  = local.devops_agent_secondary_role_name
    }
  }
  skills = {
    for k, v in each.value.skills : k => {
      agent_types = v.agent_types
      content     = file("${path.module}/${v.content_file}")
      description = v.description
      # Files next to SKILL.md: references/ and assets/ (text files only), read from the directory of content_file.
      files = {
        for f in fileset(dirname("${path.module}/${v.content_file}"), "{assets,references}/**/*.{csv,json,md,txt,yaml,yml}") :
        f => file("${dirname("${path.module}/${v.content_file}")}/${f}")
      }
      name = v.name
    }
  }
  webhook = each.value.webhook.is_enabled ? {
    secret = {
      kms_key_id = var.kms["monitor_devops_agent"].is_enabled ? module.kms_key_devops_agent.key_arn : null
      # <name_prefix without trailing "-">/<Agent Space name>/webhook (e.g. base/devops-agent/webhook)
      name                    = format("%s/%s/webhook", trimsuffix(var.name_prefix, "-"), each.key)
      recovery_window_in_days = each.value.webhook.secret.recovery_window_in_days
    }
    # Event channel service registration name (account level, one per Agent Space).
    service_name = "${var.name_prefix}${each.key}-webhook"
  } : null

  tags = var.tags
}

output "devops_agent_agent_space_arns" {
  description = "Map of Agent Space name (agent_spaces key) to Agent Space ARN. Set it as devops_agent.secondary.primary_agent_space_arn in the secondary accounts."
  value       = { for k, v in module.devops_agent : k => v.agent_space_arn }
}

output "devops_agent_agent_space_ids" {
  description = "Map of Agent Space name (agent_spaces key) to Agent Space ID."
  value       = { for k, v in module.devops_agent : k => v.agent_space_id }
}

output "devops_agent_webhook_urls" {
  description = "Map of Agent Space name (agent_spaces key) to the generic webhook URL (POST target for external systems)."
  value       = { for k, v in module.devops_agent : k => v.webhook_url }
}

output "devops_agent_webhook_secret_arns" {
  description = <<-EOT
    Map of Agent Space name (agent_spaces key) to the ARN of the Secrets Manager secret holding the webhook credentials.
    Secret value (JSON): webhook_id, webhook_secret (HMAC signing secret, or API key for the apikey type), webhook_type, webhook_url.
    Read it with: aws secretsmanager get-secret-value --secret-id <arn> --query SecretString --output text
    The secret value itself is never output and is not stored in the Terraform state.
  EOT
  value       = { for k, v in module.devops_agent : k => v.webhook_secret_arn }
}
