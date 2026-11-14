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

run "default_pattern_has_no_exclusion" {
  command = plan

  assert {
    condition     = !strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_4[0].pattern, "&&")
    error_message = "without exclusions the CloudWatch.4 pattern must stay a pure eventName OR list"
  }
  assert {
    condition     = startswith(aws_cloudwatch_log_metric_filter.cloudwatch_4[0].pattern, "{($.eventName=DeleteGroupPolicy)")
    error_message = "without exclusions the CloudWatch.4 pattern must be unchanged"
  }
}

run "exclusion_requires_principal_and_target_role" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [
      {
        event_name        = "PutRolePolicy"
        user_identity_arn = "*assumed-role/AWSServiceRoleForSSO/*"
        role_name         = "AWSReservedSSO_*"
      },
    ]
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_4[0].pattern, "($.eventName!=\"PutRolePolicy\") || ($.userIdentity.arn!=\"*assumed-role/AWSServiceRoleForSSO/*\") || ($.requestParameters.roleName!=\"AWSReservedSSO_*\")")
    error_message = "exclusion must be negated with De Morgan over eventName, arn and roleName"
  }
  assert {
    condition     = startswith(aws_cloudwatch_log_metric_filter.cloudwatch_4[0].pattern, "{(($.eventName=DeleteGroupPolicy)")
    error_message = "eventName list must be parenthesised before the exclusion clause"
  }
}

run "role_name_is_optional" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [
      {
        event_name        = "PutRolePolicy"
        user_identity_arn = "*assumed-role/AWSServiceRoleForSSO/*"
      },
    ]
  }

  assert {
    condition     = !strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_4[0].pattern, "requestParameters.roleName")
    error_message = "roleName clause must be omitted when role_name is not set"
  }
}

run "rejects_double_quote" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [
      {
        event_name        = "PutRolePolicy"
        user_identity_arn = "bad\"arn"
      },
    ]
  }

  expect_failures = [var.cloudwatch_4_event_exclusions]
}

run "rejects_pattern_over_1024_chars" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [
      { event_name = "PutRolePolicy", user_identity_arn = "arn:aws:sts::*:assumed-role/AWSServiceRoleForSSO/*", role_name = "AWSReservedSSO_*" },
      { event_name = "PutRolePolicy", user_identity_arn = "arn:aws:sts::*:assumed-role/RoleA/*", role_name = "AWSReservedSSO_*" },
      { event_name = "PutRolePolicy", user_identity_arn = "arn:aws:sts::*:assumed-role/RoleB/*", role_name = "AWSReservedSSO_*" },
      { event_name = "PutRolePolicy", user_identity_arn = "arn:aws:sts::*:assumed-role/RoleC/*", role_name = "AWSReservedSSO_*" },
      { event_name = "PutRolePolicy", user_identity_arn = "arn:aws:sts::*:assumed-role/RoleD/*", role_name = "AWSReservedSSO_*" },
    ]
  }

  expect_failures = [aws_cloudwatch_log_metric_filter.cloudwatch_4]
}

run "rejects_empty_role_name" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [
      { event_name = "PutRolePolicy", user_identity_arn = "arn:aws:sts::*:assumed-role/X/*", role_name = "" },
    ]
  }

  expect_failures = [var.cloudwatch_4_event_exclusions]
}

run "rejects_backslash" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [
      { event_name = "PutRolePolicy", user_identity_arn = "arn:aws:sts::*:assumed-role\\X/*" },
    ]
  }

  expect_failures = [var.cloudwatch_4_event_exclusions]
}

run "event_name_only_exclusion" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [{ event_name = "AttachRolePolicy" }]
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_4[0].pattern, " && (($.eventName!=\"AttachRolePolicy\"))}")
    error_message = "event_name-only exclusion must negate only eventName"
  }
}

run "event_source_only_exclusion" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [{ event_source = "iam.amazonaws.com" }]
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_4[0].pattern, " && (($.eventSource!=\"iam.amazonaws.com\"))}")
    error_message = "event_source-only exclusion must negate only eventSource"
  }
}

run "user_identity_arn_only_exclusion" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [{ user_identity_arn = "arn:aws:sts::*:assumed-role/X/*" }]
  }

  assert {
    condition     = strcontains(aws_cloudwatch_log_metric_filter.cloudwatch_4[0].pattern, " && (($.userIdentity.arn!=\"arn:aws:sts::*:assumed-role/X/*\"))}")
    error_message = "arn-only exclusion must negate only userIdentity.arn"
  }
}

run "rejects_exclusion_without_any_key" {
  command = plan

  variables {
    cloudwatch_4_event_exclusions = [{}]
  }

  expect_failures = [var.cloudwatch_4_event_exclusions]
}
