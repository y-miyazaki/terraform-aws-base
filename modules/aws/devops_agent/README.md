<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0, < 7.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 1.104.0, < 2.0.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | >= 2.0.0, < 3.0.0 |
| <a name="requirement_time"></a> [time](#requirement\_time) | >= 0.9.0, < 1.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.68.0 |
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | 1.105.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.4.2 |
| <a name="provider_terraform"></a> [terraform](#provider\_terraform) | n/a |
| <a name="provider_time"></a> [time](#provider\_time) | 0.14.2 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.agent_space_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.agent_space_service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.operator_app_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.agent_space](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.operator_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.agent_space](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.agent_space_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.agent_space_service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.operator_app](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.operator_app_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_secretsmanager_secret.webhook](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [awscc_devopsagent_agent_space.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_agent_space) | resource |
| [awscc_devopsagent_asset.agents_md](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_asset) | resource |
| [awscc_devopsagent_asset.custom_agent](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_asset) | resource |
| [awscc_devopsagent_asset.skill](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_asset) | resource |
| [awscc_devopsagent_association.aws_monitor](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_association) | resource |
| [awscc_devopsagent_association.aws_source](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_association) | resource |
| [awscc_devopsagent_association.github](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_association) | resource |
| [awscc_devopsagent_association.mcp_server](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_association) | resource |
| [awscc_devopsagent_trigger.this](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/devopsagent_trigger) | resource |
| [terraform_data.event_channel_service](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [terraform_data.webhook_association](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [time_sleep.iam_propagation](https://registry.terraform.io/providers/hashicorp/time/latest/docs/resources/sleep) | resource |
| [aws_iam_policy_document.agent_space_additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.agent_space_service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.operator_app_kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [external_external.event_channel_service](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |
| [external_external.webhook](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) AWS account ID that hosts the Agent Space (monitor account). | `string` | n/a | yes |
| <a name="input_agent_space"></a> [agent\_space](#input\_agent\_space) | (Required) AWS DevOps Agent Space configuration. | <pre>object({<br/>    # (Optional) Description of the Agent Space.<br/>    description = optional(string)<br/>    # (Optional) Whether elevated directed actions are allowed. Defaults to false.<br/>    elevated_actions_enabled = optional(bool, false)<br/>    # (Optional) Whether kms_key_arn is set. Must be known at plan time (kms_key_arn may not be), so the caller passes it explicitly.<br/>    # When true, the operator app role is granted access to kms_key_arn via aidevops. Defaults to false.<br/>    is_kms_enabled = optional(bool, false)<br/>    # (Optional) ARN of the KMS customer managed key (symmetric, single-Region) used for encryption at rest.<br/>    # The key policy must grant aidevops.amazonaws.com access. Changing this forces a new Agent Space.<br/>    kms_key_arn = optional(string)<br/>    # (Optional) Language used in agent responses (BCP 47, e.g. en-US, ja-JP). Responds in the input language when unset.<br/>    locale = optional(string)<br/>    # (Required) Name of the Agent Space.<br/>    name = string<br/>  })</pre> | n/a | yes |
| <a name="input_agent_space_additional_policy_statements"></a> [agent\_space\_additional\_policy\_statements](#input\_agent\_space\_additional\_policy\_statements) | (Optional) Extra IAM policy statements attached to the Agent Space role on top of AIDevOpsAgentAccessPolicy (e.g. read actions the managed policy lacks). Keep them least privilege. | <pre>list(object({<br/>    # (Required) IAM actions, e.g. ["lambda:GetFunction"].<br/>    actions = list(string)<br/>    # (Optional) Allow or Deny.<br/>    effect = optional(string, "Allow")<br/>    # (Required) Resource ARNs the statement applies to.<br/>    resources = list(string)<br/>    # (Required) Statement ID (alphanumeric, unique within the list).<br/>    sid = string<br/>  }))</pre> | `[]` | no |
| <a name="input_agent_space_default_policy_statements"></a> [agent\_space\_default\_policy\_statements](#input\_agent\_space\_default\_policy\_statements) | (Optional) Baseline read-only statements attached to the Agent Space role on top of AIDevOpsAgentAccessPolicy. Only add actions that return no secrets or credentials; never allow secretsmanager:GetSecretValue. Set [] to attach none. agent\_space\_additional\_policy\_statements is merged after this list. | <pre>list(object({<br/>    # (Required) IAM actions, e.g. ["glue:GetTriggers"].<br/>    actions = list(string)<br/>    # (Optional) Allow or Deny.<br/>    effect = optional(string, "Allow")<br/>    # (Required) Resource ARNs the statement applies to.<br/>    resources = list(string)<br/>    # (Required) Statement ID (alphanumeric, unique within the list).<br/>    sid = string<br/>  }))</pre> | <pre>[<br/>  {<br/>    "actions": [<br/>      "glue:GetTrigger",<br/>      "glue:GetTriggers"<br/>    ],<br/>    "resources": [<br/>      "*"<br/>    ],<br/>    "sid": "AllowReadGlueTriggers"<br/>  }<br/>]</pre> | no |
| <a name="input_agents_md"></a> [agents\_md](#input\_agents\_md) | (Optional) Agent instructions (AGENTS.md, Markdown without frontmatter) injected into every session. Key is the agent type (GENERIC applies to all agents; at most one per agent type), value is the AGENTS.md content. | `map(string)` | `{}` | no |
| <a name="input_aws_iam_role_agent_space"></a> [aws\_iam\_role\_agent\_space](#input\_aws\_iam\_role\_agent\_space) | (Required) IAM role assumed by the Agent Space (AIDevOpsAgentAccessPolicy). | <pre>object({<br/>    # (Optional) Description of the IAM role.<br/>    description = optional(string, "IAM role assumed by AWS DevOps Agent to investigate the account.")<br/>    # (Required) Name of the IAM role.<br/>    name = string<br/>    # (Optional) Path to the role.<br/>    path = optional(string, "/")<br/>  })</pre> | n/a | yes |
| <a name="input_aws_iam_role_operator_app"></a> [aws\_iam\_role\_operator\_app](#input\_aws\_iam\_role\_operator\_app) | (Required) IAM role for the operator web app (AIDevOpsOperatorAppAccessPolicy). | <pre>object({<br/>    # (Optional) Description of the IAM role.<br/>    description = optional(string, "IAM role for AWS DevOps Agent operator web app.")<br/>    # (Required) Name of the IAM role.<br/>    name = string<br/>    # (Optional) Path to the role.<br/>    path = optional(string, "/")<br/>  })</pre> | n/a | yes |
| <a name="input_custom_agents"></a> [custom\_agents](#input\_custom\_agents) | (Optional) Custom agents to create in the Agent Space, with optional scheduled triggers. | <pre>map(object({<br/>    # (Required) Custom agent name: lowercase letters, numbers and hyphens (1-64 characters).<br/>    name = string<br/>    # (Optional) Keys of var.skills to attach.<br/>    skills = optional(list(string), [])<br/>    # (Required) System prompt (AGENT.md content, Markdown, 10-50,000 characters).<br/>    system_prompt = string<br/>    # (Optional) MCP tool identifiers the agent can use (e.g. use_aws, query_cloudwatch_logs).<br/>    tools = optional(list(string), [])<br/>    # (Optional) Scheduled triggers. Key is an arbitrary stable identifier.<br/>    triggers = optional(map(object({<br/>      # (Required) EventBridge-compatible cron or rate expression (UTC). e.g. cron(0 0 ? * MON-FRI *), rate(1 day)<br/>      schedule_expression = string<br/>      # (Optional) Active or Inactive.<br/>      status = optional(string, "Active")<br/>    })), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_github_repositories"></a> [github\_repositories](#input\_github\_repositories) | (Optional) GitHub repositories to associate with the Agent Space. Key is an arbitrary stable identifier. GitHub must be registered at the account level in the console beforehand. | <pre>map(object({<br/>    # (Required) Service ID of the GitHub registration that can access the repository (account-level, registered in<br/>    # the console). One registration exists per GitHub user, organization, or GitHub Enterprise Server instance.<br/>    # ex) aws devops-agent list-services --region <region> --filter-service-type github<br/>    service_id = string<br/>    # (Required) Repository owner (user or organization name).<br/>    owner = string<br/>    # (Optional) Owner type: organization or user.<br/>    owner_type = optional(string, "organization")<br/>    # (Required) Numeric GitHub repository ID.<br/>    # ex) gh api repos/<owner>/<repo> --jq .id<br/>    repo_id = string<br/>    # (Required) Repository name.<br/>    repo_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_iam_propagation_wait"></a> [iam\_propagation\_wait](#input\_iam\_propagation\_wait) | (Optional) Wait duration after IAM role creation before creating the Agent Space (the service validates role trust policies on create). | `string` | `"30s"` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) Whether to create AWS DevOps Agent resources. | `bool` | `true` | no |
| <a name="input_mcp_servers"></a> [mcp\_servers](#input\_mcp\_servers) | (Optional) MCP servers to associate with the Agent Space (tool allowlist). Key is an arbitrary stable identifier. The MCP server must be registered at the account level beforehand. | <pre>map(object({<br/>    # (Optional) Description of the MCP server.<br/>    description = optional(string)<br/>    # (Required) MCP server endpoint (HTTPS URL).<br/>    endpoint = string<br/>    # (Required) MCP server name (letters, numbers, hyphens and underscores).<br/>    name = string<br/>    # (Required) Service ID returned by `aws devops-agent register-service --service mcpserver` (account-level).<br/>    # The credential (API key / PAT) is passed to the CLI and never enters the Terraform state.<br/>    service_id = string<br/>    # (Optional) Service type the MCP server was registered with: mcpserver (API key / OAuth) or mcpserversigv4 (SigV4).<br/>    # Must match the registration, otherwise the association fails with "Service type does match the registered service".<br/>    service_type = optional(string, "mcpserver")<br/>    # (Required) Allowlist of MCP tool names the Agent Space can use. Unlisted tools are invisible to the agent.<br/>    tools = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) Region where the Agent Space is created. Must be a supported AWS DevOps Agent region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_secondary_accounts"></a> [secondary\_accounts](#input\_secondary\_accounts) | (Optional) Secondary (source) accounts the Agent Space investigates, keyed by an identifier. The role must already exist in each account. | <pre>map(object({<br/>    # (Required) 12-digit AWS account ID of the secondary (source) account.<br/>    account_id = string<br/>    # (Required) Name of the cross-account role in the secondary account (created by modules/aws/devops_agent_secondary).<br/>    role_name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_skills"></a> [skills](#input\_skills) | (Optional) Skills to create in the Agent Space. Key is an arbitrary stable identifier referenced by custom\_agents[*].skills. | <pre>map(object({<br/>    # (Optional) Agent types the skill applies to. GENERIC cannot be combined with other values.<br/>    agent_types = optional(list(string), ["GENERIC"])<br/>    # (Required) SKILL.md content.<br/>    content = string<br/>    # (Required) When the agent should use the skill (1-1024 characters).<br/>    description = string<br/>    # (Optional) Additional text files, keyed by path relative to the skill root (references/<file> or assets/<file>), with the file content as the value.<br/>    files = optional(map(string), {})<br/>    # (Required) Skill name: lowercase letters, numbers and hyphens (1-64 characters).<br/>    name = string<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `{}` | no |
| <a name="input_webhook"></a> [webhook](#input\_webhook) | (Optional) Generic webhook for the Agent Space. The event channel service is registered and the association is created with the AWS CLI (terraform\_data); the webhook credentials are written directly to a Secrets Manager secret and never enter the Terraform state. aws CLI and jq are required where Terraform runs. | <pre>object({<br/>    # (Optional) Display name of the event channel (webhook) service registration (account-level).<br/>    # Terraform registers it on create and deregisters it on destroy; only the registration with this name is managed.<br/>    service_name = optional(string, "devops-agent-webhook")<br/>    # (Required) Secrets Manager secret that receives the webhook credentials (written via the AWS CLI, not Terraform).<br/>    secret = object({<br/>      # (Optional) KMS key ARN/ID to encrypt the secret. null uses the AWS managed key (aws/secretsmanager).<br/>      kms_key_id = optional(string)<br/>      # (Required) Secret name, slash-separated (e.g. base/devops-agent/webhook).<br/>      name = string<br/>      # (Optional) Days before the secret is deleted after destroy (0 deletes immediately, or 7-30).<br/>      recovery_window_in_days = optional(number, 7)<br/>    })<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_agent_space_arn"></a> [agent\_space\_arn](#output\_agent\_space\_arn) | ARN of the Agent Space. |
| <a name="output_agent_space_id"></a> [agent\_space\_id](#output\_agent\_space\_id) | ID of the Agent Space. |
| <a name="output_agent_space_role_arn"></a> [agent\_space\_role\_arn](#output\_agent\_space\_role\_arn) | ARN of the IAM role assumed by the Agent Space. |
| <a name="output_agents_md_asset_ids"></a> [agents\_md\_asset\_ids](#output\_agents\_md\_asset\_ids) | Map of agent type to AGENTS.md asset ID. |
| <a name="output_custom_agent_asset_ids"></a> [custom\_agent\_asset\_ids](#output\_custom\_agent\_asset\_ids) | Map of custom agent key to asset ID. |
| <a name="output_github_association_ids"></a> [github\_association\_ids](#output\_github\_association\_ids) | Map of GitHub repository key to association ID. |
| <a name="output_mcp_server_association_ids"></a> [mcp\_server\_association\_ids](#output\_mcp\_server\_association\_ids) | Map of MCP server key to association ID. |
| <a name="output_monitor_association_id"></a> [monitor\_association\_id](#output\_monitor\_association\_id) | Association ID of the monitor account. |
| <a name="output_operator_app_role_arn"></a> [operator\_app\_role\_arn](#output\_operator\_app\_role\_arn) | ARN of the IAM role for the operator web app. |
| <a name="output_secondary_association_ids"></a> [secondary\_association\_ids](#output\_secondary\_association\_ids) | Map of secondary account key to association ID. |
| <a name="output_skill_asset_ids"></a> [skill\_asset\_ids](#output\_skill\_asset\_ids) | Map of skill key to asset ID. |
| <a name="output_trigger_ids"></a> [trigger\_ids](#output\_trigger\_ids) | Map of <custom agent key>.<trigger key> to trigger ID. |
| <a name="output_webhook_association_id"></a> [webhook\_association\_id](#output\_webhook\_association\_id) | Association ID of the generic webhook (event channel). |
| <a name="output_webhook_secret_arn"></a> [webhook\_secret\_arn](#output\_webhook\_secret\_arn) | ARN of the Secrets Manager secret holding the webhook credentials (JSON: webhook\_id, webhook\_secret, webhook\_type, webhook\_url). The secret value itself is never output. |
| <a name="output_webhook_service_id"></a> [webhook\_service\_id](#output\_webhook\_service\_id) | Service ID of the event channel (webhook) registration. |
| <a name="output_webhook_type"></a> [webhook\_type](#output\_webhook\_type) | Authentication type of the generic webhook (hmac or apikey). |
| <a name="output_webhook_url"></a> [webhook\_url](#output\_webhook\_url) | URL of the generic webhook. The secret is stored in the Secrets Manager secret (webhook\_secret\_arn). |
<!-- END_TF_DOCS -->