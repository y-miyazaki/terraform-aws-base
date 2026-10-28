mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
  # command = apply validates the ARNs of the mocked resources.
  mock_resource "aws_iam_policy" {
    defaults = {
      arn = "arn:aws:iam::444444444444:policy/mock"
    }
  }
  mock_resource "aws_iam_role" {
    defaults = {
      arn = "arn:aws:iam::444444444444:role/mock"
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
  custom_agents = {
    example = {
      memory_stores = ["example"]
      name          = "example-agent"
      skills        = ["example"]
      system_prompt = "You are an example agent for this AWS account."
      tools         = ["use_aws"]
    }
  }
  memory_stores = {
    example = {
      description = "Example custom memory store."
      name        = "example-store"
    }
  }
  skills = {
    example = {
      content     = "# Example skill\n"
      description = "When the agent should use this skill."
      name        = "example-skill"
    }
  }
}

# AWS DevOps Agent adds status (and skill_type for skills) to the asset metadata. The metadata sent by Terraform includes the same
# values so that the read-back metadata does not show up as a plan difference.
# command = apply (mocked): the custom agent metadata contains the skill asset IDs, which are unknown during plan.
run "metadata_includes_service_managed_fields" {
  command = apply

  assert {
    condition     = jsondecode(awscc_devopsagent_asset.skill["example"].metadata).status == "ACTIVE" && jsondecode(awscc_devopsagent_asset.skill["example"].metadata).skill_type == "USER"
    error_message = "skill metadata must include status = ACTIVE and skill_type = USER"
  }
  assert {
    condition     = jsondecode(awscc_devopsagent_asset.custom_agent["example"].metadata).status == "ACTIVE"
    error_message = "custom agent metadata must include status = ACTIVE"
  }
  assert {
    condition     = jsondecode(awscc_devopsagent_asset.agents_md["GENERIC"].metadata).status == "ACTIVE"
    error_message = "agents_md metadata must include status = ACTIVE"
  }
  assert {
    condition     = jsondecode(awscc_devopsagent_asset.memory_store["example"].metadata).status == "ACTIVE"
    error_message = "memory store metadata must include status = ACTIVE"
  }
}

# Custom agents can write only to the custom stores listed in metadata.memory_stores (asset IDs, not names).
run "custom_agent_attaches_memory_store_ids" {
  command = apply

  assert {
    condition     = jsondecode(awscc_devopsagent_asset.custom_agent["example"].metadata).memory_stores == [awscc_devopsagent_asset.memory_store["example"].asset_id]
    error_message = "custom agent metadata.memory_stores must contain the memory store asset IDs"
  }
  assert {
    condition     = jsondecode(awscc_devopsagent_asset.memory_store["example"].metadata).name == "example-store" && jsondecode(awscc_devopsagent_asset.memory_store["example"].metadata).agent_types == ["GENERIC"]
    error_message = "memory store metadata must keep the name and default agent_types = [GENERIC]"
  }
  # Cloud Control rejects a create without files or zip ("exactly one of Files or Zip must be set on Create").
  assert {
    condition     = length(awscc_devopsagent_asset.memory_store["example"].files) == 1 && awscc_devopsagent_asset.memory_store["example"].files[0].path == "example-store.md"
    error_message = "memory store must be created with one file <name>.md"
  }
}

run "custom_agent_rejects_unknown_memory_store" {
  command = plan

  variables {
    custom_agents = {
      example = {
        memory_stores = ["missing"]
        name          = "example-agent"
        system_prompt = "You are an example agent for this AWS account."
      }
    }
  }

  expect_failures = [var.custom_agents]
}

run "metadata_keeps_user_settings" {
  command = apply

  assert {
    condition     = jsondecode(awscc_devopsagent_asset.skill["example"].metadata).name == "example-skill"
    error_message = "the skill name must stay in the metadata"
  }
  assert {
    condition     = jsondecode(awscc_devopsagent_asset.custom_agent["example"].metadata).name == "example-agent"
    error_message = "the custom agent name must stay in the metadata"
  }
  assert {
    condition     = jsondecode(awscc_devopsagent_asset.agents_md["CHAT"].metadata).agent_type == "CHAT"
    error_message = "agent_type must stay in the metadata"
  }
}
