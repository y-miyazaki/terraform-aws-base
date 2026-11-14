mock_provider "aws" {}

variables {
  region = "ap-northeast-1"
}

run "all_rules_created_keyed_by_name" {
  command = plan

  variables {
    aws_config_config_rule = [
      {
        name                        = "rule-a"
        description                 = "a"
        input_parameters            = null
        maximum_execution_frequency = null
        scope                       = []
        source                      = [{ owner = "AWS", source_identifier = "S3_BUCKET_VERSIONING_ENABLED" }]
      },
      {
        name                        = "rule-b"
        description                 = "b"
        input_parameters            = null
        maximum_execution_frequency = null
        scope                       = []
        source                      = [{ owner = "AWS", source_identifier = "S3_BUCKET_LOGGING_ENABLED" }]
      },
    ]
  }

  assert {
    condition     = toset(keys(aws_config_config_rule.this)) == toset(["rule-a", "rule-b"])
    error_message = "Every rule in the list must be created and keyed by name"
  }
}

run "disabled_creates_nothing" {
  command = plan

  variables {
    is_enabled             = false
    aws_config_config_rule = []
  }

  assert {
    condition     = length(aws_config_config_rule.this) == 0
    error_message = "No rules must be created when is_enabled is false"
  }
}
