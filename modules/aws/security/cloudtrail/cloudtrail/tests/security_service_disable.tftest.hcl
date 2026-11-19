mock_provider "aws" {
  mock_resource "aws_sns_topic" {
    defaults = {
      arn = "arn:aws:sns:ap-northeast-1:111111111111:test-topic"
    }
  }
}

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

run "alarm_is_created_with_the_name_prefix" {
  command = plan

  assert {
    condition     = module.security_service_disable.alarm_name == "test-security-service-disable"
    error_message = "The security service tampering alarm must carry the name prefix"
  }
}

run "filter_uses_the_shared_pattern_on_the_trail_log_group" {
  command = plan

  assert {
    condition     = strcontains(module.security_service_disable.pattern, "$.eventSource=\"guardduty.amazonaws.com\"") && strcontains(module.security_service_disable.pattern, "$.eventName=\"DeleteAnalyzer\"")
    error_message = "The filter must use the shared security service pattern"
  }

  assert {
    condition     = module.security_service_disable.log_group_name == "test-log"
    error_message = "The filter must read the CloudTrail log group of this module"
  }
}

run "nothing_is_created_when_disabled" {
  command = plan

  variables {
    is_enabled = false
  }

  assert {
    condition     = module.security_service_disable.alarm_name == null && module.security_service_disable.log_group_name == null
    error_message = "No filter or alarm must be created when is_enabled is false"
  }
}
