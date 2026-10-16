# Validation of devops_agent.primary / devops_agent.secondary.
# Run with the example tfvars so every other required variable is set:
#   terraform test -var-file=terraform.example.tfvars
mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "222222222222"
      arn        = "arn:aws:iam::222222222222:user/test"
      user_id    = "AIDAEXAMPLE"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}
mock_provider "awscc" {}
mock_provider "external" {}
mock_provider "local" {}
mock_provider "null" {}
mock_provider "template" {}
mock_provider "time" {}

# This module runs the AWS CLI during plan (auto-discovery); keep the test offline.
override_data {
  target = module.aws_metric_eventbridge_scheduler.data.external.list
  values = {
    result = {
      list_schedule_group = ""
    }
  }
}

# The devops_agent block of the tfvars given with -var-file must itself be valid.
run "tfvars_devops_agent_is_valid" {
  command = plan
}

run "disabled_by_default_creates_nothing" {
  command = plan
  variables {
    devops_agent = {}
  }

  assert {
    condition     = length(module.devops_agent) == 0 && module.devops_agent_secondary.role_name == null
    error_message = "an empty devops_agent must create neither Agent Spaces nor the cross-account role"
  }
}

run "primary_with_secondary_accounts_is_valid" {
  command = plan
  variables {
    devops_agent = {
      primary = {
        is_enabled = true
        secondary_accounts = {
          dev = { account_id = "111111111111" }
        }
      }
    }
  }

  assert {
    condition     = module.devops_agent_secondary.role_name == null
    error_message = "primary only must not create the cross-account role"
  }
}

run "secondary_is_valid" {
  command = plan
  variables {
    devops_agent = {
      secondary = {
        is_enabled              = true
        primary_account_id      = "444444444444"
        primary_agent_space_arn = "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/abc123"
      }
    }
  }

  assert {
    condition     = module.devops_agent_secondary.role_name == "DevOpsAgentRole-SecondaryAccount"
    error_message = "secondary must create the cross-account role with the fixed name"
  }
  assert {
    condition     = length(module.devops_agent) == 0
    error_message = "secondary only must not create Agent Spaces"
  }
}

run "primary_and_secondary_coexist" {
  command = plan
  variables {
    devops_agent = {
      primary = {
        is_enabled = true
        agent_spaces = {
          devops-agent = {}
        }
      }
      secondary = {
        is_enabled              = true
        primary_account_id      = "444444444444"
        primary_agent_space_arn = "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/abc123"
      }
    }
  }

  assert {
    condition     = module.devops_agent_secondary.role_name == "DevOpsAgentRole-SecondaryAccount"
    error_message = "secondary must create the cross-account role when primary is also enabled"
  }
  assert {
    condition     = length(module.devops_agent) == 1
    error_message = "primary must create the Agent Space when secondary is also enabled"
  }
}

run "secondary_disabled_ignores_primary_settings" {
  command = plan
  variables {
    devops_agent = {
      secondary = {
        is_enabled              = false
        primary_account_id      = "444444444444"
        primary_agent_space_arn = "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/abc123"
      }
    }
  }

  assert {
    condition     = module.devops_agent_secondary.role_name == null
    error_message = "secondary.is_enabled = false must not create the cross-account role"
  }
}

run "secondary_without_primary_account_fails" {
  command = plan
  variables {
    devops_agent = {
      secondary = {
        is_enabled = true
      }
    }
  }

  expect_failures = [var.devops_agent]
}

run "malformed_primary_account_id_fails" {
  command = plan
  variables {
    devops_agent = {
      secondary = {
        is_enabled              = true
        primary_account_id      = "4444"
        primary_agent_space_arn = "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/abc123"
      }
    }
  }

  expect_failures = [var.devops_agent]
}

run "malformed_secondary_account_id_fails" {
  command = plan
  variables {
    devops_agent = {
      primary = {
        is_enabled = true
        secondary_accounts = {
          dev = { account_id = "1234" }
        }
      }
    }
  }

  expect_failures = [var.devops_agent]
}

run "wildcard_agent_space_arn_fails" {
  command = plan
  variables {
    devops_agent = {
      secondary = {
        is_enabled              = true
        primary_account_id      = "444444444444"
        primary_agent_space_arn = "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/*"
      }
    }
  }

  expect_failures = [var.devops_agent]
}

run "secondary_additional_policy_statements_attached" {
  command = plan
  variables {
    devops_agent = {
      secondary = {
        is_enabled              = true
        primary_account_id      = "444444444444"
        primary_agent_space_arn = "arn:aws:aidevops:ap-northeast-1:444444444444:agentspace/abc123"
        additional_policy_statements = [
          {
            actions   = ["glue:GetConnection"]
            resources = ["*"]
            sid       = "AllowReadGlue"
          },
        ]
      }
    }
  }

  assert {
    condition     = module.devops_agent_secondary.additional_policy_name == "Additional-DevOpsAgentRole-SecondaryAccount"
    error_message = "secondary.additional_policy_statements must create the additional policy on the cross-account role"
  }
}

run "unknown_github_registration_fails" {
  command = plan
  variables {
    devops_agent = {
      primary = {
        is_enabled = true
        agent_spaces = {
          devops-agent = {
            github_repositories = {
              example = {
                github_registration = "missing"
                repo_id             = "123456789"
                repo_name           = "example"
              }
            }
          }
        }
      }
    }
  }

  expect_failures = [var.devops_agent]
}
