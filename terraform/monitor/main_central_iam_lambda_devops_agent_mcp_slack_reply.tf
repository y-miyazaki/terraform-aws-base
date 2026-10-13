#--------------------------------------------------------------
# Create role and policy for DevOps Agent MCP Slack Reply
# Invoked by DevOps Agent (SigV4); separate from the Agent Space roles
#--------------------------------------------------------------
data "aws_iam_policy_document" "devops_agent_mcp_slack_reply_assume_role" {
  count = local.devops_agent_mcp_slack_reply_enabled ? 1 : 0

  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "aws:SourceAccount"
      values   = [data.aws_caller_identity.current.account_id]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["arn:aws:aidevops:${var.region.primary}:${data.aws_caller_identity.current.account_id}:service/*"]
    }

    principals {
      identifiers = ["aidevops.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "devops_agent_mcp_slack_reply_invoke" {
  count = local.devops_agent_mcp_slack_reply_enabled ? 1 : 0

  statement {
    actions   = ["lambda:InvokeFunctionUrl"]
    effect    = "Allow"
    resources = [module.aws_lambda_devops_agent_mcp_slack_reply.lambda_function_arn]

    condition {
      test     = "StringEquals"
      variable = "lambda:FunctionUrlAuthType"
      values   = ["AWS_IAM"]
    }
  }
  statement {
    actions   = ["lambda:InvokeFunction"]
    effect    = "Allow"
    resources = [module.aws_lambda_devops_agent_mcp_slack_reply.lambda_function_arn]
  }
}

resource "aws_iam_role" "devops_agent_mcp_slack_reply" {
  count = local.devops_agent_mcp_slack_reply_enabled ? 1 : 0

  assume_role_policy    = data.aws_iam_policy_document.devops_agent_mcp_slack_reply_assume_role[0].json
  description           = "IAM role for AWS DevOps Agent to sign requests (SigV4) to the Slack reply MCP function URL."
  force_detach_policies = true
  name                  = "${local.devops_agent_mcp_slack_reply_name}-role"

  tags = merge(var.tags, {
    Name = "${local.devops_agent_mcp_slack_reply_name}-role"
  })
}

resource "aws_iam_role_policy" "devops_agent_mcp_slack_reply_invoke" {
  count = local.devops_agent_mcp_slack_reply_enabled ? 1 : 0

  name   = "invoke-mcp-slack-reply"
  policy = data.aws_iam_policy_document.devops_agent_mcp_slack_reply_invoke[0].json
  role   = aws_iam_role.devops_agent_mcp_slack_reply[0].id
}

output "devops_agent_mcp_slack_reply_role_arn" {
  description = "ARN of the IAM role AWS DevOps Agent assumes to sign requests to the Slack reply MCP function URL."
  value       = try(aws_iam_role.devops_agent_mcp_slack_reply[0].arn, null)
}
