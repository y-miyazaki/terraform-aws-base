#--------------------------------------------------------------
# Basically, it is already set so that the setting is completed only by changing tfvars.
# All parameters that need to be changed for each environment are described in TODO comments.
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
# TODO: need to change tags.
tags = {
  # TODO: need to change env.
  # Environment name for resource identification and cost allocation
  # Examples: "dev", "stg", "prd", "audit", "root"
  env = "example"
  # TODO: need to change service.
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
# Specifies the primary AWS region where most resources will be deployed.
# Some services like CloudFront require resources in us-east-1 regardless of this setting.
# Common regions: ap-northeast-1 (Tokyo), us-east-1 (N. Virginia), eu-west-1 (Ireland)
#--------------------------------------------------------------
# TODO: need to change region.
region = "ap-northeast-1"

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
# TODO: need to change cloudwatch_log_group settings.
cloudwatch_log_group = {
  # Default retention period for all services (in days)
  retention_in_days = 14

  # Optional: Override settings for specific services
  # Uncomment and configure as needed
  override = {
    # cloudwatch_event_ec2 = {
    #   retention_in_days = 7
    # }
    # common_lambda_log = {
    #   retention_in_days = 7
    # }
    # common_lambda_metric = {
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
  # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN (bot token xoxb-xxxxxx....)
  # Get this from your Slack app's OAuth & Permissions page
  # Format: xoxb-XXXXXXXXX-XXXXXXXXX-XXXXXXXXXXXXXXXXXXXXXXXX
  oauth_access_token = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
  # TODO: need to change SLACK_CHANNEL_ID
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
    # common_lambda_step_functions = {
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
        expiration = [
          {
            # TODO: need to change days. default 3years.
            # Adjust retention period based on your compliance requirements
            days                         = 1095
            expired_object_delete_marker = null
          }
        ]
        transition = [
          {
            days          = 30
            storage_class = "ONEZONE_IA"
          }
        ]
        noncurrent_version_expiration = [
          {
            days = 30
          }
        ]
      }
    ]
    # TODO: need to change for logging.
    # example)
    #    logging = {
    #      target_bucket = "{your bucket}"
    #      target_prefix = "AccessLogs/{your account id}/S3/{your bucket}/"
    #    }
    logging                 = {}
    restrict_public_buckets = true
    server_side_encryption_configuration = {
      rule = {
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
    # TODO: If you want to run LambdaFunctions inside a VPC, set to true. However,
    # VPC requires more cost since you need to configure NAT Gateway and other settings.
    is_enabled = false
    # TODO: If a VPC has already been established, specify false; if a new VPC is to be created, specify true.
    create_vpc = false

    # TODO: To specify a VPC that already exists, configure the following settings for Lambda.
    # If var.common_lambda.vpc.is_enabled = true and var.common_lambda.vpc.create_vpc = false,
    # the Lambda will be built in an existing VPC by referencing the parameters here.
    exists = {
      private_subnets = [
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
      ]
      security_group_id = "sg-xxxxxxxxxxxxxxxxx"
      private_subnets_us_east_1 = [
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
        "subnet-xxxxxxxxxxxxxxxxx",
      ]
      security_group_id_us_east_1 = "sg-xxxxxxxxxxxxxxxxx"
    }
    # TODO: To specify a new VPC to be set up for Lambda, please set the following information.
    # If var.common_lambda.vpc.is_enabled = true and var.common_lambda.vpc.create_vpc = true,
    # a new VPC is built by referencing the parameters here.
    new = {
      name = "vpc-lambda"
      cidr = "10.0.0.0/16"
      azs = [
        "ap-northeast-1a",
        "ap-northeast-1c",
        "ap-northeast-1d",
      ]
      azs_us_east_1 = [
        "us-east-1a",
        "us-east-1b",
        "us-east-1c",
      ]
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
        # TODO: need to change TIMEZONE.
        # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
        TIMEZONE = "Asia/Tokyo"
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
  }
  # TODO: ex
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
  # TODO: need to set is_enabled for settings of delivery log.
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
  # TODO: need to set is_enabled for settings of delivery log.
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
  # TODO: need to set is_enabled for settings of application log.
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
  aws_cloudwatch_log_metric_filter = {
    name = "application-logs-error"
    # TODO: need to change pattern for application log.
    pattern = <<PATTERN
[( msg="*\"ERROR\"*" || msg="*\"error\"*" || msg="*\"FATAL\"*" || msg="*\"fatal\"*" || msg="*\"PANIC\"*" || msg="*\"panic\"*" || msg="*\"CRITICAL\"*" || msg="*\"critical\"*" || msg="*AccessDenied*" || msg="*ERROR*" || msg="*Failed\"*" || msg="*Aborted\"*" || msg="*TimedOut\"*" || msg="*FailStateEntered\"*") && ( msg!="*'PAUSED'*" && msg!=%"level": ?"(debug|info|warn|warning)"% && msg!="{\"header\":*")]
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
# TODO: ex
#--------------------------------------------------------------
# Log:Step Functions
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to Step Functions
#--------------------------------------------------------------
metric_log_step_functions = {
  # TODO: need to set is_enabled for settings of application log.
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
    # TODO: need to change pattern for application log.
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
  # TODO: need to set is_enabled for settings of application log.
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
    # TODO: need to change pattern for application log.
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
  # TODO: need to set is_enabled for settings of application log.
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
    # TODO: need to change pattern for application log.
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
  # TODO: need to set is_enabled for settings of mysql slowquery log.
  is_enabled = false
  # TODO: need to add log_group_name for mysql slowquery.
  #       check log group name for mysql slowquery.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = [
    #    "/aws/rds/cluster/example-db/slowquery",
  ]

  aws_cloudwatch_log_metric_filter = {
    name = "mysql-slowquery-logs-error"
    # TODO: need to change pattern for postgresql log.
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
  # TODO: need to set is_enabled for settings of postgresql log.
  is_enabled = false
  # TODO: need to add log_group_name for postgresql.
  #       check log group name for postgresql.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = [
    # "/aws/rds/cluster/example-db/postgresql"
  ]

  aws_cloudwatch_log_metric_filter = {
    name = "postgresql-logs-error"
    # TODO: need to change pattern for postgresql log.
    # [the database system...]: is start database instance log.
    # [Can't handle storage runtime process crash]: is start database instance log.
    # [canceling statement due to statement timeout] is normal operation when statement timeout occurs.
    pattern = <<PATTERN
[( msg="*ERROR:*" || msg="*FATAL:*" ) && ( msg!="*FATAL:*the database system*" && msg!="*FATAL:*Can't handle storage runtime process crash*" && msg!="*ERROR:*canceling autovacuum task*" && msg!="*ERROR:*canceling statement due to statement timeout*")]
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
  # TODO: need to set is_enabled_alert for settings of postgresql slow query alert every time.
  #      If you want to set alert, set is_enabled_alert = true.
  is_enabled_alert = false
  # TODO: need to set is_enabled_report for settings of postgresql slow queries report every day.
  #      If you want to set report, set is_enabled_report = true.
  is_enabled_report = true

  # TODO: need to add log_group_name for postgresql.
  #       check log group name for postgresql.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = [
    # "/aws/rds/cluster/example-db/postgresql"
  ]

  aws_cloudwatch_log_metric_filter = {
    name = "postgresql-slowquery-logs-error"
    # TODO: need to change pattern for postgresql slow query filter.
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
  aws_eventbridge_schedule = {
    name                = "postgresql-slowquery-eventbridge-scheduler"
    schedule_expression = "cron(0 0 * * ? *)" # Every day at 00:00 UTC
    description         = "This eventbridge scheduler called PostgreSQL slow query lambda function."
  }
  aws_lambda_function = {
    environment = {
      LOG_GROUP_NAME = "/aws/rds/cluster/example-db/postgresql"
      # TODO: need to change LOG_GROUP_FILTER_PATTERN for postgresql slow query filter.
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
  # TODO: need to set is_enabled for Metric of API Gateway.
  is_enabled = false
  # TODO: need to set period for API Gateway.
  period = 300
  # TODO: need to set threshold for API Gateway.
  threshold = {
    # (Required) 4XXerror threshold (unit=%)
    enabled_error4XX = false
    error4XX         = 20
    # (Required) 5XXerror threshold (unit=%)
    enabled_error5XX = true
    error5XX         = 1
    # (Required) Error threshold (unit=Milliseconds)
    enabled_latency = true
    latency         = 8000
  }
  # (Optional) Override thresholds for specific resources. Key is the ApiName.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for Metric of CloudFront.
  is_enabled = false
  # TODO: need to set period for CloudFront.
  period = 1800
  # TODO: need to set threshold for CloudFront.
  threshold = {
    # (Required) Error401Rate threshold (unit=%)
    enabled_error_401_rate = false
    error_401_rate         = 1
    # (Required) Error403Rate threshold (unit=%)
    enabled_error_403_rate = false
    error_403_rate         = 1
    # (Required) Error404Rate threshold (unit=%)
    enabled_error_404_rate = false
    error_404_rate         = 1
    # (Required) Error502Rate threshold (unit=%)
    enabled_error_502_rate = true
    error_502_rate         = 1
    # (Required) Error503Rate threshold (unit=%)
    enabled_error_503_rate = true
    error_503_rate         = 1
    # (Required) Error504Rate threshold (unit=%)
    enabled_error_504_rate = true
    error_504_rate         = 1
    # (Required) CacheHitRate threshold (unit=%)
    enabled_cache_hit_rate = false
    cache_hit_rate         = 70
    # (Required) OriginLatency threshold (unit=Milliseconds)
    enabled_origin_latency = true
    origin_latency         = 10000
  }
  # (Optional) Override thresholds for specific resources. Key is the DistributionId.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for Metric of EC2.
  is_enabled = false
  # TODO: need to set period for EC2.
  period = 300
  # TODO: need to set threshold for EC2.
  threshold = {
    # (Required) CPUCreditBalance threshold (unit=Count)
    enabled_cpu_credit_balance = false
    cpu_credit_balance         = 100
    # (Required) CPUCreditUsage threshold (unit=Count)
    enabled_cpu_credit_usage = false
    cpu_credit_usage         = 5
    # (Required) CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = true
    cpu_utilization         = 80
    # (Required) CPUSurplusCreditBalance threshold (unit=Count)
    enabled_cpu_surplus_credit_balance = false
    cpu_surplus_credit_balance         = 5
    # (Required) CPUSurplusCreditsCharged threshold (unit=Count)
    enabled_cpu_surplus_credits_charged = false
    cpu_surplus_credits_charged         = 1
    # (Required) DedicatedHostCPUUtilization threshold (unit=Percent)
    enabled_dedicated_host_cpu_utilization = false
    dedicated_host_cpu_utilization         = 80
    # (Required) DiskReadBytes threshold (unit=Bytes)
    enabled_disk_read_bytes = false
    disk_read_bytes         = 1073741824 # 1GB
    # (Required) DiskReadOps threshold (unit=Count)
    enabled_disk_read_ops = false
    disk_read_ops         = 1000
    # (Required) DiskWriteBytes threshold (unit=Bytes)
    enabled_disk_write_bytes = false
    disk_write_bytes         = 1073741824 # 1GB
    # (Required) DiskWriteOps threshold (unit=Count)
    enabled_disk_write_ops = false
    disk_write_ops         = 1000
    # (Required) EBSByteBalance% threshold (unit=Percent)
    enabled_ebs_byte_balance_percent = false
    ebs_byte_balance_percent         = 10
    # (Required) EBSIOBalance% threshold (unit=Percent)
    enabled_ebs_io_balance_percent = false
    ebs_io_balance_percent         = 10
    # (Required) EBSReadBytes threshold (unit=Bytes)
    enabled_ebs_read_bytes = false
    ebs_read_bytes         = 1073741824 # 1GB
    # (Required) EBSReadOps threshold (unit=Count)
    enabled_ebs_read_ops = false
    ebs_read_ops         = 1000
    # (Required) EBSWriteBytes threshold (unit=Bytes)
    enabled_ebs_write_bytes = false
    ebs_write_bytes         = 1073741824 # 1GB
    # (Required) EBSWriteOps threshold (unit=Count)
    enabled_ebs_write_ops = false
    ebs_write_ops         = 1000
    # (Required) MetadataNoToken threshold (unit=Count)
    enabled_metadata_no_token = true
    metadata_no_token         = 1
    # (Required) MetadataNoTokenRejected threshold (unit=Count)
    enabled_metadata_no_token_rejected = true
    metadata_no_token_rejected         = 1
    # (Required) NetworkIn threshold (unit=Bytes)
    enabled_network_in = false
    network_in         = 1073741824 # 1GB
    # (Required) NetworkOut threshold (unit=Bytes)
    enabled_network_out = false
    network_out         = 1073741824 # 1GB
    # (Required) NetworkPacketsIn threshold (unit=Count)
    enabled_network_packets_in = false
    network_packets_in         = 1000000
    # (Required) NetworkPacketsOut threshold (unit=Count)
    enabled_network_packets_out = false
    network_packets_out         = 1000000
    # (Required) StatusCheckFailed threshold (unit=Count)
    enabled_status_check_failed = true
    status_check_failed         = 1
    # (Required) StatusCheckFailed_AttachedEBS threshold (unit=Count)
    enabled_status_check_failed_attached_ebs = false
    status_check_failed_attached_ebs         = 1
    # (Required) StatusCheckFailed_Instance threshold (unit=Count)
    enabled_status_check_failed_instance = true
    status_check_failed_instance         = 1
    # (Required) StatusCheckFailed_System threshold (unit=Count)
    enabled_status_check_failed_system = true
    status_check_failed_system         = 1
  }
  # (Optional) Override thresholds for specific resources. Key is the InstanceId.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for Metric of ECS/ContainerInsights.
  is_enabled = false
  # TODO: need to set period for ECS/ContainerInsights.
  period = 300
  # TODO: need to set threshold for ECS/ContainerInsights.
  threshold = {
    # (Required) CpuUtilized/CpuReserved threshold (unit=Percent)
    enabled_cpu_utilization = true
    cpu_utilization         = 80
    # (Required) MemoryUtilized/MemoryReserved threshold (unit=Percent)
    enabled_memory_utilization = true
    memory_utilization         = 90
  }
  # TODO: need to set dimensions for monitor of ECS/ContainerInsights.
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
  # TODO: need to set is_enabled for Metric of ElastiCache.
  is_enabled = false
  # TODO: need to set period for ElastiCache.
  period = 300
  # TODO: need to set threshold for ElastiCache.
  threshold = {
    # (Required) AuthenticationFailures threshold (unit=Count)
    enabled_authentication_failures = true
    authentication_failures         = 1
    # (Required) CacheHitRate threshold (unit=Percent)
    enabled_cache_hit_rate = true
    cache_hit_rate         = 10
    # (Required) CommandAuthorizationFailures threshold (unit=Count)
    enabled_command_authorization_failures = true
    command_authorization_failures         = 1
    # (Required) CurrConnections threshold (unit=Count)
    enabled_curr_connections = true
    curr_connections         = 50
    # (Required) DatabaseMemoryUsagePercentage threshold (unit=Percent)
    enabled_database_memory_usage_percentage = true
    database_memory_usage_percentage         = 80
    # (Required) EngineCPUUtilization threshold (unit=Percent)
    enabled_engine_cpu_utilization = true
    engine_cpu_utilization         = 90
    # (Required) ErrorCount threshold (unit=Count)
    enabled_error_count = true
    error_count         = 1
    # (Required) Evictions threshold (unit=Count)
    enabled_evictions = true
    evictions         = 100
    # (Required) IamAuthenticationExpirations threshold (unit=Count)
    enabled_iam_authentication_expirations = true
    iam_authentication_expirations         = 1
    # (Required) IamAuthenticationThrottling threshold (unit=Count)
    enabled_iam_authentication_throttling = true
    iam_authentication_throttling         = 1
    # (Required) KeyAuthorizationFailures threshold (unit=Count)
    enabled_key_authorization_failures = true
    key_authorization_failures         = 1
    # (Required) MemoryFragmentationRatio threshold (unit=None)
    enabled_memory_fragmentation_ratio = true
    memory_fragmentation_ratio         = 5
    # (Required) NewConnections threshold (unit=Count)
    enabled_new_connections = true
    new_connections         = 100
    # (Required) ReplicationBytes threshold (unit=Bytes)
    enabled_replication_bytes = true
    replication_bytes         = 104857600 # 100MB
    # (Required) ReplicationLag threshold (unit=Seconds)
    enabled_replication_lag = true
    replication_lag         = 30
    # (Required) SaveInProgress threshold (unit=None)
    enabled_save_in_progress = true
    save_in_progress         = 1
    # (Required) SuccessfulReadRequestLatency threshold (unit=Microseconds)
    enabled_successful_read_request_latency = true
    successful_read_request_latency         = 10000
    # (Required) SuccessfulWriteRequestLatency threshold (unit=Microseconds)
    enabled_successful_write_request_latency = true
    successful_write_request_latency         = 10000
    # (Required) SwapUsage threshold (unit=Bytes)
    enabled_swap_usage = true
    swap_usage         = 52428800 # 50MB
    # (Required) TrafficManagementActive threshold (unit=None)
    enabled_traffic_management_active = true
    traffic_management_active         = 1
  }
  # (Optional) Override thresholds for specific resources. Key is the CacheClusterId.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for Metric of ELB (ALB/NLB).
  is_enabled = false
  # TODO: need to set period for ELB.
  period = 1800
  # TODO: need to set threshold for ELB.
  threshold = {
    # (Required) ActiveConnectionCount threshold (unit=Count)
    enabled_active_connection_count = true
    active_connection_count         = 10000
    # (Required) ClientTLSNegotiationErrorCount threshold (unit=Count)
    enabled_client_tls_negotiation_error_count = true
    client_tls_negotiation_error_count         = 10
    # (Required) ConsumedLCUs threshold (unit=Count)
    enabled_consumed_lcus = true
    consumed_lcus         = 5
    # (Required) HTTPCode_4XX_Count	threshold (unit=Count)
    enabled_httpcode_4xx_count = true
    httpcode_4xx_count         = 1
    # (Required) HTTPCode_5XX_Count	threshold (unit=Count)
    enabled_httpcode_5xx_count = true
    httpcode_5xx_count         = 1
    # (Required) HTTPCode_ELB_4XX_Count	threshold (unit=Count)
    enabled_httpcode_elb_4xx_count = true
    httpcode_elb_4xx_count         = 1
    # (Required) HTTPCode_ELB_5XX_Count	threshold (unit=Count)
    enabled_httpcode_elb_5xx_count = true
    httpcode_elb_5xx_count         = 1
    # (Required) TargetResponseTime	threshold (unit=)
    enabled_target_response_time = true
    target_response_time         = 10
    # (Required) TargetTLSNegotiationErrorCount	threshold (unit=Count)
    enabled_target_tls_negotiation_error_count = true
    target_tls_negotiation_error_count         = 10
    # (Required) UnHealthyHostCount	threshold (unit=Count)
    enabled_unhealthy_host_count = true
    unhealthy_host_count         = 1
  }
  # (Optional) Override thresholds for specific resources. Key is the LoadBalancer.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  #   ex)
  #   dimensions = [
  #     {
  #       "LoadBalancer" = "example-elb"
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
  # TODO: need to set is_enabled for Metric of EventBridge Scheduler.
  is_enabled = false
  # TODO: need to set period for EventBridge Scheduler.
  period = 300
  # TODO: need to set threshold for EventBridge Scheduler.
  threshold = {
    # InvocationAttemptCount threshold (unit=Count)
    enabled_invocation_attempt_count = false
    invocation_attempt_count         = 0
    # TargetErrorCount threshold (unit=Count)
    enabled_target_error_count = true
    target_error_count         = 1
    # TargetErrorThrottledCount threshold (unit=Count)
    enabled_target_error_throttled_count = true
    target_error_throttled_count         = 1
    # InvocationThrottleCount threshold (unit=Count)
    enabled_invocation_throttle_count = true
    invocation_throttle_count         = 1
    # InvocationDroppedCount threshold (unit=Count)
    enabled_invocation_dropped_count = true
    invocation_dropped_count         = 1
  }
  # (Optional) Per-schedule-group threshold overrides. Key is the schedule group name.
  # threshold_override = {
  #   "my-critical-group" = {
  #     target_error_count = 0  # Stricter threshold for critical group
  #   }
  # }
  threshold_override = {}
  # (Optional) Builds a list of schedule groups to automatically set dimensions. If this is true, the dimensions setting will be ignored.
  create_auto_dimensions = true
  # (Optional) If create_auto_dimensions is set to true, a list of schedule groups will be automatically registered, but at that time, specify the schedule group name you want to exclude using partial match.
  auto_dimensions_exclude_list = []
  # (Optional) If create_auto_dimensions is set to true and this list is not empty, only schedule group names matching any of these patterns (partial match) will be included.
  auto_dimensions_include_list = []
  # TODO: need to set dimensions for monitor of EventBridge Scheduler.
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
  # TODO: need to set is_enabled for monitor of Lambda.
  is_enabled = false
  # TODO: need to set period for Lambda.
  period = 300
  # TODO: need to set threshold for Lambda.
  threshold = {
    # (Required) AsyncEventAge threshold (unit=Milliseconds)
    enabled_async_event_age = true
    async_event_age         = 30000
    # (Required) AsyncEventsDropped threshold (unit=Count)
    enabled_async_events_dropped = true
    async_events_dropped         = 1
    # (Optional) AsyncEventsReceived threshold (unit=Count)
    enabled_async_events_received = false
    async_events_received         = 100000
    # (Optional) ClaimedAccountConcurrency threshold (unit=Count)
    enabled_claimed_account_concurrency = false
    claimed_account_concurrency         = 900
    # (Required) ConcurrentExecutions threshold (unit=Count)
    enabled_concurrent_executions = true
    concurrent_executions         = 500
    # (Required) DeadLetterErrors threshold (unit=Count)
    enabled_dead_letter_errors = true
    dead_letter_errors         = 1
    # (Required) DestinationDeliveryFailures threshold (unit=Count)
    enabled_destination_delivery_failures = true
    destination_delivery_failures         = 1
    # (Required) Duration threshold (unit=Milliseconds)
    enabled_duration = true
    duration         = 10000
    # (Required) Errors threshold (unit=Count)
    enabled_errors = true
    errors         = 1
    # (Required) Invocations threshold (unit=Count)
    enabled_invocations = true
    invocations         = 100000
    # (Required) IteratorAge threshold (unit=Milliseconds)
    enabled_iterator_age = true
    iterator_age         = 60000
    # (Optional) OffsetLag threshold (unit=Milliseconds)
    enabled_offset_lag = false
    offset_lag         = 100000
    # (Optional) PostRuntimeExtensionsDuration threshold (unit=Milliseconds)
    enabled_post_runtime_extensions_duration = false
    post_runtime_extensions_duration         = 5000
    # (Optional) ProvisionedConcurrencyInvocations threshold (unit=Count)
    enabled_provisioned_concurrency_invocations = false
    provisioned_concurrency_invocations         = 10000
    # (Optional) ProvisionedConcurrencySpilloverInvocations threshold (unit=Count)
    enabled_provisioned_concurrency_spillover_invocations = false
    provisioned_concurrency_spillover_invocations         = 100
    # (Optional) ProvisionedConcurrencyUtilization threshold (unit=Percent)
    enabled_provisioned_concurrency_utilization = false
    provisioned_concurrency_utilization         = 80
    # (Required) RecursiveInvocationsDropped threshold (unit=Count)
    enabled_recursive_invocations_dropped = true
    recursive_invocations_dropped         = 1
    # (Required) Throttles threshold (unit=Count)
    enabled_throttles = true
    throttles         = 1
    # (Optional) UnreservedConcurrentExecutions threshold (unit=Count)
    enabled_unreserved_concurrent_executions = false
    unreserved_concurrent_executions         = 800
  }
  # (Optional) Override thresholds for specific resources. Key is the FunctionName.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for monitor of NAT Gateway.
  is_enabled = false
  # TODO: need to set period for NAT Gateway.
  period = 300
  # TODO: need to set threshold for NAT Gateway.
  threshold = {
    # (Optional) ActiveConnectionCount threshold (unit=Count)
    enabled_active_connection_count = false
    active_connection_count         = 10000
    # (Required) BytesOutToDestination threshold (unit=Bytes)
    enabled_bytes_out_to_destination = true
    bytes_out_to_destination         = 107374182400 # 100GB in bytes
    # (Required) BytesInFromSource threshold (unit=Bytes)
    enabled_bytes_in_from_source = true
    bytes_in_from_source         = 107374182400 # 100GB in bytes
    # (Optional) BytesInFromDestination threshold (unit=Bytes)
    enabled_bytes_in_from_destination = false
    bytes_in_from_destination         = 107374182400 # 100GB in bytes
    # (Optional) BytesOutToSource threshold (unit=Bytes)
    enabled_bytes_out_to_source = false
    bytes_out_to_source         = 107374182400 # 100GB in bytes
    # (Required) PacketsDropCount threshold (unit=Count)
    enabled_packets_drop_count = true
    packets_drop_count         = 100
    # (Required) ErrorPortAllocation threshold (unit=Count)
    enabled_error_port_allocation = true
    error_port_allocation         = 10
    # (Optional) IdleTimeoutCount threshold (unit=Count)
    enabled_idle_timeout_count = false
    idle_timeout_count         = 100
    # (Optional) PacketsInFromDestination threshold (unit=Count)
    enabled_packets_in_from_destination = false
    packets_in_from_destination         = 10000000
    # (Optional) PacketsInFromSource threshold (unit=Count)
    enabled_packets_in_from_source = false
    packets_in_from_source         = 10000000
    # (Optional) PacketsOutToDestination threshold (unit=Count)
    enabled_packets_out_to_destination = false
    packets_out_to_destination         = 10000000
    # (Optional) PacketsOutToSource threshold (unit=Count)
    enabled_packets_out_to_source = false
    packets_out_to_source         = 10000000
    # (Required) ConnectionAttemptCount threshold (unit=Count)
    enabled_connection_attempt_count = true
    connection_attempt_count         = 10000
    # (Required) ConnectionEstablishedCount threshold (unit=Count)
    enabled_connection_established_count = true
    connection_established_count         = 10000
    # (Optional) PeakBytesPerSecond threshold (unit=Bytes/Second)
    enabled_peak_bytes_per_second = false
    peak_bytes_per_second         = 1073741824 # 1GB/sec
    # (Optional) PeakPacketsPerSecond threshold (unit=Count/Second)
    enabled_peak_packets_per_second = false
    peak_packets_per_second         = 100000
  }
  # (Optional) Override thresholds for specific resources. Key is the NatGatewayId.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for monitor of RDS Cluster.
  is_enabled = false
  # TODO: need to set is_aurora for monitor of RDS(Aurora).
  # If the target DB to be monitored is Aurora, set to true.
  is_aurora = true
  # TODO: need to set is_aurora for monitor of RDS(MySQL).
  # If the target DB to be monitored is MySQL, set to true.
  is_mysql = false
  # TODO: need to set is_aurora for monitor of RDS(PostgreSQL).
  # If the target DB to be monitored is PostgreSQL, set to true.
  is_postgresql = true
  # TODO: need to set period for RDS.
  period = 300
  # TODO: need to set threshold for RDS.
  threshold = {
    # (Required) AuroraReplicaLag threshold (unit=Milliseconds)
    enabled_aurora_replica_lag = true
    aurora_replica_lag         = 1000
    # (Required) BufferCacheHitRatio threshold (unit=Percent)
    enabled_buffer_cache_hit_ratio = false
    buffer_cache_hit_ratio         = 95
    # (Required) CommitLatency threshold (unit=Milliseconds)
    enabled_commit_latency = true
    commit_latency         = 10000
    # (Required) CPUCreditBalance threshold (unit=Count)
    enabled_cpu_credit_balance = true
    cpu_credit_balance         = 100
    # (Required) CPUUtilization threshold (unit=%)
    enabled_cpu_utilization = true
    cpu_utilization         = 80
    # (Required) DatabaseConnections threshold (unit=Count)
    enabled_database_connections = true
    database_connections         = 100
    # (Required) Deadlocks threshold (unit=Count)
    enabled_deadlocks = true
    deadlocks         = 1
    # (Required) DeleteLatency threshold (unit=Count)
    enabled_delete_latency = true
    delete_latency         = 10
    # (Required) DiskQueueDepth threshold (unit=Count)
    enabled_disk_queue_depth = true
    disk_queue_depth         = 64
    # (Required) EngineUptime threshold (unit=Seconds)
    enabled_engine_uptime = false
    engine_uptime         = 86400
    # (Required) FreeLocalStorage threshold (unit=Bytes)
    enabled_free_local_storage = false
    free_local_storage         = 1073741824
    # (Required) FreeableMemory threshold (unit=Megabytes)
    enabled_freeable_memory = true
    freeable_memory         = 512
    # (Required) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    enabled_network_receive_throughput = false
    network_receive_throughput         = 1024 * 1024
    # (Required) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    enabled_network_transmit_throughput = false
    network_transmit_throughput         = 1024 * 1024
    # (Required) ReadIOPS threshold (unit=Count/Second)
    enabled_read_iops = false
    read_iops         = 1000
    # (Required) ReadLatency threshold (unit=Seconds)
    enabled_read_latency = true
    read_latency         = 10
    # (Required) ReadThroughput threshold (unit=Bytes/Second)
    enabled_read_throughput = false
    read_throughput         = 1024 * 1024 * 1024
    # (Required) WriteIOPS threshold (unit=Count/Second)
    enabled_write_iops = false
    write_iops         = 1000
    # (Required) WriteLatency threshold (unit=Seconds)
    enabled_write_latency = true
    write_latency         = 10
    # (Required) WriteThroughput threshold (unit=Bytes/Second)
    enabled_write_throughput = false
    write_throughput         = 1024 * 1024 * 1024
  }
  # (Optional) Override thresholds for specific resources. Key is the DBClusterIdentifier.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for monitor of Redshift.
  is_enabled = false
  # TODO: need to set period for Redshift.
  period = 300
  # TODO: need to set threshold for Redshift.
  threshold = {
    # (Required) CommitQueueLength threshold (unit=Count)
    enabled_commit_queue_length = true
    commit_queue_length         = 100
    # (Required) ConcurrencyScalingActiveClusters threshold (unit=Count)
    enabled_concurrency_scaling_active_clusters = true
    concurrency_scaling_active_clusters         = 100
    # (Required) ConcurrencyScalingSeconds threshold (unit=Seconds)
    enabled_concurrency_scaling_seconds = true
    concurrency_scaling_seconds         = 10
    # (Required) CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = true
    cpu_utilization         = 80
    # (Required) DatabaseConnections threshold (unit=Count)
    enabled_database_connections = true
    database_connections         = 100
    # (Required) HealthStatus threshold (HEALTHY(1)/UNHEALTHY(0))
    enabled_health_status = true
    health_status         = 0
    # (Required) MaintenanceMode threshold (unit=Count(ON(1)/OFF(0)))
    enabled_maintenance_mode = true
    maintenance_mode         = 1
    # (Required) MaxConfiguredConcurrencyScalingClusters threshold (unit=Count)
    enabled_max_configured_concurrency_scaling_clusters = true
    max_configured_concurrency_scaling_clusters         = 5
    # (Required) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    enabled_network_receive_throughput = false
    network_receive_throughput         = 1024 * 1024
    # (Required) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    enabled_network_transmit_throughput = false
    network_transmit_throughput         = 1024 * 1024
    # (Required) PercentageDiskSpaceUsed threshold (unit=Percent)
    enabled_percentage_disk_space_used = true
    percentage_disk_space_used         = 80
    # (Required) QueriesCompletedPerSecond threshold (unit=Count/Second)
    enabled_queries_completed_per_second = true
    queries_completed_per_second         = 100
    # (Required) QueryDuration threshold (unit=Microseconds)
    enabled_query_duration = true
    query_duration         = 3000000
    # (Required) QueryRuntimeBreakdown threshold (unit=Microseconds)
    enabled_query_runtime_breakdown = true
    query_runtime_breakdown         = 3000000
    # (Required) ReadIOPS threshold (unit=Count/Second)
    enabled_read_iops = false
    read_iops         = 1000
    # (Required) ReadLatency threshold (unit=Seconds)
    enabled_read_latency = true
    read_latency         = 3
    # (Required) ReadThroughput threshold (unit=Bytes)
    enabled_read_throughput = false
    read_throughput         = 1024 * 1024 * 1024
    # (Required) RedshiftManagedStorageTotalCapacity threshold (unit=Megabytes)
    enabled_redshift_managed_storage_total_capacity = false
    redshift_managed_storage_total_capacity         = 1024 * 1024 * 500
    # (Required) TotalTableCount threshold (unit=Count)
    enabled_total_table_count = false
    total_table_count         = 50
    # (Required) WLMQueueLength threshold (unit=Count)
    enabled_wlm_queue_length = true
    wlm_queue_length         = 5
    # (Required) WLMQueueWaitTime threshold (unit=Milliseconds)
    enabled_wlm_queue_wait_time = true
    wlm_queue_wait_time         = 100
    # (Required) WLMQueriesCompletedPerSecond threshold (unit=Count/Second)
    enabled_wlm_queries_completed_per_second = false
    wlm_queries_completed_per_second         = 100
    # (Required) WLMQueryDuration threshold (unit=Microseconds)
    enabled_wlm_query_duration = true
    wlm_query_duration         = 3000000
    # (Required) WLMRunningQueries threshold (unit=Count)
    enabled_wlm_running_queries = false
    wlm_running_queries         = 10
    # (Required) WriteIOPS threshold (unit=Count/Second)
    enabled_write_iops = false
    write_iops         = 1000
    # (Required) WriteLatency threshold (unit=Seconds)
    enabled_write_latency = true
    write_latency         = 3
    # (Required) WriteThroughput threshold (unit=Bytes)
    enabled_write_throughput = false
    write_throughput         = 1024 * 1024 * 1024
    # (Required) SchemaQuota threshold (unit=Megabytes)
    enabled_schema_quota = false
    schema_quota         = 1024
    # (Required) NumExceededSchemaQuotas threshold (unit=Count)
    enabled_num_exceeded_schema_quotas = true
    num_exceeded_schema_quotas         = 0
    # (Required) StorageUsed threshold (unit=Megabytes)
    enabled_storage_used = false
    storage_used         = 1024
    # (Required) PercentageQuotaUsed threshold (unit=Percent)
    enabled_percentage_quota_used = false
    percentage_quota_used         = 1024
  }
  # (Optional) Override thresholds for specific resources. Key is the ClusterIdentifier.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for monitor of SES.
  is_enabled = false
  # TODO: need to set period for SES.
  period = 300
  # TODO: need to set threshold for SES.
  threshold = {
    # Reputation.BounceRate threshold (unit=Percent)
    enabled_reputation_bouncerate = true
    reputation_bouncerate         = 5
    # Reputation.ComplaintRate threshold (unit=Percent)
    enabled_reputation_complaintrate = true
    reputation_complaintrate         = 0.1
  }
  dimensions = []
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
  # TODO: need to set is_enabled for monitor of SNS.
  is_enabled = false
  # TODO: need to set period for SNS.
  period = 300
  # TODO: need to set threshold for SNS.
  threshold = {
    # (Required) NumberOfMessagesPublished threshold (unit=Count)
    enabled_number_of_messages_published = false
    number_of_messages_published         = 1000
    # (Required) NumberOfNotificationsDelivered threshold (unit=Count)
    enabled_number_of_notifications_delivered = false
    number_of_notifications_delivered         = 1000
    # (Required) NumberOfNotificationsFailed threshold (unit=Count)
    enabled_number_of_notifications_failed = true
    number_of_notifications_failed         = 1
    # (Required) NumberOfNotificationsFailedToRedriveToDlq threshold (unit=Count)
    enabled_number_of_notifications_failed_to_redrive_to_dlq = true
    number_of_notifications_failed_to_redrive_to_dlq         = 1
    # (Required) NumberOfNotificationsFilteredOut threshold (unit=Count)
    enabled_number_of_notifications_filtered_out = false
    number_of_notifications_filtered_out         = 100
    # (Required) NumberOfNotificationsFilteredOut-InvalidAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_invalid_attributes = false
    number_of_notifications_filtered_out_invalid_attributes         = 1
    # (Required) NumberOfNotificationsFilteredOut-InvalidMessageBody threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_invalid_message_body = false
    number_of_notifications_filtered_out_invalid_message_body         = 1
    # (Required) NumberOfNotificationsFilteredOut-MessageAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_message_attributes = false
    number_of_notifications_filtered_out_message_attributes         = 100
    # (Required) NumberOfNotificationsFilteredOut-MessageBody threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_message_body = false
    number_of_notifications_filtered_out_message_body         = 100
    # (Required) NumberOfNotificationsFilteredOut-NoMessageAttributes threshold (unit=Count)
    enabled_number_of_notifications_filtered_out_no_message_attributes = false
    number_of_notifications_filtered_out_no_message_attributes         = 100
    # (Required) NumberOfNotificationsRedrivenToDlq threshold (unit=Count)
    enabled_number_of_notifications_redriven_to_dlq = false
    number_of_notifications_redriven_to_dlq         = 10
    # (Required) PublishSize threshold (unit=Bytes)
    enabled_publish_size = false
    publish_size         = 262144
  }
  # (Optional) Override thresholds for specific resources. Key is the TopicName.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for monitor of SQS.
  is_enabled = false
  # TODO: need to set period for SQS.
  period = 300
  # TODO: need to set threshold for SQS.
  threshold = {
    # (Required) ApproximateAgeOfOldestMessage threshold (unit=Seconds)
    enabled_approximate_age_of_oldest_message = true
    approximate_age_of_oldest_message         = 3600
    # (Required) ApproximateAgeOfOldestMessageInQuietGroups threshold (unit=Seconds, Fair Queues only)
    enabled_approximate_age_of_oldest_message_in_quiet_groups = false
    approximate_age_of_oldest_message_in_quiet_groups         = 3600
    # (Required) ApproximateNumberOfGroupsWithInflightMessages threshold (unit=Count, FIFO only)
    enabled_approximate_number_of_groups_with_inflight_messages = false
    approximate_number_of_groups_with_inflight_messages         = 100
    # (Required) ApproximateNumberOfMessagesDelayed threshold (unit=Count)
    enabled_approximate_number_of_messages_delayed = false
    approximate_number_of_messages_delayed         = 1000
    # (Required) ApproximateNumberOfMessagesDelayedInQuietGroups threshold (unit=Count, Fair Queues only)
    enabled_approximate_number_of_messages_delayed_in_quiet_groups = false
    approximate_number_of_messages_delayed_in_quiet_groups         = 100
    # (Required) ApproximateNumberOfMessagesNotVisible threshold (unit=Count)
    enabled_approximate_number_of_messages_not_visible = false
    approximate_number_of_messages_not_visible         = 1000
    # (Required) ApproximateNumberOfMessagesNotVisibleInQuietGroups threshold (unit=Count, Fair Queues only)
    enabled_approximate_number_of_messages_not_visible_in_quiet_groups = false
    approximate_number_of_messages_not_visible_in_quiet_groups         = 100
    # (Required) ApproximateNumberOfMessagesVisible threshold (unit=Count)
    enabled_approximate_number_of_messages_visible = true
    approximate_number_of_messages_visible         = 1
    # (Required) ApproximateNumberOfMessagesVisibleInQuietGroups threshold (unit=Count, Fair Queues only)
    enabled_approximate_number_of_messages_visible_in_quiet_groups = false
    approximate_number_of_messages_visible_in_quiet_groups         = 100
    # (Required) ApproximateNumberOfNoisyGroups threshold (unit=Count, Fair Queues only)
    enabled_approximate_number_of_noisy_groups = false
    approximate_number_of_noisy_groups         = 10
    # (Required) NumberOfDeduplicatedSentMessages threshold (unit=Count, FIFO only)
    enabled_number_of_deduplicated_sent_messages = false
    number_of_deduplicated_sent_messages         = 100
    # (Required) NumberOfEmptyReceives threshold (unit=Count)
    enabled_number_of_empty_receives = false
    number_of_empty_receives         = 1000
    # (Required) NumberOfMessagesDeleted threshold (unit=Count)
    enabled_number_of_messages_deleted = false
    number_of_messages_deleted         = 1000
    # (Required) NumberOfMessagesReceived threshold (unit=Count)
    enabled_number_of_messages_received = false
    number_of_messages_received         = 1000
    # (Required) NumberOfMessagesSent threshold (unit=Count)
    enabled_number_of_messages_sent = false
    number_of_messages_sent         = 1000
    # (Required) SentMessageSize threshold (unit=Bytes)
    enabled_sent_message_size = false
    sent_message_size         = 262144
  }
  # (Optional) Override thresholds for specific resources. Key is the QueueName.
  # threshold_override = {
  #   "resource-name" = {
  #     enabled_some_metric = false
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
  # TODO: need to set is_enabled for settings of EC2.
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
      # TODO: need to set is_enabled for Metric of Synthetics Canary.
      is_enabled = false
      # TODO: need to set period for Synthetics Canary.
      period = 300
      # TODO: need to set threshold for Synthetics Canary.
      threshold = {
        # (Required) 2xx threshold (unit=Count)
        enabled_2xx = false
        http_2xx    = 100
        # (Required) 4xx threshold (unit=Count)
        enabled_4xx = true
        http_4xx    = 1
        # (Required) 5xx threshold (unit=Count)
        enabled_5xx = true
        http_5xx    = 1
        # (Required) Duration threshold (unit=Milliseconds)
        enabled_duration = true
        duration         = 30000
        # (Required) DurationDryRun threshold (unit=Milliseconds)
        enabled_duration_dry_run = false
        duration_dry_run         = 30000
        # (Required) Failed threshold (unit=Count)
        enabled_failed = true
        failed         = 1
        # (Required) FailedRequests threshold (unit=Count)
        enabled_failed_requests = false
        failed_requests         = 1
        # (Required) SuccessPercent threshold (unit=Percent)
        enabled_success_percent = false
        success_percent         = 99
        # (Required) SuccessPercentDryRun threshold (unit=Percent)
        enabled_success_percent_dry_run = false
        success_percent_dry_run         = 99
        # (Required) SuccessPercentWithRetries threshold (unit=Percent)
        enabled_success_percent_with_retries = false
        success_percent_with_retries         = 99
        # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)
        enabled_visual_monitoring_success_percent = false
        visual_monitoring_success_percent         = 99
      }
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
        # TODO: If you are restricting IP addresses using WAF or other methods but are allowing access from a VPC, you must configure the VPC accordingly.
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
        # TODO: Set the Heartbeat URL and list of acceptable status codes.
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
      # TODO: need to set is_enabled for Metric of Synthetics Canary.
      is_enabled = false
      # TODO: need to set period for Synthetics Canary.
      period = 300
      # TODO: need to set threshold for Synthetics Canary.
      threshold = {
        # (Required) 2xx threshold (unit=Count)
        enabled_2xx = false
        http_2xx    = 100
        # (Required) 4xx threshold (unit=Count)
        enabled_4xx = true
        http_4xx    = 1
        # (Required) 5xx threshold (unit=Count)
        enabled_5xx = true
        http_5xx    = 1
        # (Required) Duration threshold (unit=Milliseconds)
        enabled_duration = false
        duration         = 30000
        # (Required) DurationDryRun threshold (unit=Milliseconds)
        enabled_duration_dry_run = false
        duration_dry_run         = 30000
        # (Required) Failed threshold (unit=Count)
        enabled_failed = true
        failed         = 1
        # (Required) FailedRequests threshold (unit=Count)
        enabled_failed_requests = false
        failed_requests         = 1
        # (Required) SuccessPercent threshold (unit=Percent)
        enabled_success_percent = false
        success_percent         = 99
        # (Required) SuccessPercentDryRun threshold (unit=Percent)
        enabled_success_percent_dry_run = false
        success_percent_dry_run         = 99
        # (Required) SuccessPercentWithRetries threshold (unit=Percent)
        enabled_success_percent_with_retries = false
        success_percent_with_retries         = 99
        # (Required) VisualMonitoringSuccessPercent threshold (unit=Percent)
        enabled_visual_monitoring_success_percent = false
        visual_monitoring_success_percent         = 99
      }

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
        # TODO: If you are restricting IP addresses using WAF or other methods but are allowing access from a VPC, you must configure the VPC accordingly.
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
        # TODO: Set the URL for the link check and the maximum number of links to follow.
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
  # TODO: need to set is_enabled for Athena.
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
  # TODO: To check CloudFront logs with Athena, specify true.
  enabled_cloudfront = true
  # TODO: Specify the S3 bucket where CloudFront logs are stored. s3://{bucket name}/{bucket prefix}
  cloudfront_log_bucket = "s3://base-aws-log-application-0123456789012/Logs/CloudFront/"
  # TODO: To check SES logs with Athena, specify true.
  enabled_ses = true
  # TODO: Specify the S3 bucket where SES logs are stored. s3://{bucket name}/{bucket prefix}
  ses_log_bucket = "s3://base-aws-log-application-0123456789012/Logs/base-aws-ses-log/"
}

#--------------------------------------------------------------
# Report CSP
#--------------------------------------------------------------
report_csp = {
  # TODO: need to set is_enabled for report CSP.
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
    # TODO: need to set is_enabled for enable and disable batch job queue schedule.
    is_enabled = false
    # TODO: need to set schedule_expression_stop for disable batch job queue.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # TODO: need to set schedule_expression_start for enable batch job queue.
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
    #       # TODO: need to set job_queue for enable and disable batch job queue.
    #       job_queue = "example-job-queue"
    #       # TODO: (Optional) if you want to override schedule_expression_stop for batch job queue.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # TODO: (Optional) if you want to override schedule_expression_start for batch job queue.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # TODO: (Optional) if you want to override description for batch job queue.
    #       description = "Enable and disable example Batch job queue"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic stop and start of EC2 Instance.
  #--------------------------------------------------------------
  ec2 = {
    # TODO: need to set is_enabled for stop and start ec2_instance schedule.
    is_enabled = false
    # TODO: need to set schedule_expression_stop for stop ec2 instance.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # TODO: need to set schedule_expression_start for start ec2 instance.
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
    #       # TODO: (Required) need to set instance_id for stop and start ec2 instance.
    #       instance_id = "i-1234567890abcdef0"
    #       # TODO: (Optional) if you want to override schedule_expression_stop for ec2 instance.
    #       # schedule_expression_stop = "cron(0 10 * * ? *)"
    #       # TODO: (Optional) if you want to override schedule_expression_start for ec2 instance.
    #       # schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # TODO: (Optional) if you want to override description for ec2 instance.
    #       description = "Stop and start example EC2 instance"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic stop and start of ECS Service.
  #--------------------------------------------------------------
  ecs_service = {
    # TODO: need to set is_enabled for stop and start ecs_service schedule.
    is_enabled = false
    # TODO: need to set schedule_expression_stop for stop ecs service.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # TODO: need to set schedule_expression_start for start ecs service.
    schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    # (Optional) Automatically discover ECS services to create schedules. If true, schedules variable is ignored.
    create_auto_schedules = true
    # (Optional) List of patterns to exclude from auto-discovery (partial match on cluster or service name).
    auto_schedules_exclude_list = []
    # (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included.
    auto_schedules_include_list = []
    # TODO: need to set autoscaling_min_capacity for start ecs service with autoscaling (set to 0 to skip autoscaling adjustment).
    autoscaling_min_capacity = 1
    # TODO: need to set autoscaling_max_capacity for start ecs service with autoscaling (set to 0 to use discovered value).
    autoscaling_max_capacity = 10
    # TODO: need to set desired_count for start ecs service.
    desired_count = 1
    # (Optional) If create_auto_schedules is set to false, need to set schedules for stop and start ECS Service.
    # Specify the instance of the target ECS Service to be scheduled by Map.
    # check ECS Cluster and Service list command.
    # ex) for cluster in $(aws ecs list-clusters --query 'clusterArns[]' --output text); do cluster_name=$(basename $cluster); for service in $(aws ecs list-services --cluster $cluster --query 'serviceArns[]' --output text); do service_name=$(basename $service); desired=$(aws ecs describe-services --cluster $cluster --services $service --query 'services[0].desiredCount' --output text); echo "$cluster_name / $service_name / desired_count=$desired"; done; done
    #   ex)
    #   schedules = {
    #     example-service = {
    #       # TODO: (Required) need to set ecs_cluster for stop and start ecs service.
    #       ecs_cluster   = "example-cluster"
    #       # TODO: (Required) need to set ecs_service for stop and start ecs service.
    #       ecs_service   = "example-service"
    #       # TODO: (Optional) if you want to override autoscaling_min_capacity for start ecs service with autoscaling (set to 0 to skip autoscaling adjustment).
    #       autoscaling_min_capacity = 1
    #       # TODO: (Optional) if you want to override autoscaling_max_capacity for start ecs service with autoscaling (set to 0 to use discovered value).
    #       autoscaling_max_capacity = 10
    #       # TODO: (Optional) if you want to override desired_count for start ecs service.
    #       desired_count = 1
    #       # TODO: (Optional) if you want to override schedule_expression_stop for ecs service.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # TODO: (Optional) if you want to override schedule_expression_start for ecs service.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # TODO: (Optional) if you want to override description for ecs service.
    #       description = "Stop and start example ECS service"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic enable and disable of ECS Scheduled Task (EventBridge Rule).
  #--------------------------------------------------------------
  ecs_scheduled_task = {
    # TODO: need to set is_enabled for enable and disable ecs scheduled task schedule.
    is_enabled = false
    # TODO: need to set schedule_expression_stop for disable ecs scheduled task rule.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # TODO: need to set schedule_expression_start for enable ecs scheduled task rule.
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
    #       # TODO: (Required) need to set ecs_cluster for enable and disable ecs scheduled task rule.
    #       ecs_cluster = "example-ecs-cluster"
    #       # TODO: (Required) need to set task_definition for enable and disable ecs scheduled task rule.
    #       task_definition = "example-task-definition-family"
    #       # TODO: (Optional) if you want to override schedule_expression_stop for ecs scheduled task rule.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # TODO: (Optional) if you want to override schedule_expression_start for ecs scheduled task rule.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # TODO: (Optional) if you want to override description for ecs scheduled task rule.
    #       description = "Enable and disable example ECS task rule"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic stop and start of RDS Cluster.
  #--------------------------------------------------------------
  rds_cluster = {
    # TODO: need to set is_enabled for stop and start rds_cluster schedule.
    is_enabled = false
    # TODO: need to set schedule_expression_stop for stop rds cluster.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # TODO: need to set schedule_expression_start for start rds cluster.
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
    #       # TODO: (Required) need to set db_cluster_identifier for stop and start rds cluster.
    #       db_cluster_identifier = "example-db"
    #       # TODO: (Optional) if you want to override schedule_expression_stop for rds cluster.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # TODO: (Optional) if you want to override schedule_expression_start for rds cluster.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # TODO: (Optional) if you want to override description for rds cluster.
    #       description = "Stop and start example RDS cluster"
    #     }
    #   }
    schedules = {}
  }
  #--------------------------------------------------------------
  # Schedule automatic pause and resume of Redshift Cluster.
  #--------------------------------------------------------------
  redshift = {
    # TODO: need to set is_enabled for pause and resume redshift cluster schedule.
    is_enabled = true
    # TODO: need to set schedule_expression_stop for pause redshift cluster.
    schedule_expression_stop = "cron(0 10 * * ? *)"
    # TODO: need to set schedule_expression_start for resume redshift cluster.
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
    #       # TODO: (Required) need to set cluster_identifier for pause and resume redshift cluster.
    #       cluster_identifier = "example-redshift"
    #       # TODO: (Optional) if you want to override schedule_expression_stop for redshift cluster.
    #       schedule_expression_stop  = "cron(0 10 * * ? *)"
    #       # TODO: (Optional) if you want to override schedule_expression_start for redshift cluster.
    #       schedule_expression_start = "cron(0 1 ? * MON-FRI *)"
    #       # TODO: (Optional) if you want to override description for redshift cluster.
    #       description = "Pause and resume example Redshift cluster"
    #     }
    #   }
    schedules = {}
  }
}
