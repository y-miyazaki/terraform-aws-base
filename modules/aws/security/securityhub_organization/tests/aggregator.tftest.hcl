mock_provider "aws" {}

variables {
  configuration_policy_name     = "test-policy"
  is_enabled_finding_aggregator = true
  region                        = "ap-northeast-1"
  target_id                     = "r-xxxx"
}

run "aggregator_links_only_the_given_regions" {
  command = plan

  variables {
    linked_regions = ["ap-northeast-3", "us-east-1"]
  }

  assert {
    condition     = aws_securityhub_finding_aggregator.this[0].linking_mode == "SPECIFIED_REGIONS" && aws_securityhub_finding_aggregator.this[0].specified_regions == toset(["ap-northeast-3", "us-east-1"])
    error_message = "The aggregator must link the given regions only, not ALL_REGIONS (a disabled opt-in region fails the policy association)"
  }
}

run "rejects_an_aggregator_without_linked_regions" {
  command = plan

  expect_failures = [
    aws_securityhub_finding_aggregator.this,
  ]
}

run "nothing_is_created_when_the_aggregator_is_disabled" {
  command = plan

  variables {
    is_enabled_finding_aggregator = false
  }

  assert {
    condition     = length(aws_securityhub_finding_aggregator.this) == 0
    error_message = "No aggregator must be created when is_enabled_finding_aggregator is false"
  }
}
