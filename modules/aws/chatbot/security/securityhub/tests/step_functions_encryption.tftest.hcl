mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "111111111111"
    }
  }
}

variables {
  cloudwatch_log_group_retention_in_days = 30
  name_prefix                            = "test-"
  region                                 = "ap-northeast-1"
}

run "event_targets_use_default_retry_policy" {
  command = plan

  assert {
    condition = alltrue([
      aws_cloudwatch_event_target.sns_publish[0].retry_policy[0].maximum_retry_attempts == 185,
      aws_cloudwatch_event_target.step_functions[0].retry_policy[0].maximum_event_age_in_seconds == 86400,
    ])
    error_message = "EventBridge targets must use the default retry_policy"
  }
}

run "event_targets_use_custom_retry_policy" {
  command = plan

  variables {
    retry_policy = {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 10
    }
  }

  assert {
    condition = alltrue([
      aws_cloudwatch_event_target.sns_publish[0].retry_policy[0].maximum_retry_attempts == 10,
      aws_cloudwatch_event_target.step_functions[0].retry_policy[0].maximum_event_age_in_seconds == 3600,
    ])
    error_message = "retry_policy variable must be applied to both targets"
  }
}

run "kms_statements_are_scoped_when_key_is_set" {
  command = plan

  variables {
    step_functions_kms_key_arn = "arn:aws:kms:ap-northeast-1:111111111111:key/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition = length([
      for s in data.aws_iam_policy_document.step_functions.statement : s
      if s.sid == "StateMachineEncryption"
      && contains(s.actions, "kms:Decrypt")
      && contains(s.actions, "kms:GenerateDataKey")
      && contains(s.resources, "arn:aws:kms:ap-northeast-1:111111111111:key/00000000-0000-0000-0000-000000000000")
      && length([for c in s.condition : c if c.variable == "kms:EncryptionContext:aws:states:stateMachineArn" && contains(c.values, "arn:aws:states:ap-northeast-1:111111111111:stateMachine:test-security-securityhub-update-findings-sfn")]) == 1
    ]) == 1
    error_message = "Execution role must be allowed to use the key only for this state machine"
  }

  assert {
    condition = length([
      for s in data.aws_iam_policy_document.step_functions.statement : s
      if s.sid == "StateMachineLogsEncryption"
      && s.actions == toset(["kms:GenerateDataKey"])
      && length([for c in s.condition : c if c.variable == "kms:EncryptionContext:SourceArn"]) == 1
    ]) == 1
    error_message = "Execution role must be allowed to generate data keys for CloudWatch Logs delivery"
  }
}

run "no_kms_statement_without_key" {
  command = plan

  assert {
    condition     = length([for s in data.aws_iam_policy_document.step_functions.statement : s if s.sid != null && startswith(s.sid, "StateMachine")]) == 0
    error_message = "No KMS statement expected when no CMK is set"
  }
}
