mock_provider "aws" {}

variables {
  aws_cloudwatch_event_target = {
    arn = "arn:aws:lambda:ap-northeast-1:123456789012:function:example"
  }
  region = "ap-northeast-1"
}

run "state_defaults_to_enabled" {
  command = plan

  variables {
    aws_cloudwatch_event_rule = {
      name = "example-rule"
    }
  }

  assert {
    condition     = aws_cloudwatch_event_rule.this[0].state == "ENABLED"
    error_message = "The rule state must default to ENABLED"
  }
}

run "state_is_passed_to_the_rule" {
  command = plan

  variables {
    aws_cloudwatch_event_rule = {
      name  = "example-rule"
      state = "DISABLED"
    }
  }

  assert {
    condition     = aws_cloudwatch_event_rule.this[0].state == "DISABLED"
    error_message = "The configured rule state must be applied"
  }
}

run "nothing_is_created_when_disabled" {
  command = plan

  variables {
    is_enabled = false
    aws_cloudwatch_event_rule = {
      name = "example-rule"
    }
  }

  assert {
    condition     = length(aws_cloudwatch_event_rule.this) == 0 && length(aws_cloudwatch_event_target.this) == 0
    error_message = "No rule or target must be created when is_enabled is false"
  }
}
