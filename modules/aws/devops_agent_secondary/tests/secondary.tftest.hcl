mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

variables {
  account_id = "222222222222"
  primary = {
    account_id      = "444444444444"
    agent_space_arn = "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/abc123"
  }
  aws_iam_role = {
    name = "DevOpsAgentRole-SecondaryAccount"
  }
}

run "trust_pinned_to_primary_agent_space" {
  command = plan

  assert {
    condition     = jsondecode(aws_iam_role.this[0].assume_role_policy).Statement[0].Principal.Service == "aidevops.amazonaws.com"
    error_message = "trust principal must be aidevops.amazonaws.com"
  }
  assert {
    condition     = jsondecode(aws_iam_role.this[0].assume_role_policy).Statement[0].Condition.StringEquals["aws:SourceAccount"] == "444444444444"
    error_message = "aws:SourceAccount must be the primary account"
  }
  assert {
    condition     = jsondecode(aws_iam_role.this[0].assume_role_policy).Statement[0].Condition.ArnLike["aws:SourceArn"] == "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/abc123"
    error_message = "aws:SourceArn must be the exact primary Agent Space ARN (no wildcard)"
  }
}

run "attaches_access_policy" {
  command = plan

  assert {
    condition     = aws_iam_role_policy_attachment.access[0].policy_arn == "arn:aws:iam::aws:policy/AIDevOpsAgentAccessPolicy"
    error_message = "AIDevOpsAgentAccessPolicy must be attached"
  }
}

run "disabled_creates_nothing" {
  command = plan
  variables {
    is_enabled = false
  }

  assert {
    condition     = length(aws_iam_role.this) == 0
    error_message = "is_enabled = false must create no role"
  }
}

run "rejects_wildcard_agent_space_arn" {
  command = plan
  variables {
    primary = {
      account_id      = "444444444444"
      agent_space_arn = "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/*"
    }
  }

  expect_failures = [var.primary]
}

run "no_additional_policy_by_default" {
  command = plan

  assert {
    condition     = length(aws_iam_policy.additional) == 0 && length(aws_iam_role_policy_attachment.additional) == 0
    error_message = "no additional policy must be created when additional_policy_statements is empty"
  }
}

run "attaches_additional_policy_statements" {
  command = plan
  variables {
    additional_policy_statements = [
      {
        actions   = ["glue:GetConnection", "glue:GetTriggers"]
        resources = ["*"]
        sid       = "AllowReadGlue"
      },
    ]
  }

  assert {
    condition     = aws_iam_policy.additional[0].name == "Additional-DevOpsAgentRole-SecondaryAccount"
    error_message = "additional policy must be named Additional-<role name>"
  }
  assert {
    condition     = length(aws_iam_role_policy_attachment.additional) == 1
    error_message = "additional policy must be attached to the role"
  }
}

run "rejects_non_alphanumeric_sid" {
  command = plan
  variables {
    additional_policy_statements = [
      {
        actions   = ["glue:GetConnection"]
        resources = ["*"]
        sid       = "Allow-Read"
      },
    ]
  }

  expect_failures = [var.additional_policy_statements]
}
