mock_provider "aws" {}

variables {
  name_prefix = "test-"
  region      = "ap-northeast-1"
}

run "rule_matches_only_active_external_access_findings" {
  command = plan

  assert {
    condition     = jsondecode(aws_cloudwatch_event_rule.this[0].event_pattern).source == ["aws.access-analyzer"]
    error_message = "The rule must match Access Analyzer events only"
  }

  assert {
    condition     = jsondecode(aws_cloudwatch_event_rule.this[0].event_pattern)["detail-type"] == ["Access Analyzer Finding"]
    error_message = "The rule must match external access findings only (not internal or unused access findings)"
  }

  assert {
    condition     = jsondecode(aws_cloudwatch_event_rule.this[0].event_pattern).detail.status == ["ACTIVE"] && jsondecode(aws_cloudwatch_event_rule.this[0].event_pattern).detail.isDeleted == [false]
    error_message = "Resolved, archived and deleted findings must not be notified"
  }

  assert {
    condition     = jsondecode(aws_cloudwatch_event_rule.this[0].event_pattern).detail.error == [{ exists = false }]
    error_message = "Error findings (the resource could not be analyzed) must not be notified"
  }
}

run "names_carry_the_prefix_and_region_is_applied" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_rule.this[0].name == "test-security-access-analyzer-rule" && aws_sns_topic.this[0].name == "test-security-access-analyzer-chatbot-slack-topic"
    error_message = "Resource names must carry name_prefix"
  }

  assert {
    condition     = aws_cloudwatch_event_rule.this[0].region == "ap-northeast-1" && aws_sns_topic.this[0].region == "ap-northeast-1"
    error_message = "Resources must be created in the given region"
  }
}

run "target_reshapes_the_event_into_a_chatbot_custom_notification" {
  command = plan

  assert {
    condition     = strcontains(aws_cloudwatch_event_target.sns_publish[0].input_transformer[0].input_template, "\"source\": \"custom\"") && strcontains(aws_cloudwatch_event_target.sns_publish[0].input_transformer[0].input_template, "\"version\": \"1.0\"")
    error_message = "The notification must use the Chatbot custom notification schema"
  }

  assert {
    condition     = alltrue([for k in ["resource", "resource_type", "account_id", "region", "is_public", "finding_id"] : contains(keys(aws_cloudwatch_event_target.sns_publish[0].input_transformer[0].input_paths), k)])
    error_message = "All placeholders used by the template must be defined in input_paths"
  }
}

run "retry_policy_defaults_to_the_eventbridge_defaults" {
  command = plan

  assert {
    condition     = aws_cloudwatch_event_target.sns_publish[0].retry_policy[0].maximum_event_age_in_seconds == 86400 && aws_cloudwatch_event_target.sns_publish[0].retry_policy[0].maximum_retry_attempts == 185
    error_message = "The retry policy must default to 24 hours and 185 attempts"
  }
}

run "kms_key_is_applied_to_the_topic" {
  command = plan

  variables {
    kms_master_key_id = "11111111-2222-3333-4444-555555555555"
  }

  assert {
    condition     = aws_sns_topic.this[0].kms_master_key_id == "11111111-2222-3333-4444-555555555555"
    error_message = "The configured KMS key must be set on the topic"
  }
}

run "topic_is_unencrypted_without_a_kms_key" {
  command = plan

  assert {
    condition     = aws_sns_topic.this[0].kms_master_key_id == null
    error_message = "The topic must not be encrypted when no KMS key is given (non-primary regions)"
  }
}

run "nothing_is_created_when_disabled" {
  command = plan

  variables {
    is_enabled = false
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) == 0 && length(aws_sns_topic.this) == 0 && length(aws_sns_topic_policy.this) == 0 && length(aws_cloudwatch_event_target.sns_publish) == 0
    error_message = "No resource must be created when is_enabled is false"
  }

  assert {
    condition     = output.sns_topic_arn == null
    error_message = "The topic ARN output must be null when disabled"
  }
}
