mock_provider "aws" {}

variables {
  aws_guardduty_detector = {
    enable                       = true
    finding_publishing_frequency = "FIFTEEN_MINUTES"
  }
  aws_guardduty_member = []
  region               = "ap-northeast-1"
}

run "no_invite_accepted_by_default" {
  command = plan

  assert {
    condition     = length(aws_guardduty_invite_accepter.this) == 0
    error_message = "No invitation must be accepted when master_account_id is not set"
  }
}

run "invite_accepted_from_master_account" {
  command = plan

  variables {
    master_account_id = "111111111111"
  }

  assert {
    condition     = length(aws_guardduty_invite_accepter.this) == 1 && aws_guardduty_invite_accepter.this[0].master_account_id == "111111111111"
    error_message = "The invitation must be accepted from the given master account"
  }
}

run "invite_not_accepted_when_disabled" {
  command = plan

  variables {
    is_enabled        = false
    master_account_id = "111111111111"
  }

  assert {
    condition     = length(aws_guardduty_invite_accepter.this) == 0
    error_message = "No invitation must be accepted when is_enabled is false"
  }
}
