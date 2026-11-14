variable "tags" {
  description = "(Required) Default tags applied to all resources created by this stack."
  type        = map(string)
}

variable "name_prefix" {
  description = "(Required) Prefix prepended to the names of resources created by this stack."
  type        = string
}

variable "region" {
  description = "Region configuration for multi-region deployment"
  type = object({
    # Region => account IDs allowed in that region (allowlist).
    # Regions without a key apply to all accounts.
    account_allowlist = optional(map(list(string)), {})
    global            = string
    primary           = string
    targets           = list(string)
  })
  validation {
    condition     = length(var.region.targets) > 0
    error_message = "region.targets must contain at least one region"
  }
  validation {
    condition     = contains(var.region.targets, var.region.primary)
    error_message = "region.primary must be included in region.targets"
  }
  validation {
    condition     = alltrue([for r in keys(var.region.account_allowlist) : contains(var.region.targets, r)])
    error_message = "region.account_allowlist keys must be included in region.targets"
  }
  validation {
    condition     = alltrue([for ids in values(var.region.account_allowlist) : alltrue([for id in ids : can(regex("^[0-9]{12}$", id))])])
    error_message = "region.account_allowlist values must be 12-digit AWS account IDs"
  }
}

variable "cloudwatch_log_group" {
  description = <<-EOT
    Common CloudWatch Log Group configuration for all services.

    Priority order (higher priority overrides lower):
    1. var.cloudwatch_log_group.override.<service_name>.retention_in_days (highest priority)
    2. var.cloudwatch_log_group.retention_in_days (lowest priority - common default)

    Example:
      cloudwatch_log_group = {
        retention_in_days = 14  # Default for all services
        override = {
          security_cloudtrail = {
            retention_in_days = 90  # Override for security_cloudtrail service
          }
        }
      }
  EOT
  type = object({
    retention_in_days = number
    override = optional(object({
      security_cloudtrail = optional(object({
        retention_in_days = optional(number)
      }))
    }))
  })
}

variable "kms" {
  description = "(Required) KMS key settings (deletion window and key rotation) used to encrypt data of supported services."
  type = map(object({
    description             = string
    deletion_window_in_days = number
    is_enabled              = bool
  }))
}

variable "oidc_github" {
  description = "(Required) GitHub Actions IAM OIDC identity provider and role settings. dangerously_attach_admin_policy should be false in production."
  type = object({
    is_enabled                      = bool
    dangerously_attach_admin_policy = bool
    iam_role_policy_names           = list(string)
    create_oidc_provider            = bool
    github_subjects                 = list(string)
    iam_role_name                   = string
    iam_role_path                   = string
  })
}

variable "security_notification" {
  description = "(Required) Slack channel and workspace settings used for security notifications."
  type = object({
    slack_channel_id = string
    slack_team_id    = string
    guardduty = object({
      is_enabled = bool
    })
    securityhub = object({
      is_enabled = bool
    })
  })
}

variable "access_analyzer_organization" {
  description = "(Required) Organization-level IAM Access Analyzer settings."
  type = object({
    is_enabled    = bool
    analyzer_name = string
  })
}


variable "guardduty_organization" {
  description = "(Required) Organization-level GuardDuty settings."
  type = object({
    is_enabled                       = bool
    create_detector                  = optional(bool, false)
    auto_enable_organization_members = optional(string, "ALL")
    features = optional(map(object({
      auto_enable = string
      additional_configurations = optional(list(object({
        name        = string
        auto_enable = string
      })), [])
    })), {})
  })
}


variable "inspector2_organization" {
  description = "(Required) Organization-level Amazon Inspector v2 settings."
  type = object({
    is_enabled = bool
    enabler = optional(map(object({
      account_ids    = list(string)
      resource_types = list(string)
    })), {})
    # Region => resource types not supported there (e.g. LAMBDA_CODE), removed from every enabler.
    region_excluded_resource_types = optional(map(list(string)), {})
    is_enabled_configuration       = optional(bool, false)
    configuration = optional(object({
      auto_enable_ec2             = bool
      auto_enable_ecr             = bool
      auto_enable_lambda          = bool
      auto_enable_lambda_code     = bool
      auto_enable_code_repository = bool
    }))
  })
}


variable "macie_organization" {
  description = "(Required) Organization-level Amazon Macie settings."
  type = object({
    is_enabled                   = bool
    auto_enable                  = bool
    status                       = string
    finding_publishing_frequency = string
    classification_jobs          = optional(any, [])
    findings_filters             = optional(any, [])
  })
}


variable "securityhub_organization" {
  description = "(Required) Organization-level Security Hub settings."
  type = object({
    is_enabled                    = bool
    is_enabled_finding_aggregator = optional(bool, false)
    configuration_policy = object({
      service_enabled       = bool
      name                  = optional(string)
      enabled_standard_arns = optional(list(string), [])
      security_controls_configuration = optional(object({
        disabled_control_identifiers = optional(list(string), [])
      }))
    })
    configuration_policy_name        = optional(string)
    configuration_policy_description = optional(string, "")
    linking_mode                     = optional(string, "ALL_REGIONS")
    target_id                        = string
  })
}
