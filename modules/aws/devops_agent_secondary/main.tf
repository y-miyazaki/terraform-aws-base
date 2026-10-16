#--------------------------------------------------------------
# Module: aws/devops_agent_secondary
# Purpose: Cross-account IAM role in a secondary (source) account that the AWS DevOps Agent Space in the primary account assumes.
# Notes: The trust policy is pinned to one Agent Space ARN. Create the Agent Space in the primary account first.
#        https://docs.aws.amazon.com/devopsagent/latest/userguide/getting-started-with-aws-devops-agent-getting-started-with-aws-devops-agent-using-terraform.html
#--------------------------------------------------------------
locals {
  policy_statements = concat(var.default_policy_statements, var.additional_policy_statements)
}

data "aws_iam_policy_document" "service_linked_role" {
  statement {
    actions   = ["iam:CreateServiceLinkedRole"] # nosemgrep: terraform.lang.security.iam.no-iam-resource-exposure.no-iam-resource-exposure -- scoped to the single Resource Explorer service-linked role ARN
    resources = ["arn:aws:iam::${var.account_id}:role/aws-service-role/resource-explorer-2.amazonaws.com/AWSServiceRoleForResourceExplorer"]
    sid       = "AllowCreateResourceExplorerServiceLinkedRole"
  }
}

resource "aws_iam_role" "this" {
  count = var.is_enabled ? 1 : 0

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = var.primary.agent_space_arn
          }
          StringEquals = {
            "aws:SourceAccount" = var.primary.account_id
          }
        }
        Effect = "Allow"
        Principal = {
          Service = "aidevops.amazonaws.com"
        }
      }
    ]
  })
  description           = var.aws_iam_role.description
  force_detach_policies = true
  name                  = var.aws_iam_role.name
  path                  = var.aws_iam_role.path
  tags                  = var.tags
}

resource "aws_iam_role_policy_attachment" "access" {
  count = var.is_enabled ? 1 : 0

  policy_arn = "arn:aws:iam::aws:policy/AIDevOpsAgentAccessPolicy"
  role       = aws_iam_role.this[0].name
}

resource "aws_iam_policy" "service_linked_role" {
  count = var.is_enabled ? 1 : 0

  description = "Allow creation of the Resource Explorer service-linked role."
  name        = "${var.aws_iam_role.name}-service-linked-role"
  path        = var.aws_iam_role.path
  policy      = data.aws_iam_policy_document.service_linked_role.json
  tags        = var.tags
}

resource "aws_iam_role_policy_attachment" "service_linked_role" {
  count = var.is_enabled ? 1 : 0

  policy_arn = aws_iam_policy.service_linked_role[0].arn
  role       = aws_iam_role.this[0].name
}

data "aws_iam_policy_document" "additional" {
  count = var.is_enabled && length(local.policy_statements) > 0 ? 1 : 0

  dynamic "statement" {
    for_each = local.policy_statements

    content {
      actions   = statement.value.actions
      effect    = statement.value.effect
      resources = statement.value.resources
      sid       = statement.value.sid
    }
  }
}

resource "aws_iam_policy" "additional" {
  count = var.is_enabled && length(local.policy_statements) > 0 ? 1 : 0

  name   = "Additional-${var.aws_iam_role.name}"
  path   = var.aws_iam_role.path
  policy = data.aws_iam_policy_document.additional[0].json
  tags   = var.tags
}

resource "aws_iam_role_policy_attachment" "additional" {
  count = var.is_enabled && length(local.policy_statements) > 0 ? 1 : 0

  policy_arn = aws_iam_policy.additional[0].arn
  role       = aws_iam_role.this[0].name
}
