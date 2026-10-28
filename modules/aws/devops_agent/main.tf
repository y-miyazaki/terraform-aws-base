#--------------------------------------------------------------
# Module: aws/devops_agent
# Purpose: Create AWS DevOps Agent Space with IAM roles, operator web app, optional encryption with a caller-provided KMS key,
#          monitor account association, GitHub repository associations, agent instructions (AGENTS.md), and skills/memory stores/custom agents/scheduled triggers.
# Notes: When agent_space.kms_key_arn is set, the key policy must grant aidevops.amazonaws.com access
#        (managed by the caller).
#        https://docs.aws.amazon.com/devopsagent/latest/userguide/aws-devops-agent-security-encryption-at-rest-for-devops-agent.html
#        GitHub must be registered at the account level in the console (GitHub App OAuth flow) before
#        repository associations can be created; this cannot be automated by Terraform.
#        https://docs.aws.amazon.com/devopsagent/latest/userguide/connecting-to-cicd-pipelines-connecting-github.html
#        Generic webhook (optional, var.webhook):
#        - The event channel service cannot be registered by CloudFormation/awscc; it is registered/deregistered with
#          the AWS CLI (terraform_data.event_channel_service).
#        - The webhook secret is returned only once, by AssociateService. awscc (Cloud Control) discards it, so the
#          association is created with the AWS CLI (terraform_data.webhook_association) and the credentials are
#          written directly to AWS Secrets Manager (aws_secretsmanager_secret.webhook). The secret value never enters
#          the Terraform state or outputs; only the secret ARN is output. Terraform does not manage the secret version.
#        - aws CLI, jq and aidevops:RegisterService/DeregisterService/ListServices/AssociateService/DisassociateService/
#          ListAssociations/ListWebhooks, secretsmanager:PutSecretValue (and kms:GenerateDataKey on the secret key)
#          are required where Terraform runs.
#        https://docs.aws.amazon.com/devopsagent/latest/userguide/configuring-integrations-and-knowledge-invoking-devops-agent-through-webhook.html
#--------------------------------------------------------------
data "aws_region" "current" {}

locals {
  agent_space_policy_statements = concat(var.agent_space_default_policy_statements, var.agent_space_additional_policy_statements)
  region                        = coalesce(var.region, data.aws_region.current.region)
  # Trust policy for roles assumed by the AWS DevOps Agent service.
  assume_role_condition = {
    ArnLike = {
      "aws:SourceArn" = "arn:aws:aidevops:${local.region}:${var.account_id}:agentspace/*"
    }
    StringEquals = {
      "aws:SourceAccount" = var.account_id
    }
  }
  agents_md = var.is_enabled ? var.agents_md : {}
  # awscc resources do not inherit provider default_tags.
  awscc_tags          = [for k, v in var.tags : { key = k, value = tostring(v) }]
  custom_agents       = var.is_enabled ? var.custom_agents : {}
  github_repositories = var.is_enabled ? var.github_repositories : {}
  is_webhook_enabled  = var.is_enabled && var.webhook != null
  memory_stores       = var.is_enabled ? var.memory_stores : {}
  skills              = var.is_enabled ? var.skills : {}
  triggers = merge([
    for agent_key, agent in local.custom_agents : {
      for trigger_key, trigger in agent.triggers : "${agent_key}.${trigger_key}" => merge(trigger, {
        agent_key = agent_key
      })
    }
  ]...)
}

#--------------------------------------------------------------
# IAM role for Agent Space
#--------------------------------------------------------------
resource "aws_iam_role" "agent_space" {
  count = var.is_enabled ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Condition = local.assume_role_condition
        Effect    = "Allow"
        Principal = {
          Service = "aidevops.amazonaws.com"
        }
      }
    ]
  })
  description           = var.aws_iam_role_agent_space.description
  force_detach_policies = true
  name                  = var.aws_iam_role_agent_space.name
  path                  = var.aws_iam_role_agent_space.path
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "agent_space" {
  count = var.is_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsAgentAccessPolicy"
  role       = aws_iam_role.agent_space[0].name
}

data "aws_iam_policy_document" "agent_space_service_linked_role" {
  count = var.is_enabled ? 1 : 0

  statement {
    sid       = "AllowCreateResourceExplorerServiceLinkedRole"
    effect    = "Allow"
    actions   = ["iam:CreateServiceLinkedRole"] # nosemgrep: terraform.lang.security.iam.no-iam-resource-exposure.no-iam-resource-exposure -- scoped to the single Resource Explorer service-linked role ARN
    resources = ["arn:aws:iam::${var.account_id}:role/aws-service-role/resource-explorer-2.amazonaws.com/AWSServiceRoleForResourceExplorer"]
  }
}

resource "aws_iam_policy" "agent_space_service_linked_role" {
  count = var.is_enabled ? 1 : 0

  name   = "AllowCreateServiceLinkedRoles-${var.aws_iam_role_agent_space.name}"
  policy = data.aws_iam_policy_document.agent_space_service_linked_role[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "agent_space_service_linked_role" {
  count = var.is_enabled ? 1 : 0

  policy_arn = aws_iam_policy.agent_space_service_linked_role[0].arn
  role       = aws_iam_role.agent_space[0].name
}

data "aws_iam_policy_document" "agent_space_additional" {
  count = var.is_enabled && length(local.agent_space_policy_statements) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = local.agent_space_policy_statements

    content {
      actions   = statement.value.actions
      effect    = statement.value.effect
      resources = statement.value.resources
      sid       = statement.value.sid
    }
  }
}

resource "aws_iam_policy" "agent_space_additional" {
  count = var.is_enabled && length(local.agent_space_policy_statements) > 0 ? 1 : 0

  name   = "Additional-${var.aws_iam_role_agent_space.name}"
  policy = data.aws_iam_policy_document.agent_space_additional[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "agent_space_additional" {
  count = var.is_enabled && length(local.agent_space_policy_statements) > 0 ? 1 : 0

  policy_arn = aws_iam_policy.agent_space_additional[0].arn
  role       = aws_iam_role.agent_space[0].name
}

#--------------------------------------------------------------
# IAM role for operator web app
#--------------------------------------------------------------
resource "aws_iam_role" "operator_app" {
  count = var.is_enabled ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
        Condition = local.assume_role_condition
        Effect    = "Allow"
        Principal = {
          Service = "aidevops.amazonaws.com"
        }
      }
    ]
  })
  description           = var.aws_iam_role_operator_app.description
  force_detach_policies = true
  name                  = var.aws_iam_role_operator_app.name
  path                  = var.aws_iam_role_operator_app.path
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "operator_app" {
  count = var.is_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsOperatorAppAccessPolicy"
  role       = aws_iam_role.operator_app[0].name
}

# Synchronous operations from the operator web app run with this role and need access to the Agent Space CMK.
# The key policy delegates caller access to IAM (enable_default_policy); restrict use to the DevOps Agent service.
data "aws_iam_policy_document" "operator_app_kms" {
  count = var.is_enabled && var.agent_space.is_kms_enabled ? 1 : 0

  statement {
    sid    = "AllowAgentSpaceKmsKeyAccessViaDevOpsAgent"
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*",
    ]
    resources = [var.agent_space.kms_key_arn]

    condition {
      test     = "StringEquals"
      variable = "kms:ViaService"
      values   = ["aidevops.${local.region}.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "operator_app_kms" {
  count = var.is_enabled && var.agent_space.is_kms_enabled ? 1 : 0

  name   = "AllowAgentSpaceKmsKeyAccess-${var.aws_iam_role_operator_app.name}"
  policy = data.aws_iam_policy_document.operator_app_kms[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "operator_app_kms" {
  count = var.is_enabled && var.agent_space.is_kms_enabled ? 1 : 0

  policy_arn = aws_iam_policy.operator_app_kms[0].arn
  role       = aws_iam_role.operator_app[0].name
}

#--------------------------------------------------------------
# Wait for IAM propagation (the service validates trust policies on Agent Space creation)
#--------------------------------------------------------------
resource "time_sleep" "iam_propagation" {
  count = var.is_enabled ? 1 : 0

  create_duration = var.iam_propagation_wait

  depends_on = [
    aws_iam_role_policy_attachment.agent_space,
    aws_iam_role_policy_attachment.agent_space_additional,
    aws_iam_role_policy_attachment.agent_space_service_linked_role,
    aws_iam_role_policy_attachment.operator_app_kms,
    aws_iam_role_policy_attachment.operator_app,
  ]
}

#--------------------------------------------------------------
# Agent Space
#--------------------------------------------------------------
resource "awscc_devopsagent_agent_space" "this" {
  count = var.is_enabled ? 1 : 0

  description = var.agent_space.description
  kms_key_arn = var.agent_space.kms_key_arn
  locale      = var.agent_space.locale
  name        = var.agent_space.name
  operator_app = {
    iam = {
      operator_app_role_arn = aws_iam_role.operator_app[0].arn
    }
  }
  preferences = {
    elevated_actions_enabled = var.agent_space.elevated_actions_enabled
  }
  tags = local.awscc_tags

  depends_on = [time_sleep.iam_propagation]
}

#--------------------------------------------------------------
# Association: monitor account (the account hosting the Agent Space)
#--------------------------------------------------------------
resource "awscc_devopsagent_association" "aws_monitor" {
  count = var.is_enabled ? 1 : 0

  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  configuration = {
    aws = {
      account_id         = var.account_id
      account_type       = "monitor"
      assumable_role_arn = aws_iam_role.agent_space[0].arn
    }
  }
  service_id = "aws"
}

#--------------------------------------------------------------
# Association: secondary (source) accounts
# The cross-account role in each account must exist before the association is created.
#--------------------------------------------------------------
resource "awscc_devopsagent_association" "aws_source" {
  for_each = var.is_enabled ? var.secondary_accounts : {}

  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  configuration = {
    source_aws = {
      account_id         = each.value.account_id
      account_type       = "source"
      assumable_role_arn = "arn:aws:iam::${each.value.account_id}:role/${each.value.role_name}"
    }
  }
  service_id = "aws"
}

#--------------------------------------------------------------
# Association: GitHub repositories
#--------------------------------------------------------------
resource "awscc_devopsagent_association" "github" {
  for_each = local.github_repositories

  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  configuration = {
    git_hub = {
      owner      = each.value.owner
      owner_type = each.value.owner_type
      repo_id    = each.value.repo_id
      repo_name  = each.value.repo_name
    }
  }
  service_id = each.value.service_id
}

#--------------------------------------------------------------
# Association: MCP servers (tool allowlist)
# The MCP server itself is registered at the account level with the AWS CLI (credentials never enter the state).
#--------------------------------------------------------------
resource "awscc_devopsagent_association" "mcp_server" {
  for_each = var.is_enabled ? var.mcp_servers : {}

  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  configuration = {
    # The configuration type must match the type the service was registered with (mcpserver / mcpserversigv4).
    mcp_server = each.value.service_type == "mcpserver" ? {
      description = each.value.description
      endpoint    = each.value.endpoint
      name        = each.value.name
      tools       = each.value.tools
    } : null
    mcp_server_sig_v4 = each.value.service_type == "mcpserversigv4" ? {
      tools = each.value.tools
    } : null
  }
  service_id = each.value.service_id
}

#--------------------------------------------------------------
# Assets: skills
# https://docs.aws.amazon.com/devopsagent/latest/userguide/about-aws-devops-agent-managing-assets.html
#--------------------------------------------------------------
resource "awscc_devopsagent_asset" "skill" {
  for_each = local.skills

  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  asset_type     = "skill"
  files = concat(
    [
      {
        content_text = each.value.content
        path         = "SKILL.md"
      }
    ],
    [for path in sort(keys(each.value.files)) : { content_text = each.value.files[path], path = path }]
  )
  # status and skill_type are set by the service and returned in the metadata; sending the same values avoids a perpetual plan difference.
  metadata = jsonencode({
    agent_types = each.value.agent_types
    description = each.value.description
    name        = each.value.name
    skill_type  = "USER"
    status      = "ACTIVE"
  })
}

#--------------------------------------------------------------
# Assets: agent instructions (AGENTS.md), injected into every session of the agent type
# https://docs.aws.amazon.com/devopsagent/latest/userguide/about-aws-devops-agent-agent-instructions.html
#--------------------------------------------------------------
resource "awscc_devopsagent_asset" "agents_md" {
  for_each = local.agents_md

  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  asset_type     = "agents_md"
  files = [
    {
      content_text = each.value
      path         = "AGENTS.md"
    }
  ]
  # status is set by the service and returned in the metadata; sending the same value avoids a perpetual plan difference.
  metadata = jsonencode({
    agent_type = each.key
    status     = "ACTIVE"
  })
}

#--------------------------------------------------------------
# Assets: custom memory stores (custom agents can write only to attached custom stores)
# https://docs.aws.amazon.com/devopsagent/latest/userguide/about-aws-devops-agent-devops-agent-memories.html
#--------------------------------------------------------------
resource "awscc_devopsagent_asset" "memory_store" {
  for_each = local.memory_stores

  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  asset_type     = "memory_store"
  # Cloud Control requires exactly one of files or zip on create. Managed stores hold a single <name>.md with a "# <name>" heading; follow that.
  files = [
    {
      content_text = "# ${each.value.name}\n"
      path         = "${each.value.name}.md"
    }
  ]
  # status is set by the service and returned in the metadata; sending the same value avoids a perpetual plan difference.
  metadata = jsonencode({
    agent_types = each.value.agent_types
    description = each.value.description
    name        = each.value.name
    status      = "ACTIVE"
  })
}

#--------------------------------------------------------------
# Assets: custom agents
#--------------------------------------------------------------
resource "awscc_devopsagent_asset" "custom_agent" {
  for_each = local.custom_agents

  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  asset_type     = "custom_agent"
  files = [
    {
      content_text = each.value.system_prompt
      path         = "AGENT.md"
    }
  ]
  # status is set by the service and returned in the metadata; sending the same value avoids a perpetual plan difference.
  metadata = jsonencode({
    memory_stores = [for k in each.value.memory_stores : awscc_devopsagent_asset.memory_store[k].asset_id]
    name          = each.value.name
    skills        = [for k in each.value.skills : awscc_devopsagent_asset.skill[k].asset_id]
    status        = "ACTIVE"
    tools         = each.value.tools
  })
}

#--------------------------------------------------------------
# Triggers: run custom agents on a schedule (only TIME_BASED is supported)
# https://docs.aws.amazon.com/AWSCloudFormation/latest/TemplateReference/aws-resource-devopsagent-trigger.html
#--------------------------------------------------------------
resource "awscc_devopsagent_trigger" "this" {
  for_each = local.triggers

  action = jsonencode({
    actionType = "create:task"
    task = {
      agent = "custom:${awscc_devopsagent_asset.custom_agent[each.value.agent_key].asset_id}"
    }
  })
  agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
  condition = {
    schedule = {
      expression = each.value.schedule_expression
    }
  }
  status = each.value.status
  type   = "TIME_BASED"
}

#--------------------------------------------------------------
# Event channel (webhook) service registration (account-level)
# CloudFormation/awscc cannot register eventChannel, so register/deregister it with the AWS CLI.
# On destroy the association is removed first (implicit dependency), then the registration is deregistered.
#--------------------------------------------------------------
resource "terraform_data" "event_channel_service" {
  count = local.is_webhook_enabled ? 1 : 0

  input = {
    name   = var.webhook.service_name
    region = local.region
    script = "${path.module}/scripts/event_channel_service.sh"
  }
  triggers_replace = [var.webhook.service_name, local.region]

  provisioner "local-exec" {
    command = "bash \"$SCRIPT\" register \"$NAME\" \"$REGION\""
    environment = {
      NAME   = self.input.name
      REGION = self.input.region
      SCRIPT = self.input.script
    }
  }

  provisioner "local-exec" {
    command = "bash \"$SCRIPT\" deregister \"$NAME\" \"$REGION\""
    environment = {
      NAME   = self.input.name
      REGION = self.input.region
      SCRIPT = self.input.script
    }
    when = destroy
  }
}

data "external" "event_channel_service" {
  count = local.is_webhook_enabled ? 1 : 0

  program = [
    "bash",
    "${path.module}/scripts/event_channel_service.sh",
    "get",
    terraform_data.event_channel_service[0].output.name,
    local.region,
  ]
}

#--------------------------------------------------------------
# Secret for the webhook credentials
# The value is written by terraform_data.webhook_association (AWS CLI), not by Terraform, so it never enters the state.
# Secret value (JSON): {"webhook_id", "webhook_secret" (HMAC signing secret or API key), "webhook_type", "webhook_url"}
#--------------------------------------------------------------
resource "aws_secretsmanager_secret" "webhook" {
  count = local.is_webhook_enabled ? 1 : 0

  region                  = local.region
  description             = "AWS DevOps Agent generic webhook credentials for ${var.agent_space.name} (written by Terraform via the AWS CLI)."
  kms_key_id              = var.webhook.secret.kms_key_id
  name                    = var.webhook.secret.name
  recovery_window_in_days = var.webhook.secret.recovery_window_in_days
  tags = merge(var.tags, {
    Name = var.webhook.secret.name
  })
}

#--------------------------------------------------------------
# Association: generic webhook (event channel)
# Created with the AWS CLI because AssociateService returns the webhook secret only once and awscc discards it.
# Any change of the inputs recreates the association: the webhook URL and secret change, and the new credentials
# are written to the secret as a new version.
#--------------------------------------------------------------
resource "terraform_data" "webhook_association" {
  count = local.is_webhook_enabled ? 1 : 0

  input = {
    agent_space_id = awscc_devopsagent_agent_space.this[0].agent_space_id
    region         = local.region
    script         = "${path.module}/scripts/webhook_association.sh"
    secret_arn     = aws_secretsmanager_secret.webhook[0].arn
    service_id     = data.external.event_channel_service[0].result.service_id
  }
  triggers_replace = [
    awscc_devopsagent_agent_space.this[0].agent_space_id,
    aws_secretsmanager_secret.webhook[0].arn,
    data.external.event_channel_service[0].result.service_id,
  ]

  provisioner "local-exec" {
    command = "bash \"$SCRIPT\" create \"$AGENT_SPACE_ID\" \"$SERVICE_ID\" \"$SECRET_ARN\" \"$REGION\""
    environment = {
      AGENT_SPACE_ID = self.input.agent_space_id
      REGION         = self.input.region
      SCRIPT         = self.input.script
      SECRET_ARN     = self.input.secret_arn
      SERVICE_ID     = self.input.service_id
    }
  }

  provisioner "local-exec" {
    command = "bash \"$SCRIPT\" delete \"$AGENT_SPACE_ID\" \"$SERVICE_ID\" \"$REGION\""
    environment = {
      AGENT_SPACE_ID = self.input.agent_space_id
      REGION         = self.input.region
      SCRIPT         = self.input.script
      SERVICE_ID     = self.input.service_id
    }
    when = destroy
  }

  # Destroy the association before deregistering the event channel service (the dependency through
  # data.external.event_channel_service is not used for destroy ordering).
  depends_on = [terraform_data.event_channel_service]
}

# Association ID and webhook URL (ListAssociations/ListWebhooks); the secret is not returned by these APIs.
data "external" "webhook" {
  count = local.is_webhook_enabled ? 1 : 0

  program = [
    "bash",
    "${path.module}/scripts/webhook_association.sh",
    "get",
    terraform_data.webhook_association[0].output.agent_space_id,
    terraform_data.webhook_association[0].output.service_id,
    local.region,
  ]
}
