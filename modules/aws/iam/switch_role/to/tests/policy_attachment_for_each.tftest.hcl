mock_provider "aws" {}

variables {
  aws_iam_role = {
    account_id         = "111111111111"
    assume_role_policy = null
    name               = "switch-role"
  }
}

run "attachments_keyed_by_policy_arn" {
  command = plan

  variables {
    policy = [
      { policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" },
      { policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess" },
    ]
  }

  assert {
    condition = toset(keys(aws_iam_role_policy_attachment.this)) == toset([
      "arn:aws:iam::aws:policy/AdministratorAccess",
      "arn:aws:iam::aws:policy/ReadOnlyAccess",
    ])
    error_message = "Attachments must be keyed by policy_arn"
  }
}

run "disabled_creates_nothing" {
  command = plan

  variables {
    is_enabled = false
    policy     = [{ policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess" }]
  }

  assert {
    condition     = length(aws_iam_role_policy_attachment.this) == 0
    error_message = "No attachments must be created when is_enabled is false"
  }
}
