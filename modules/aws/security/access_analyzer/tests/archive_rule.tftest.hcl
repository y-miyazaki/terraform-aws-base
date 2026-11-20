mock_provider "aws" {}

variables {
  analyzer_name = "test-analyzer"
  region        = "ap-northeast-1"
  type          = "ACCOUNT"
}

run "rules_keyed_by_name_with_criteria" {
  command = plan

  variables {
    archive_rules = {
      sso = {
        filters = {
          "principal.Federated" = { contains = ["saml-provider/AWSSSO_"] }
          "resourceType"        = { eq = ["AWS::IAM::Role"] }
        }
      }
    }
  }

  assert {
    condition     = toset(keys(aws_accessanalyzer_archive_rule.this)) == toset(["sso"])
    error_message = "Archive rules must be keyed by rule name"
  }

  assert {
    condition     = toset([for f in aws_accessanalyzer_archive_rule.this["sso"].filter : f.criteria]) == toset(["principal.Federated", "resourceType"])
    error_message = "Each filter key must become a criteria"
  }
}

run "exists_is_converted_to_string" {
  command = plan

  variables {
    archive_rules = {
      r = { filters = { "error" = { exists = false } } }
    }
  }

  assert {
    condition     = one(aws_accessanalyzer_archive_rule.this["r"].filter).exists == "false"
    error_message = "exists must be passed to the provider as a string"
  }
}

run "no_rules_by_default" {
  command = plan

  assert {
    condition     = length(aws_accessanalyzer_archive_rule.this) == 0
    error_message = "No archive rules must be created by default"
  }
}

run "disabled_creates_nothing" {
  command = plan

  variables {
    is_enabled    = false
    archive_rules = { r = { filters = { "error" = { exists = true } } } }
  }

  assert {
    condition     = length(aws_accessanalyzer_archive_rule.this) == 0
    error_message = "No archive rules must be created when is_enabled is false"
  }
}

run "skipped_when_organization_analyzer_exists" {
  command = plan

  variables {
    type          = "ORGANIZATION"
    archive_rules = { r = { filters = { "error" = { exists = true } } } }
  }

  override_data {
    target = data.external.organization_analyzer_exists[0]
    values = { result = { exists = "true" } }
  }

  assert {
    condition     = length(aws_accessanalyzer_archive_rule.this) == 0
    error_message = "Rules must not be created when this module does not create the analyzer"
  }
}

run "created_for_organization_when_no_analyzer_exists" {
  command = plan

  variables {
    type          = "ORGANIZATION"
    archive_rules = { r = { filters = { "error" = { exists = true } } } }
  }

  override_data {
    target = data.external.organization_analyzer_exists[0]
    values = { result = { exists = "false" } }
  }

  assert {
    condition     = toset(keys(aws_accessanalyzer_archive_rule.this)) == toset(["r"])
    error_message = "Rules must be created when this module creates the organization analyzer"
  }
}

run "filter_without_operator_is_rejected" {
  command = plan

  variables {
    archive_rules = { r = { filters = { "error" = {} } } }
  }

  expect_failures = [var.archive_rules]
}

run "rule_without_filters_is_rejected" {
  command = plan

  variables {
    archive_rules = { r = { filters = {} } }
  }

  expect_failures = [var.archive_rules]
}
