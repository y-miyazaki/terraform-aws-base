variable "tags" {
  description = "Tags applied to all resources through the AWS provider default_tags (e.g. env, service)"
  type        = map(any)
}

variable "name_prefix" {
  description = "Prefix attached to resource names to identify the project and environment (e.g. base- gives base-lambda)"
  type        = string
}

variable "region" {
  description = "Region configuration for multi-region deployment"
  type = object({
    global  = string
    primary = string
    targets = list(string)
  })
  validation {
    condition     = length(var.region.targets) > 0
    error_message = "region.targets must contain at least one region"
  }
  validation {
    condition     = contains(var.region.targets, var.region.primary)
    error_message = "region.primary must be included in region.targets"
  }
}

variable "cloudwatch_log_group" {
  description = <<-EOT
    Common CloudWatch Log Group configuration for all services.

    Priority order (higher priority overrides lower):
    1. var.cloudwatch_log_group.override.<service_name>.retention_in_days (highest priority)
    2. var.cloudwatch_log_group.retention_in_days (lowest priority - common default)

    Example:
      cloudwatch_log_group = {
        retention_in_days = 14  # Default for all services
        override = {
          cloudwatch_event_ec2 = {
            retention_in_days = 7  # Override for EC2 events
          }
          metric_log_postgresql_slowquery = {
            retention_in_days = 30  # Override for PostgreSQL slow query
          }
        }
      }
  EOT
  type = object({
    retention_in_days = number
    override = optional(object({
      cloudwatch_event_ec2 = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_log = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_metric = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_ses = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_step_functions = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_step_functions_us_east_1 = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_vpc_flow_log = optional(object({
        retention_in_days = optional(number)
      }))
      metric_log_application = optional(object({
        retention_in_days = optional(number)
      }))
      metric_log_postgresql_slowquery = optional(object({
        retention_in_days = optional(number)
      }))
    }))
  })
}

variable "slack" {
  description = <<-EOT
    Common Slack configuration for all Lambda functions.

    Priority order (higher priority overrides lower):
    1. var.slack.override.<function_name> (highest priority)
    2. var.slack (lowest priority - common defaults)

    Example:
      slack = {
        oauth_access_token = "xoxb-common-token"
        channel_id         = "C-common-channel"
        override = {
          common_lambda_log = {
            channel_id = "C-log-specific-channel"
          }
        }
      }
  EOT
  type = object({
    oauth_access_token = string
    channel_id         = string
    override = optional(object({
      apigateway_report_csp = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      cloudwatch_event_ec2 = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      common_lambda_log = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      common_lambda_metric = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      common_lambda_ses = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      common_lambda_step_functions = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      metric_log_application = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      metric_log_postgresql_slowquery = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
    }))
  })
  #   sensitive = true
}

variable "kms" {
  description = "KMS customer managed keys keyed by purpose : is_enabled, description, deletion_window_in_days"
  type        = any
}

variable "common_lambda" {
  description = "Common Lambda configuration for all monitor Lambda functions (vpc: run in a VPC, create_vpc or use an existing one via exists/new)"
  type        = any
}

variable "common_log" {
  description = "Common log storage configuration (e.g. s3_application_log: S3 bucket for application logs)"
  type        = any
}

variable "delivery_log" {
  description = "CloudWatch Logs delivery to S3 in the primary region (is_enabled, log group auto-discovery with include/exclude lists)"
  type        = any
}

variable "delivery_log_us_east_1" {
  description = "CloudWatch Logs delivery to S3 in the global region (region.global); effective only when region.global differs from region.primary"
  type        = any
}

variable "metric_log_application" {
  type        = any
  description = "CloudWatch Logs (Application) resources on AWS"
}

variable "metric_log_application_report" {
  type        = any
  description = "CloudWatch Logs (Application) errors report resources on AWS"
}

# TODO: will be removed in the future
variable "metric_log_step_functions" {
  type        = any
  description = "CloudWatch Logs (Step Functions) resources on AWS"
}

variable "metric_log_waf" {
  type        = any
  description = "CloudWatch Logs (WAF) resources on AWS"
}

variable "metric_log_waf_us_east_1" {
  type        = any
  description = "CloudWatch Logs (WAF) resources on AWS in us-east-1"
}

variable "metric_log_mysql_slowquery" {
  type        = any
  description = "CloudWatch Logs (MySQL slow query) resources on AWS"
}

variable "metric_log_postgresql" {
  type        = any
  description = "CloudWatch Logs (PostgreSQL) resources on AWS"
}

variable "metric_log_postgresql_slowquery" {
  type        = any
  description = "CloudWatch Logs (PostgreSQL slow query) resources on AWS"
}

variable "metric_log_postgresql_slowquery_report" {
  type        = any
  description = "CloudWatch Logs (PostgreSQL slow query) report resources on AWS"
}

variable "metric_resource_api_gateway" {
  type        = any
  description = "CloudWatch metric resource(API Gateway) resources on AWS"
}

variable "metric_resource_cloudfront" {
  type        = any
  description = "CloudWatch metric resource(CloudFront) resources on AWS"
}

variable "metric_resource_ec2" {
  type        = any
  description = "CloudWatch metric resource(EC2) resources on AWS"
}

variable "metric_resource_ecs_container_insights" {
  type        = any
  description = "CloudWatch metric resource(ECS/ContainerInsights) resources on AWS"
}

variable "metric_resource_elasticache" {
  type        = any
  description = "CloudWatch event(ElastiCache) resources on AWS"
}

variable "metric_resource_elb" {
  type        = any
  description = "CloudWatch metric resource(ELB - ALB/NLB) resources on AWS"
}

variable "metric_resource_eventbridge_scheduler" {
  type        = any
  description = "CloudWatch event(EventBridge Scheduler) resources on AWS"
}

variable "metric_resource_lambda" {
  type        = any
  description = "CloudWatch event(Lambda) resources on AWS"
}

variable "metric_resource_nat_gateway" {
  type        = any
  description = "CloudWatch metric resource(NAT Gateway) resources on AWS"
}

variable "metric_resource_rds_cluster" {
  type        = any
  description = "CloudWatch metric resource(RDS) resources on AWS"
}

variable "metric_resource_redshift" {
  type        = any
  description = "CloudWatch event(Redshift) resources on AWS"
}

variable "metric_resource_ses" {
  type        = any
  description = "CloudWatch event(SES) resources on AWS"
}

variable "metric_resource_sns" {
  type        = any
  description = "CloudWatch event(SNS) resources on AWS"
}

variable "metric_resource_sqs" {
  type        = any
  description = "CloudWatch event(SQS) resources on AWS"
}

variable "cloudwatch_event_ec2" {
  type        = any
  description = "CloudWatch event(EC2) resources on AWS"
}

variable "metric_synthetics_canary" {
  type        = any
  description = "Synthetics canary resources on AWS. Map of function name to configuration (e.g., heartbeat, linkcheck)"
}

variable "athena" {
  type        = any
  description = "Athena resources on AWS"
}

variable "report_csp" {
  type        = any
  description = "API Gateway resources on AWS"
}

variable "eventbridge" {
  type        = any
  description = "EventBridge resources on AWS"
}

variable "devops_agent" {
  description = <<-EOT
    (Optional) AWS DevOps Agent configuration. primary and secondary are independent; both can be enabled in one account
    (it hosts Agent Spaces that investigate itself and is also investigated by the Agent Space of another primary account).
    primary hosts the Agent Spaces (primary.is_enabled). Account-level settings (github_registrations, mcp_server_registrations,
    mcp_slack_reply, secondary_accounts) are shared by all Agent Spaces.
    primary.agent_spaces is a map keyed by the Agent Space name (name_prefix is prepended); module.devops_agent is called
    with for_each over it. An Agent Space is created when both primary.is_enabled and agent_spaces[*].is_enabled are true.
    Each Agent Space gets IAM roles (<name_prefix><key>-agent-space-role / -operator-app-role), the operator web app,
    the monitor account association, GitHub repository associations, agent instructions (AGENTS.md), skills/custom agents/scheduled triggers,
    and optionally a generic webhook.
    The KMS customer managed key shared by all Agent Spaces is declared in var.kms["monitor_devops_agent"]
    (module.kms_key_devops_agent in main_central_kms.tf).
    primary.secondary_accounts (a map keyed by an identifier, account_id = 12-digit ID) are associated with every Agent Space as source accounts.
    secondary (secondary.is_enabled) creates only the read-only cross-account role (fixed name DevOpsAgentRole-SecondaryAccount) that
    trusts secondary.primary_agent_space_arn in secondary.primary_account_id (both required when secondary.is_enabled).
    secondary.additional_policy_statements adds IAM statements to that role on top of AIDevOpsAgentAccessPolicy,
    like primary.agent_spaces[*].additional_policy_statements does for the Agent Space role.
    Apply the primary account first to obtain the Agent Space ARN, then the secondary accounts, then add secondary_accounts to the primary.
    primary.github_registrations is a map of the account-level GitHub registrations (one per GitHub user, organization, or GitHub Enterprise
    Server instance), registered in the AWS DevOps Agent console beforehand; set github_registrations.<name>.service_id to the
    registered service ID. agent_spaces[*].github_repositories[*].github_registration refers to a key of github_registrations.
    primary.mcp_server_registrations is a map of the account-level MCP server registrations (e.g. GitHub MCP server, Notion MCP server),
    registered beforehand with `aws devops-agent register-service --service mcpserver` (the credential never enters the Terraform
    state); set mcp_server_registrations.<name>.service_id to the returned service ID. agent_spaces[*].mcp_servers[*].mcp_server_registration
    refers to a key of mcp_server_registrations, and tools is the allowlist of MCP tool names the Agent Space can use.
    primary.mcp_slack_reply.is_enabled creates the Slack reply MCP server (Lambda function URL with IAM authentication), registers it in
    AWS DevOps Agent (SigV4), and attaches it to every Agent Space (key mcp_slack_reply; do not define it in agent_spaces[*].mcp_servers).
    agent_spaces[*].webhook.is_enabled creates a generic webhook. The event channel service
    (name: <name_prefix><key>-webhook) is registered and the association is created with the AWS CLI. The webhook
    credentials (returned only once at creation) are written directly to the Secrets Manager secret
    <name_prefix without trailing "-">/<key>/webhook, encrypted with module.kms_key_devops_agent when kms["monitor_devops_agent"].is_enabled
    (otherwise aws/secretsmanager); they never enter the Terraform state. aws CLI and jq are required where Terraform runs.
    agents_md is keyed by the agent type (GENERIC applies to all agents; at most one per agent type), and agents_md[*].content_file is the AGENTS.md path relative to this stack directory.
    agent_spaces[*].linear.team is the Linear team (name or key) in which the Agent Space creates Issues with the Linear MCP server. When it is set,
    main_central_devops_agent.tf appends a Linear section (the team and the stop rule) to the GENERIC AGENTS.md of that Agent Space
    (a GENERIC AGENTS.md is created when agents_md has none); the file given by content_file is never edited. Leave it null to add nothing.
    skills[*].content_file (the SKILL.md of a skill directory; text files under references/ and assets/ next to it are attached automatically) and custom_agents[*].system_prompt_file are paths relative to this stack directory.
  EOT
  type = object({
    primary = optional(object({
      is_enabled = optional(bool, false)
      github_registrations = optional(map(object({
        service_id = string
        owner      = string
        owner_type = optional(string, "organization")
      })), {})
      mcp_slack_reply = optional(object({
        is_enabled  = optional(bool, false)
        memory_size = optional(number, 128)
        timeout     = optional(number, 30)
      }), {})
      mcp_server_registrations = optional(map(object({
        description = optional(string)
        endpoint    = string
        name        = string
        service_id  = string
      })), {})
      secondary_accounts = optional(map(object({
        account_id = string
      })), {})
      agent_spaces = optional(map(object({
        is_enabled               = optional(bool, true)
        description              = optional(string, "AWS DevOps Agent Space")
        elevated_actions_enabled = optional(bool, false)
        locale                   = optional(string)
        additional_policy_statements = optional(list(object({
          actions   = list(string)
          effect    = optional(string, "Allow")
          resources = list(string)
          sid       = string
        })), [])
        github_repositories = optional(map(object({
          github_registration = string
          repo_id             = string
          repo_name           = string
        })), {})
        mcp_servers = optional(map(object({
          mcp_server_registration = string
          tools                   = list(string)
        })), {})
        agents_md = optional(map(object({
          content_file = string
        })), {})
        linear = optional(object({
          team = optional(string)
        }), {})
        skills = optional(map(object({
          agent_types  = optional(list(string), ["GENERIC"])
          content_file = string
          description  = string
          name         = string
        })), {})
        custom_agents = optional(map(object({
          name               = string
          skills             = optional(list(string), [])
          system_prompt_file = string
          tools              = optional(list(string), [])
          triggers = optional(map(object({
            schedule_expression = string
            status              = optional(string, "Active")
          })), {})
        })), {})
        webhook = optional(object({
          is_enabled = optional(bool, false)
          secret = optional(object({
            recovery_window_in_days = optional(number, 7)
          }), {})
        }), {})
      })), {})
    }), {})
    secondary = optional(object({
      is_enabled = optional(bool, false)
      additional_policy_statements = optional(list(object({
        actions   = list(string)
        effect    = optional(string, "Allow")
        resources = list(string)
        sid       = string
      })), [])
      primary_account_id      = optional(string)
      primary_agent_space_arn = optional(string)
    }), {})
  })
  validation {
    condition = !var.devops_agent.secondary.is_enabled || (
      var.devops_agent.secondary.primary_account_id != null &&
      var.devops_agent.secondary.primary_agent_space_arn != null
    )
    error_message = "devops_agent.secondary.is_enabled requires devops_agent.secondary.primary_account_id and primary_agent_space_arn."
  }
  validation {
    condition     = var.devops_agent.secondary.primary_account_id == null || can(regex("^[0-9]{12}$", var.devops_agent.secondary.primary_account_id))
    error_message = "devops_agent.secondary.primary_account_id must be a 12-digit AWS account ID."
  }
  validation {
    condition     = var.devops_agent.secondary.primary_agent_space_arn == null || can(regex("^arn:aws:aidevops:[a-z0-9-]+:[0-9]{12}:agentspace/[A-Za-z0-9-]+$", var.devops_agent.secondary.primary_agent_space_arn))
    error_message = "devops_agent.secondary.primary_agent_space_arn must be an Agent Space ARN (arn:aws:aidevops:<region>:<account>:agentspace/<id>) without wildcards."
  }
  validation {
    condition     = alltrue([for v in values(var.devops_agent.primary.secondary_accounts) : can(regex("^[0-9]{12}$", v.account_id))])
    error_message = "devops_agent.primary.secondary_accounts[*].account_id must be a 12-digit AWS account ID."
  }
  validation {
    condition     = alltrue([for k in keys(var.devops_agent.primary.agent_spaces) : can(regex("^[a-z0-9]([a-z0-9-]{0,38}[a-z0-9])?$", k))])
    error_message = "devops_agent.primary.agent_spaces keys (Agent Space names) must be 1-40 lowercase letters, digits or hyphens, starting and ending with a letter or digit."
  }
  validation {
    condition = alltrue(flatten([
      for v in values(var.devops_agent.primary.agent_spaces) : [
        for r in values(v.github_repositories) : contains(keys(var.devops_agent.primary.github_registrations), r.github_registration)
      ]
    ]))
    error_message = "devops_agent.primary.agent_spaces[*].github_repositories[*].github_registration must be a key of devops_agent.primary.github_registrations."
  }
  validation {
    condition = alltrue(flatten([
      for k, a in var.devops_agent.primary.agent_spaces : [
        for m in a.mcp_servers : contains(keys(var.devops_agent.primary.mcp_server_registrations), m.mcp_server_registration)
      ]
    ]))
    error_message = "devops_agent.primary.agent_spaces[*].mcp_servers[*].mcp_server_registration must be a key of devops_agent.primary.mcp_server_registrations."
  }
  validation {
    condition     = alltrue([for k, a in var.devops_agent.primary.agent_spaces : !contains(keys(a.mcp_servers), "mcp_slack_reply")])
    error_message = "devops_agent.primary.agent_spaces[*].mcp_servers must not define the key mcp_slack_reply (built-in, attached by devops_agent.primary.mcp_slack_reply)."
  }
  validation {
    condition     = alltrue([for k, a in var.devops_agent.primary.agent_spaces : a.linear.team == null || can(regex("^[^\\x00-\\x1f\\x7f]{1,64}$", a.linear.team)) && trimspace(a.linear.team) == a.linear.team])
    error_message = "devops_agent.primary.agent_spaces[*].linear.team must be 1-64 characters without control characters (newline) or leading/trailing spaces."
  }
  default = {}
}
