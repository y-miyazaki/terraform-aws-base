mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}
mock_provider "awscc" {}
mock_provider "time" {}
mock_provider "external" {}

variables {
  account_id = "444444444444"
  region     = "ap-northeast-1"
  agent_space = {
    name = "devops-agent"
  }
  aws_iam_role_agent_space = {
    name = "devops-agent-agent-space-role"
  }
  aws_iam_role_operator_app = {
    name = "devops-agent-operator-app-role"
  }
  secondary_accounts = {
    dev = { account_id = "111111111111", role_name = "DevOpsAgentRole-SecondaryAccount" }
    qa  = { account_id = "222222222222", role_name = "DevOpsAgentRole-SecondaryAccount" }
  }
}

run "creates_one_source_association_per_secondary" {
  command = plan

  assert {
    condition     = length(awscc_devopsagent_association.aws_source) == 2
    error_message = "one source association per secondary account"
  }
  assert {
    condition     = awscc_devopsagent_association.aws_source["dev"].configuration.source_aws.assumable_role_arn == "arn:aws:iam::111111111111:role/DevOpsAgentRole-SecondaryAccount"
    error_message = "assumable_role_arn must be built from account_id and role_name"
  }
  assert {
    condition     = awscc_devopsagent_association.aws_source["dev"].configuration.source_aws.account_type == "source"
    error_message = "account_type must be source"
  }
  assert {
    condition     = awscc_devopsagent_association.aws_source["dev"].service_id == "aws"
    error_message = "service_id must be aws"
  }
}

run "disabled_creates_no_source_association" {
  command = plan
  variables {
    is_enabled = false
  }

  assert {
    condition     = length(awscc_devopsagent_association.aws_source) == 0
    error_message = "is_enabled = false must create no association"
  }
}

run "rejects_malformed_account_id" {
  command = plan
  variables {
    secondary_accounts = {
      dev = { account_id = "1234", role_name = "DevOpsAgentRole-SecondaryAccount" }
    }
  }

  expect_failures = [var.secondary_accounts]
}
