mock_provider "aws" {
  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:ap-northeast-1:111111111111:test-topic"
    }
  }
}

variables {
  cloudwatch_name_prefix = "test-"
  region                 = "ap-northeast-1"
  aws_sns_topic = {
    name                                     = "test-topic"
    name_prefix                              = null
    display_name                             = null
    delivery_policy                          = null
    application_success_feedback_role_arn    = null
    application_success_feedback_sample_rate = null
    application_failure_feedback_role_arn    = null
    http_success_feedback_role_arn           = null
    http_success_feedback_sample_rate        = null
    http_failure_feedback_role_arn           = null
    lambda_success_feedback_role_arn         = null
    lambda_success_feedback_sample_rate      = null
    lambda_failure_feedback_role_arn         = null
    sqs_success_feedback_role_arn            = null
    sqs_success_feedback_sample_rate         = null
    sqs_failure_feedback_role_arn            = null
  }
  aws_sns_topic_subscription = {
    endpoint                        = "arn:aws:lambda:ap-northeast-1:111111111111:function:test"
    protocol                        = "lambda"
    confirmation_timeout_in_minutes = null
    delivery_policy                 = null
    endpoint_auto_confirms          = false
    filter_policy                   = null
    raw_message_delivery            = null
    redrive_policy                  = null
  }
}

run "defaults_detect_failed_console_logins" {
  command = plan

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.console_login_failure[0].pattern, "($.eventName=\"ConsoleLogin\") && ($.responseElements.ConsoleLogin=\"Failure\")")
    error_message = "The filter must match failed ConsoleLogin events only"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.console_login_failure[0].threshold == 5 && aws_cloudwatch_metric_alarm.console_login_failure[0].period == 300 && aws_cloudwatch_metric_alarm.console_login_failure[0].evaluation_periods == 1
    error_message = "The console login failure alarm must default to 5 events within one 5-minute period"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.console_login_failure[0].alarm_name == "test-console-login-failure-burst"
    error_message = "The alarm name must carry the name prefix"
  }
}

run "defaults_detect_mass_unauthorized_calls" {
  command = plan

  assert {
    condition     = aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].threshold == 100 && aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].period == 300 && aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].evaluation_periods == 1
    error_message = "The unauthorized operation burst alarm must default to 100 events within one 5-minute period"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].alarm_name == "test-unauthorized-operation-api-burst"
    error_message = "The alarm name must carry the name prefix"
  }
}

run "burst_alarm_counts_the_cloudwatch_2_metric" {
  # apply with the mock provider: the filter id is unknown at plan time.
  command = apply

  variables {
    cloudwatch_2_event_exclusions = [
      { user_identity_arn = "arn:aws:sts::*:assumed-role/DevOpsAgentRole-SecondaryAccount/*" },
    ]
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].metric_name == aws_cloudwatch_log_metric_filter.cloudwatch_2[0].id
    error_message = "The burst alarm must count the metric of the CloudWatch.2 filter so the exclusions have a single definition"
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_2[0].pattern, "assumed-role/DevOpsAgentRole-SecondaryAccount/*")
    error_message = "cloudwatch_2_event_exclusions must be applied to the counted filter"
  }
}

run "burst_alarms_send_alarm_notifications_only" {
  command = plan

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.console_login_failure[0].alarm_actions) == 1 && length(aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].alarm_actions) == 1
    error_message = "Both burst alarms must notify the SNS topic on ALARM"
  }

  assert {
    condition     = try(length(aws_cloudwatch_metric_alarm.console_login_failure[0].ok_actions), 0) == 0 && try(length(aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].ok_actions), 0) == 0
    error_message = "Burst alarms must not send recovery notices"
  }
}

run "thresholds_accept_the_lower_boundary" {
  command = plan

  variables {
    console_login_failure_threshold        = 1
    unauthorized_operation_burst_threshold = 1
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.console_login_failure[0].threshold == 1 && aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].threshold == 1
    error_message = "A threshold of 1 must be applied as configured"
  }
}

run "thresholds_are_applied_to_alarm_and_description" {
  command = plan

  variables {
    console_login_failure_threshold        = 10
    unauthorized_operation_burst_threshold = 250
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.console_login_failure[0].threshold == 10 && strcontains(aws_cloudwatch_metric_alarm.console_login_failure[0].alarm_description, "10 or more")
    error_message = "The configured console login failure threshold must be used by the alarm and its description"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].threshold == 250 && strcontains(aws_cloudwatch_metric_alarm.unauthorized_operation_burst[0].alarm_description, "250 or more")
    error_message = "The configured burst threshold must be used by the alarm and its description"
  }
}

run "rejects_zero_console_login_failure_threshold" {
  command = plan

  variables {
    console_login_failure_threshold = 0
  }

  expect_failures = [var.console_login_failure_threshold]
}

run "rejects_fractional_unauthorized_operation_burst_threshold" {
  command = plan

  variables {
    unauthorized_operation_burst_threshold = 1.5
  }

  expect_failures = [var.unauthorized_operation_burst_threshold]
}

run "nothing_is_created_when_disabled" {
  command = plan

  variables {
    is_enabled = false
  }

  assert {
    condition     = length(aws_cloudwatch_log_metric_filter.console_login_failure) == 0 && length(aws_cloudwatch_metric_alarm.console_login_failure) == 0 && length(aws_cloudwatch_metric_alarm.unauthorized_operation_burst) == 0
    error_message = "No burst filter or alarm must be created when is_enabled is false"
  }
}

run "identity_center_failures_use_credential_verification" {
  command = plan

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.identity_center_login_failure[0].pattern, "$.eventName=\"CredentialVerification\"") && strcontains(aws_cloudwatch_log_metric_filter.identity_center_login_failure[0].pattern, "$.serviceEventDetails.CredentialVerification=\"Failure\"") && strcontains(aws_cloudwatch_log_metric_filter.identity_center_login_failure[0].pattern, "$.eventSource=\"signin.amazonaws.com\"")
    error_message = "The filter must match failed Identity Center credential verifications only"
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.identity_center_login_failure[0].threshold == 10 && aws_cloudwatch_metric_alarm.identity_center_login_failure[0].period == 300 && try(length(aws_cloudwatch_metric_alarm.identity_center_login_failure[0].ok_actions), 0) == 0
    error_message = "The alarm must default to 10 events within 5 minutes without a recovery notice"
  }
}

run "identity_center_threshold_is_configurable_and_validated" {
  command = plan

  variables {
    identity_center_login_failure_threshold = 1
  }

  assert {
    condition     = aws_cloudwatch_metric_alarm.identity_center_login_failure[0].threshold == 1 && strcontains(aws_cloudwatch_metric_alarm.identity_center_login_failure[0].alarm_description, "1 or more")
    error_message = "A threshold of 1 must be applied as configured"
  }
}

run "rejects_zero_identity_center_threshold" {
  command = plan

  variables {
    identity_center_login_failure_threshold = 0
  }

  expect_failures = [var.identity_center_login_failure_threshold]
}

run "security_service_alarm_fires_on_a_single_call" {
  command = plan

  assert {
    condition     = module.security_service_disable.alarm_name == "test-security-service-disable"
    error_message = "The security service tampering alarm must be created with the name prefix"
  }

  assert {
    condition     = module.security_service_disable.log_group_name != null && strcontains(module.security_service_disable.pattern, "$.eventName=\"DeleteDetector\"")
    error_message = "The filter must read the CloudTrail log group and use the shared security service pattern"
  }
}

run "new_alarms_are_not_created_when_disabled" {
  command = plan

  variables {
    is_enabled = false
  }

  assert {
    condition     = length(aws_cloudwatch_metric_alarm.identity_center_login_failure) == 0 && module.security_service_disable.alarm_name == null && length(aws_cloudwatch_log_metric_filter.identity_center_login_failure) == 0 && module.security_service_disable.log_group_name == null
    error_message = "No filter or alarm must be created when is_enabled is false"
  }
}
