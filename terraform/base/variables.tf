variable "control_tower" {
  description = <<-EOT
    (Optional) Control Tower and organization-managed security services configuration.

    Use this object to describe whether Control Tower is enabled and which
    services are centrally managed outside this base stack.

    When managed_services.<service> is omitted, it falls back to is_enabled.
  EOT
  type = object({
    is_enabled = bool
    managed_services = optional(object({
      access_analyzer = optional(bool)
      cloudtrail      = optional(bool)
      config          = optional(bool)
      guardduty       = optional(bool)
      inspector2      = optional(bool)
      macie           = optional(bool)
      securityhub     = optional(bool)
    }))
  })
  default  = null
  nullable = true
}

variable "tags" {
  description = "(Required) Default tags applied to all resources created by this stack."
  type        = map(any)
}

variable "name_prefix" {
  description = "(Required) Prefix prepended to the names of resources created by this stack."
  type        = string
}

variable "region" {
  description = "(Required) Region configuration for multi-region deployment."
  type = object({
    global  = string
    primary = string
    targets = list(string)
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
    condition     = contains(var.region.targets, var.region.global)
    error_message = "region.global must be included in region.targets"
  }
}

variable "cloudwatch_log_group" {
  description = <<-EOT
    (Required) Common CloudWatch Log Group configuration for all services.

    Priority order (higher priority overrides lower):
    1. var.cloudwatch_log_group.override.<service_name>.retention_in_days (highest priority)
    2. var.cloudwatch_log_group.retention_in_days (lowest priority - common default)

    Example:
      cloudwatch_log_group = {
        retention_in_days = 14  # Default for all services
        override = {
          budgets = {
            retention_in_days = 7  # Override for budgets service
          }
          security_cloudtrail = {
            retention_in_days = 90  # Override for security_cloudtrail service
          }
        }
      }
  EOT
  type = object({
    retention_in_days = number
    override = optional(object({
      budgets = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_vpc_flow_log = optional(object({
        retention_in_days = optional(number)
      }))
      guardduty = optional(object({
        retention_in_days = optional(number)
      }))
      health = optional(object({
        retention_in_days = optional(number)
      }))
      iam_password_expired = optional(object({
        retention_in_days = optional(number)
      }))
      security_cloudtrail = optional(object({
        retention_in_days = optional(number)
      }))
      security_config = optional(object({
        retention_in_days = optional(number)
      }))
      security_ssm_automation = optional(object({
        retention_in_days = optional(number)
      }))
      trusted_advisor = optional(object({
        retention_in_days = optional(number)
      }))
    }))
  })
}

variable "slack" {
  description = <<-EOT
    (Required) Common Slack configuration for all Lambda functions.

    Priority order (higher priority overrides lower):
    1. var.slack.override.<function_name> (highest priority)
    2. var.<function_name>.aws_lambda_function.environment.SLACK_* (middle priority)
    3. var.slack (lowest priority - common defaults)

    Example:
      slack = {
        oauth_access_token = "xoxb-common-token"
        channel_id         = "C-common-channel"
        override = {
          budgets = {
            channel_id = "C-budgets-specific-channel"  # Override only channel_id for budgets
          }
          guardduty = {
            oauth_access_token = "xoxb-guardduty-token"  # Override token for guardduty
            channel_id         = "C-guardduty-channel"   # Override channel for guardduty
          }
        }
      }
  EOT
  type = object({
    oauth_access_token = string
    channel_id         = string
    override = optional(object({
      budgets = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      guardduty = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      health = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      trusted_advisor = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      iam_password_expired = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      security_cloudtrail = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      security_config = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
    }))
  })
  #   sensitive = true
}

variable "kms" {
  description = "(Required) KMS key settings (deletion window and key rotation) used to encrypt data of supported services."
  type        = any
}

variable "oidc_github" {
  description = "(Required) GitHub Actions IAM OIDC identity provider and role settings. dangerously_attach_admin_policy should be false in production."
  type        = any
}

variable "resource_groups" {
  description = "(Required) AWS Resource Groups settings."
  type        = any
}

variable "budgets" {
  description = "(Required) AWS Budgets settings, including budget limits and cost alert notification."
  type        = any
}

variable "compute_optimizer" {
  description = "(Required) AWS AWS Compute Optimizer settings for resource right-sizing recommendations and notification."
  type = object({
    is_enabled = bool
  })
}

variable "guardduty" {
  description = "(Required) GuardDuty finding notification settings (EventBridge, Lambda and Slack)."
  type = object({
    is_enabled = bool
    aws_cloudwatch_event_rule = object({
      description = string
      name        = string
      state       = string
    })
  })
}

variable "health" {
  description = "(Required) AWS Health event monitoring and Slack notification settings (regional and global events)."
  type = object({
    is_enabled = bool
    aws_cloudwatch_event_rule = object({
      description = string
      name        = string
      state       = string
    })
  })
}

variable "trusted_advisor" {
  description = "(Required) AWS Trusted Advisor check monitoring and notification settings."
  type = object({
    is_enabled = bool
    aws_eventbridge_schedule = object({
      description         = string
      name                = string
      schedule_expression = string
    })
  })
}

variable "iam_password_expired" {
  description = "(Required) IAM password expiration check and notification settings."
  type = object({
    is_enabled = bool
    aws_eventbridge_schedule = object({
      description         = string
      name                = string
      schedule_expression = string
    })
  })
}

variable "iam" {
  description = "(Required) IAM user, group and switch role settings."
  type        = any
}

variable "common_lambda" {
  description = "(Required) Common Lambda settings (for example VPC placement) shared by the Lambda functions in this stack."
  type        = any
}

variable "common_log" {
  description = "(Required) Common settings for log buckets and log delivery shared across services."
  type        = any
}
# security
variable "security_access_analyzer" {
  description = "(Required) IAM Access Analyzer settings."
  type = object({
    is_enabled = bool
    aws_accessanalyzer_analyzer = object({
      analyzer_name = string
      type          = string
    })
  })
}

variable "security_athena" {
  description = "(Required) Athena security settings (query result encryption for the primary workgroup)."
  type = object({
    is_enabled      = bool
    output_location = optional(string)
    workgroup       = optional(string, "primary")
  })
}

variable "security_cloudtrail" {
  description = "(Required) CloudTrail settings, including CloudWatch log metric filters, alarms and notification."
  type        = any
}

variable "security_config" {
  description = "(Required) AWS Config recorder, delivery channel and rule settings."
  type        = any
}

variable "security_default_vpc" {
  description = "(Required) Default VPC hardening settings (default VPC, subnets, security group and flow logs)."
  type        = any
}

variable "security_ebs" {
  description = "(Required) EBS account-level security defaults (encryption by default and public snapshot access blocking)."
  type = object({
    is_enabled                                  = bool
    is_enabled_ebs_encryption_by_default        = bool
    is_enabled_ebs_public_snapshot_block_access = bool
    state                                       = optional(string, "block-all-sharing")
  })
}

variable "security_ec2_metadata" {
  description = "(Required) EC2 instance metadata defaults (IMDSv2 required for new instances)."
  type = object({
    is_enabled                  = bool
    http_endpoint               = string
    http_put_response_hop_limit = number
    http_tokens                 = string
  })
}

variable "security_ecr" {
  description = "(Required) ECR account-level security defaults (enhanced scanning)."
  type = object({
    is_enabled = bool
  })
}

variable "security_guardduty" {
  description = "(Required) GuardDuty detector and member account settings."
  type = object({
    is_enabled = bool
    aws_guardduty_detector = object({
      enable                       = bool
      finding_publishing_frequency = string
    })
    aws_guardduty_detector_feature = optional(map(object({
      status = string
      additional_configurations = optional(list(object({
        name   = string
        status = string
      })), [])
    })), {})
    aws_guardduty_member = optional(list(object({
      account_id                 = string
      disable_email_notification = bool
      email                      = string
      invitation_message         = string
      invite                     = bool
    })), [])
    # Administrator account ID per region (key: region) whose invitation this account accepts.
    master_account_ids = optional(map(string), {})
  })
  validation {
    condition     = alltrue([for account_id in values(var.security_guardduty.master_account_ids) : can(regex("^[0-9]{12}$", account_id))])
    error_message = "security_guardduty.master_account_ids values must be 12-digit AWS account IDs"
  }
  validation {
    condition     = alltrue([for region in keys(var.security_guardduty.master_account_ids) : contains(var.region.targets, region)])
    error_message = "security_guardduty.master_account_ids keys must be included in region.targets"
  }
}

variable "security_iam" {
  description = "(Required) IAM account security settings, including password policy and support role."
  type        = any
}

variable "security_inspector2" {
  description = "(Required) Amazon Inspector v2 settings."
  type = object({
    is_enabled     = bool
    resource_types = list(string)
  })
}

variable "security_macie" {
  description = "(Required) Amazon Macie settings."
  type = object({
    is_enabled                   = bool
    classification_jobs          = any
    finding_publishing_frequency = string
    findings_filters             = any
    status                       = string
  })
}

variable "security_s3" {
  description = "(Required) S3 account-level public access block settings."
  type = object({
    is_enabled              = bool
    block_public_acls       = bool
    block_public_policy     = bool
    ignore_public_acls      = bool
    restrict_public_buckets = bool
  })
}

variable "security_securityhub" {
  description = "(Required) Security Hub settings, including standards and finding aggregation."
  type = object({
    is_enabled = bool
    # Applied only when Security Hub is enabled for the first time.
    auto_enable_controls = bool
    aws_securityhub_action_target = object({
      description = string
      identifier  = string
      name        = string
    })
    aws_securityhub_member                = map(any)
    aws_securityhub_product_subscription  = map(any)
    cis_aws_foundations_benchmark_version = string
    enable_default_standards              = bool
    enabled_cis_aws_foundations_benchmark = bool
    enabled_pci_dss                       = bool
    pci_dss_version                       = string
  })
}

variable "security_ssm_automation" {
  description = "(Required) Systems Manager Automation security settings (SSM.6 logging and SSM.7 public document sharing block)."
  type = object({
    is_enabled                = bool
    cloudwatch_log_group_name = string
  })
}
