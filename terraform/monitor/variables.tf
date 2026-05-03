variable "tags" {
  type = map(any)
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
          cloudwatch_event_ec2 = {
            retention_in_days = 7  # Override for EC2 events
          }
          metric_log_postgresql_slowquery = {
            retention_in_days = 30  # Override for PostgreSQL slow query
          }
        }
      }
  EOT
  type = object({
    retention_in_days = number
    override = optional(object({
      cloudwatch_event_ec2 = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_log = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_metric = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_ses = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_step_functions = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_step_functions_us_east_1 = optional(object({
        retention_in_days = optional(number)
      }))
      common_lambda_vpc_flow_log = optional(object({
        retention_in_days = optional(number)
      }))
      metric_log_application = optional(object({
        retention_in_days = optional(number)
      }))
      metric_log_postgresql_slowquery = optional(object({
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
    2. var.slack (lowest priority - common defaults)

    Example:
      slack = {
        oauth_access_token = "xoxb-common-token"
        channel_id         = "C-common-channel"
        override = {
          common_lambda_log = {
            channel_id = "C-log-specific-channel"
          }
        }
      }
  EOT
  type = object({
    oauth_access_token = string
    channel_id         = string
    override = optional(object({
      apigateway_report_csp = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      cloudwatch_event_ec2 = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      common_lambda_log = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      common_lambda_metric = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      common_lambda_ses = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      common_lambda_step_functions = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      metric_log_application = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
      metric_log_postgresql_slowquery = optional(object({
        oauth_access_token = optional(string)
        channel_id         = optional(string)
      }))
    }))
  })
  #   sensitive = true
}
variable "kms" {
  type = any
}
variable "common_lambda" {
  type = any
}
variable "common_log" {
  type = any
}
variable "delivery_log" {
  type = any
}
variable "delivery_log_us_east_1" {
  type = any
}
variable "metric_log_application" {
  type        = any
  description = "CloudWatch Logs (Application) resources on AWS"
}
variable "metric_log_application_report" {
  type        = any
  description = "CloudWatch Logs (Application) errors report resources on AWS"
}
# TODO: ex
variable "metric_log_step_functions" {
  type        = any
  description = "CloudWatch Logs (Step Functions) resources on AWS"
}
variable "metric_log_waf" {
  type        = any
  description = "CloudWatch Logs (WAF) resources on AWS"
}
variable "metric_log_waf_us_east_1" {
  type        = any
  description = "CloudWatch Logs (WAF) resources on AWS in us-east-1"
}
variable "metric_log_mysql_slowquery" {
  type        = any
  description = "CloudWatch Logs (MySQL slow query) resources on AWS"
}
variable "metric_log_postgresql" {
  type        = any
  description = "CloudWatch Logs (PostgreSQL) resources on AWS"
}
variable "metric_log_postgresql_slowquery" {
  type        = any
  description = "CloudWatch Logs (PostgreSQL slow query) resources on AWS"
}
variable "metric_log_postgresql_slowquery_report" {
  type        = any
  description = "CloudWatch Logs (PostgreSQL slow query) report resources on AWS"
}
variable "metric_resource_api_gateway" {
  type        = any
  description = "CloudWatch metric resource(API Gateway) resources on AWS"
}
variable "metric_resource_cloudfront" {
  type        = any
  description = "CloudWatch metric resource(CloudFront) resources on AWS"
}
variable "metric_resource_ec2" {
  type        = any
  description = "CloudWatch metric resource(EC2) resources on AWS"
}
variable "metric_resource_ecs_container_insights" {
  type        = any
  description = "CloudWatch metric resource(ECS/ContainerInsights) resources on AWS"
}
variable "metric_resource_elasticache" {
  type        = any
  description = "CloudWatch event(ElastiCache) resources on AWS"
}
variable "metric_resource_elb" {
  type        = any
  description = "CloudWatch metric resource(ELB - ALB/NLB) resources on AWS"
}
variable "metric_resource_eventbridge_scheduler" {
  type        = any
  description = "CloudWatch event(EventBridge Scheduler) resources on AWS"
}
variable "metric_resource_lambda" {
  type        = any
  description = "CloudWatch event(Lambda) resources on AWS"
}
variable "metric_resource_nat_gateway" {
  type        = any
  description = "CloudWatch metric resource(NAT Gateway) resources on AWS"
}
variable "metric_resource_rds_cluster" {
  type        = any
  description = "CloudWatch metric resource(RDS) resources on AWS"
}
variable "metric_resource_redshift" {
  type        = any
  description = "CloudWatch event(Redshift) resources on AWS"
}
variable "metric_resource_ses" {
  type        = any
  description = "CloudWatch event(SES) resources on AWS"
}
variable "metric_resource_sns" {
  type        = any
  description = "CloudWatch event(SNS) resources on AWS"
}
variable "metric_resource_sqs" {
  type        = any
  description = "CloudWatch event(SQS) resources on AWS"
}
variable "cloudwatch_event_ec2" {
  type        = any
  description = "CloudWatch event(EC2) resources on AWS"
}
variable "metric_synthetics_canary" {
  type        = any
  description = "Synthetics canary resources on AWS. Map of function name to configuration (e.g., heartbeat, linkcheck)"
}
variable "athena" {
  type        = any
  description = "Athena resources on AWS"
}
variable "report_csp" {
  type        = any
  description = "API Gateway resources on AWS"
}
variable "eventbridge" {
  type        = any
  description = "EventBridge resources on AWS"
}
