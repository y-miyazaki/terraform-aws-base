mock_provider "aws" {}

variables {
  name_prefix = "test-"
  region      = "ap-northeast-1"
}

run "disabled_creates_nothing_and_plans" {
  command = plan

  variables {
    is_enabled = false
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) == 0 && length(aws_sns_topic.this) == 0 && length(aws_sns_topic_policy.this) == 0 && length(data.aws_iam_policy_document.sns_topic) == 0
    error_message = "Nothing may be created (and the plan must not fail) when is_enabled is false"
  }
}

run "enabled_rule_matches_guardduty_findings" {
  command = plan

  assert {
    condition     = jsondecode(aws_cloudwatch_event_rule.this[0].event_pattern).source == ["aws.guardduty"] && jsondecode(aws_cloudwatch_event_rule.this[0].event_pattern)["detail-type"] == ["GuardDuty Finding"]
    error_message = "The rule must match GuardDuty findings only"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.this[0].region == "ap-northeast-1" && aws_sns_topic.this[0].region == "ap-northeast-1"
    error_message = "Resources must be created in the given region"
  }
}

run "topic_policy_is_restricted_to_the_rule" {
  command = plan

  assert {
    condition     = length([for c in data.aws_iam_policy_document.sns_topic[0].statement[0].condition : c if c.variable == "aws:SourceArn" && c.test == "ArnEquals"]) == 1
    error_message = "The SNS topic policy must restrict publishers with an aws:SourceArn condition"
  }
}
