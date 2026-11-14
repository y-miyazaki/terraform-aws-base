mock_provider "aws" {
  mock_data "aws_caller_identity" {
    defaults = {
      account_id = "111111111111"
    }
  }
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
  mock_data "aws_ssoadmin_instances" {
    defaults = {
      arns               = ["arn:aws:sso:::instance/ssoins-0000000000000000"]
      identity_store_ids = ["d-0000000000"]
    }
  }
}

variables {
  lambda_zip_base_path = "./tests"
  name_prefix          = "test-"
  profiles             = {}
  region               = "ap-northeast-1"
  slack = {
    approver_channel_id = "C0000000000"
    bot_token           = "dummy-token"
    signing_secret      = "test" # pragma: allowlist secret
    user_mappings       = {}
  }
}

run "execution_role_has_no_kms_statement_without_key" {
  command = plan

  assert {
    condition     = length([for s in data.aws_iam_policy_document.sfn.statement : s if s.sid != null && startswith(s.sid, "StateMachine")]) == 0
    error_message = "No KMS statement expected when kms_key_arn is null"
  }
}

run "execution_role_is_scoped_to_state_machine_when_key_is_set" {
  command = plan

  variables {
    kms_key_arn = "arn:aws:kms:ap-northeast-1:111111111111:key/00000000-0000-0000-0000-000000000000"
  }

  assert {
    condition = length([
      for s in data.aws_iam_policy_document.sfn.statement : s
      if s.sid == "StateMachineEncryption"
      && contains(s.actions, "kms:Decrypt")
      && contains(s.actions, "kms:GenerateDataKey")
      && length([for c in s.condition : c if c.variable == "kms:EncryptionContext:aws:states:stateMachineArn" && contains(c.values, "arn:aws:states:ap-northeast-1:111111111111:stateMachine:test-jit-access-sfn")]) == 1
    ]) == 1
    error_message = "Execution role must be allowed to use the key only for the JIT access state machine"
  }

  assert {
    condition = length([
      for s in data.aws_iam_policy_document.sfn.statement : s
      if s.sid == "StateMachineLogsEncryption" && s.actions == toset(["kms:GenerateDataKey"])
    ]) == 1
    error_message = "Execution role must be allowed to generate data keys for CloudWatch Logs delivery"
  }
}
