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
      jit_access = optional(object({
        retention_in_days = optional(number)
      }))
      security_cloudtrail = optional(object({
        retention_in_days = optional(number)
      }))
    }))
  })
}
variable "slack" {
  description = <<-EOT
    Common Slack configuration for all Lambda functions.

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
            channel_id = "C-budgets-specific-channel"
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
      security_cloudtrail = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
    }))
  })
  #   sensitive = true
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
variable "budgets" {
  type = object({
    is_enabled = bool
    aws_budgets_budget = object({
      name         = string
      limit_amount = string
      time_unit    = optional(string, "MONTHLY")
      cost_filter  = optional(list(any), [])
      notification = list(object({
        comparison_operator        = string
        threshold                  = string
        threshold_type             = string
        notification_type          = string
        subscriber_email_addresses = list(string)
        subscriber_sns_topic_arns  = optional(list(string))
      }))
    })
    aws_eventbridge_schedule = object({
      name                = string
      schedule_expression = string
      description         = string
    })
    aws_lambda_function = object({
      environment = map(string)
    })
  })
}
variable "common_lambda" {
  type = object({
    vpc = object({
      is_enabled = bool
      create_vpc = bool
      exists = optional(object({
        private_subnets             = list(string)
        security_group_id           = string
        private_subnets_us_east_1   = optional(list(string), [])
        security_group_id_us_east_1 = optional(string, "")
      }))
      new = optional(object({
        name                                      = string
        cidr                                      = string
        azs                                       = list(string)
        azs_us_east_1                             = optional(list(string), [])
        private_subnets                           = list(string)
        public_subnets                            = list(string)
        enable_dns_support                        = bool
        enable_dns_hostnames                      = bool
        enable_nat_gateway                        = bool
        single_nat_gateway                        = bool
        one_nat_gateway_per_az                    = bool
        enable_vpn_gateway                        = bool
        enable_flow_log                           = bool
        create_flow_log_cloudwatch_log_group      = bool
        create_flow_log_cloudwatch_iam_role       = bool
        flow_log_max_aggregation_interval         = number
        flow_log_cloudwatch_log_group_name_prefix = string
        flow_log_file_format                      = string
      }))
    })
    aws_iam_role = optional(object({
      description = optional(string)
      name        = string
      path        = string
    }))
    aws_iam_policy = optional(object({
      description = optional(string)
      name        = string
      path        = string
    }))
  })
}
variable "security_cloudtrail" {
  type = object({
    is_enabled = bool
    aws_cloudwatch_log = optional(map(object({
      aws_cloudwatch_log_metric_filter = object({
        name    = string
        pattern = string
        metric_transformation = list(object({
          name      = string
          namespace = string
          value     = string
        }))
      })
      aws_cloudwatch_metric_alarm = object({
        alarm_name          = string
        comparison_operator = string
        evaluation_periods  = number
        period              = number
        statistic           = string
        threshold           = number
        threshold_metric_id = optional(string)
        actions_enabled     = bool
        alarm_description   = string
        datapoints_to_alarm = number
        dimensions          = optional(map(string))
        treat_missing_data  = string
      })
    })), {})
    aws_sns_topic = optional(object({
      name                                     = string
      name_prefix                              = optional(string)
      display_name                             = optional(string)
      delivery_policy                          = optional(string)
      application_success_feedback_role_arn    = optional(string)
      application_success_feedback_sample_rate = optional(number)
      application_failure_feedback_role_arn    = optional(string)
      http_success_feedback_role_arn           = optional(string)
      http_success_feedback_sample_rate        = optional(number)
      http_failure_feedback_role_arn           = optional(string)
      lambda_success_feedback_role_arn         = optional(string)
      lambda_success_feedback_sample_rate      = optional(number)
      lambda_failure_feedback_role_arn         = optional(string)
      sqs_success_feedback_role_arn            = optional(string)
      sqs_success_feedback_sample_rate         = optional(number)
      sqs_failure_feedback_role_arn            = optional(string)
    }))
    aws_sns_topic_subscription = optional(object({
      protocol                        = string
      endpoint_auto_confirms          = optional(bool, false)
      confirmation_timeout_in_minutes = optional(number)
      raw_message_delivery            = optional(bool)
      filter_policy                   = optional(string)
      delivery_policy                 = optional(string)
      redrive_policy                  = optional(string)
    }))
  })
}
variable "jit_access" {
  description = <<-EOT
    JIT (Just-In-Time) privileged access configuration.
    Manages temporary IAM Identity Center Permission Set assignments via Slack.
  EOT
  type = object({
    is_enabled = bool
    slack = object({
      # Slack channel ID for approval notifications.
      approver_channel_id = string
      # Slack Bot OAuth token (xoxb-...).
      bot_token = string
      # Slack App signing secret for request verification.
      signing_secret = string
      # Slack User ID → Identity Center User ID mapping for users whose Slack email doesn't match Identity Center UserName.
      user_mappings = optional(map(string), {})
      # Shared secret for Slack Workflow Builder webhook authentication. Set null to disable.
      workflow_secret = optional(string)
    })
    # Map of JIT access profiles.
    profiles = map(object({
      account_id           = string
      approvers            = list(string)
      description          = optional(string, "")
      max_duration_minutes = number
      permission_set_arn   = string
    }))
    # EventBridge schedule expression for cleanup checker.
    cleanup_schedule_expression = optional(string, "rate(15 minutes)")
  })
}
