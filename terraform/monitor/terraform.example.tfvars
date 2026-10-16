#--------------------------------------------------------------
# Basically, it is already set so that the setting is completed only by changing tfvars.
# All parameters that need to be changed for each environment are described in CUSTOMIZE comments.
#
# ENVIRONMENT-SPECIFIC CONFIGURATION GUIDE:
# - Development: Minimal monitoring, disable expensive analytics, basic alerting
# - Staging: Moderate monitoring, enable testing features, moderate alerting
# - Production: Comprehensive monitoring, enable analytics, strict alerting thresholds
#
# IMPORTANT: Always review and adjust these settings based on your monitoring
# requirements, alerting preferences, and cost constraints.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Default Tags for Resources
# A tag that is set globally for the resources used.
# These tags are automatically applied to all resources created by this Terraform configuration.
# Common tags help with cost allocation, resource organization, and compliance tracking.
#--------------------------------------------------------------
# CUSTOMIZE: need to change tags.
tags = {
  # CUSTOMIZE: need to change env.
  # Environment name for resource identification and cost allocation
  # Examples: "dev", "stg", "prd", "audit", "root"
  env = "example"
  # CUSTOMIZE: need to change service.
  # Service/project name for resource grouping and identification
  # This should match your project name, job name, or product name
  service = "base"
  # Map Program (optional)
  # Uncomment and set if you have a Migration Acceleration Program (MAP) assessment ID
  # This helps track resources for AWS migration programs
  # map-migrated = "xxxxxxxxxxxxx"
}

#--------------------------------------------------------------
# Name prefix
# It is used as a prefix attached to various resource names.
# This prefix helps identify resources belonging to this project and environment.
# Example: If name_prefix="myproject-", resources will be named "myproject-vpc", "myproject-lambda", etc.
#--------------------------------------------------------------
name_prefix = "base-"

#--------------------------------------------------------------
# Default Region for Resources
# Region Configuration
# - global:  Global resources (CloudFront, Route53, WAF, ACM) — must be us-east-1
# - primary: Development and operations base region (fallback for provider)
# - targets: All regions where regional resources are deployed
#
# Common regions:
# https://docs.aws.amazon.com/global-infrastructure/latest/regions/aws-regions.html
#--------------------------------------------------------------
region = {
  # CUSTOMIZE: Global resources (CloudFront, Route53, WAF, ACM) — must be us-east-1
  global = "us-east-1"
  # CUSTOMIZE: Development and operations base region (fallback for provider)
  primary = "ap-northeast-1"
  # CUSTOMIZE: All regions where regional resources are deployed
  targets = ["ap-northeast-1", "us-east-1"]
}

#--------------------------------------------------------------
# CloudWatch Log Group Configuration
# Common CloudWatch Log Group settings for all services.
# This configuration is applied globally but can be overridden per service.
#
# Priority order (higher priority overrides lower):
# 1. cloudwatch_log_group.override.<service_name>.retention_in_days (highest priority)
# 2. cloudwatch_log_group.retention_in_days (lowest priority - common default)
#
# retention_in_days: How long logs are kept before automatic deletion
# Common values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653
# COST CONSIDERATION: Longer retention = higher CloudWatch Logs storage costs
#
# Use cloudwatch_log_group.override for centralized management.
#--------------------------------------------------------------
# CUSTOMIZE: need to change cloudwatch_log_group settings.
cloudwatch_log_group = {
  # Default retention period for all services (in days)
  retention_in_days = 14

  # Optional: Override settings for specific services
  # Uncomment and configure as needed
  override = {
    # cloudwatch_event_ec2 = {
    #   retention_in_days = 7
    # }
    # common_lambda_kinesis_data_firehose_cloudwatch_logs_processor = {
    #   retention_in_days = 14
    # }
    # common_lambda_log = {
    #   retention_in_days = 7
    # }
    # common_lambda_metric = {
    #   retention_in_days = 14
    # }
    # common_lambda_s3_notification_s3_object_created_for_athena = {
    #   retention_in_days = 14
    # }
    # common_lambda_ses = {
    #   retention_in_days = 7
    # }
    # common_lambda_step_functions = {
    #   retention_in_days = 14
    # }
    # common_lambda_vpc_flow_log = {
    #   retention_in_days = 7
    # }
    # metric_log_application = {
    #   retention_in_days = 14
    # }
    # metric_log_postgresql_slowquery = {
    #   retention_in_days = 14
    # }
  }
}

#--------------------------------------------------------------
# Slack Configuration
# Common Slack settings for Lambda function notifications.
#
# Priority order (higher priority overrides lower):
# 1. slack.override.<function_name> (highest priority)
# 2. slack (lowest priority - common defaults)
#
# These values can be overridden in individual Lambda function configurations if needed.
# Use slack.override for centralized management instead of environment variables.
#--------------------------------------------------------------
slack = {
  # CUSTOMIZE: need to change SLACK_OAUTH_ACCESS_TOKEN (bot token xoxb-xxxxxx....)
  # Get this from your Slack app's OAuth & Permissions page
  # Format: xoxb-XXXXXXXXX-XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX
  oauth_access_token = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
  # CUSTOMIZE: need to change SLACK_CHANNEL_ID
  # Right-click on your Slack channel and select "Copy link" to find the channel ID
  channel_id = "C0XXXXXXXXX"

  # -----------------------------------------------------------
  # Override Configuration (Optional)
  # Override Slack settings for specific Lambda functions.
  # Priority order: override (highest) > defaults (lowest)
  #
  # Available function overrides:
  # - common_lambda_log: CloudWatch Alarms to Slack
  # - common_lambda_ses: CloudWatch Alarms via SES to Slack
  # - common_lambda_metric: Kinesis Data Firehose CloudWatch Logs Processor
  # - step_functions: Step Functions Log to Slack
  # - cloudwatch_event_ec2: EC2 Events to Slack
  # - metric_log_application: Application Errors Report to Slack
  # - metric_log_postgresql_slowquery: PostgreSQL Slow Query to Slack
  # - apigateway_report_csp: API Gateway CSP Reports to Slack
  # -----------------------------------------------------------
  # Optional: Override slack settings for specific Lambda functions
  # Uncomment and configure as needed
  override = {
    # apigateway_report_csp = {
    #   channel_id         = "C0XXXXXXXX"
    # }
    # cloudwatch_event_ec2 = {
    #   channel_id         = "C0XXXXXXXXX"
    # }
    # common_lambda_log = {
    #   channel_id         = "C0XXXXXXXXX"
    # }
    # common_lambda_metric = {
    #   channel_id         = "C0XXXXXXXXX"
    # }
    # common_lambda_ses = {
    #   channel_id         = "C0XXXXXXXXX"
    # }
    # common_lambda_s3_notification_s3_object_created_for_athena = {
    #   channel_id         = "C0XXXXXXXXX"
    # }
    # common_lambda_step_functions = {
    #   channel_id         = "C0XXXXXXXXX"
    # }
    # metric_log_application = {
    #   channel_id         = "C0XXXXXXXXX"
    # }
    # metric_log_postgresql_slowquery = {
    #   channel_id         = "C0XXXXXXXXX"
    # }
  }
}

#--------------------------------------------------------------
# KMS
# AWS Key Management Service (KMS) keys for encrypting sensitive data.
# These keys are used to encrypt many services.
# Enable key rotation for enhanced security (rotates keys annually).
#--------------------------------------------------------------
kms = {
  monitor = {
    description             = "This key used for monitor default."
    deletion_window_in_days = 7
    is_enabled              = true
  }
  monitor_devops_agent = {
    description             = "This key used for AWS DevOps Agent Space."
    deletion_window_in_days = 30
    is_enabled              = true
  }
}

#--------------------------------------------------------------
# Common:Log Bucket
#--------------------------------------------------------------
common_log = {
  #--------------------------------------------------------------
  # S3 for application log
  # https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
  #--------------------------------------------------------------
  s3_application_log = {
    bucket               = "aws-log-application"
    create_bucket        = true
    attach_public_policy = true
    block_public_acls    = true
    block_public_policy  = true
    force_destroy        = true
    ignore_public_acls   = true
    lifecycle_rule = [
      {
        id                                     = "default"
        abort_incomplete_multipart_upload_days = 7
        enabled                                = true
        prefix                                 = null
        expiration = {
          # CUSTOMIZE: need to change days. default 3years.
          # Adjust retention period based on your compliance requirements
          days                         = 1095
          expired_object_delete_marker = null
        }
        transition = [
          {
            days          = 30
            storage_class = "ONEZONE_IA"
          }
        ]
        noncurrent_version_expiration = {
          days = 30
        }
      }
    ]
    # CUSTOMIZE: need to change for logging.
    # example)
    #    logging = {
    #      target_bucket = "{your bucket}"
    #      target_prefix = "AccessLogs/{your account id}/S3/{your bucket}/"
    #    }
    logging                 = null
    restrict_public_buckets = true
    server_side_encryption_configuration = {
      rule = {
        bucket_key_enabled       = false
        blocked_encryption_types = ["SSE-C"]
        apply_server_side_encryption_by_default = {
          sse_algorithm     = "AES256"
          kms_master_key_id = null
        }
      }
    }
    versioning = {
      enabled = true
    }
  }
}

#--------------------------------------------------------------
# Common: settings for notifying metrics
#--------------------------------------------------------------
common_lambda = {
  vpc = {
    # CUSTOMIZE: If you want to run LambdaFunctions inside a VPC, set to true. However,
    # VPC requires more cost since you need to configure NAT Gateway and other settings.
    is_enabled = false
    # CUSTOMIZE: If a VPC has already been established, specify false; if a new VPC is to be created, specify true.
    create_vpc = false

    # CUSTOMIZE: To specify a VPC that already exists, configure the following settings for Lambda.
    # If var.common_lambda.vpc.is_enabled = true and var.common_lambda.vpc.create_vpc = false,
    # the Lambda will be built in an existing VPC by referencing the parameters here.
    exists = {
      private_subnets = [
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
      ]
      security_group_id = "sg-xxxxxxxxxxxxxxxxx"
    }
    # CUSTOMIZE: To specify a new VPC to be set up for Lambda, please set the following information.
    # If var.common_lambda.vpc.is_enabled = true and var.common_lambda.vpc.create_vpc = true,
    # a new VPC is built by referencing the parameters here.
    new = {
      name = "vpc-lambda"
      cidr = "10.0.0.0/16"
      private_subnets = [
        "10.0.1.0/24",
        "10.0.2.0/24",
        "10.0.3.0/24"
      ]
      public_subnets = [
        "10.0.101.0/24",
        "10.0.102.0/24",
        "10.0.103.0/24"
      ]
      enable_dns_support   = true
      enable_dns_hostnames = true

      # No NAT Gateway(private subnet can't access internet.)
      #   enable_nat_gateway     = false
      #   single_nat_gateway     = false
      #   one_nat_gateway_per_az = false

      # One NAT Gateway per subnet (default behavior)
      enable_nat_gateway     = true
      single_nat_gateway     = false
      one_nat_gateway_per_az = false

      # VPN Gateway
      enable_vpn_gateway = false

      # Flow Log(plain-text or parquet)
      enable_flow_log                      = true
      create_flow_log_cloudwatch_log_group = true
      create_flow_log_cloudwatch_iam_role  = true
      flow_log_file_format                 = "plain-text"
    }
  }
  metric = {
    aws_sns_topic = {
      name                                     = "aws-metric"
      name_prefix                              = null
      display_name                             = null
      policy                                   = null
      delivery_policy                          = null
      application_success_feedback_role_arn    = null
      application_success_feedback_sample_rate = null
      application_failure_feedback_role_arn    = null
      http_success_feedback_role_arn           = null
      http_success_feedback_sample_rate        = null
      http_failure_feedback_role_arn           = null
      lambda_success_feedback_role_arn         = null
      lambda_success_feedback_sample_rate      = null
      lambda_failure_feedback_role_arn         = null
      sqs_success_feedback_role_arn            = null
      sqs_success_feedback_sample_rate         = null
      sqs_failure_feedback_role_arn            = null
    }
    aws_lambda_function = {
      environment = {
        # CUSTOMIZE: need to change TIMEZONE.
        # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
        TIMEZONE = "Asia/Tokyo"
        # CUSTOMIZE: AWS DevOps Agent generic webhook (of the Agent Space in the primary account) that the alert Lambda forwards to.
        # Both values come from the primary account (prd):
        #   URL         : terraform output -json devops_agent_webhook_urls | jq -r '."<name>"'
        #   HMAC secret : aws secretsmanager get-secret-value --secret-id <name_prefix without "-">/<name>/webhook --query SecretString --output text | jq -r .webhook_secret
        # The HMAC secret is kept in tfvars and in the Lambda environment, like SLACK_OAUTH_ACCESS_TOKEN. Never commit it to a public repository.
        # Notes:
        #   - The webhook exists only in the primary account (agent_spaces.<name>.webhook.is_enabled = true there). Apply it first.
        #   - Re-creating the webhook (destroy, or renaming the Agent Space key) changes both values. Update every account afterwards.
        #   - Set the same values for every Lambda that sends to the webhook (metric and log).
        # DEVOPS_AGENT_WEBHOOK_URL = "https://example.invalid/webhook" # pragma: allowlist secret
        # DEVOPS_AGENT_WEBHOOK_HMAC_SECRET = "xxxxxxxx" # pragma: allowlist secret
      }
    }
  }
  log = {
    aws_sns_topic = {
      name                                     = "aws-log"
      name_prefix                              = null
      display_name                             = null
      policy                                   = null
      delivery_policy                          = null
      application_success_feedback_role_arn    = null
      application_success_feedback_sample_rate = null
      application_failure_feedback_role_arn    = null
      http_success_feedback_role_arn           = null
      http_success_feedback_sample_rate        = null
      http_failure_feedback_role_arn           = null
      lambda_success_feedback_role_arn         = null
      lambda_success_feedback_sample_rate      = null
      lambda_failure_feedback_role_arn         = null
      sqs_success_feedback_role_arn            = null
      sqs_success_feedback_sample_rate         = null
      sqs_failure_feedback_role_arn            = null
    }
    aws_lambda_function = {
      environment = {
        # CUSTOMIZE: AWS DevOps Agent generic webhook (of the Agent Space in the primary account) that the alert Lambda forwards to.
        # Both values come from the primary account (prd):
        #   URL         : terraform output -json devops_agent_webhook_urls | jq -r '."<name>"'
        #   HMAC secret : aws secretsmanager get-secret-value --secret-id <name_prefix without "-">/<name>/webhook --query SecretString --output text | jq -r .webhook_secret
        # The HMAC secret is kept in tfvars and in the Lambda environment, like SLACK_OAUTH_ACCESS_TOKEN. Never commit it to a public repository.
        # Notes:
        #   - The webhook exists only in the primary account (agent_spaces.<name>.webhook.is_enabled = true there). Apply it first.
        #   - Re-creating the webhook (destroy, or renaming the Agent Space key) changes both values. Update every account afterwards.
        #   - Set the same values for every Lambda that sends to the webhook (metric and log).
        # DEVOPS_AGENT_WEBHOOK_URL = "https://example.invalid/webhook" # pragma: allowlist secret
        # DEVOPS_AGENT_WEBHOOK_HMAC_SECRET = "xxxxxxxx" # pragma: allowlist secret
      }
    }
  }
  step_functions_log = {
    aws_sns_topic = {
      name                                     = "aws-step-functions-log"
      name_prefix                              = null
      display_name                             = null
      policy                                   = null
      delivery_policy                          = null
      application_success_feedback_role_arn    = null
      application_success_feedback_sample_rate = null
      application_failure_feedback_role_arn    = null
      http_success_feedback_role_arn           = null
      http_success_feedback_sample_rate        = null
      http_failure_feedback_role_arn           = null
      lambda_success_feedback_role_arn         = null
      lambda_success_feedback_sample_rate      = null
      lambda_failure_feedback_role_arn         = null
      sqs_success_feedback_role_arn            = null
      sqs_success_feedback_sample_rate         = null
      sqs_failure_feedback_role_arn            = null
    }
  }
  ses = {
    aws_sns_topic = {
      name                                     = "aws-ses"
      name_prefix                              = null
      display_name                             = null
      policy                                   = null
      delivery_policy                          = null
      application_success_feedback_role_arn    = null
      application_success_feedback_sample_rate = null
      application_failure_feedback_role_arn    = null
      http_success_feedback_role_arn           = null
      http_success_feedback_sample_rate        = null
      http_failure_feedback_role_arn           = null
      lambda_success_feedback_role_arn         = null
      lambda_success_feedback_sample_rate      = null
      lambda_failure_feedback_role_arn         = null
      sqs_success_feedback_role_arn            = null
      sqs_success_feedback_sample_rate         = null
      sqs_failure_feedback_role_arn            = null
    }
    aws_lambda_function = {
      environment = {
        LOG_GROUP_NAME = "/aws/ses/log"
      }
    }
  }
  aws_iam_role = {
    description = null
    name        = "monitor-lambda-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = null
    name        = "monitor-lambda-policy"
    path        = "/"
  }
  aws_sns_topic_subscription = {
    protocol                        = "lambda"
    endpoint_auto_confirms          = false
    confirmation_timeout_in_minutes = null
    raw_message_delivery            = null
    filter_policy                   = null
    delivery_policy                 = null
    redrive_policy                  = null
  }
}

#--------------------------------------------------------------
# Delivery: log
# Each log group in CloudWatchLogs is transferred to S3 by Kinesis Data Firehose.
# Specify the target log group in the log_group_names variable to transfer logs to S3.
#--------------------------------------------------------------
delivery_log = {
  # CUSTOMIZE: need to set is_enabled for settings of delivery log.
  is_enabled = false
  # (Optional) Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored.
  create_auto_log_group_names = true
  # (Optional) If create_auto_log_group_names is set to true, a list of log_group_names will be automatically registered, but at that time, specify the log group name you want to exclude using partial match.
  auto_log_group_names_exclude_list = [
    "/aws/apigateway/welcome",
    "/aws/lambda/aws-controltower-NotificationForwarder",
    "StackSet-AWSControlTowerBP-VPC-ACCOUNT-FACTORY"
  ]
  # (Optional) If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included.
  auto_log_group_names_include_list = []

  # (Optional) If create_auto_log_group_names is set to false, need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/lambda | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  # ex3) aws logs describe-log-groups | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []
  #--------------------------------------------------------------
  # Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
  #--------------------------------------------------------------
  aws_kinesis_firehose_delivery_stream = {
    extended_s3_configuration = {
      buffering_size     = 5
      buffering_interval = 60
      prefix             = "Logs/"
      compression_format = "GZIP"
      dynamic_partitioning_configuration = {
        enabled = false
      }
    }
  }
  aws_iam_role_kinesis_firehose = {
    description = null
    name        = "monitor-kinesis-firehose-role"
    path        = "/"
  }
  aws_iam_policy_kinesis_firehose = {
    description = null
    name        = "monitor-kinesis-firehose-policy"
    path        = "/"
  }
  aws_iam_role_cloudwatch_logs = {
    description = null
    name        = "monitor-cloudwatch-logs-kinesis-firehose-role"
    path        = "/"
  }
  aws_iam_policy_cloudwatch_logs = {
    description = null
    name        = "monitor-cloudwatch-logs-kinesis-firehose-policy"
    path        = "/"
  }
}

#--------------------------------------------------------------
# Delivery: log(us-east-1)
# Each log group in CloudWatchLogs is transferred to S3 by Kinesis Data Firehose.
# Specify the target log group in the log_group_names variable to transfer logs to S3.
#--------------------------------------------------------------
delivery_log_us_east_1 = {
  # CUSTOMIZE: need to set is_enabled for settings of delivery log.
  is_enabled = false
  # (Optional) Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored.
  create_auto_log_group_names = true
  # (Optional) If create_auto_log_group_names is set to true, a list of log_group_names will be automatically registered, but at that time, specify the log group name you want to exclude using partial match.
  auto_log_group_names_exclude_list = [
    "/aws/apigateway/welcome",
    "/aws/lambda/aws-controltower-NotificationForwarder",
    "StackSet-AWSControlTowerBP-VPC-ACCOUNT-FACTORY"
  ]
  # (Optional) If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included.
  auto_log_group_names_include_list = []

  # (Optional) If create_auto_log_group_names is set to false, need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --region us-east-1 --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --region us-east-1 --log-group-name-prefix /aws/lambda | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  # ex3) aws logs describe-log-groups --region us-east-1 | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []
  #--------------------------------------------------------------
  # Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
  #--------------------------------------------------------------
  aws_kinesis_firehose_delivery_stream = {
    extended_s3_configuration = {
      buffering_size     = 5
      buffering_interval = 60
      prefix             = "Logs/"
      compression_format = "GZIP"
      dynamic_partitioning_configuration = {
        enabled = false
      }
    }
  }
  aws_iam_role_kinesis_firehose = {
    description = null
    name        = "monitor-kinesis-firehose-us-east-1-role"
    path        = "/"
  }
  aws_iam_policy_kinesis_firehose = {
    description = null
    name        = "monitor-kinesis-firehose-us-east-1-policy"
    path        = "/"
  }
  aws_iam_role_cloudwatch_logs = {
    description = null
    name        = "monitor-cloudwatch-logs-kinesis-firehose-us-east-1-role"
    path        = "/"
  }
  aws_iam_policy_cloudwatch_logs = {
    description = null
    name        = "monitor-cloudwatch-logs-kinesis-firehose-us-east-1-policy"
    path        = "/"
  }
}

#--------------------------------------------------------------
# Log:Application
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to Application.
#--------------------------------------------------------------
metric_log_application = {
  # CUSTOMIZE: need to set is_enabled for settings of application log.
  is_enabled = false
  # (Optional) Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored.
  create_auto_log_group_names = true
  # (Optional) If create_auto_log_group_names is set to true, a list of log_group_names will be automatically registered, but at that time, specify the log group name you want to exclude using partial match.
  auto_log_group_names_exclude_list = [
    "/aws-glue/jobs/error",
    "/aws-glue/jobs/logs-v2",
    "/aws-glue/sessions/error",
    "/aws/api-gateway",
    "/aws/apigateway",
    "/aws/ecs/containerinsights",
    "/aws/ecs/example-",
    "/aws/lambda/aws-controltower-NotificationForwarder",
    "/aws/lambda/base-",
    "/aws/kinesis",
    "/aws/rds",
    "/aws/redshift",
    "/aws/transfer/",
    "/aws/vpc-flow-log/",
    "API-Gateway-Execution-Logs",
    "StackSet",
    "aws-waf-logs",
    "base-aws-vpc",
  ]
  # (Optional) If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included.
  auto_log_group_names_include_list = []

  # (Optional) If create_auto_log_group_names is set to false, need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []

  # (Optional) Override settings for specific log groups. Key is the exact log group name.
  # Each log group can override enabled / pattern / threshold / evaluation_periods / datapoints_to_alarm / period (all optional; unspecified values fall back to aws_cloudwatch_log_metric_filter and aws_cloudwatch_metric_alarm).
  # enabled = false creates neither the metric filter nor the alarm for that log group. pattern replaces the whole filter pattern, so copy the common pattern and add the exclusions.
  # log_group_override = {
  #   "/aws/lambda/example" = {
  #     enabled             = false
  #     pattern             = "?ERROR"
  #     threshold           = 5
  #     evaluation_periods  = 1
  #     datapoints_to_alarm = 1
  #     period              = 60
  #   }
  # }
  log_group_override = {}
  aws_cloudwatch_log_metric_filter = {
    name = "application-logs-error"
    # CUSTOMIZE: need to change pattern for application log.
    pattern = <<PATTERN
[( msg="*\"ERROR\"*" || msg="*\"error\"*" || msg="*\"FATAL\"*" || msg="*\"fatal\"*" || msg="*\"PANIC\"*" || msg="*\"panic\"*" || msg="*\"CRITICAL\"*" || msg="*\"critical\"*" || msg="*AccessDenied*" || msg="*ERROR*" || msg="*Failed\"*" || msg="*Aborted\"*" || msg="*TimedOut\"*" || msg="*FailStateEntered\"*") && ( msg!="*ExecutionSucceeded\"*" && msg!="*'PAUSED'*" && msg!=%"level": ?"(debug|info|warn|warning)"% && msg!="{\"header\":*")]
PATTERN

    metric_transformation = [
      {
        name      = "application-logs-error"
        namespace = "Application"
        value     = "1"
      }
    ]
  }
  aws_cloudwatch_metric_alarm = {
    alarm_name          = "application-logs-error"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    period              = 60
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Alert log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
}

#--------------------------------------------------------------
# Log:Application Errors Report
# Periodically aggregates application error logs and sends a summary report to Slack.
# Uses EventBridge Scheduler to trigger a Lambda function that queries CloudWatch Logs.
#--------------------------------------------------------------
metric_log_application_report = {
  # CUSTOMIZE: need to set is_enabled for settings of application errors report every day.
  #      If you want to set report, set is_enabled = true.
  is_enabled = false
  aws_eventbridge_schedule = {
    name                = "application-errors-sch"
    schedule_expression = "cron(0 0 * * ? *)" # Every day at 00:00 UTC
    description         = "This eventbridge scheduler called application errors lambda function."
  }
  aws_lambda_function = {
    environment = {
      # CUSTOMIZE: need to change OUTPUT_MODE. csv, html, both are available, but html is recommended for readability.
      OUTPUT_MODE = "html"
      # CUSTOMIZE: need to change TIMEZONE.
      # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      TIMEZONE = "Asia/Tokyo"
    }
  }
}

#--------------------------------------------------------------
# Log:Step Functions
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to Step Functions
#--------------------------------------------------------------
metric_log_step_functions = {
  # CUSTOMIZE: need to set is_enabled for settings of application log.
  is_enabled = false
  # (Optional) Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored.
  create_auto_log_group_names = true
  # (Optional) If create_auto_log_group_names is set to true, a list of log_group_names will be automatically registered, but at that time, specify the log group name you want to exclude using partial match.
  auto_log_group_names_exclude_list = []
  # (Optional) If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included.
  auto_log_group_names_include_list = [
    "/aws/sfn/",
  ]
  # (Optional) If create_auto_log_group_names is set to false, need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/sfn/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []

  aws_cloudwatch_log_metric_filter = {
    name = "step-functions-logs-success"
    # CUSTOMIZE: need to change pattern for application log.
    pattern = <<PATTERN
[( msg="*ExecutionSucceeded\"*")]
PATTERN

    metric_transformation = [
      {
        name      = "step-functions-logs-success"
        namespace = "Application"
        value     = "1"
      }
    ]
  }
  aws_cloudwatch_metric_alarm = {
    alarm_name          = "step-functions-logs-success"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    period              = 60
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Success log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
}

#--------------------------------------------------------------
# Log:WAF
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to WAF.
#--------------------------------------------------------------
metric_log_waf = {
  # CUSTOMIZE: need to set is_enabled for settings of application log.
  is_enabled = false
  # (Optional) Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored.
  create_auto_log_group_names = true
  # (Optional) If create_auto_log_group_names is set to true, a list of log_group_names will be automatically registered, but at that time, specify the log group name you want to exclude using partial match.
  auto_log_group_names_exclude_list = []
  # (Optional) If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included.
  auto_log_group_names_include_list = [
    "aws-waf-logs",
  ]

  # (Optional) If create_auto_log_group_names is set to false, need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex) aws logs describe-log-groups --log-group-name-prefix aws-waf | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []
  aws_cloudwatch_log_metric_filter = {
    name = "waf-logs-error"
    # CUSTOMIZE: need to change pattern for application log.
    pattern = <<PATTERN
{$.action= "BLOCK" && $.terminatingRuleType = "MANAGED_RULE_GROUP"}
PATTERN

    metric_transformation = [
      {
        name      = "waf-logs-error"
        namespace = "WAF"
        value     = "1"
      }
    ]
  }
  aws_cloudwatch_metric_alarm = {
    alarm_name          = "waf-logs-error"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    period              = 60
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Alert WAF log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
}

#--------------------------------------------------------------
# Log:WAF(us-east-1)
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to WAF.
#--------------------------------------------------------------
metric_log_waf_us_east_1 = {
  # CUSTOMIZE: need to set is_enabled for settings of application log.
  is_enabled = false
  # (Optional) Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored.
  create_auto_log_group_names = true
  # (Optional) If create_auto_log_group_names is set to true, a list of log_group_names will be automatically registered, but at that time, specify the log group name you want to exclude using partial match.
  auto_log_group_names_exclude_list = []
  # (Optional) If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included.
  auto_log_group_names_include_list = [
    "aws-waf-logs",
  ]

  # (Optional) If create_auto_log_group_names is set to false, need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex) aws logs describe-log-groups --log-group-name-prefix aws-waf | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []
  aws_cloudwatch_log_metric_filter = {
    name = "waf-logs-error"
    # CUSTOMIZE: need to change pattern for application log.
    pattern = <<PATTERN
{$.action= "BLOCK" && $.terminatingRuleType = "MANAGED_RULE_GROUP"}
PATTERN

    metric_transformation = [
      {
        name      = "waf-logs-error"
        namespace = "WAF"
        value     = "1"
      }
    ]
  }
  aws_cloudwatch_metric_alarm = {
    alarm_name          = "waf-logs-error"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    period              = 60
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Alert WAF log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
}

#--------------------------------------------------------------
# Log:MySQL slow query
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to MySQL.
#--------------------------------------------------------------
metric_log_mysql_slowquery = {
  # CUSTOMIZE: need to set is_enabled for settings of mysql slowquery log.
  is_enabled = false
  # CUSTOMIZE: need to add log_group_name for mysql slowquery.
  #       check log group name for mysql slowquery.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = [
    #    "/aws/rds/cluster/example-db/slowquery",
  ]

  aws_cloudwatch_log_metric_filter = {
    name = "mysql-slowquery-logs-error"
    # CUSTOMIZE: need to change pattern for postgresql log.
    pattern = <<PATTERN
-rdsproxy -rdsproxyadmin -rdsadmin
PATTERN
    metric_transformation = [
      {
        name      = "mysql-slowquery-logs-error"
        namespace = "MySQL"
        value     = "1"
      }
    ]
  }
  aws_cloudwatch_metric_alarm = {
    alarm_name          = "mysql-slowquery-logs-error"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    period              = 300
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Alert MySQL slow query log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
}

#--------------------------------------------------------------
# Log:PostgreSQL
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to PostgreSQL.
#--------------------------------------------------------------
metric_log_postgresql = {
  # CUSTOMIZE: need to set is_enabled for settings of postgresql log.
  is_enabled = false
  # CUSTOMIZE: need to add log_group_name for postgresql.
  #       check log group name for postgresql.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = [
    # "/aws/rds/cluster/example-db/postgresql"
  ]

  aws_cloudwatch_log_metric_filter = {
    name = "postgresql-logs-error"
    # CUSTOMIZE: need to change pattern for postgresql log.
    # [the database system...]: is start database instance log.
    # [Can't handle storage runtime process crash]: is start database instance log.
    # [canceling statement due to statement timeout] is normal operation when statement timeout occurs.
    # [idle-in-transaction timeout]: application-level protection (db-long-lock-mitigation, B2C-11941). benign nightly batch event.
    # [connection to client lost]: client disconnected during nightly batch. benign.
    # [conflict with recovery]: reader WAL-apply conflict during recovery. benign and transient.
    # [terminating background worker]: parallel-worker teardown after client-side timeout during the daily batch. benign nightly batch event.
    # [could not map dynamic shared memory segment]: parallel-worker DSM teardown after a canceled parallel query (statement timeout). benign, reader-only.
    # [could not attach to dynamic shared area]: parallel-worker DSA teardown after a canceled parallel query (statement timeout). benign, reader-only.
    pattern = <<PATTERN
[( msg="*ERROR:*" || msg="*FATAL:*" ) && ( msg!="*FATAL:*the database system*" && msg!="*FATAL:*Can't handle storage runtime process crash*" && msg!="*ERROR:*canceling autovacuum task*" && msg!="*ERROR:*canceling statement due to statement timeout*" && msg!="*FATAL:*idle-in-transaction timeout*" && msg!="*FATAL:*connection to client lost*" && msg!="*conflict with recovery*" && msg!="*FATAL:*terminating background worker*" && msg!="*ERROR:*could not map dynamic shared memory segment*" && msg!="*ERROR:*could not attach to dynamic shared area*")]
PATTERN
    metric_transformation = [
      {
        name      = "postgresql-logs-error"
        namespace = "PostgreSQL"
        value     = "1"
      }
    ]
  }
  aws_cloudwatch_metric_alarm = {
    alarm_name          = "postgresql-logs-error"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    period              = 300
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Alert PostgreSQL log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
}

#--------------------------------------------------------------
# Log:PostgreSQL slow query
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to PostgreSQL.
#--------------------------------------------------------------
metric_log_postgresql_slowquery = {
  # CUSTOMIZE: need to set is_enabled for settings of postgresql slow query alert every time.
  #      If you want to set alert, set is_enabled = true.
  is_enabled = false

  # CUSTOMIZE: need to add log_group_name for postgresql.
  #       check log group name for postgresql.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = [
    # "/aws/rds/cluster/example-db/postgresql"
  ]

  aws_cloudwatch_log_metric_filter = {
    name = "postgresql-slowquery-logs-error"
    # CUSTOMIZE: need to change pattern for postgresql slow query filter.
    pattern = <<PATTERN
[( msg="*duration:*" ) && ( msg!="*aws_s3.table_import_from_s3*" && msg!="*INSERT INTO*" && msg!="*MERGE INTO*" && msg!=%ci[0-9]{5}.do% && msg!="*statement: FETCH*" && msg!="*statement: REFRESH MATERIALIZED VIEW*")]
PATTERN
    metric_transformation = [
      {
        name      = "postgresql-slowquery-error"
        namespace = "PostgreSQL"
        value     = "1"
      }
    ]
  }
  aws_cloudwatch_metric_alarm = {
    alarm_name          = "postgresql-slowquery-logs-error"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    period              = 300
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Alert PostgreSQL slow query log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
}

#--------------------------------------------------------------
# Log:PostgreSQL slow query report
# Periodically aggregates PostgreSQL slow query logs and sends a summary report to Slack.
# Uses EventBridge Scheduler to trigger a Lambda function that queries CloudWatch Logs.
#--------------------------------------------------------------
metric_log_postgresql_slowquery_report = {
  # CUSTOMIZE: need to set is_enabled for settings of postgresql slow queries report every day.
  #      If you want to set report, set is_enabled = true.
  is_enabled = true
  aws_eventbridge_schedule = {
    name                = "postgresql-slowquery-sch"
    schedule_expression = "cron(0 0 * * ? *)" # Every day at 00:00 UTC
    description         = "This eventbridge scheduler called PostgreSQL slow query lambda function."
  }
  aws_lambda_function = {
    environment = {
      LOG_GROUP_NAME = "/aws/rds/cluster/example-db/postgresql"
      # CUSTOMIZE: need to change LOG_GROUP_FILTER_PATTERN for postgresql slow query filter.
      LOG_GROUP_FILTER_PATTERN = <<PATTERN
[( msg="*duration:*" ) && ( msg!="*aws_s3.table_import_from_s3*" && msg!="*INSERT INTO*" && msg!="*MERGE INTO*" && msg!=%ci[0-9]{5}.do% && msg!="*statement: FETCH*" && msg!="*statement: REFRESH MATERIALIZED VIEW*")]
PATTERN
    }
  }
}

#--------------------------------------------------------------
# Metrics:API Gateway
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about API Gateway will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-metrics-and-dimensions.html
#--------------------------------------------------------------
metric_resource_api_gateway = {
  # CUSTOMIZE: need to set is_enabled for Metric of API Gateway.
  is_enabled = false
  # CUSTOMIZE: need to set period for API Gateway.
  period = 300
  # CUSTOMIZE: need to set threshold for API Gateway.
  threshold = {
    # (Required) 4XXerror threshold (unit=%)
    error4XX = { enabled = false, value = 20 }
    # (Required) 5XXerror threshold (unit=%)
    error5XX = { enabled = true, value = 1 }
    # (Required) IntegrationLatency threshold (unit=Milliseconds)
    integration_latency = { enabled = false, value = 10000 }
    # (Required) Latency threshold (unit=Milliseconds)
    latency = { enabled = true, value = 8000 }
  }
  # (Optional) Override thresholds for specific resources. Key is the ApiName.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of API Gateways to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of API Gateways will be automatically registered, but at that time, specify the API Gateway name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only API Gateway names matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of API Gateway
  # Specify the instance of the target API Gateway name to be monitored by Map.
  # check API Gateway name list command.
  # ex) aws apigateway get-rest-apis | jq -r '.items[] | .Dimensions = "{\n  \"ApiName\" = \"" + .name + "\"\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "ApiName" = "example-api"
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:CloudFront
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about CloudFront will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/monitoring-using-cloudwatch.html
#--------------------------------------------------------------
metric_resource_cloudfront = {
  # CUSTOMIZE: need to set is_enabled for Metric of CloudFront.
  is_enabled = false
  # CUSTOMIZE: need to set period for CloudFront.
  period = 1800
  # CUSTOMIZE: need to set threshold for CloudFront.
  threshold = {
    # (Required) Error401Rate threshold (unit=%)
    error_401_rate = { enabled = false, value = 1 }
    # (Required) Error403Rate threshold (unit=%)
    error_403_rate = { enabled = false, value = 1 }
    # (Required) Error404Rate threshold (unit=%)
    error_404_rate = { enabled = false, value = 1 }
    # (Required) Error502Rate threshold (unit=%)
    error_502_rate = { enabled = true, value = 1 }
    # (Required) Error503Rate threshold (unit=%)
    error_503_rate = { enabled = true, value = 1 }
    # (Required) Error504Rate threshold (unit=%)
    error_504_rate = { enabled = true, value = 1 }
    # (Required) CacheHitRate threshold (unit=%)
    cache_hit_rate = { enabled = false, value = 70 }
    # (Required) OriginLatency threshold (unit=Milliseconds)
    origin_latency = { enabled = true, value = 10000 }
  }
  # (Optional) Override thresholds for specific resources. Key is the DistributionId.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of CloudFronts to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of CloudFronts will be automatically registered, but at that time, specify the CloudFront name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only CloudFront distribution IDs matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of CloudFront
  # Specify the instance of the target CloudFront name to be monitored by Map.
  # check CloudFront distribution name list command.
  # ex) aws cloudfront list-distributions | jq -r '.DistributionList.Items[] | if .Aliases.Items[0] then .Dimensions = "{\n  \"DistributionId\" = \"" + .Id + "\"\n  \"Region\" = \"Global\"\n  \"Domain\" = \"" + .Aliases.Items[0] + "\"\n }," else .Dimensions = "{\n  \"DistributionId\" = \"" + .Id + "\"\n  \"Region\" = \"Global\"\n  \"Domain\" = \"" + .DomainName + "\"\n }," end | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "DistributionId" = "ABCDEFG12345"
  #       "Region"         = "Global"
  #       "Domain"         = "aaaaaaaaaaaa.cloudfront.net"
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:EC2
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about EC2 will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/viewing_metrics_with_cloudwatch.html
#--------------------------------------------------------------
metric_resource_ec2 = {
  # CUSTOMIZE: need to set is_enabled for Metric of EC2.
  is_enabled = false
  # CUSTOMIZE: need to set period for EC2.
  period = 300
  # CUSTOMIZE: need to set threshold for EC2.
  threshold = {
    # (Required) CPUCreditBalance threshold (unit=Count)
    cpu_credit_balance = { enabled = false, value = 100 }
    # (Required) CPUCreditUsage threshold (unit=Count)
    cpu_credit_usage = { enabled = false, value = 5 }
    # (Required) CPUUtilization threshold (unit=Percent)
    cpu_utilization = { enabled = true, value = 80 }
    # (Required) CPUSurplusCreditBalance threshold (unit=Count)
    cpu_surplus_credit_balance = { enabled = false, value = 5 }
    # (Required) CPUSurplusCreditsCharged threshold (unit=Count)
    cpu_surplus_credits_charged = { enabled = false, value = 1 }
    # (Required) DedicatedHostCPUUtilization threshold (unit=Percent)
    dedicated_host_cpu_utilization = { enabled = false, value = 80 }
    # (Required) DiskReadBytes threshold (unit=Bytes)
    disk_read_bytes = { enabled = false, value = 1073741824 } # 1GB
    # (Required) DiskReadOps threshold (unit=Count)
    disk_read_ops = { enabled = false, value = 1000 }
    # (Required) DiskWriteBytes threshold (unit=Bytes)
    disk_write_bytes = { enabled = false, value = 1073741824 } # 1GB
    # (Required) DiskWriteOps threshold (unit=Count)
    disk_write_ops = { enabled = false, value = 1000 }
    # (Required) EBSByteBalance% threshold (unit=Percent)
    ebs_byte_balance_percent = { enabled = false, value = 10 }
    # (Required) EBSIOBalance% threshold (unit=Percent)
    ebs_io_balance_percent = { enabled = false, value = 10 }
    # (Required) EBSReadBytes threshold (unit=Bytes)
    ebs_read_bytes = { enabled = false, value = 1073741824 } # 1GB
    # (Required) EBSReadOps threshold (unit=Count)
    ebs_read_ops = { enabled = false, value = 1000 }
    # (Required) EBSWriteBytes threshold (unit=Bytes)
    ebs_write_bytes = { enabled = false, value = 1073741824 } # 1GB
    # (Required) EBSWriteOps threshold (unit=Count)
    ebs_write_ops = { enabled = false, value = 1000 }
    # (Required) InstanceEBSIOPSExceededCheck threshold (unit=None)
    instance_ebs_iops_exceeded_check = { enabled = true, value = 1 }
    # (Required) InstanceEBSThroughputExceededCheck threshold (unit=None)
    instance_ebs_throughput_exceeded_check = { enabled = true, value = 1 }
    # (Required) MetadataNoToken threshold (unit=Count)
    metadata_no_token = { enabled = true, value = 1 }
    # (Required) MetadataNoTokenRejected threshold (unit=Count)
    metadata_no_token_rejected = { enabled = true, value = 1 }
    # (Required) NetworkIn threshold (unit=Bytes)
    network_in = { enabled = false, value = 1073741824 } # 1GB
    # (Required) NetworkOut threshold (unit=Bytes)
    network_out = { enabled = false, value = 1073741824 } # 1GB
    # (Required) NetworkPacketsIn threshold (unit=Count)
    network_packets_in = { enabled = false, value = 1000000 }
    # (Required) NetworkPacketsOut threshold (unit=Count)
    network_packets_out = { enabled = false, value = 1000000 }
    # (Required) StatusCheckFailed threshold (unit=Count)
    status_check_failed = { enabled = true, value = 1 }
    # (Required) StatusCheckFailed_AttachedEBS threshold (unit=Count)
    status_check_failed_attached_ebs = { enabled = false, value = 1 }
    # (Required) StatusCheckFailed_Instance threshold (unit=Count)
    status_check_failed_instance = { enabled = true, value = 1 }
    # (Required) StatusCheckFailed_System threshold (unit=Count)
    status_check_failed_system = { enabled = true, value = 1 }
  }
  # (Optional) Override thresholds for specific resources. Key is the InstanceId.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of EC2s to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of EC2s will be automatically registered, but at that time, specify the EC2 instance ID you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only EC2 instance IDs matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of EC2
  # Specify the instance of the target EC2 name to be monitored by Map.
  # check EC2 distribution name list command.
  # ex) aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | .Dimensions = "{\n  \"InstanceId\" = \"" + .InstanceId + "\" # " + .InstanceType + "\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "InstanceId" = "i-xxxxxxxxxxxxxxx" # t3.small
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:ECS/ContainerInsights
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about ECS/ContainerInsights will be checked and you will be notified via Slack if the specified threshold is exceeded.
#--------------------------------------------------------------
metric_resource_ecs_container_insights = {
  # CUSTOMIZE: need to set is_enabled for Metric of ECS/ContainerInsights.
  is_enabled = false
  # CUSTOMIZE: need to set period for ECS/ContainerInsights.
  period = 300
  # CUSTOMIZE: need to set threshold for ECS/ContainerInsights.
  threshold = {
    # (Required) CpuUtilized/CpuReserved threshold (unit=Percent)
    cpu_utilization = { enabled = true, value = 80 }
    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)
    memory_utilization = { enabled = true, value = 90 }
    # (Optional) NetworkRxBytes threshold (unit=Bytes/Second)
    network_rx_bytes = { enabled = false, value = 104857600 }
    # (Optional) NetworkTxBytes threshold (unit=Bytes/Second)
    network_tx_bytes = { enabled = false, value = 104857600 }
    # (Optional) StorageReadBytes threshold (unit=Bytes)
    storage_read_bytes = { enabled = false, value = 1073741824 }
    # (Optional) StorageWriteBytes threshold (unit=Bytes)
    storage_write_bytes = { enabled = false, value = 1073741824 }
  }
  # (Optional) Override thresholds for specific resources. Key is the TaskDefinitionFamily.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     cpu_utilization = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # CUSTOMIZE: need to set dimensions for monitor of ECS/ContainerInsights.
  # check ECS distribution name list command.
  # ex) scripts/terraform/ecs_container_sights.sh
  #   ex)
  #   dimensions = [
  #     {
  #       "ClusterName" = "clustername",
  #       "TaskDefinitionFamily" = "taskdefinition"
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:ElastiCache
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about ElastiCache will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/CacheMetrics.html
#--------------------------------------------------------------
metric_resource_elasticache = {
  # CUSTOMIZE: need to set is_enabled for Metric of ElastiCache.
  is_enabled = false
  # CUSTOMIZE: need to set period for ElastiCache.
  period = 300
  # CUSTOMIZE: need to set threshold for ElastiCache.
  threshold = {
    # (Required) AuthenticationFailures threshold (unit=Count)
    authentication_failures = { enabled = true, value = 1 }
    # (Optional) BytesUsedForCache threshold (unit=Bytes)
    bytes_used_for_cache = { enabled = false, value = 10737418240 }
    # (Optional) CacheHits threshold (unit=Count)
    cache_hits = { enabled = false, value = 1000000 }
    # (Required) CacheHitRate threshold (unit=Percent)
    cache_hit_rate = { enabled = true, value = 10 }
    # (Optional) CacheMisses threshold (unit=Count)
    cache_misses = { enabled = true, value = 1000 }
    # (Required) CommandAuthorizationFailures threshold (unit=Count)
    command_authorization_failures = { enabled = true, value = 1 }
    # (Optional) CPUUtilization threshold (unit=Percent)
    cpu_utilization = { enabled = false, value = 90 }
    # (Required) CurrConnections threshold (unit=Count)
    curr_connections = { enabled = true, value = 50 }
    # (Optional) CurrItems threshold (unit=Count)
    curr_items = { enabled = false, value = 1000000 }
    # (Optional) DatabaseCapacityUsagePercentage threshold (unit=Percent)
    database_capacity_usage_percentage = { enabled = false, value = 80 }
    # (Required) DatabaseMemoryUsagePercentage threshold (unit=Percent)
    database_memory_usage_percentage = { enabled = true, value = 80 }
    # (Required) EngineCPUUtilization threshold (unit=Percent)
    engine_cpu_utilization = { enabled = true, value = 90 }
    # (Required) ErrorCount threshold (unit=Count)
    error_count = { enabled = true, value = 1 }
    # (Required) Evictions threshold (unit=Count)
    evictions = { enabled = true, value = 100 }
    # (Optional) FreeableMemory threshold (unit=Bytes)
    freeable_memory = { enabled = false, value = 104857600 }
    # (Required) IamAuthenticationExpirations threshold (unit=Count)
    iam_authentication_expirations = { enabled = true, value = 1 }
    # (Required) IamAuthenticationThrottling threshold (unit=Count)
    iam_authentication_throttling = { enabled = true, value = 1 }
    # (Required) KeyAuthorizationFailures threshold (unit=Count)
    key_authorization_failures = { enabled = true, value = 1 }
    # (Required) MemoryFragmentationRatio threshold (unit=None)
    memory_fragmentation_ratio = { enabled = true, value = 5 }
    # (Optional) NetworkBytesIn threshold (unit=Bytes)
    network_bytes_in = { enabled = false, value = 104857600 }
    # (Optional) NetworkBytesOut threshold (unit=Bytes)
    network_bytes_out = { enabled = false, value = 104857600 }
    # (Required) NewConnections threshold (unit=Count)
    new_connections = { enabled = true, value = 100 }
    # (Required) ReplicationBytes threshold (unit=Bytes)
    replication_bytes = { enabled = true, value = 104857600 } # 100MB
    # (Required) ReplicationLag threshold (unit=Seconds)
    replication_lag = { enabled = true, value = 30 }
    # (Required) SaveInProgress threshold (unit=None)
    save_in_progress = { enabled = true, value = 1 }
    # (Required) SuccessfulReadRequestLatency threshold (unit=Microseconds)
    successful_read_request_latency = { enabled = true, value = 10000 }
    # (Required) SuccessfulWriteRequestLatency threshold (unit=Microseconds)
    successful_write_request_latency = { enabled = true, value = 10000 }
    # (Required) SwapUsage threshold (unit=Bytes)
    swap_usage = { enabled = true, value = 52428800 } # 50MB
    # (Required) TrafficManagementActive threshold (unit=None)
    traffic_management_active = { enabled = true, value = 1 }
  }
  # (Optional) Override thresholds for specific resources. Key is the CacheClusterId.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of ElastiCache clusters to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of ElastiCache clusters will be automatically registered, but at that time, specify the ElastiCache cluster ID you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only ElastiCache cluster IDs matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of ElastiCache
  # Specify the instance of the target ElastiCache cluster to be monitored by Map.
  # check ElastiCache CacheClusterId list command.
  # ex) aws elasticache describe-cache-clusters | jq -r '.CacheClusters[] | .Dimensions = "{\n  \"CacheClusterId\" = \"" + .CacheClusterId + "\" # " + .CacheNodeType + "\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "CacheClusterId" = "cluster-1"
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:ELB (ALB/NLB)
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about ALB will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
#--------------------------------------------------------------
metric_resource_elb = {
  # CUSTOMIZE: need to set is_enabled for Metric of ELB (ALB/NLB).
  is_enabled = false
  # CUSTOMIZE: need to set period for ELB.
  period = 1800
  # CUSTOMIZE: need to set threshold for ELB.
  threshold = {
    # (Required) ActiveConnectionCount threshold (unit=Count)
    active_connection_count = { enabled = true, value = 10000 }
    # (Required) ClientTLSNegotiationErrorCount threshold (unit=Count)
    client_tls_negotiation_error_count = { enabled = true, value = 10 }
    # (Required) ConsumedLCUs threshold (unit=Count)
    consumed_lcus = { enabled = true, value = 5 }
    # (Required) HTTPCode_4XX_Count	threshold (unit=Count)
    httpcode_4xx_count = { enabled = true, value = 1 }
    # (Required) HTTPCode_5XX_Count	threshold (unit=Count)
    httpcode_5xx_count = { enabled = true, value = 1 }
    # (Required) HTTPCode_ELB_4XX_Count	threshold (unit=Count)
    httpcode_elb_4xx_count = { enabled = true, value = 1 }
    # (Required) HTTPCode_ELB_5XX_Count	threshold (unit=Count)
    httpcode_elb_5xx_count = { enabled = true, value = 1 }
    # (Required) TargetResponseTime	threshold (unit=)
    target_response_time = { enabled = true, value = 10 }
    # (Required) TargetTLSNegotiationErrorCount	threshold (unit=Count)
    target_tls_negotiation_error_count = { enabled = true, value = 10 }
    # (Required) UnHealthyHostCount	threshold (unit=Count)
    unhealthy_host_count = { enabled = true, value = 1 }
  }
  # (Optional) Override thresholds for specific resources. Key is the LoadBalancer.
  # NOTE: Metrics requiring TargetGroup dimension (enabled by default = false):
  #   - anomalous_host_count, healthy_host_count, request_count_per_target, zonal_shifted_host_count
  #   - mitigated_host_count, healthy_state_dns, healthy_state_routing, unhealthy_state_dns,
  #   - unhealthy_state_routing, unhealthy_routing_request_count, lambda_internal_error, lambda_user_error
  # To enable TargetGroup-specific metrics, create dimensions with TargetGroup parameter.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of ELB to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of ELB will be automatically registered, but at that time, specify the ELB name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true, a list of ELB will be automatically registered, but at that time, specify the ELB name you want to include using partial match. If empty, all ELBs will be included (except excluded ones).
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of ELB
  # Specify the instance of the target ELB name to be monitored by Map.
  # NOTE: To monitor TargetGroup-specific metrics, include TargetGroup in dimensions.
  #   ex) LoadBalancer only:
  #   dimensions = [
  #     {
  #       "LoadBalancer" = "app/example-alb/1234567890abcdef"
  #     }
  #   ]
  #   ex) LoadBalancer + TargetGroup (required for target-specific metrics):
  #   dimensions = [
  #     {
  #       "LoadBalancer" = "app/example-alb/1234567890abcdef"
  #       "TargetGroup" = "targetgroup/example-tg/1234567890abcdef" # pragma: allowlist secret
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:EventBridge Scheduler
# EventBridge is a serverless service that uses events to connect application components together,
# making it easier for you to build scalable event-driven applications. Event-driven architecture is a
# style of building loosely-coupled software systems that work together by emitting and responding to events.
# Event-driven architecture can help you boost agility and build reliable, scalable applications.
# https://docs.aws.amazon.com/eventbridge/latest/userguide/eb-what-is.html
#--------------------------------------------------------------
metric_resource_eventbridge_scheduler = {
  # CUSTOMIZE: need to set is_enabled for Metric of EventBridge Scheduler.
  is_enabled = false
  # CUSTOMIZE: need to set period for EventBridge Scheduler.
  period = 300
  # CUSTOMIZE: need to set threshold for EventBridge Scheduler.
  threshold = {
    # InvocationAttemptCount threshold (unit=Count)
    invocation_attempt_count = { enabled = false, value = 0 }
    # TargetErrorCount threshold (unit=Count)
    target_error_count = { enabled = true, value = 1 }
    # TargetErrorThrottledCount threshold (unit=Count)
    target_error_throttled_count = { enabled = true, value = 1 }
    # InvocationThrottleCount threshold (unit=Count)
    invocation_throttle_count = { enabled = true, value = 1 }
    # InvocationDroppedCount threshold (unit=Count)
    invocation_dropped_count = { enabled = true, value = 1 }
  }
  # (Optional) Per-schedule-group threshold overrides. Key is the schedule group name.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "my-critical-group" = {
  #     target_error_count = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of schedule groups to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of schedule groups will be automatically registered, but at that time, specify the schedule group name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only schedule group names matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # CUSTOMIZE: need to set dimensions for monitor of EventBridge Scheduler.
  # Specify the instance of the target EventBridge Scheduler name to be monitored by Map.
  # check EventBridge Scheduler id list command.
  # ex) aws scheduler list-schedule-groups | jq -r '.ScheduleGroups[] | .Dimensions = "{\n  \"ScheduleGroup\" = \"" + .Name + "\"\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "ScheduleGroup" = "default"
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:Lambda
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about Lambda will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/lambda/latest/dg/monitoring-metrics.html
#--------------------------------------------------------------
metric_resource_lambda = {
  # CUSTOMIZE: need to set is_enabled for monitor of Lambda.
  is_enabled = false
  # CUSTOMIZE: need to set period for Lambda.
  period = 300
  # CUSTOMIZE: need to set threshold for Lambda.
  threshold = {
    # (Required) AsyncEventAge threshold (unit=Milliseconds)
    async_event_age = { enabled = true, value = 30000 }
    # (Required) AsyncEventsDropped threshold (unit=Count)
    async_events_dropped = { enabled = true, value = 1 }
    # (Optional) AsyncEventsReceived threshold (unit=Count)
    async_events_received = { enabled = false, value = 100000 }
    # (Optional) ClaimedAccountConcurrency threshold (unit=Count)
    claimed_account_concurrency = { enabled = false, value = 900 }
    # (Required) ConcurrentExecutions threshold (unit=Count)
    concurrent_executions = { enabled = true, value = 500 }
    # (Required) DeadLetterErrors threshold (unit=Count)
    dead_letter_errors = { enabled = true, value = 1 }
    # (Required) DestinationDeliveryFailures threshold (unit=Count)
    destination_delivery_failures = { enabled = true, value = 1 }
    # (Required) Duration threshold (unit=Milliseconds)
    duration = { enabled = true, value = 10000 }
    # (Required) Errors threshold (unit=Count)
    errors = { enabled = true, value = 1 }
    # (Required) Invocations threshold (unit=Count)
    invocations = { enabled = true, value = 100000 }
    # (Required) IteratorAge threshold (unit=Milliseconds)
    iterator_age = { enabled = true, value = 60000 }
    # (Optional) OffsetLag threshold (unit=Milliseconds)
    offset_lag = { enabled = false, value = 100000 }
    # (Optional) PostRuntimeExtensionsDuration threshold (unit=Milliseconds)
    post_runtime_extensions_duration = { enabled = false, value = 5000 }
    # (Optional) ProvisionedConcurrentExecutions threshold (unit=Count)
    provisioned_concurrent_executions = { enabled = false, value = 500 }
    # (Optional) ProvisionedConcurrencyInvocations threshold (unit=Count)
    provisioned_concurrency_invocations = { enabled = false, value = 10000 }
    # (Optional) ProvisionedConcurrencySpilloverInvocations threshold (unit=Count)
    provisioned_concurrency_spillover_invocations = { enabled = false, value = 100 }
    # (Optional) ProvisionedConcurrencyUtilization threshold (unit=Percent)
    provisioned_concurrency_utilization = { enabled = false, value = 80 }
    # (Required) RecursiveInvocationsDropped threshold (unit=Count)
    recursive_invocations_dropped = { enabled = true, value = 1 }
    # (Required) Throttles threshold (unit=Count)
    throttles = { enabled = true, value = 1 }
    # (Optional) UnreservedConcurrentExecutions threshold (unit=Count)
    unreserved_concurrent_executions = { enabled = false, value = 800 }
  }
  # (Optional) Override thresholds for specific resources. Key is the FunctionName.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of Lambda to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of Lambda will be automatically registered, but at that time, specify the Lambda name you want to exclude using partial match.
  auto_dimensions_exclude_list = [
    "aws-controltower-NotificationForwarder",
    "base-",
    "cw-role",
  ]
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only Lambda function names matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of Lambda
  # Specify the instance of the target Lambda name to be monitored by Map.
  # check Lambda function name list command.
  # ex) aws lambda list-functions | jq -r '.Functions[] | .Dimensions = "{\n  \"FunctionName\" = \"" + .FunctionName + "\"\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "FunctionName" = "function-1"
  #     },
  #     {
  #       "FunctionName" = "function-2"
  #     },
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:NAT Gateway
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about NAT Gateway will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/vpc/latest/userguide/metrics-dimensions-nat-gateway.html
#--------------------------------------------------------------
metric_resource_nat_gateway = {
  # CUSTOMIZE: need to set is_enabled for monitor of NAT Gateway.
  is_enabled = false
  # CUSTOMIZE: need to set period for NAT Gateway.
  period = 300
  # CUSTOMIZE: need to set threshold for NAT Gateway.
  threshold = {
    # (Optional) ActiveConnectionCount threshold (unit=Count)
    active_connection_count = { enabled = false, value = 10000 }
    # (Required) BytesOutToDestination threshold (unit=Bytes)
    bytes_out_to_destination = { enabled = true, value = 107374182400 } # 100GB in bytes
    # (Required) BytesInFromSource threshold (unit=Bytes)
    bytes_in_from_source = { enabled = true, value = 107374182400 } # 100GB in bytes
    # (Optional) BytesInFromDestination threshold (unit=Bytes)
    bytes_in_from_destination = { enabled = false, value = 107374182400 } # 100GB in bytes
    # (Optional) BytesOutToSource threshold (unit=Bytes)
    bytes_out_to_source = { enabled = false, value = 107374182400 } # 100GB in bytes
    # (Required) PacketsDropCount threshold (unit=Count)
    packets_drop_count = { enabled = true, value = 100 }
    # (Required) ErrorPortAllocation threshold (unit=Count)
    error_port_allocation = { enabled = true, value = 10 }
    # (Optional) IdleTimeoutCount threshold (unit=Count)
    idle_timeout_count = { enabled = false, value = 100 }
    # (Optional) PacketsInFromDestination threshold (unit=Count)
    packets_in_from_destination = { enabled = false, value = 10000000 }
    # (Optional) PacketsInFromSource threshold (unit=Count)
    packets_in_from_source = { enabled = false, value = 10000000 }
    # (Optional) PacketsOutToDestination threshold (unit=Count)
    packets_out_to_destination = { enabled = false, value = 10000000 }
    # (Optional) PacketsOutToSource threshold (unit=Count)
    packets_out_to_source = { enabled = false, value = 10000000 }
    # (Required) ConnectionAttemptCount threshold (unit=Count)
    connection_attempt_count = { enabled = true, value = 10000 }
    # (Required) ConnectionEstablishedCount threshold (unit=Count)
    connection_established_count = { enabled = true, value = 10000 }
    # (Optional) PeakBytesPerSecond threshold (unit=Bytes/Second)
    peak_bytes_per_second = { enabled = false, value = 1073741824 } # 1GB/sec
    # (Optional) PeakPacketsPerSecond threshold (unit=Count/Second)
    peak_packets_per_second = { enabled = false, value = 100000 }
  }
  # (Optional) Override thresholds for specific resources. Key is the NatGatewayId.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of NAT Gateways to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of NAT Gateways will be automatically registered, but at that time, specify the NAT Gateway ID you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only NAT Gateway IDs matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of NAT Gateway
  # Specify the instance of the target NAT Gateway ID to be monitored by Map.
  # check NAT Gateway ID list command.
  # ex) aws ec2 describe-nat-gateways | jq -r '.NatGateways[] | .Dimensions = "{\n  \"NatGatewayId\" = \"" + .NatGatewayId + "\" # " + .State + "\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "NatGatewayId" = "nat-xxxxxxxxxxxxxxx" # available
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:RDS Cluster
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about RDS will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/monitoring-cloudwatch.html
#--------------------------------------------------------------
metric_resource_rds_cluster = {
  # CUSTOMIZE: need to set is_enabled for monitor of RDS Cluster.
  is_enabled = false
  # CUSTOMIZE: need to set is_aurora for monitor of RDS(Aurora).
  # If the target DB to be monitored is Aurora, set to true.
  is_aurora = true
  # CUSTOMIZE: need to set is_aurora for monitor of RDS(MySQL).
  # If the target DB to be monitored is MySQL, set to true.
  is_mysql = false
  # CUSTOMIZE: need to set is_aurora for monitor of RDS(PostgreSQL).
  # If the target DB to be monitored is PostgreSQL, set to true.
  is_postgresql = true
  # CUSTOMIZE: need to set period for RDS.
  period = 300
  # CUSTOMIZE: need to set threshold for RDS.
  threshold = {
    # (Required) AuroraReplicaLag threshold (unit=Milliseconds)
    aurora_replica_lag = { enabled = true, value = 1000 }
    # (Required) BufferCacheHitRatio threshold (unit=Percent)
    buffer_cache_hit_ratio = { enabled = false, value = 95 }
    # (Required) CommitLatency threshold (unit=Milliseconds)
    commit_latency = { enabled = true, value = 10000 }
    # (Required) CPUCreditBalance threshold (unit=Count)
    cpu_credit_balance = { enabled = true, value = 100 }
    # (Required) CPUUtilization threshold (unit=%)
    cpu_utilization = { enabled = true, value = 80 }
    # (Required) DatabaseConnections threshold (unit=Count)
    database_connections = { enabled = true, value = 100 }
    # (Required) Deadlocks threshold (unit=Count)
    deadlocks = { enabled = true, value = 1 }
    # (Required) DeleteLatency threshold (unit=Count)
    delete_latency = { enabled = true, value = 10 }
    # (Required) DiskQueueDepth threshold (unit=Count)
    disk_queue_depth = { enabled = true, value = 64 }
    # (Required) EngineUptime threshold (unit=Seconds)
    engine_uptime = { enabled = false, value = 86400 }
    # (Required) FreeLocalStorage threshold (unit=Bytes)
    free_local_storage = { enabled = false, value = 1073741824 }
    # (Required) FreeableMemory threshold (unit=Megabytes)
    freeable_memory = { enabled = true, value = 512 }
    # (Required) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    network_receive_throughput = { enabled = false, value = 1024 * 1024 }
    # (Required) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    network_transmit_throughput = { enabled = false, value = 1024 * 1024 }
    # (Required) ReadIOPS threshold (unit=Count/Second)
    read_iops = { enabled = false, value = 1000 }
    # (Required) ReadLatency threshold (unit=Seconds)
    read_latency = { enabled = true, value = 10 }
    # (Required) ReadThroughput threshold (unit=Bytes/Second)
    read_throughput = { enabled = false, value = 1024 * 1024 * 1024 }
    # (Required) WriteIOPS threshold (unit=Count/Second)
    write_iops = { enabled = false, value = 1000 }
    # (Required) WriteLatency threshold (unit=Seconds)
    write_latency = { enabled = true, value = 10 }
    # (Required) WriteThroughput threshold (unit=Bytes/Second)
    write_throughput = { enabled = false, value = 1024 * 1024 * 1024 }
  }
  # (Optional) Override thresholds for specific resources. Key is the DBClusterIdentifier.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of RDS to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of RDS will be automatically registered, but at that time, specify the RDS name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only RDS cluster names matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of RDS
  # Specify the instance of the target DB to be monitored by Map.
  # check RDS Cluster Identifier list command.
  # ex) aws rds describe-db-clusters | jq -r '.DBClusters[] | .Dimensions = "{\n  \"DBClusterIdentifier\" = \"" + .DBClusterIdentifier + "\"\n}," | .Dimensions'
  #   ex) RDS
  #   dimensions = [
  #     {
  #       "DBInstanceIdentifier" = "exampledb"
  #     }
  #   ]
  #   ex) RDS(Aurora)
  #   dimensions = [
  #     {
  #       "DBClusterIdentifier" = "exampledb"
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:Redshift
# Using CloudWatch metrics for Amazon Redshift, you can get information about
# your cluster's health and performance and see information at the node level.
# When working with these metrics, keep in mind that each metric has one or more dimensions
# associated with it. These dimensions tell you what the metric is applicable to,
# that is the scope of the metric. Amazon Redshift has the following two dimensions:
#
# https://docs.aws.amazon.com/redshift/latest/mgmt/metrics-listing.html
#--------------------------------------------------------------
metric_resource_redshift = {
  # CUSTOMIZE: need to set is_enabled for monitor of Redshift.
  is_enabled = false
  # CUSTOMIZE: need to set period for Redshift.
  period = 300
  # CUSTOMIZE: need to set threshold for Redshift.
  threshold = {
    # (Required) CommitQueueLength threshold (unit=Count)
    commit_queue_length = { enabled = true, value = 100 }
    # (Required) ConcurrencyScalingActiveClusters threshold (unit=Count)
    concurrency_scaling_active_clusters = { enabled = true, value = 100 }
    # (Required) ConcurrencyScalingSeconds threshold (unit=Seconds)
    concurrency_scaling_seconds = { enabled = true, value = 10 }
    # (Required) CPUUtilization threshold (unit=Percent)
    cpu_utilization = { enabled = true, value = 80 }
    # (Required) DatabaseConnections threshold (unit=Count)
    database_connections = { enabled = true, value = 100 }
    # (Required) HealthStatus threshold (HEALTHY(1)/UNHEALTHY(0))
    health_status = { enabled = true, value = 0 }
    # (Required) MaintenanceMode threshold (unit=Count(ON(1)/OFF(0)))
    maintenance_mode = { enabled = true, value = 1 }
    # (Required) MaxConfiguredConcurrencyScalingClusters threshold (unit=Count)
    max_configured_concurrency_scaling_clusters = { enabled = true, value = 5 }
    # (Required) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    network_receive_throughput = { enabled = false, value = 1024 * 1024 }
    # (Required) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    network_transmit_throughput = { enabled = false, value = 1024 * 1024 }
    # (Required) PercentageDiskSpaceUsed threshold (unit=Percent)
    percentage_disk_space_used = { enabled = true, value = 80 }
    # (Required) QueriesCompletedPerSecond threshold (unit=Count/Second)
    queries_completed_per_second = { enabled = true, value = 100 }
    # (Required) QueryDuration threshold (unit=Microseconds)
    query_duration = { enabled = true, value = 3000000 }
    # (Required) QueryRuntimeBreakdown threshold (unit=Microseconds)
    query_runtime_breakdown = { enabled = true, value = 3000000 }
    # (Required) ReadIOPS threshold (unit=Count/Second)
    read_iops = { enabled = false, value = 1000 }
    # (Required) ReadLatency threshold (unit=Seconds)
    read_latency = { enabled = true, value = 3 }
    # (Required) ReadThroughput threshold (unit=Bytes)
    read_throughput = { enabled = false, value = 1024 * 1024 * 1024 }
    # (Required) RedshiftManagedStorageTotalCapacity threshold (unit=Megabytes)
    redshift_managed_storage_total_capacity = { enabled = false, value = 1024 * 1024 * 500 }
    # (Required) TotalTableCount threshold (unit=Count)
    total_table_count = { enabled = false, value = 50 }
    # (Required) WLMQueueLength threshold (unit=Count)
    wlm_queue_length = { enabled = true, value = 5 }
    # (Required) WLMQueueWaitTime threshold (unit=Milliseconds)
    wlm_queue_wait_time = { enabled = true, value = 100 }
    # (Required) WLMQueriesCompletedPerSecond threshold (unit=Count/Second)
    wlm_queries_completed_per_second = { enabled = false, value = 100 }
    # (Required) WLMQueryDuration threshold (unit=Microseconds)
    wlm_query_duration = { enabled = true, value = 3000000 }
    # (Required) WLMRunningQueries threshold (unit=Count)
    wlm_running_queries = { enabled = false, value = 10 }
    # (Required) WriteIOPS threshold (unit=Count/Second)
    write_iops = { enabled = false, value = 1000 }
    # (Required) WriteLatency threshold (unit=Seconds)
    write_latency = { enabled = true, value = 3 }
    # (Required) WriteThroughput threshold (unit=Bytes)
    write_throughput = { enabled = false, value = 1024 * 1024 * 1024 }
    # (Required) SchemaQuota threshold (unit=Megabytes)
    schema_quota = { enabled = false, value = 1024 }
    # (Required) NumExceededSchemaQuotas threshold (unit=Count)
    num_exceeded_schema_quotas = { enabled = true, value = 0 }
    # (Required) StorageUsed threshold (unit=Megabytes)
    storage_used = { enabled = false, value = 1024 }
    # (Required) PercentageQuotaUsed threshold (unit=Percent)
    percentage_quota_used = { enabled = false, value = 1024 }
  }
  # (Optional) Override thresholds for specific resources. Key is the ClusterIdentifier.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of Redshift to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of Redshift will be automatically registered, but at that time, specify the Redshift name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only Redshift cluster IDs matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of Redshift
  # Specify the instance of the target DB to be monitored by Map.
  # check Redshift Cluster Identifier list command.
  # ex) aws redshift describe-clusters | jq -r '.Clusters[] | .Dimensions = "{\n  \"ClusterIdentifier\" = \"" + .ClusterIdentifier + "\"\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "ClusterIdentifier" = "example-redshift"
  #     },
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:SES
# Metrics are data about the performance of your systems. By default,
# many services provide free metrics for resources (such as Amazon EC2 instances,
# Amazon EBS volumes, and Amazon RDS DB instances).
# You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
# or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
# (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
#
# Metrics about SES will be checked and you will be notified via Slack if the specified threshold is exceeded.
# https://docs.aws.amazon.com/ses/latest/dg/event-publishing-retrieving-cloudwatch.html
#--------------------------------------------------------------
metric_resource_ses = {
  # CUSTOMIZE: need to set is_enabled for monitor of SES.
  is_enabled = false
  # CUSTOMIZE: need to set period for SES.
  period = 300
  # CUSTOMIZE: need to set threshold for SES.
  threshold = {
    # (Optional) Bounce threshold (unit=Count)
    bounce = { enabled = false, value = 100 }
    # (Optional) Complaint threshold (unit=Count)
    complaint = { enabled = false, value = 10 }
    # (Optional) Delivery threshold (unit=Count)
    delivery = { enabled = false, value = 100000 }
    # (Optional) Reject threshold (unit=Count)
    reject = { enabled = false, value = 10 }
    # Reputation.BounceRate threshold (unit=Percent)
    reputation_bouncerate = { enabled = true, value = 5 }
    # Reputation.ComplaintRate threshold (unit=Percent)
    reputation_complaintrate = { enabled = true, value = 0.1 }
    # (Optional) Send threshold (unit=Count)
    send = { enabled = false, value = 100000 }
  }
  # (Optional) thresholds specific resources. Key is ConfigurationSetName ("default" when dimensions is empty).
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  dimensions         = []
}

#--------------------------------------------------------------
# Metrics:SNS
# Amazon SNS publishes useful metrics to CloudWatch about your topics.
# You can use these metrics to monitor your SNS topics, set alarms, or troubleshoot issues.
# https://docs.aws.amazon.com/sns/latest/dg/sns-monitoring-using-cloudwatch.html
# NOTE: SMS-related metrics (SMSMonthToDateSpentUSD, SMSSuccessRate) are excluded
#       because they use different dimensions (no TopicName).
#--------------------------------------------------------------
metric_resource_sns = {
  # CUSTOMIZE: need to set is_enabled for monitor of SNS.
  is_enabled = false
  # CUSTOMIZE: need to set period for SNS.
  period = 300
  # CUSTOMIZE: need to set threshold for SNS.
  threshold = {
    # (Required) NumberOfMessagesPublished threshold (unit=Count)
    number_of_messages_published = { enabled = false, value = 1000 }
    # (Required) NumberOfNotificationsDelivered threshold (unit=Count)
    number_of_notifications_delivered = { enabled = false, value = 1000 }
    # (Required) NumberOfNotificationsFailed threshold (unit=Count)
    number_of_notifications_failed = { enabled = true, value = 1 }
    # (Required) NumberOfNotificationsFailedToRedriveToDlq threshold (unit=Count)
    number_of_notifications_failed_to_redrive_to_dlq = { enabled = true, value = 1 }
    # (Required) NumberOfNotificationsFilteredOut threshold (unit=Count)
    number_of_notifications_filtered_out = { enabled = false, value = 100 }
    # (Required) NumberOfNotificationsFilteredOut-InvalidAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_invalid_attributes = { enabled = false, value = 1 }
    # (Required) NumberOfNotificationsFilteredOut-InvalidMessageBody threshold (unit=Count)
    number_of_notifications_filtered_out_invalid_message_body = { enabled = false, value = 1 }
    # (Required) NumberOfNotificationsFilteredOut-MessageAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_message_attributes = { enabled = false, value = 100 }
    # (Required) NumberOfNotificationsFilteredOut-MessageBody threshold (unit=Count)
    number_of_notifications_filtered_out_message_body = { enabled = false, value = 100 }
    # (Required) NumberOfNotificationsFilteredOut-NoMessageAttributes threshold (unit=Count)
    number_of_notifications_filtered_out_no_message_attributes = { enabled = false, value = 100 }
    # (Required) NumberOfNotificationsRedrivenToDlq threshold (unit=Count)
    number_of_notifications_redriven_to_dlq = { enabled = false, value = 10 }
    # (Required) PublishSize threshold (unit=Bytes)
    publish_size = { enabled = false, value = 262144 }
  }
  # (Optional) Override thresholds for specific resources. Key is the TopicName.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of SNS topics to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of topics will be automatically registered, but at that time, specify the topic name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only topic names matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of SNS
  # ex) aws sns list-topics | jq -r '.Topics[] | .TopicArn | split(":") | .[-1]'
  #   ex)
  #   dimensions = [
  #     {
  #       "TopicName" = "my-topic",
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# Metrics:SQS
# Amazon SQS publishes useful metrics to CloudWatch about your queues.
# You can use these metrics to monitor your SQS queues, set alarms, or troubleshoot issues.
# https://docs.aws.amazon.com/AWSSimpleQueueService/latest/SQSDeveloperGuide/sqs-available-cloudwatch-metrics.html
# NOTE: FIFO-specific metrics (ApproximateNumberOfGroupsWithInflightMessages, NumberOfDeduplicatedSentMessages)
#       and Fair Queues metrics (*InQuietGroups, ApproximateNumberOfNoisyGroups) are included.
#       For standard queues, these metrics will simply not be available, and treat_missing_data = "notBreaching"
#       ensures no false alarms.
#--------------------------------------------------------------
metric_resource_sqs = {
  # CUSTOMIZE: need to set is_enabled for monitor of SQS.
  is_enabled = false
  # CUSTOMIZE: need to set period for SQS.
  period = 300
  # CUSTOMIZE: need to set threshold for SQS.
  threshold = {
    # (Required) ApproximateAgeOfOldestMessage threshold (unit=Seconds)
    approximate_age_of_oldest_message = { enabled = true, value = 3600 }
    # (Required) ApproximateAgeOfOldestMessageInQuietGroups threshold (unit=Seconds, Fair Queues only)
    approximate_age_of_oldest_message_in_quiet_groups = { enabled = false, value = 3600 }
    # (Required) ApproximateNumberOfGroupsWithInflightMessages threshold (unit=Count, FIFO only)
    approximate_number_of_groups_with_inflight_messages = { enabled = false, value = 100 }
    # (Required) ApproximateNumberOfMessagesDelayed threshold (unit=Count)
    approximate_number_of_messages_delayed = { enabled = false, value = 1000 }
    # (Required) ApproximateNumberOfMessagesDelayedInQuietGroups threshold (unit=Count, Fair Queues only)
    approximate_number_of_messages_delayed_in_quiet_groups = { enabled = false, value = 100 }
    # (Required) ApproximateNumberOfMessagesNotVisible threshold (unit=Count)
    approximate_number_of_messages_not_visible = { enabled = false, value = 1000 }
    # (Required) ApproximateNumberOfMessagesNotVisibleInQuietGroups threshold (unit=Count, Fair Queues only)
    approximate_number_of_messages_not_visible_in_quiet_groups = { enabled = false, value = 100 }
    # (Required) ApproximateNumberOfMessagesVisible threshold (unit=Count)
    approximate_number_of_messages_visible = { enabled = true, value = 1 }
    # (Required) ApproximateNumberOfMessagesVisibleInQuietGroups threshold (unit=Count, Fair Queues only)
    approximate_number_of_messages_visible_in_quiet_groups = { enabled = false, value = 100 }
    # (Required) ApproximateNumberOfNoisyGroups threshold (unit=Count, Fair Queues only)
    approximate_number_of_noisy_groups = { enabled = false, value = 10 }
    # (Required) NumberOfDeduplicatedSentMessages threshold (unit=Count, FIFO only)
    number_of_deduplicated_sent_messages = { enabled = false, value = 100 }
    # (Required) NumberOfEmptyReceives threshold (unit=Count)
    number_of_empty_receives = { enabled = false, value = 1000 }
    # (Required) NumberOfMessagesDeleted threshold (unit=Count)
    number_of_messages_deleted = { enabled = false, value = 1000 }
    # (Required) NumberOfMessagesReceived threshold (unit=Count)
    number_of_messages_received = { enabled = false, value = 1000 }
    # (Required) NumberOfMessagesSent threshold (unit=Count)
    number_of_messages_sent = { enabled = false, value = 1000 }
    # (Required) SentMessageSize threshold (unit=Bytes)
    sent_message_size = { enabled = false, value = 262144 }
  }
  # (Optional) Override thresholds for specific resources. Key is the QueueName.
  # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
  # threshold_override = {
  #   "resource-name" = {
  #     some_metric = {
  #       enabled             = false
  #       value               = 100
  #       datapoints_to_alarm = 1
  #       evaluation_periods  = 1
  #     }
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of SQS queues to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of queues will be automatically registered, but at that time, specify the queue name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only queue names matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # (Optional) If create_auto_dimensions is set to false, need to set dimensions for monitor of SQS
  # ex) aws sqs list-queues | jq -r '.QueueUrls[]? | split("/") | .[-1]'
  #   ex)
  #   dimensions = [
  #     {
  #       "QueueName" = "my-queue",
  #     }
  #   ]
  dimensions = []
}

#--------------------------------------------------------------
# CloudWatch Events:EC2
# The following events are monitored.
# - EC2 Instance Rebalance Recommendation
# - EC2 Spot Instance Interruption Warning
#--------------------------------------------------------------
cloudwatch_event_ec2 = {
  # CUSTOMIZE: need to set is_enabled for settings of EC2.
  is_enabled = false
  aws_cloudwatch_event_rule = {
    name        = "ec2-cloudwatch-event-rule"
    description = "This cloudwatch event used for EC2."
    state       = "ENABLED"
  }
  aws_lambda_function = {
    environment = {
      LANGUAGE = "en"
    }
  }
}

#--------------------------------------------------------------
# Metrics: Synthetics Canary
# You can use Amazon CloudWatch Synthetics to create canaries,
# configurable scripts that run on a schedule, to monitor your endpoints and APIs.
# Canaries follow the same routes and perform the same actions as a customer,
# which makes it possible for you to continually verify your customer experience even
# when you don't have any customer traffic on your applications. By using canaries,
# you can discover issues before your customers do.
#
# Using Synthetics Canary, the status code is checked against the specified URL,
# and if an unexpected status code is returned, the user is notified via Slack.
# https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/CloudWatch_Synthetics_Canaries.html
#--------------------------------------------------------------
metric_synthetics_canary = {
  functions = {
    #--------------------------------------------------------------
    # Function: Heartbeat
    # Monitors availability of specified endpoints via periodic HTTP checks.
    #--------------------------------------------------------------
    heartbeat = {
      # CUSTOMIZE: need to set is_enabled for Metric of Synthetics Canary.
      is_enabled = false
      # CUSTOMIZE: need to set period for Synthetics Canary.
      period = 300
      # CUSTOMIZE: need to set threshold for Synthetics Canary.
      threshold = {
        # (Required) 2xx threshold (unit=Count)
        http_2xx = { enabled = false, value = 100 }
        # (Required) 4xx threshold (unit=Count)
        http_4xx = { enabled = true, value = 1 }
        # (Required) 5xx threshold (unit=Count)
        http_5xx = { enabled = true, value = 1 }
        # (Required) Duration threshold (unit=Milliseconds)
        duration = { enabled = true, value = 30000 }
        # (Required) DurationDryRun threshold (unit=Milliseconds)
        duration_dry_run = { enabled = false, value = 30000 }
        # (Required) Failed threshold (unit=Count)
        failed = { enabled = true, value = 1 }
        # (Required) FailedRequests threshold (unit=Count)
        failed_requests = { enabled = false, value = 1 }
        # (Required) SuccessPercent threshold (unit=Percent)
        success_percent = { enabled = false, value = 99 }
        # (Required) SuccessPercentDryRun threshold (unit=Percent)
        success_percent_dry_run = { enabled = false, value = 99 }
        # (Required) SuccessPercentWithRetries threshold (unit=Percent)
        success_percent_with_retries = { enabled = false, value = 99 }
        # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)
        visual_monitoring_success_percent = { enabled = false, value = 99 }
      }
      # (Optional) thresholds specific resources. Key is CanaryName.
      # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
      # threshold_override = {
      #   "resource-name" = {
      #     some_metric = {
      #       enabled             = false
      #       value               = 100
      #       datapoints_to_alarm = 1
      #       evaluation_periods  = 1
      #     }
      #   }
      # }
      threshold_override = {}
      aws_synthetics_canary = {
        # ARN of the IAM role to be used to run the canary. see AWS Docs for permissions needs for IAM Role.
        # If not specified, a role policy is automatically created.
        execution_role_arn = null
        # (Required) Configuration block providing how often the canary is to run and when these test runs are to stop. Detailed below.
        schedule = [
          {
            expression = "cron(*/5 * * * ? *)"
          }
        ]
        # (Optional) Configuration block. Detailed below.
        # CUSTOMIZE: If you are restricting IP addresses using WAF or other methods but are allowing access from a VPC, you must configure the VPC accordingly.
        #       When a request must be made from a fixed IP, such as in the case of a site with restricted access.
        vpc_config = [
          # {
          #   subnet_ids = [
          #     "subnet-xxxxxxxxxxxxxxxxx",
          #     "subnet-xxxxxxxxxxxxxxxxx",
          #     "subnet-xxxxxxxxxxxxxxxxx",
          #   ]
          #   security_group_ids = [
          #     "subnet-xxxxxxxxxxxxxxxxx",
          #   ]
          # }
        ]
        # (Optional) Number of days to retain data about failed runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
        failure_retention_period = 7
        # (Optional) Whether to run or stop the canary.
        start_canary = true
        # (Optional) Number of days to retain data about successful runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
        success_retention_period = 7
        # (Optional) configuration for canary artifacts, including the encryption-at-rest settings for artifacts that the canary uploads to Amazon S3. See Artifact Config.
        artifact_config = [
          {
            s3_encryption = [
              {
                encryption_mode = "SSE_S3"
              }
            ]
          }
        ]
        # CUSTOMIZE: Set the Heartbeat URL and list of acceptable status codes.
        # (Optional) URLS/STATUS_CODE_RANGES is an environment variable that can be specified as a delimited string to allow heart beats to be thrown to multiple URLs.
        env = {
          URLS = "https://yahoo.co.jp/"
        }
      }
    }
    #--------------------------------------------------------------
    # Function: Linkcheck
    # Validates that all links on specified pages are functional.
    #--------------------------------------------------------------
    linkcheck = {
      # CUSTOMIZE: need to set is_enabled for Metric of Synthetics Canary.
      is_enabled = false
      # CUSTOMIZE: need to set period for Synthetics Canary.
      period = 300
      # CUSTOMIZE: need to set threshold for Synthetics Canary.
      threshold = {
        # (Required) 2xx threshold (unit=Count)
        http_2xx = { enabled = false, value = 100 }
        # (Required) 4xx threshold (unit=Count)
        http_4xx = { enabled = true, value = 1 }
        # (Required) 5xx threshold (unit=Count)
        http_5xx = { enabled = true, value = 1 }
        # (Required) Duration threshold (unit=Milliseconds)
        duration = { enabled = false, value = 30000 }
        # (Required) DurationDryRun threshold (unit=Milliseconds)
        duration_dry_run = { enabled = false, value = 30000 }
        # (Required) Failed threshold (unit=Count)
        failed = { enabled = true, value = 1 }
        # (Required) FailedRequests threshold (unit=Count)
        failed_requests = { enabled = false, value = 1 }
        # (Required) SuccessPercent threshold (unit=Percent)
        success_percent = { enabled = false, value = 99 }
        # (Required) SuccessPercentDryRun threshold (unit=Percent)
        success_percent_dry_run = { enabled = false, value = 99 }
        # (Required) SuccessPercentWithRetries threshold (unit=Percent)
        success_percent_with_retries = { enabled = false, value = 99 }
        # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)
        visual_monitoring_success_percent = { enabled = false, value = 99 }
      }
      # (Optional) thresholds specific resources. Key is CanaryName.
      # Each metric can override enabled / value / datapoints_to_alarm / evaluation_periods (all optional; unspecified values fall back to threshold).
      # threshold_override = {
      #   "resource-name" = {
      #     some_metric = {
      #       enabled             = false
      #       value               = 100
      #       datapoints_to_alarm = 1
      #       evaluation_periods  = 1
      #     }
      #   }
      # }
      threshold_override = {}

      aws_synthetics_canary = {
        # ARN of the IAM role to be used to run the canary. see AWS Docs for permissions needs for IAM Role.
        # If not specified, a role policy is automatically created.
        execution_role_arn = null
        # (Required) Configuration block providing how often the canary is to run and when these test runs are to stop. Detailed below.
        schedule = [
          {
            expression = "cron(0 0 * * ? *)"
          }
        ]
        # (Optional) Configuration block. Detailed below.
        # CUSTOMIZE: If you are restricting IP addresses using WAF or other methods but are allowing access from a VPC, you must configure the VPC accordingly.
        #       When a request must be made from a fixed IP, such as in the case of a site with restricted access.
        vpc_config = [
          #   {
          #     subnet_ids = [
          #       "subnet-xxxxxxxxxxxxxxxxx",
          #     ]
          #     security_group_ids = [
          #       "sg-xxxxxxxxxxxxxxxxx",
          #     ]
          #   }
        ]
        # (Optional) Number of days to retain data about failed runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
        failure_retention_period = 7
        # (Optional) Whether to run or stop the canary.
        start_canary = true
        # (Optional) Number of days to retain data about successful runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
        success_retention_period = 7
        # (Optional) configuration for canary artifacts, including the encryption-at-rest settings for artifacts that the canary uploads to Amazon S3. See Artifact Config.
        artifact_config = [
          {
            s3_encryption = [
              {
                encryption_mode = "SSE_S3"
              }
            ]
          }
        ]
        # CUSTOMIZE: Set the URL for the link check and the maximum number of links to follow.
        # (Optional) URLS/LIMIT is an environment variable that can be specified as a delimited string to allow heart beats to be thrown to multiple URLs.
        env = {
          URLS  = "https://yahoo.co.jp/"
          LIMIT = 10
        }
      }
    }
  }
}

#--------------------------------------------------------------
# Athena
# Amazon Athena is an interactive query service that makes it easy to
# analyze data directly in Amazon Simple Storage Service (Amazon S3) using standard SQL.
# With a few actions in the AWS Management Console, you can point Athena at your data stored in
# Amazon S3 and begin using standard SQL to run ad-hoc queries and get results in seconds.
#
# With this configuration, CloudFront and SES logs can be viewed in Athena.
#--------------------------------------------------------------
athena = {
  # CUSTOMIZE: need to set is_enabled for Athena.
  is_enabled     = false
  workgroup_name = "analytics"
  workgroup_configuration = {
    result_configuration = {
      encryption_configuration = {
        encryption_option = "SSE_S3"
      }
    }
  }
  workgroup_state       = "ENABLED"
  workgroup_description = "Workgroup for analysis."
  database_name         = "analytics"
  database_comment      = "Database for analyzing various logs."
  database_encryption_configuration = {
    encryption_option = "SSE_S3"
  }
  # CUSTOMIZE: To check CloudFront logs with Athena, specify true.
  enabled_cloudfront = true
  # CUSTOMIZE: Specify the S3 bucket where CloudFront logs are stored. s3://{bucket name}/{bucket prefix}
  cloudfront_log_bucket = "s3://base-aws-log-application-0123456789012/Logs/CloudFront/"
  # CUSTOMIZE: To check SES logs with Athena, specify true.
  enabled_ses = true
  # CUSTOMIZE: Specify the S3 bucket where SES logs are stored. s3://{bucket name}/{bucket prefix}
  ses_log_bucket = "s3://base-aws-log-application-0123456789012/Logs/base-aws-ses-log/"
}

#--------------------------------------------------------------
# Report CSP
#--------------------------------------------------------------
report_csp = {
  # CUSTOMIZE: need to set is_enabled for report CSP.
  is_enabled = false
}

#--------------------------------------------------------------
# Processes automatic shutdowns, restarts, etc. using EventBridge.
# The following are covered
# - AWS Batch Job Queue
# - EC2 Instance
# - ECS Service
# - ECS Scheduled Task
# - RDS Cluster
# - Redshift Cluster
#--------------------------------------------------------------
eventbridge = {
  #--------------------------------------------------------------
  # Schedule automatic enable and disable of AWS Batch Job Queue.
  #--------------------------------------------------------------
  batch = {
    # CUSTOMIZE: need to set is_enabled for enable and disable batch job queue schedule.
    is_enabled = false
    # CUSTOMIZE: need to set schedule_expression_stop for disable batch job queue.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # CUSTOMIZE: need to set schedule_expression_start for enable batch job queue.
    schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    # (Optional) Automatically discover AWS Batch job queues to create schedules. If true, schedules variable is ignored.
    create_auto_schedules = true
    # (Optional) List of patterns to exclude from auto-discovery (partial match on job queue name).
    auto_schedules_exclude_list = []
    # (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included.
    auto_schedules_include_list = []
    # (Optional) If create_auto_schedules is set to false, need to set schedules for enable and disable AWS Batch Job Queue.
    # Specify the instance of the target AWS Batch Job Queue to be scheduled by Map.
    # check AWS Batch Job Queue list command.
    # ex) aws batch describe-job-queues --query 'jobQueues[].[jobQueueName, state]' --output table
    #   ex)
    #   schedules = {
    #     example = {
    #       # CUSTOMIZE: need to set job_queue for enable and disable batch job queue.
    #       job_queue = "example-job-queue"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_stop for batch job queue.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_start for batch job queue.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # CUSTOMIZE: (Optional) if you want to override description for batch job queue.
    #       description = "Enable and disable example Batch job queue"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic stop and start of EC2 Instance.
  #--------------------------------------------------------------
  ec2 = {
    # CUSTOMIZE: need to set is_enabled for stop and start ec2_instance schedule.
    is_enabled = false
    # CUSTOMIZE: need to set schedule_expression_stop for stop ec2 instance.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # CUSTOMIZE: need to set schedule_expression_start for start ec2 instance.
    schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    # (Optional) Automatically discover EC2 instances to create schedules. If true, schedules variable is ignored.
    create_auto_schedules = true
    # (Optional) List of patterns to exclude from auto-discovery (partial match on instance ID or Name tag).
    auto_schedules_exclude_list = []
    # (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included.
    auto_schedules_include_list = []
    # (Optional) If create_auto_schedules is set to false, need to set schedules for stop and start EC2 Instance.
    # Specify the instance of the target EC2 Instance to be scheduled by Map.
    # check EC2 Instance ID list command.
    # ex) aws ec2 describe-instances --filters "Name=instance-state-name,Values=running,stopped" --query 'Reservations[].Instances[].[InstanceId, Tags[?Key==`Name`].Value | [0]]' --output table
    #   ex)
    #   schedules = {
    #     example = {
    #       # CUSTOMIZE: (Required) need to set instance_id for stop and start ec2 instance.
    #       instance_id = "i-1234567890abcdef0"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_stop for ec2 instance.
    #       # schedule_expression_stop = "cron(0 10 * * ? *)"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_start for ec2 instance.
    #       # schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # CUSTOMIZE: (Optional) if you want to override description for ec2 instance.
    #       description = "Stop and start example EC2 instance"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic stop and start of ECS Service.
  #--------------------------------------------------------------
  ecs_service = {
    # CUSTOMIZE: need to set is_enabled for stop and start ecs_service schedule.
    is_enabled = false
    # CUSTOMIZE: need to set schedule_expression_stop for stop ecs service.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # CUSTOMIZE: need to set schedule_expression_start for start ecs service.
    schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    # (Optional) Automatically discover ECS services to create schedules. If true, schedules variable is ignored.
    create_auto_schedules = true
    # (Optional) List of patterns to exclude from auto-discovery (partial match on cluster or service name).
    auto_schedules_exclude_list = []
    # (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included.
    auto_schedules_include_list = []
    # CUSTOMIZE: need to set autoscaling_min_capacity for start ecs service with autoscaling (set to 0 to skip autoscaling adjustment).
    autoscaling_min_capacity = 1
    # CUSTOMIZE: need to set autoscaling_max_capacity for start ecs service with autoscaling (set to 0 to use discovered value).
    autoscaling_max_capacity = 10
    # CUSTOMIZE: need to set desired_count for start ecs service.
    desired_count = 1
    # (Optional) If create_auto_schedules is set to false, need to set schedules for stop and start ECS Service.
    # Specify the instance of the target ECS Service to be scheduled by Map.
    # check ECS Cluster and Service list command.
    # ex) for cluster in $(aws ecs list-clusters --query 'clusterArns[]' --output text); do cluster_name=$(basename $cluster); for service in $(aws ecs list-services --cluster $cluster --query 'serviceArns[]' --output text); do service_name=$(basename $service); desired=$(aws ecs describe-services --cluster $cluster --services $service --query 'services[0].desiredCount' --output text); echo "$cluster_name / $service_name / desired_count=$desired"; done; done
    #   ex)
    #   schedules = {
    #     example-service = {
    #       # CUSTOMIZE: (Required) need to set ecs_cluster for stop and start ecs service.
    #       ecs_cluster   = "example-cluster"
    #       # CUSTOMIZE: (Required) need to set ecs_service for stop and start ecs service.
    #       ecs_service   = "example-service"
    #       # CUSTOMIZE: (Optional) if you want to override autoscaling_min_capacity for start ecs service with autoscaling (set to 0 to skip autoscaling adjustment).
    #       autoscaling_min_capacity = 1
    #       # CUSTOMIZE: (Optional) if you want to override autoscaling_max_capacity for start ecs service with autoscaling (set to 0 to use discovered value).
    #       autoscaling_max_capacity = 10
    #       # CUSTOMIZE: (Optional) if you want to override desired_count for start ecs service.
    #       desired_count = 1
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_stop for ecs service.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_start for ecs service.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # CUSTOMIZE: (Optional) if you want to override description for ecs service.
    #       description = "Stop and start example ECS service"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic enable and disable of ECS Scheduled Task (EventBridge Rule).
  #--------------------------------------------------------------
  ecs_scheduled_task = {
    # CUSTOMIZE: need to set is_enabled for enable and disable ecs scheduled task schedule.
    is_enabled = false
    # CUSTOMIZE: need to set schedule_expression_stop for disable ecs scheduled task rule.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # CUSTOMIZE: need to set schedule_expression_start for enable ecs scheduled task rule.
    schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    # (Optional) Automatically discover EventBridge rules targeting ECS tasks to create schedules. If true, schedules variable is ignored.
    create_auto_schedules = true
    # (Optional) List of patterns to exclude from auto-discovery (partial match on rule name).
    auto_schedules_exclude_list = []
    # (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included.
    auto_schedules_include_list = []
    # (Optional) If create_auto_schedules is set to false, need to set schedules for enable and disable ECS Scheduled Task Rule.
    # Specify the instance of the target EventBridge Rule to be scheduled by Map.
    # check EventBridge Rule list command.
    # ex) aws events list-rules --query 'Rules[].[Name, State]' --output table
    #   ex)
    #   schedules = {
    #     example = {
    #       # CUSTOMIZE: (Required) need to set ecs_cluster for enable and disable ecs scheduled task rule.
    #       ecs_cluster = "example-ecs-cluster"
    #       # CUSTOMIZE: (Required) need to set task_definition for enable and disable ecs scheduled task rule.
    #       task_definition = "example-task-definition-family"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_stop for ecs scheduled task rule.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_start for ecs scheduled task rule.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # CUSTOMIZE: (Optional) if you want to override description for ecs scheduled task rule.
    #       description = "Enable and disable example ECS task rule"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic stop and start of RDS Cluster.
  #--------------------------------------------------------------
  rds_cluster = {
    # CUSTOMIZE: need to set is_enabled for stop and start rds_cluster schedule.
    is_enabled = false
    # CUSTOMIZE: need to set schedule_expression_stop for stop rds cluster.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # CUSTOMIZE: need to set schedule_expression_start for start rds cluster.
    schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    # (Optional) Automatically discover RDS clusters to create schedules. If true, schedules variable is ignored.
    create_auto_schedules = true
    # (Optional) List of patterns to exclude from auto-discovery (partial match on cluster identifier).
    auto_schedules_exclude_list = []
    # (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included.
    auto_schedules_include_list = []
    # (Optional) If create_auto_schedules is set to false, need to set schedules for stop and start RDS Cluster.
    # Specify the instance of the target RDS Cluster to be scheduled by Map.
    # check RDS Cluster Identifier list command.
    # ex) aws rds describe-db-clusters --query 'DBClusters[].[DBClusterIdentifier, Status]' --output table
    #   ex)
    #   schedules = {
    #     example = {
    #       # CUSTOMIZE: (Required) need to set db_cluster_identifier for stop and start rds cluster.
    #       db_cluster_identifier = "example-db"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_stop for rds cluster.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_start for rds cluster.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # CUSTOMIZE: (Optional) if you want to override description for rds cluster.
    #       description = "Stop and start example RDS cluster"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic pause and resume of Redshift Cluster.
  #--------------------------------------------------------------
  redshift = {
    # CUSTOMIZE: need to set is_enabled for pause and resume redshift cluster schedule.
    is_enabled = false
    # CUSTOMIZE: need to set schedule_expression_stop for pause redshift cluster.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # CUSTOMIZE: need to set schedule_expression_start for resume redshift cluster.
    schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    # (Optional) Automatically discover Redshift clusters to create schedules. If true, schedules variable is ignored.
    create_auto_schedules = true
    # (Optional) List of patterns to exclude from auto-discovery (partial match on cluster identifier).
    auto_schedules_exclude_list = []
    # (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included.
    auto_schedules_include_list = []
    # (Optional) If create_auto_schedules is set to false, need to set schedules for pause and resume Redshift Cluster.
    # Specify the instance of the target Redshift Cluster to be scheduled by Map.
    # check Redshift Cluster Identifier list command.
    # ex) aws redshift describe-clusters --query 'Clusters[].[ClusterIdentifier, ClusterStatus]' --output table
    #   ex)
    #   schedules = {
    #     example = {
    #       # CUSTOMIZE: (Required) need to set cluster_identifier for pause and resume redshift cluster.
    #       cluster_identifier = "example-redshift"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_stop for redshift cluster.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # CUSTOMIZE: (Optional) if you want to override schedule_expression_start for redshift cluster.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # CUSTOMIZE: (Optional) if you want to override description for redshift cluster.
    #       description = "Pause and resume example Redshift cluster"
    #     }
    #   }
    schedules = {}
  }
}

#--------------------------------------------------------------
# AWS DevOps Agent
# AWS DevOps Agent investigates incidents across AWS resources and connected tools
# (e.g. GitHub) and proposes root causes and mitigations.
# This creates an Agent Space in region.primary with IAM roles, the operator web app,
# a KMS customer managed key, the monitor account association, GitHub repository associations,
# and custom agents with scheduled triggers.
#
# Agent Spaces:
#   devops_agent.primary.agent_spaces is a map keyed by the Agent Space name; one Agent Space (module.devops_agent[<name>])
#   is created per entry when devops_agent.primary.is_enabled and agent_spaces.<name>.is_enabled are true.
#   Account-level settings shared by all Agent Spaces: kms (one key), primary.github_registrations.
#
# Prerequisite for GitHub:
#   Register GitHub at the account level in the AWS DevOps Agent console (cannot be automated by Terraform).
#   The registration is shared by all Agent Spaces in the AWS account; register once per AWS account.
#   Console: AWS DevOps Agent > Capabilities > Pipeline > Add > GitHub > Connection type
#
#   A) App registration (recommended: supports webhooks, no token expiration)
#     1. Connection type: App registration
#     2. Select Organization and enter the GitHub organization name (must match exactly).
#     3. GitHub App permissions: Read and write (default) or Read-only.
#        Read-only cannot post PR comments, propose fixes, or trigger workflows.
#     4. Verification method: Browser-based callback > Submit.
#        (If the GitHub App is already installed on the organization, e.g. from another AWS account,
#         "Verify with a personal access token" can be used instead. The token needs read:org
#         (classic) or Organization Administration: Read-only (fine-grained), and its owner must be
#         an organization owner. The token is used once and not stored.)
#     5. Authorize the app on GitHub, then install it on the organization with
#        "Only select repositories" and choose the repositories to connect.
#     Requires: organization owner (permission to install GitHub Apps).
#
#   B) Personal access token (no webhooks: no real-time push/PR/deployment events)
#     1. Create a token on GitHub (Settings > Developer settings > Personal access tokens).
#        - Fine-grained (recommended):
#            Resource owner: the GitHub organization
#            Repository access: Only select repositories (the repositories to connect)
#            Repository permissions: Contents: Read-only, Metadata: Read-only
#            Organization permissions: Members: Read-only
#        - Classic:
#            Scopes: repo, read:org
#            (repo grants read/write to every repository the owner can access; prefer fine-grained)
#            If the organization uses SAML SSO, authorize the token for the organization (Configure SSO).
#        Set an expiration that fits the security policy. The organization may restrict PAT usage
#        (Organization settings > Personal access tokens).
#     2. Connection type: Personal access token. Enter the token and the GitHub organization name > Submit.
#        The token owner must be an active member of the organization.
#     3. The token cannot be updated. Before it expires: create a new token, deregister GitHub,
#        register again, then update github_registrations.<name>.service_id below (the service ID changes) and apply.
#
#   Each registration corresponds to one GitHub user, organization, or GitHub Enterprise Server instance;
#   register each organization separately and add one entry per registration to github_registrations below.
#   After registration, get the service ID and set github_registrations.<name>.service_id below.
#   Repository ID: gh api repos/<owner>/<repo> --jq .id
#   https://docs.aws.amazon.com/devopsagent/latest/userguide/connecting-to-cicd-pipelines-connecting-github.html
#
# Webhook (optional):
#   A generic webhook lets external systems (e.g. monitoring tools) start investigations via HTTP POST
#   signed with HMAC (x-amzn-event-signature / x-amzn-event-timestamp headers).
#   How it works (agent_spaces.<name>.webhook.is_enabled = true), per Agent Space:
#     1. Terraform registers the event channel service (account level, name: <name_prefix><name>-webhook)
#        with the AWS CLI. CloudFormation/awscc cannot register it.
#     2. Terraform creates the Secrets Manager secret <name_prefix without "-">/<name>/webhook (empty, e.g.
#        base/devops-agent/webhook), encrypted with the
#        DevOps Agent KMS key when kms["monitor_devops_agent"].is_enabled is true (otherwise the AWS managed key aws/secretsmanager).
#     3. Terraform creates the webhook with the AWS CLI (associate-service). The webhook secret is returned only
#        once at this point, so it is written directly to the secret above. awscc would discard it.
#        The secret value never appears in the Terraform state, plan, outputs or logs.
#   Outputs after apply:
#     terraform output devops_agent_webhook_urls          # map: Agent Space name => POST target URL
#     terraform output devops_agent_webhook_secret_arns   # map: Agent Space name => secret holding the credentials
#   Secret value (JSON): webhook_id, webhook_secret (HMAC signing secret, or API key when webhook_type is apikey),
#     webhook_type (hmac or apikey; the API does not let callers choose it, so check it after the first apply), webhook_url
#     aws secretsmanager get-secret-value --secret-id <devops_agent_webhook_secret_arns[name]> --query SecretString --output text
#     Grant senders (e.g. Lambda) secretsmanager:GetSecretValue on the secret (and kms:Decrypt on the key).
#   Requirements where Terraform runs: aws CLI v2 with devops-agent, jq, and
#     aidevops:RegisterService/DeregisterService/ListServices/AssociateService/DisassociateService/ListAssociations/
#     ListWebhooks, secretsmanager:PutSecretValue (and kms:GenerateDataKey on the KMS key).
#   Notes:
#     - Do not put the webhook secret in tfvars. Terraform does not manage the secret version; do not edit it by hand.
#     - Recreating the webhook (agent space / service / secret changes, or terraform apply -replace=
#       'module.devops_agent["<name>"].terraform_data.webhook_association[0]') changes the URL and the secret, and the new
#       credentials are written as a new secret version. Update the senders afterwards.
#     - Rotating the webhook in the console keeps the URL but does NOT update the secret; prefer the -replace above,
#       or put the rotated secret into the secret manually.
#     - If the secret could not be stored, apply fails; run terraform apply again (the webhook is recreated).
#     - agent_spaces.<name>.webhook.is_enabled = false (or destroy) removes the webhook, deregisters the event
#       channel service, and schedules the secret deletion (webhook.secret.recovery_window_in_days).
#   https://docs.aws.amazon.com/devopsagent/latest/userguide/configuring-integrations-and-knowledge-invoking-devops-agent-through-webhook.html
#
# Notes:
#   - kms["monitor_devops_agent"].is_enabled cannot be changed after the Agent Space is created (forces a new Agent Space
#     and the investigation history is lost). Decide before the first apply.
#   - Triggers support schedules only (TIME_BASED). Expressions are evaluated in UTC.
#
# Supported regions: us-east-1, us-west-2, ap-southeast-2, ap-northeast-1, eu-central-1, eu-west-1
# https://docs.aws.amazon.com/devopsagent/latest/userguide/connecting-to-cicd-pipelines-connecting-github.html
#--------------------------------------------------------------
devops_agent = {
  # How this account takes part in AWS DevOps Agent. primary and secondary are independent; both can be enabled in one account
  # (it hosts Agent Spaces that investigate itself and is also investigated by the Agent Space of another primary account).
  #   primary   : hosts the Agent Spaces (primary.agent_spaces) and associates primary.secondary_accounts as source accounts.
  #   secondary : creates only the read-only cross-account role (DevOpsAgentRole-SecondaryAccount) that trusts
  #               secondary.primary_agent_space_arn in secondary.primary_account_id.
  # Rollout (primary = prd, secondary = dev / qa / stg). Values that only exist after an apply are placeholders until then.
  #   1) Before the first primary apply, register the account-level services in the primary account and replace the
  #      placeholder service_id ("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx") in the primary tfvars. IDs from another account do not work.
  #        - primary.github_registrations.<name>.service_id    : register GitHub in the AWS DevOps Agent console (see "Prerequisite for GitHub" above), then
  #          aws devops-agent list-services --region ap-northeast-1 --filter-service-type github --query 'services[].{id:serviceId,owner:additionalServiceDetails.github.owner}'
  #        - primary.mcp_server_registrations.<name>.service_id : aws devops-agent register-service --service mcpserver ... (see mcp_server_registrations below)
  #   2) Apply the primary account. If the source associations fail because the secondary role does not exist yet,
  #      continue with 3) and 4), then apply the primary account again.
  #   3) Read the values that the primary apply created (run in the primary account):
  #        - Agent Space ARN : terraform output -json devops_agent_agent_space_arns | jq -r '."devops-agent"'
  #        - Webhook URL     : terraform output -json devops_agent_webhook_urls | jq -r '."devops-agent"'
  #        - HMAC secret     : aws secretsmanager get-secret-value --secret-id "$(terraform output -json devops_agent_webhook_secret_arns | jq -r '."devops-agent"')" --query SecretString --output text | jq -r .webhook_secret
  #   4) In every secondary tfvars, replace secondary.primary_agent_space_arn (placeholder ".../agentspace/set-after-prd-apply") with the ARN from 3), and apply.
  #   5) In every tfvars (primary and secondary), set DEVOPS_AGENT_WEBHOOK_URL and DEVOPS_AGENT_WEBHOOK_HMAC_SECRET from 3) in
  #      metric.aws_lambda_function.environment and log.aws_lambda_function.environment, and apply.
  #      Until then the alert Lambda functions in that account do not forward alarms to AWS DevOps Agent.
  #   Re-creating the Agent Space (renaming its key, or changing kms["monitor_devops_agent"].is_enabled) changes the ARN: repeat 3) and 4).
  #   Re-creating the webhook changes the URL and the HMAC secret: repeat 3) and 5).
  primary = {
    # CUSTOMIZE: need to set is_enabled to host the AWS DevOps Agent Spaces in this account (all Agent Spaces).
    is_enabled = false
    # (Optional) Secondary (source) accounts the Agent Space investigates. Key: arbitrary identifier.
    # Add an account only after the secondary account has been applied (the cross-account role must exist).
    #   ex)
    #   secondary_accounts = {
    #     dev = { account_id = "123456789012" }
    #   }
    secondary_accounts = {}
    # GitHub registrations (account level, registered in the console; see "Prerequisite for GitHub" above).
    # One registration per GitHub user, organization, or GitHub Enterprise Server instance.
    # Key: arbitrary name referred to by agent_spaces.<name>.github_repositories[*].github_registration.
    # check GitHub service ID / owner command.
    # ex) aws devops-agent list-services --region ap-northeast-1 --filter-service-type github --query 'services[].{id:serviceId,owner:additionalServiceDetails.github.owner}'
    #   ex)
    #   github_registrations = {
    #     "example-org" = {
    #       service_id = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    #       owner      = "example-org"
    #       owner_type = "organization"
    #     }
    #   }
    github_registrations = {}
    # Slack reply MCP server (reply to the alert thread as the Bot); attached to every Agent Space
    #   ex)
    #   mcp_slack_reply = {
    #     is_enabled = true
    #   }
    mcp_slack_reply = {}
    # MCP server registrations (account level). Register with the AWS CLI first; the credential never enters the Terraform state.
    # Key: arbitrary name referred to by agent_spaces.<name>.mcp_servers[*].mcp_server_registration.
    # Write access (Issue / branch / Draft PR) needs the GitHub MCP server; the native GitHub integration is read-only.
    #   ex) register each MCP server with the AWS CLI. Read the credential from Secrets Manager (do not type it in the shell history):
    #     - GitHub (PAT: fine-grained, only the target repositories; Issues / Contents / Pull requests: read and write):
    #         aws devops-agent register-service --service mcpserver --region ap-northeast-1 \
    #           --service-details '{"mcpserver":{"name":"GitHubMcpServer","endpoint":"https://api.githubcopilot.com/mcp/","authorizationConfig":{"apiKey":{"apiKeyName":"github-pat","apiKeyHeader":"Authorization","apiKeyValue":"Bearer <PAT>"}}}}' # pragma: allowlist secret
    #     - Linear (API key / token; OAuth is also possible via the console):
    #         aws devops-agent register-service --service mcpserver --region ap-northeast-1 \
    #           --service-details '{"mcpserver":{"name":"LinearMcpServer","endpoint":"https://mcp.linear.app/mcp","authorizationConfig":{"apiKey":{"apiKeyName":"linear-api-key","apiKeyHeader":"Authorization","apiKeyValue":"Bearer <TOKEN>"}}}}' # pragma: allowlist secret
    #         If the Linear credential cannot create labels, create the label devops-agent in Linear beforehand.
    #     - Notion (hosted MCP uses OAuth): register it in the console (Capability Providers) and copy the service ID.
    #     GitHub label: create the label devops-agent in every target repository beforehand. It needs Label creation permission in GitHub; the GitHub MCP server has no tool to create it, so the agent cannot.
    #     aws devops-agent list-services --region ap-northeast-1 --query 'services[].{id:serviceId,type:serviceType}'
    #   ex)
    #   mcp_server_registrations = {
    #     github = {
    #       description = "GitHub MCP server (Issue / Draft PR)"
    #       endpoint    = "https://api.githubcopilot.com/mcp/"
    #       name        = "GitHubMcpServer"
    #       service_id  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    #     }
    #     notion = {
    #       description = "Notion MCP server (incident pages)"
    #       endpoint    = "https://mcp.notion.com/mcp"
    #       name        = "NotionMcpServer"
    #       service_id  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    #     }
    #     linear = {
    #       description = "Linear MCP server (incident Issues)"
    #       endpoint    = "https://mcp.linear.app/mcp"
    #       name        = "LinearMcpServer"
    #       service_id  = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
    #     }
    #   }
    mcp_server_registrations = {}
    # Agent Spaces. Key: Agent Space name (name_prefix is prepended; 1-40 lowercase letters, digits or hyphens).
    # Derived names: IAM roles <name_prefix><key>-agent-space-role / <name_prefix><key>-operator-app-role,
    # webhook event channel <name_prefix><key>-webhook, webhook secret <name_prefix without "-">/<key>/webhook.
    # Renaming a key recreates the Agent Space and everything in it (the investigation history is lost).
    agent_spaces = {
      "devops-agent" = {
        # (Optional) Create this Agent Space (also requires devops_agent.primary.is_enabled).
        is_enabled = true
        # (Optional) Agent Space description.
        description = "AWS DevOps Agent Space"
        # (Optional) Allow elevated directed actions.
        elevated_actions_enabled = false
        # (Optional) Language used in agent responses (BCP 47). Responds in the input language when unset.
        locale = "en-US"
        # (Optional) Extra IAM statements for the Agent Space role on top of AIDevOpsAgentAccessPolicy. Never allow secretsmanager:GetSecretValue.
        #   ex)
        #   additional_policy_statements = [
        #     {
        #       sid       = "AllowReadLambdaFunctions"
        #       actions   = ["lambda:GetFunction", "lambda:GetFunctionConfiguration"]
        #       resources = ["arn:aws:lambda:ap-northeast-1:*:function:*"]
        #     },
        #   ]
        additional_policy_statements = []
        # (Optional) GitHub repositories to associate. github_registration: key of devops_agent.primary.github_registrations
        # (the registration that can access the repository).
        # check GitHub repository ID command.
        # ex) gh api repos/<owner>/<repo> --jq .id
        #   ex)
        #   github_repositories = {
        #     example = {
        #       github_registration = "example-org"
        #       repo_id   = "123456789"
        #       repo_name = "example"
        #     }
        #   }
        github_repositories = {}
        # (Optional) MCP servers to associate (tool allowlist; unlisted tools are invisible to the agent).
        # mcp_server_registration: key of devops_agent.primary.mcp_server_registrations. Do not allowlist merge / delete tools.
        # Tool names follow the current GitHub MCP server (issue_write / issue_read; there is no create_issue). Notion and Linear tool names: verify with tools/list.
        #   ex)
        #   mcp_servers = {
        #     github = {
        #       mcp_server_registration = "github"
        #       tools = [
        #         "add_issue_comment", "create_branch", "create_or_update_file", "create_pull_request", "get_file_contents", "get_label",
        #         "issue_read",
        #         "issue_write", "list_branches", "list_issues", "pull_request_read", "push_files", "search_code",
        #         "search_issues", "search_repositories", "update_pull_request",
        #       ]
        #     }
        #     notion = {
        #       mcp_server_registration = "notion"
        #       tools                   = ["notion-create-pages", "notion-fetch", "notion-search", "notion-update-page"]
        #     }
        #     linear = {
        #       mcp_server_registration = "linear"
        #       tools = [
        #         "get_issue", "list_comments", "list_issue_labels", "list_issue_statuses", "list_issues", "list_teams",
        #         "save_comment", "save_issue", "save_issue_label",
        #       ]
        #     }
        #   }
        mcp_servers = {}
        # (Optional) Agent instructions (AGENTS.md) injected into every session. Key: agent type (GENERIC = all agents; at most one per agent type).
        # Other agent types: CHAT, INCIDENT_TRIAGE, INCIDENT_RCA, INCIDENT_MITIGATION, INCIDENT_UI, PREVENTION, RELEASE_READINESS_REVIEW, RELEASE_TESTING.
        # content_file / content_files are relative to terraform/monitor (Markdown only, no frontmatter, max 25 KB in total per agent type).
        # content_files are concatenated in order after content_file, so rules can be split into one file per category (e.g. incident-suppression/ = alarms that must not be listed as incidents).
        agents_md = {
          GENERIC = {
            content_file = "devops_agent/agents_md/generic.md"
            content_files = [
              "devops_agent/agents_md/incident-suppression/postgresql-operation.md",
              "devops_agent/agents_md/incident-suppression/scheduled-stop.md",
            ]
          }
        }
        # (Optional) Linear team (name or key) in which this Agent Space creates Issues with the Linear MCP server (linear_issue_* custom agents).
        # When set, Terraform appends a "Linear" section (the team and the rule to create Issues only in it) to the GENERIC AGENTS.md of this Agent Space;
        # the file given by content_file (generic.md) is not edited. null adds nothing. Set it together with the linear mcp_servers, skills and custom_agents examples.
        #   ex) linear = { team = "ENG" }
        linear = {
          team = null
        }
        # (Optional) Skills to attach to custom agents. content_file is relative to terraform/monitor.
        # name and description are optional: when omitted they are read from the frontmatter of SKILL.md; a value set here takes precedence.
        #   ex)
        #   skills = {
        #     example_skill = {
        #       name         = "example-skill"
        #       description  = "When the agent should use this skill."
        #       content_file = "devops_agent/skills/example-skill/SKILL.md"
        #     }
        #   }
        # Linear skills (attach to the linear_issue_* custom agents below).
        #   ex)
        #   skills = {
        #     linear_issue_draft_pr = {
        #       agent_types  = ["INCIDENT_RCA", "INCIDENT_MITIGATION"]
        #       name         = "linear-issue-draft-pr"
        #       description  = "Record an alarm investigation as a Linear Issue labeled devops-agent and, for a small confirmed fix, a GitHub Draft PR labeled devops-agent (to the repository default branch). Use this when an investigation of a CloudWatch alarm or incident finds a root cause and the team tracks incidents in Linear. It also replies to the Slack alert thread. Do not use it together with another tracker skill for the same alarm."
        #       content_file = "devops_agent/skills/linear-issue-draft-pr/SKILL.md"
        #     }
        #     linear_issue_pr_followup = {
        #       agent_types  = ["GENERIC"]
        #       name         = "linear-issue-pr-followup"
        #       description  = "Follow up on unanswered human comments on Linear Issues and their GitHub PRs labeled devops-agent: answer, update the text, re-check the incident, fix the Draft PR, and close when allowed. Use this in the scheduled follow-up run. Do not use it to start an investigation or to create Issues, PRs or labels."
        #       content_file = "devops_agent/skills/linear-issue-pr-followup/SKILL.md"
        #     }
        #   }
        skills = {}
        # Issue / Draft PR agents (enable together with mcp_servers above; tool name prefix <MCP server name>_ is assumed, verify in the console).
        #   ex)
        #   custom_agents = {
        #     github_issue_pr_agent = {
        #       name               = "github-issue-pr-agent"
        #       system_prompt_file = "devops_agent/agents/github_issue_pr_agent.md"
        #       skills             = ["github_issue_draft_pr"]
        #       tools = [
        #         "use_aws", "query_cloudwatch_logs", "McpSlackReply_slack_reply_to_thread",
        #         "GitHubMcpServer_add_issue_comment", "GitHubMcpServer_create_branch", "GitHubMcpServer_create_or_update_file",
        #         "GitHubMcpServer_create_pull_request", "GitHubMcpServer_get_file_contents", "GitHubMcpServer_get_label",
        #         "GitHubMcpServer_issue_write", "GitHubMcpServer_list_branches", "GitHubMcpServer_list_issues",
        #         "GitHubMcpServer_search_code", "GitHubMcpServer_search_issues", "GitHubMcpServer_search_repositories",
        #       ]
        #     }
        #     notion_issue_pr_agent = {
        #       name               = "notion-issue-pr-agent"
        #       system_prompt_file = "devops_agent/agents/notion_issue_pr_agent.md"
        #       skills             = ["notion_issue_draft_pr"]
        #       tools = [
        #         "use_aws", "query_cloudwatch_logs", "McpSlackReply_slack_reply_to_thread",
        #         "NotionMcpServer_notion-create-pages", "NotionMcpServer_notion-search", "NotionMcpServer_notion-update-page",
        #         "GitHubMcpServer_create_branch", "GitHubMcpServer_create_or_update_file", "GitHubMcpServer_create_pull_request",
        #         "GitHubMcpServer_get_file_contents", "GitHubMcpServer_get_label", "GitHubMcpServer_issue_write", "GitHubMcpServer_list_branches",
        #         "GitHubMcpServer_search_repositories",
        #       ]
        #     }
        #     github_issue_pr_followup_agent = {
        #       name               = "github-issue-pr-followup-agent"
        #       system_prompt_file = "devops_agent/agents/github_issue_pr_followup_agent.md"
        #       skills             = ["github_issue_pr_followup"]
        #       tools = [
        #         "use_aws", "query_cloudwatch_logs",
        #         "GitHubMcpServer_add_issue_comment", "GitHubMcpServer_create_or_update_file", "GitHubMcpServer_get_file_contents", "GitHubMcpServer_issue_read",
        #         "GitHubMcpServer_issue_write", "GitHubMcpServer_pull_request_read", "GitHubMcpServer_push_files", "GitHubMcpServer_search_code",
        #         "GitHubMcpServer_search_issues", "GitHubMcpServer_update_pull_request",
        #       ]
        #       triggers = {
        #         # Weekdays 09:00-19:00 JST, hourly
        #         weekday_hourly = {
        #           schedule_expression = "cron(0 0-10 ? * MON-FRI *)"
        #           status              = "Active"
        #         }
        #       }
        #     }
        #     linear_issue_pr_agent = {
        #       name               = "linear-issue-pr-agent"
        #       system_prompt_file = "devops_agent/agents/linear_issue_pr_agent.md"
        #       skills             = ["linear_issue_draft_pr"]
        #       tools = [
        #         "use_aws", "query_cloudwatch_logs", "McpSlackReply_slack_reply_to_thread",
        #         "LinearMcpServer_list_issue_labels", "LinearMcpServer_list_issues", "LinearMcpServer_list_teams",
        #         "LinearMcpServer_save_comment", "LinearMcpServer_save_issue", "LinearMcpServer_save_issue_label",
        #         "GitHubMcpServer_create_branch", "GitHubMcpServer_create_or_update_file", "GitHubMcpServer_create_pull_request",
        #         "GitHubMcpServer_get_file_contents", "GitHubMcpServer_get_label", "GitHubMcpServer_issue_write",
        #         "GitHubMcpServer_list_branches", "GitHubMcpServer_push_files", "GitHubMcpServer_search_code",
        #         "GitHubMcpServer_search_repositories",
        #       ]
        #     }
        #     linear_issue_pr_followup_agent = {
        #       name               = "linear-issue-pr-followup-agent"
        #       system_prompt_file = "devops_agent/agents/linear_issue_pr_followup_agent.md"
        #       skills             = ["linear_issue_pr_followup"]
        #       tools = [
        #         "use_aws", "query_cloudwatch_logs",
        #         "LinearMcpServer_list_comments", "LinearMcpServer_list_issue_statuses", "LinearMcpServer_list_issues",
        #         "LinearMcpServer_list_teams", "LinearMcpServer_save_comment", "LinearMcpServer_save_issue",
        #         "GitHubMcpServer_add_issue_comment", "GitHubMcpServer_create_or_update_file", "GitHubMcpServer_get_file_contents",
        #         "GitHubMcpServer_pull_request_read", "GitHubMcpServer_push_files", "GitHubMcpServer_search_code",
        #         "GitHubMcpServer_update_pull_request",
        #       ]
        #       triggers = {
        #         # Weekdays 09:00-19:00 JST, hourly
        #         weekday_hourly = {
        #           schedule_expression = "cron(0 0-10 ? * MON-FRI *)"
        #           status              = "Active"
        #         }
        #       }
        #     }
        #   }
        # (Optional) Custom agents and scheduled triggers. system_prompt_file is relative to terraform/monitor.
        custom_agents = {}
        # (Optional) Generic webhook (HMAC). See "Webhook" above.
        # The webhook credentials are written to the Secrets Manager secret by the AWS CLI (never to the Terraform state).
        webhook = {
          is_enabled = false
          secret = {
            # Days before the secret is deleted after destroy (0 or 7-30).
            recovery_window_in_days = 7
          }
        }
      }
    }
  }
  secondary = {
    # CUSTOMIZE: need to set is_enabled to let the Agent Space of the primary account investigate this account.
    is_enabled = false
    # (Optional) Extra IAM statements for the cross-account role (DevOpsAgentRole-SecondaryAccount) on top of
    # AIDevOpsAgentAccessPolicy, for read actions the managed policy lacks (AccessDenied in the investigation). Never allow secretsmanager:GetSecretValue.
    # The primary account uses primary.agent_spaces.<name>.additional_policy_statements instead.
    #   ex)
    #   additional_policy_statements = [
    #     {
    #       sid       = "AllowReadLambdaFunctions"
    #       actions   = ["lambda:GetFunction", "lambda:GetFunctionConfiguration"]
    #       resources = ["arn:aws:lambda:ap-northeast-1:*:function:*"]
    #     },
    #   ]
    additional_policy_statements = []
    # (Required when is_enabled) The primary account and the ARN of its Agent Space.
    # check Agent Space ARN command (run in the primary account). ex) terraform output -json devops_agent_agent_space_arns
    #   ex)
    #   primary_account_id      = "123456789012"
    #   primary_agent_space_arn = "arn:aws:aidevops:ap-northeast-1:123456789012:agentspace/xxxxxxxx"
    primary_account_id      = "123456789012"
    primary_agent_space_arn = "arn:aws:aidevops:ap-northeast-1:123456789012:agentspace/xxxxxxxx-xxxxxx-xxxxx-xxxxxxxxxxx"
  }
}
