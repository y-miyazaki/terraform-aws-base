mock_provider "aws" {}

variables {
  aws_guardduty_detector = {
    enable                       = true
    finding_publishing_frequency = "FIFTEEN_MINUTES"
  }
  region = "ap-northeast-1"
}

run "members_keyed_by_account_id" {
  command = plan

  variables {
    aws_guardduty_member = [
      { account_id = "111111111111", email = "a@example.com", invite = false, invitation_message = "", disable_email_notification = false },
      { account_id = "222222222222", email = "b@example.com", invite = false, invitation_message = "", disable_email_notification = false },
    ]
  }

  assert {
    condition     = toset(keys(aws_guardduty_member.this)) == toset(["111111111111", "222222222222"])
    error_message = "aws_guardduty_member must be keyed by account_id"
  }
}

run "removing_first_member_keeps_other_address" {
  command = plan

  variables {
    aws_guardduty_member = [
      { account_id = "222222222222", email = "b@example.com", invite = false, invitation_message = "", disable_email_notification = false },
    ]
  }

  assert {
    condition     = toset(keys(aws_guardduty_member.this)) == toset(["222222222222"])
    error_message = "Remaining member address must not depend on list position"
  }
}

run "disabled_creates_nothing" {
  command = plan

  variables {
    is_enabled = false
    aws_guardduty_member = [
      { account_id = "111111111111", email = "a@example.com", invite = false, invitation_message = "", disable_email_notification = false },
    ]
  }

  assert {
    condition     = length(aws_guardduty_member.this) == 0
    error_message = "No members must be created when is_enabled is false"
  }
}

run "detector_features_are_created_by_name" {
  command = plan

  variables {
    aws_guardduty_member = []
    aws_guardduty_detector_feature = {
      S3_DATA_EVENTS = { status = "ENABLED" }
      RUNTIME_MONITORING = {
        status = "ENABLED"
        additional_configurations = [
          { name = "EC2_AGENT_MANAGEMENT", status = "DISABLED" },
        ]
      }
    }
  }

  assert {
    condition     = toset(keys(aws_guardduty_detector_feature.this)) == toset(["S3_DATA_EVENTS", "RUNTIME_MONITORING"])
    error_message = "Detector features must be keyed by feature name"
  }
}

run "detector_features_skipped_when_detector_disabled" {
  command = plan

  variables {
    aws_guardduty_detector = {
      enable                       = false
      finding_publishing_frequency = "FIFTEEN_MINUTES"
    }
    aws_guardduty_member           = []
    aws_guardduty_detector_feature = { S3_DATA_EVENTS = { status = "ENABLED" } }
  }

  assert {
    condition     = length(aws_guardduty_detector_feature.this) == 0
    error_message = "No features must be managed when the detector is disabled"
  }
}
