mock_provider "aws" {}

variables {
  account_id = "111111111111"
  aws_cloudwatch_log_group = {
    name              = "test-log"
    retention_in_days = 90
  }
  aws_s3_bucket_existing = {
    bucket_arn = "arn:aws:s3:::test"
    bucket_id  = "test"
  }
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

run "default_pattern_is_unchanged" {
  command = plan

  assert {
    condition     = aws_cloudwatch_log_metric_filter.cloudwatch_2[0].pattern == "{(($.errorCode=\"*UnauthorizedOperation\") || ($.errorCode=\"AccessDenied*\")) && ($.userIdentity.arn!=\"*assumed-role/AWSServiceRoleFor*\") && ($.userIdentity.arn!=\"*assumed-role/AIOpsRole*\")}\n"
    error_message = "without exclusions the CloudWatch.2 pattern must equal the historical literal"
  }
}

run "source_and_name_only_keeps_legacy_clause" {
  command = plan

  variables {
    cloudwatch_2_event_exclusions = [
      { event_name = "ListProfiles", event_source = "codewhisperer.amazonaws.com" },
    ]
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_2[0].pattern, " && (($.eventSource!=\"codewhisperer.amazonaws.com\") || ($.eventName!=\"ListProfiles\"))}")
    error_message = "exclusion without user_identity_arn must keep the legacy two-term clause"
  }
}

run "user_identity_arn_is_anded_into_exclusion" {
  command = plan

  variables {
    cloudwatch_2_event_exclusions = [
      {
        event_name        = "GetSecretValue"
        event_source      = "secretsmanager.amazonaws.com"
        user_identity_arn = "arn:aws:sts::*:assumed-role/DevOpsAgentRole-SecondaryAccount/*"
      },
    ]
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_2[0].pattern, " && (($.eventSource!=\"secretsmanager.amazonaws.com\") || ($.eventName!=\"GetSecretValue\") || ($.userIdentity.arn!=\"arn:aws:sts::*:assumed-role/DevOpsAgentRole-SecondaryAccount/*\"))}")
    error_message = "exclusion with user_identity_arn must negate eventSource, eventName and arn together"
  }
}

run "rejects_empty_or_unsafe_user_identity_arn" {
  command = plan

  variables {
    cloudwatch_2_event_exclusions = [
      { event_name = "GetSecretValue", event_source = "secretsmanager.amazonaws.com", user_identity_arn = "" },
    ]
  }

  expect_failures = [var.cloudwatch_2_event_exclusions]
}

run "rejects_pattern_over_1024_chars" {
  command = plan

  variables {
    cloudwatch_2_event_exclusions = [
      for i in range(8) : {
        event_name        = "GetSecretValue"
        event_source      = "secretsmanager.amazonaws.com"
        user_identity_arn = "arn:aws:sts::*:assumed-role/Role${i}/*"
      }
    ]
  }

  expect_failures = [aws_cloudwatch_log_metric_filter.cloudwatch_2]
}

run "arn_only_exclusion_ignores_event_source_and_name" {
  command = plan

  variables {
    cloudwatch_2_event_exclusions = [
      { user_identity_arn = "arn:aws:sts::*:assumed-role/DevOpsAgentRole-SecondaryAccount/*" },
    ]
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_2[0].pattern, " && (($.userIdentity.arn!=\"arn:aws:sts::*:assumed-role/DevOpsAgentRole-SecondaryAccount/*\"))}")
    error_message = "arn-only exclusion must negate only userIdentity.arn"
  }
  assert {
    condition     = !strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_2[0].pattern, "DevOpsAgentRole-SecondaryAccount/*\") || (")
    error_message = "arn-only exclusion must not add eventSource/eventName terms"
  }
}

run "rejects_exclusion_without_any_key" {
  command = plan

  variables {
    cloudwatch_2_event_exclusions = [{}]
  }

  expect_failures = [var.cloudwatch_2_event_exclusions]
}
