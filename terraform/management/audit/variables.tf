variable "tags" {
  type = map(string)
}
variable "name_prefix" {
  type = string
}
variable "region" {
  type = string
}
variable "us_east_1" {
  description = "Configuration for us-east-1 region resources. Set is_enabled to false to skip all us-east-1 resources."
  type = object({
    is_enabled = bool
  })
  default = {
    is_enabled = true
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
  type = map(object({
    description             = string
    deletion_window_in_days = number
    is_enabled              = bool
  }))
}
variable "oidc_github" {
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
  type = object({
    is_enabled    = bool
    analyzer_name = string
  })
}
variable "access_analyzer_organization_us_east_1" {
  type = object({
    is_enabled    = bool
    analyzer_name = string
  })
}
variable "guardduty_organization" {
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
variable "guardduty_organization_us_east_1" {
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
  type = object({
    is_enabled = bool
    enabler = optional(map(object({
      account_ids    = list(string)
      resource_types = list(string)
    })), {})
    is_enabled_configuration = optional(bool, false)
    configuration = optional(object({
      auto_enable_ec2             = bool
      auto_enable_ecr             = bool
      auto_enable_lambda          = bool
      auto_enable_lambda_code     = bool
      auto_enable_code_repository = bool
    }))
  })
}
variable "inspector2_organization_us_east_1" {
  type = object({
    is_enabled = bool
    enabler = optional(map(object({
      account_ids    = list(string)
      resource_types = list(string)
    })), {})
    is_enabled_configuration = optional(bool, false)
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
  type = object({
    is_enabled                   = bool
    auto_enable                  = bool
    status                       = string
    finding_publishing_frequency = string
    classification_jobs          = optional(any, [])
    findings_filters             = optional(any, [])
  })
}
variable "macie_organization_us_east_1" {
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
variable "securityhub_organization_us_east_1" {
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
