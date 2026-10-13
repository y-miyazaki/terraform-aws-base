#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) Whether to create AWS DevOps Agent resources."
  default     = true
}

variable "account_id" {
  type        = string
  description = "(Required) AWS account ID that hosts the Agent Space (monitor account)."
}

variable "region" {
  type        = string
  description = "(Optional) Region where the Agent Space is created. Must be a supported AWS DevOps Agent region. Defaults to provider region."
  default     = null
  validation {
    condition = var.region == null ? true : contains([
      "ap-northeast-1",
      "ap-southeast-2",
      "eu-central-1",
      "eu-west-1",
      "us-east-1",
      "us-west-2",
    ], var.region)
    error_message = "region must be one of the AWS DevOps Agent supported regions: ap-northeast-1, ap-southeast-2, eu-central-1, eu-west-1, us-east-1, us-west-2."
  }
}

variable "agent_space" {
  type = object({
    # (Optional) Description of the Agent Space.
    description = optional(string)
    # (Optional) Whether elevated directed actions are allowed. Defaults to false.
    elevated_actions_enabled = optional(bool, false)
    # (Optional) Whether kms_key_arn is set. Must be known at plan time (kms_key_arn may not be), so the caller passes it explicitly.
    # When true, the operator app role is granted access to kms_key_arn via aidevops. Defaults to false.
    is_kms_enabled = optional(bool, false)
    # (Optional) ARN of the KMS customer managed key (symmetric, single-Region) used for encryption at rest.
    # The key policy must grant aidevops.amazonaws.com access. Changing this forces a new Agent Space.
    kms_key_arn = optional(string)
    # (Optional) Language used in agent responses (BCP 47, e.g. en-US, ja-JP). Responds in the input language when unset.
    locale = optional(string)
    # (Required) Name of the Agent Space.
    name = string
  })
  description = "(Required) AWS DevOps Agent Space configuration."
  validation {
    condition     = var.agent_space.locale == null ? true : can(regex("^[a-zA-Z]{2,3}(-[a-zA-Z0-9]{2,8})*$", var.agent_space.locale))
    error_message = "agent_space.locale must be a BCP 47 language tag (e.g. en-US, ja-JP)."
  }
}

variable "aws_iam_role_agent_space" {
  type = object({
    # (Optional) Description of the IAM role.
    description = optional(string, "IAM role assumed by AWS DevOps Agent to investigate the account.")
    # (Required) Name of the IAM role.
    name = string
    # (Optional) Path to the role.
    path = optional(string, "/")
  })
  description = "(Required) IAM role assumed by the Agent Space (AIDevOpsAgentAccessPolicy)."
}

variable "aws_iam_role_operator_app" {
  type = object({
    # (Optional) Description of the IAM role.
    description = optional(string, "IAM role for AWS DevOps Agent operator web app.")
    # (Required) Name of the IAM role.
    name = string
    # (Optional) Path to the role.
    path = optional(string, "/")
  })
  description = "(Required) IAM role for the operator web app (AIDevOpsOperatorAppAccessPolicy)."
}

variable "github_repositories" {
  type = map(object({
    # (Required) Service ID of the GitHub registration that can access the repository (account-level, registered in
    # the console). One registration exists per GitHub user, organization, or GitHub Enterprise Server instance.
    # ex) aws devops-agent list-services --region <region> --filter-service-type github
    service_id = string
    # (Required) Repository owner (user or organization name).
    owner = string
    # (Optional) Owner type: organization or user.
    owner_type = optional(string, "organization")
    # (Required) Numeric GitHub repository ID.
    # ex) gh api repos/<owner>/<repo> --jq .id
    repo_id = string
    # (Required) Repository name.
    repo_name = string
  }))
  description = "(Optional) GitHub repositories to associate with the Agent Space. Key is an arbitrary stable identifier. GitHub must be registered at the account level in the console beforehand."
  default     = {}
  validation {
    condition     = alltrue([for r in var.github_repositories : contains(["organization", "user"], r.owner_type)])
    error_message = "github_repositories[*].owner_type must be organization or user."
  }
  validation {
    condition     = alltrue([for r in var.github_repositories : can(regex("^[0-9]+$", r.repo_id))])
    error_message = "github_repositories[*].repo_id must be the numeric GitHub repository ID."
  }
}

variable "mcp_servers" {
  type = map(object({
    # (Optional) Description of the MCP server.
    description = optional(string)
    # (Required) MCP server endpoint (HTTPS URL).
    endpoint = string
    # (Required) MCP server name (letters, numbers, hyphens and underscores).
    name = string
    # (Required) Service ID returned by `aws devops-agent register-service --service mcpserver` (account-level).
    # The credential (API key / PAT) is passed to the CLI and never enters the Terraform state.
    service_id = string
    # (Optional) Service type the MCP server was registered with: mcpserver (API key / OAuth) or mcpserversigv4 (SigV4).
    # Must match the registration, otherwise the association fails with "Service type does match the registered service".
    service_type = optional(string, "mcpserver")
    # (Required) Allowlist of MCP tool names the Agent Space can use. Unlisted tools are invisible to the agent.
    tools = list(string)
  }))
  description = "(Optional) MCP servers to associate with the Agent Space (tool allowlist). Key is an arbitrary stable identifier. The MCP server must be registered at the account level beforehand."
  default     = {}
  validation {
    condition     = alltrue([for m in var.mcp_servers : can(regex("^https://", m.endpoint))])
    error_message = "mcp_servers[*].endpoint must be an HTTPS URL."
  }
  validation {
    condition     = alltrue([for m in var.mcp_servers : can(regex("^[a-zA-Z0-9_-]+$", m.name))])
    error_message = "mcp_servers[*].name must match ^[a-zA-Z0-9_-]+$."
  }
  validation {
    condition     = alltrue([for m in var.mcp_servers : contains(["mcpserver", "mcpserversigv4"], m.service_type)])
    error_message = "mcp_servers[*].service_type must be mcpserver or mcpserversigv4."
  }
  validation {
    condition     = alltrue([for m in var.mcp_servers : length(m.tools) > 0])
    error_message = "mcp_servers[*].tools must not be empty."
  }
}

variable "skills" {
  type = map(object({
    # (Optional) Agent types the skill applies to. GENERIC cannot be combined with other values.
    agent_types = optional(list(string), ["GENERIC"])
    # (Required) SKILL.md content.
    content = string
    # (Required) When the agent should use the skill (1-1024 characters).
    description = string
    # (Optional) Additional text files, keyed by path relative to the skill root (references/<file> or assets/<file>), with the file content as the value.
    files = optional(map(string), {})
    # (Required) Skill name: lowercase letters, numbers and hyphens (1-64 characters).
    name = string
  }))
  description = "(Optional) Skills to create in the Agent Space. Key is an arbitrary stable identifier referenced by custom_agents[*].skills."
  default     = {}
  validation {
    condition     = alltrue([for s in var.skills : can(regex("^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$", s.name))])
    error_message = "skills[*].name must be 1-64 lowercase letters, numbers or hyphens, not starting or ending with a hyphen."
  }
  validation {
    condition     = alltrue([for s in var.skills : alltrue([for path in keys(s.files) : can(regex("^(references|assets)/[^.][^/]*(/[^.][^/]*)*$", path))])])
    error_message = "skills[*].files keys must be relative paths under references/ or assets/ (no leading dot, no '..')."
  }
}

variable "agents_md" {
  type        = map(string)
  description = "(Optional) Agent instructions (AGENTS.md, Markdown without frontmatter) injected into every session. Key is the agent type (GENERIC applies to all agents; at most one per agent type), value is the AGENTS.md content."
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.agents_md) : contains(["GENERIC", "CHAT", "INCIDENT_TRIAGE", "INCIDENT_RCA", "INCIDENT_MITIGATION", "INCIDENT_UI", "PREVENTION", "RELEASE_READINESS_REVIEW", "RELEASE_TESTING"], k)])
    error_message = "agents_md keys must be one of GENERIC, CHAT, INCIDENT_TRIAGE, INCIDENT_RCA, INCIDENT_MITIGATION, INCIDENT_UI, PREVENTION, RELEASE_READINESS_REVIEW, RELEASE_TESTING."
  }
  validation {
    # 25 KB hard limit in bytes (25,000, conservative). Terraform has no byte-length function: bytes = base64 length / 4 * 3 - padding.
    condition     = alltrue([for v in values(var.agents_md) : length(trimspace(v)) > 0 && length(base64encode(v)) / 4 * 3 - length(regexall("=", base64encode(v))) <= 25000])
    error_message = "agents_md values must be non-empty and at most 25 KB."
  }
}

variable "custom_agents" {
  type = map(object({
    # (Required) Custom agent name: lowercase letters, numbers and hyphens (1-64 characters).
    name = string
    # (Optional) Keys of var.skills to attach.
    skills = optional(list(string), [])
    # (Required) System prompt (AGENT.md content, Markdown, 10-50,000 characters).
    system_prompt = string
    # (Optional) MCP tool identifiers the agent can use (e.g. use_aws, query_cloudwatch_logs).
    tools = optional(list(string), [])
    # (Optional) Scheduled triggers. Key is an arbitrary stable identifier.
    triggers = optional(map(object({
      # (Required) EventBridge-compatible cron or rate expression (UTC). e.g. cron(0 0 ? * MON-FRI *), rate(1 day)
      schedule_expression = string
      # (Optional) Active or Inactive.
      status = optional(string, "Active")
    })), {})
  }))
  description = "(Optional) Custom agents to create in the Agent Space, with optional scheduled triggers."
  default     = {}
  validation {
    condition     = alltrue([for a in var.custom_agents : can(regex("^[a-z0-9]([a-z0-9-]{0,62}[a-z0-9])?$", a.name))])
    error_message = "custom_agents[*].name must be 1-64 lowercase letters, numbers or hyphens, not starting or ending with a hyphen."
  }
  validation {
    condition     = alltrue([for a in var.custom_agents : length(a.system_prompt) >= 10 && length(a.system_prompt) <= 50000])
    error_message = "custom_agents[*].system_prompt must be 10-50,000 characters."
  }
  validation {
    condition     = alltrue(flatten([for a in var.custom_agents : [for k in a.skills : contains(keys(var.skills), k)]]))
    error_message = "custom_agents[*].skills must reference keys of var.skills."
  }
  validation {
    condition     = alltrue(flatten([for a in var.custom_agents : [for t in a.triggers : contains(["Active", "Inactive"], t.status)]]))
    error_message = "custom_agents[*].triggers[*].status must be Active or Inactive."
  }
  validation {
    condition     = alltrue(flatten([for a in var.custom_agents : [for t in a.triggers : can(regex("^(cron|rate)\\(.+\\)$", t.schedule_expression))]]))
    error_message = "custom_agents[*].triggers[*].schedule_expression must be a cron(...) or rate(...) expression."
  }
}

variable "agent_space_additional_policy_statements" {
  type = list(object({
    # (Required) IAM actions, e.g. ["lambda:GetFunction"].
    actions = list(string)
    # (Optional) Allow or Deny.
    effect = optional(string, "Allow")
    # (Required) Resource ARNs the statement applies to.
    resources = list(string)
    # (Required) Statement ID (alphanumeric, unique within the list).
    sid = string
  }))
  description = "(Optional) Extra IAM policy statements attached to the Agent Space role on top of AIDevOpsAgentAccessPolicy (e.g. read actions the managed policy lacks). Keep them least privilege."
  default     = []
  validation {
    condition     = alltrue([for s in var.agent_space_additional_policy_statements : contains(["Allow", "Deny"], s.effect)])
    error_message = "agent_space_additional_policy_statements[*].effect must be Allow or Deny."
  }
  validation {
    condition     = alltrue([for s in var.agent_space_additional_policy_statements : can(regex("^[A-Za-z0-9]+$", s.sid))])
    error_message = "agent_space_additional_policy_statements[*].sid must be alphanumeric."
  }
}

variable "iam_propagation_wait" {
  type        = string
  description = "(Optional) Wait duration after IAM role creation before creating the Agent Space (the service validates role trust policies on create)."
  default     = "30s"
}

variable "secondary_accounts" {
  type = map(object({
    # (Required) 12-digit AWS account ID of the secondary (source) account.
    account_id = string
    # (Required) Name of the cross-account role in the secondary account (created by modules/aws/devops_agent_secondary).
    role_name = string
  }))
  description = "(Optional) Secondary (source) accounts the Agent Space investigates, keyed by an identifier. The role must already exist in each account."
  default     = {}
  validation {
    condition     = alltrue([for v in values(var.secondary_accounts) : can(regex("^[0-9]{12}$", v.account_id))])
    error_message = "secondary_accounts[*].account_id must be a 12-digit AWS account ID."
  }
}

variable "tags" {
  type        = map(any)
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = {}
}
variable "webhook" {
  type = object({
    # (Optional) Display name of the event channel (webhook) service registration (account-level).
    # Terraform registers it on create and deregisters it on destroy; only the registration with this name is managed.
    service_name = optional(string, "devops-agent-webhook")
    # (Required) Secrets Manager secret that receives the webhook credentials (written via the AWS CLI, not Terraform).
    secret = object({
      # (Optional) KMS key ARN/ID to encrypt the secret. null uses the AWS managed key (aws/secretsmanager).
      kms_key_id = optional(string)
      # (Required) Secret name, slash-separated (e.g. base/devops-agent/webhook).
      name = string
      # (Optional) Days before the secret is deleted after destroy (0 deletes immediately, or 7-30).
      recovery_window_in_days = optional(number, 7)
    })
  })
  description = "(Optional) Generic webhook for the Agent Space. The event channel service is registered and the association is created with the AWS CLI (terraform_data); the webhook credentials are written directly to a Secrets Manager secret and never enter the Terraform state. aws CLI and jq are required where Terraform runs."
  default     = null
  validation {
    condition     = var.webhook == null ? true : can(regex("^[A-Za-z0-9 _-]{1,255}$", var.webhook.service_name))
    error_message = "webhook.service_name must be 1-255 characters of letters, digits, spaces, underscores or hyphens."
  }
  validation {
    condition     = var.webhook == null ? true : (var.webhook.secret.recovery_window_in_days == 0 || (var.webhook.secret.recovery_window_in_days >= 7 && var.webhook.secret.recovery_window_in_days <= 30))
    error_message = "webhook.secret.recovery_window_in_days must be 0 or between 7 and 30."
  }
  validation {
    condition     = var.webhook == null ? true : can(regex("^[A-Za-z0-9/_+=.@-]{1,512}$", var.webhook.secret.name))
    error_message = "webhook.secret.name must be 1-512 characters of letters, digits and /_+=.@- (e.g. base/devops-agent/webhook)."
  }
}
