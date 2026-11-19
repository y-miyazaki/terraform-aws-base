mock_provider "aws" {}

variables {
  alarm_actions  = ["arn:aws:sns:ap-northeast-1:111111111111:test-topic"]
  log_group_name = "test-log"
  name_prefix    = "test-"
  region         = "ap-northeast-1"
}

run "alarm_fires_on_a_single_tampering_call" {
  command = apply

  assert {
    condition     = aws_cloudwatch_metric_alarm.this[0].threshold == 1 && aws_cloudwatch_metric_alarm.this[0].period == 300 && aws_cloudwatch_metric_alarm.this[0].evaluation_periods == 1
    error_message = "One matching call within a 5-minute period must raise the alarm"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.this[0].alarm_name == "test-security-service-disable" && aws_cloudwatch_log_metric_filter.this[0].name == "test-security-service-disable"
    error_message = "Names must carry the name prefix"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.this[0].metric_name == aws_cloudwatch_log_metric_filter.this[0].metric_transformation[0].name
    error_message = "The alarm must watch the metric of the filter"
  }
}

run "alarm_notifies_on_alarm_only" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_alarm.this[0].alarm_actions == toset(["arn:aws:sns:ap-northeast-1:111111111111:test-topic"]) && try(length(aws_cloudwatch_metric_alarm.this[0].ok_actions), 0) == 0
    error_message = "The alarm must notify the given targets on ALARM only"
  }
}

run "filter_reads_the_given_log_group_and_region" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_metric_filter.this[0].log_group_name == "test-log" && aws_cloudwatch_log_metric_filter.this[0].region == "ap-northeast-1"
    error_message = "The filter must read the given log group in the given region"
  }
}

run "pattern_covers_each_security_service" {
  command = plan

  assert {
    condition     = alltrue([for s in ["guardduty.amazonaws.com", "securityhub.amazonaws.com", "macie2.amazonaws.com", "access-analyzer.amazonaws.com", "inspector2.amazonaws.com"] : strcontains(output.pattern, "$.eventSource=\"${s}\"")])
    error_message = "The pattern must match every security service"
  }

  assert {
    condition     = alltrue([for n in ["DeleteDetector", "DeleteAnalyzer", "BatchDisableStandards", "DisableSecurityHub", "DisableMacie", "DisableOrganizationAdminAccount"] : strcontains(output.pattern, "$.eventName=\"${n}\"")])
    error_message = "The pattern must match the delete and disable calls"
  }
}

run "pattern_does_not_use_a_disable_wildcard" {
  command = plan

  assert {
    condition     = !strcontains(output.pattern, "Disable*")
    error_message = "Disable* would match benign calls such as DisableImportFindingsForProduct"
  }
}

run "pattern_is_well_formed_and_within_the_length_limit" {
  command = plan

  assert {
    condition     = startswith(output.pattern, "{(") && endswith(output.pattern, ")}") && length(regexall("\\(", output.pattern)) == length(regexall("\\)", output.pattern))
    error_message = "The pattern must be one braced expression with balanced parentheses"
  }

  assert {
    condition     = length(output.pattern) <= 1024
    error_message = "A CloudWatch Logs metric filter pattern is limited to 1024 characters"
  }
}

run "nothing_is_created_when_disabled" {
  command = plan

  variables {
    is_enabled = false
  }

  assert {
    condition     = length(aws_cloudwatch_log_metric_filter.this) == 0 && length(aws_cloudwatch_metric_alarm.this) == 0
    error_message = "No filter or alarm must be created when is_enabled is false"
  }
}
