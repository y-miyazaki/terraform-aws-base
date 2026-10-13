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
  agents_md = {
    GENERIC = "# Agent Space Instructions\n"
    CHAT    = "# Chat Instructions\n"
  }
}

run "creates_one_asset_per_agent_type" {
  command = plan

  assert {
    condition     = length(awscc_devopsagent_asset.agents_md) == 2
    error_message = "one agents_md asset per agent type"
  }
  assert {
    condition     = awscc_devopsagent_asset.agents_md["GENERIC"].asset_type == "agents_md"
    error_message = "asset_type must be agents_md"
  }
  assert {
    condition     = jsondecode(awscc_devopsagent_asset.agents_md["GENERIC"].metadata).agent_type == "GENERIC"
    error_message = "metadata.agent_type must be the map key"
  }
  assert {
    condition     = awscc_devopsagent_asset.agents_md["GENERIC"].files[0].path == "AGENTS.md"
    error_message = "file path must be AGENTS.md"
  }
  assert {
    condition     = awscc_devopsagent_asset.agents_md["GENERIC"].files[0].content_text == "# Agent Space Instructions\n"
    error_message = "content_text must be the map value"
  }
}

run "disabled_creates_no_agents_md" {
  command = plan
  variables {
    is_enabled = false
  }

  assert {
    condition     = length(awscc_devopsagent_asset.agents_md) == 0
    error_message = "is_enabled = false must create no agents_md asset"
  }
}

run "rejects_unknown_agent_type" {
  command = plan
  variables {
    agents_md = {
      UNKNOWN = "# Instructions\n"
    }
  }

  expect_failures = [var.agents_md]
}

run "rejects_empty_content" {
  command = plan
  variables {
    agents_md = {
      GENERIC = "  \n"
    }
  }

  expect_failures = [var.agents_md]
}

run "rejects_content_over_25kb" {
  command = plan
  variables {
    agents_md = {
      GENERIC = replace(format("%25001s", ""), " ", "a")
    }
  }

  expect_failures = [var.agents_md]
}

run "rejects_multibyte_content_over_25kb" {
  command = plan
  variables {
    agents_md = {
      # 8,334 characters x 3 bytes = 25,002 bytes
      GENERIC = replace(format("%8334s", ""), " ", "あ")
    }
  }

  expect_failures = [var.agents_md]
}

run "accepts_content_of_exactly_25kb" {
  command = plan
  variables {
    agents_md = {
      GENERIC = replace(format("%25000s", ""), " ", "a")
    }
  }

  assert {
    condition     = length(awscc_devopsagent_asset.agents_md) == 1
    error_message = "25,000-byte content must be accepted"
  }
}
