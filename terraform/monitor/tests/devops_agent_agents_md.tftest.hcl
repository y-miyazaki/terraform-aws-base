# GENERIC AGENTS.md (generic.md): the per-alarm memory suppression rule must stay in it.
# The follow-up custom agents write memory monitors-<alarm-name> to the custom store suppressions (managed stores such as
# directives are read-only for custom agents); this rule is its only reader at
# investigation start (skills are loaded later), so removing it silently disables suppression.
# Run with the example tfvars so every other required variable is set:
#   terraform test -var-file=terraform.example.tfvars -filter=tests/devops_agent_agents_md.tftest.hcl
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

run "generic_keeps_memory_suppression_rule" {
  command = plan
  variables {
    devops_agent = {
      primary = {
        is_enabled = true
        agent_spaces = {
          devops-agent = {
            agents_md = { GENERIC = { content_file = "devops_agent/agents_md/generic.md" } }
          }
        }
      }
    }
  }

  assert {
    condition     = strcontains(local.devops_agent_agents_md["devops-agent"]["GENERIC"], "## Incident suppression: per-alarm memory directives")
    error_message = "the GENERIC AGENTS.md must keep the per-alarm memory suppression section"
  }
  assert {
    condition     = strcontains(local.devops_agent_agents_md["devops-agent"]["GENERIC"], "monitors-<alarm-name>")
    error_message = "the suppression section must name the memory monitors-<alarm-name> written by the follow-up skills"
  }
  assert {
    condition     = strcontains(local.devops_agent_agents_md["devops-agent"]["GENERIC"], "read `monitors-<alarm-name>` in `suppressions`, then in `directives`")
    error_message = "the suppression section must read the custom store suppressions (written by the follow-up custom agents) and directives (written in Chat)"
  }
  assert {
    condition     = strcontains(local.devops_agent_agents_md["devops-agent"]["GENERIC"], "Do not create or update Issues, PRs, labels, or memories.")
    error_message = "a suppressed alarm must not create Issues, PRs, labels, or memories"
  }
}

# The follow-up custom agents can write only to attached custom stores, so the store must be passed through to the module.
run "custom_agent_memory_stores_reach_module" {
  command = plan
  variables {
    devops_agent = {
      primary = {
        is_enabled = true
        agent_spaces = {
          devops-agent = {
            memory_stores = {
              suppressions = {
                description = "Per-alarm suppression decisions."
                name        = "suppressions"
              }
            }
            custom_agents = {
              followup = {
                memory_stores      = ["suppressions"]
                name               = "followup-agent"
                system_prompt_file = "devops_agent/agents/linear_issue_pr_followup_agent.md"
              }
            }
          }
        }
      }
    }
  }

  assert {
    condition     = contains(keys(module.devops_agent["devops-agent"].memory_store_asset_ids), "suppressions")
    error_message = "the suppressions memory store must be created in the Agent Space"
  }
}
