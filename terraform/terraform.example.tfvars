#--------------------------------------------------------------
# Basically, it is already set so that the setting is completed only by changing tfvars.
# All parameters that need to be changed for each environment are described in TODO comments.
#--------------------------------------------------------------

#--------------------------------------------------------------
# Default Tags for Resources
# A tag that is set globally for the resources used.
#--------------------------------------------------------------
# TODO: need to change tags.
tags = {
  # TODO: need to change env.
  env = "dev"
  # TODO: need to change service.
  # service is project name or job name or product name.
  service = "base"
}
#--------------------------------------------------------------
# Name prefix
# It is used as a prefix attached to various resource names.
#--------------------------------------------------------------
name_prefix = "base-"
#--------------------------------------------------------------
# Default Tags for Resources
#--------------------------------------------------------------
# TODO: need to change region.
region = "ap-northeast-1"
#--------------------------------------------------------------
# Resource Group
#--------------------------------------------------------------
# TODO: need to change env and service.
resourcegroups_group = {
  name = "resource-group"
  resource_query = [
    {
      query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::AllSupported"
  ],
  "TagFilters": [
    {
      "Key": "env",
      "Values": ["dev"]
    },
    {
      "Key": "service",
      "Values": ["base"]
    }
  ]
}
JSON
    }
  ]
}
#--------------------------------------------------------------
# Budgets
#--------------------------------------------------------------
budgets = {
  # Provides a budgets budget resource. Budgets use the cost visualisation provided
  # by Cost Explorer to show you the status of your budgets, to provide forecasts of
  # your estimated costs, and to track your AWS usage, including your free tier usage.
  aws_budgets_budget = {
    name = "budgets-monthly"
    # TODO: need to change limit_amount for Service
    limit_amount = "100.0"
    time_unit    = "MONTHLY"
    notification = [
      {
        comparison_operator = "GREATER_THAN"
        threshold           = "80"
        threshold_type      = "PERCENTAGE"
        notification_type   = "ACTUAL"
        # TODO: need to change subscriber_email_addresses.
        # If the threshold is exceeded, you will be notified to the email address provided.
        # At least one must set an email address.
        subscriber_email_addresses = [
          # example)
          "youremail@test.test.com"
        ]
        subscriber_sns_topic_arns = null
      }
    ]
  }
  aws_cloudwatch_event_rule = {
    name = "budgets-cloudwatch-event-rule"
    # TODO: need to change schedule_expression.
    # schedule_expression when Budgets will be notified.
    schedule_expression = "cron(0 0 * * ? *)"
    description         = "This cloudwatch event used for Budgets."
    is_enabled          = true
  }
  aws_cloudwatch_log_group_lambda = {
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
      # TODO: need to change TIMEZONE.
      # https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
      TIMEZONE = "Asia/Tokyo"
      # TODO: need to change MONTHLY_TARGET_COST.(unit USD)
      # Set an estimated monthly AWS cost.
      MONTHLY_TARGET_COST = 450
      # need to change REGION.
      REGION = "ap-northeast-1"
      # TODO: need to change SERVICE.
      # SERVICE is project name or job name or product name.
      SERVICE = "test"
      # TODO: need to change ENV.
      ENV = "dev"
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.
      SLACK_OAUTH_ACCESS_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "xxxxxxxxxx"
      LOGGER_FORMATTER = "json"
      LOGGER_OUT       = "stdout"
      LOGGER_LEVEL     = "warn"
    }
  }
}
#--------------------------------------------------------------
# Trusted Advisor
#--------------------------------------------------------------
trusted_advisor = {
  // TODO: need to set is_enabled.
  // If you are not in a business or enterprise plan with a support plan, set is_enable to false as notifications will fail. If not, set it to true.
  is_enabled = false
  aws_cloudwatch_event_rule = {
    name                = "trusted-advisor-cloudwatch-event-rule"
    schedule_expression = "cron(0 0 * * ? *)"
    description         = "This cloudwatch event used for Trusted Advisor."
    is_enabled          = true
  }
  aws_cloudwatch_log_group_lambda = {
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
      LANGUAGE = "en"
      # TODO: need to change SERVICE.
      # SERVICE is project name or job name or product name.
      SERVICE = "test"
      # TODO: need to change ENV.
      ENV = "dev"
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.
      SLACK_OAUTH_ACCESS_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "xxxxxxxxxx"
      LOGGER_FORMATTER = "json"
      LOGGER_OUT       = "stdout"
      LOGGER_LEVEL     = "warn"
    }
  }
}
#--------------------------------------------------------------
# IAM: Users
#--------------------------------------------------------------
iam = {
  # TODO: need to change IAM User.
  user = [
    "test1",
    "test2",
    "test3",
  ]
  # TODO: need to change IAM Group.
  # Please specify the user with the same name that has been set in users.
  group = {
    administrator = {
      users = [
        "test1",
      ]
      # TODO: need to set base policy.
      # Please specify the base policy to provide.
      # default null.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy_document = null
      # TODO: need to add policy arn. group policy limit is 10.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy = [
        {
          policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
        }
      ]
    }
    developer = {
      users = [
        "test2",
      ]
      # TODO: need to set base policy.
      # Please specify the base policy to provide.
      # default null.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy_document = {
        name        = "iam-group-developer-base-policy"
        path        = "/"
        description = ""
        statement = [
          {
            sid    = "AllowAWSSecurityHubReadOnlyAccess"
            effect = "Allow"
            actions = [
              "securityhub:Get*",
              "securityhub:List*",
              "securityhub:Describe*",
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "AllowAWSConfigUserAccess"
            effect = "Allow"
            actions = [
              "config:Get*",
              "config:Describe*",
              "config:Deliver*",
              "config:List*",
              "config:Select*",
              "tag:GetResources",
              "tag:GetTagKeys",
              "cloudtrail:DescribeTrails",
              "cloudtrail:GetTrailStatus",
              "cloudtrail:LookupEvents",
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "AllowCloudWatchFullAccess1"
            effect = "Allow"
            actions = [
              "autoscaling:Describe*",
              "cloudwatch:*",
              "logs:*",
              "sns:*",
              "iam:GetPolicy",
              "iam:GetPolicyVersion",
              "iam:GetRole"
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "AllowCloudWatchFullAccess2"
            effect = "Allow"
            actions = [
              "iam:CreateServiceLinkedRole",
            ]
            resources = [
              "arn:aws:iam::*:role/aws-service-role/events.amazonaws.com/AWSServiceRoleForCloudWatchEvents"
            ]
            condition = [
              {
                test     = "StringLike"
                variable = "iam:AWSServiceName"
                values   = ["events.amazonaws.com"]
              }
            ]
          },
        ]
      }
      # TODO: need to add policy arn. group policy limit is 10.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy = [
        {
          policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
        },
        {
          policy_arn = "arn:aws:iam::aws:policy/AmazonVPCFullAccess"
        },
      ]
    }
    operator = {
      users = [
        "test2",
        "test3",
      ]
      # TODO: need to set base policy.
      # Please specify the base policy to provide.
      # default null.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy_document = {
        name        = "iam-group-operator-base-policy"
        path        = "/"
        description = ""
        statement = [
          {
            sid    = "AllowCloudWatchReadOnlyAccess"
            effect = "Allow"
            actions = [
              "autoscaling:Describe*",
              "cloudwatch:Describe*",
              "cloudwatch:Get*",
              "cloudwatch:List*",
              "logs:Get*",
              "logs:List*",
              "logs:StartQuery",
              "logs:StopQuery",
              "logs:Describe*",
              "logs:TestMetricFilter",
              "logs:FilterLogEvents",
              "sns:Get*",
              "sns:List*"
            ]
            resources = [
              "*"
            ]
          },
          {
            sid    = "AllowAmazonS3ReadOnlyAccess"
            effect = "Allow"
            actions = [
              "s3:Get*",
              "s3:List*"
            ]
            resources = [
              "*"
            ]
          },
        ]
      }
      # TODO: need to add policy arn. group policy limit is 10.
      # You need to check this document.
      # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
      policy = []
    }
  }
}
#--------------------------------------------------------------
# Security:IAM
#--------------------------------------------------------------
security_iam = {
  aws_iam_account_password_policy = {
    allow_users_to_change_password = true
    hard_expiry                    = true
    max_password_age               = 90
    minimum_password_length        = 14
    password_reuse_prevention      = 24
    require_lowercase_characters   = true
    require_numbers                = true
    require_symbols                = true
    require_uppercase_characters   = true
  }
  # TODO: need to set principal role arn for Support IAM Role.
  # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cis-controls.html#cis-1.20-remediation
  support_iam_role_principal_arns = [
    # example)
    # "arn:aws:iam::{account id}:{iam user}"
    "arn:aws:iam::999999999999:root"
  ]
  aws_iam_role = {
    description = null
    name        = "security-support-role"
    path        = "/"
  }
}
#--------------------------------------------------------------
# Security:Default VPC
#--------------------------------------------------------------
security_default_vpc = {
  enabled          = true
  enable_flow_logs = true
  # A boolean flag to enable/disable VPC Endpoint for [EC2.10]. Defaults true."
  # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#ec2-10-remediation
  # If true, the EC2-10 indication will be resolved.
  # If false, Security Hub will point out Severity: Medium on EC2-10.
  # This flag will set the VPC Endpoint for the default VPC in each region.
  # Normally, it costs more than 10 USD a month for the default VPC that you do not use, so the initial value is set to false.
  enable_vpc_end_point = false
  aws_cloudwatch_log_group = {
    name_prefix       = "flow-log-"
    retention_in_days = 30
  }
  aws_iam_role = {
    description = null
    name        = "security-vpc-flow-log-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = null
    name        = "security-vpc-flow-log-policy"
    path        = "/"
  }
}

#--------------------------------------------------------------
# Security:Lambda
#--------------------------------------------------------------
security_lambda = {
  aws_iam_role = {
    description = null
    name        = "security-lambda-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = null
    name        = "security-lambda-policy"
    path        = "/"
  }
}
#--------------------------------------------------------------
# Security:Logging Bucket
#--------------------------------------------------------------
security_logging = {
  aws_s3_bucket = {
    bucket        = "aws-logging"
    acl           = "log-delivery-write"
    force_destroy = true
    versioning = [
      {
        enabled = true
      }
    ]
    logging = []
    lifecycle_rule = [
      {
        id                                     = "default"
        abort_incomplete_multipart_upload_days = 7
        enabled                                = true
        prefix                                 = null
        expiration = [
          {
            # TODO: need to change days. default 3years.
            days                         = 1095
            expired_object_delete_marker = false
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
    server_side_encryption_configuration = [
      {
        rule = [
          {
            apply_server_side_encryption_by_default = [
              {
                sse_algorithm     = "AES256"
                kms_master_key_id = null
              }
            ]
          }
        ]
      }
    ]
  }
}
#--------------------------------------------------------------
# Security:AWS Config
#--------------------------------------------------------------
security_config = {
  aws_config_configuration_recorder = {
    name = "aws-config-configuration-recorder"
    recording_group = [
      {
        all_supported                 = true
        include_global_resource_types = true
      }
    ]
  }
  aws_iam_role = {
    description = null
    name        = "security-config-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = null
    name        = "security-config-policy"
    path        = "/"
  }
  aws_s3_bucket = {
    # Random suffix is automatically added to the bucket name.
    bucket        = "aws-config"
    acl           = "private"
    force_destroy = true
    versioning = [
      {
        enabled = true
      }
    ]
    logging = []
    lifecycle_rule = [
      {
        id                                     = "default"
        abort_incomplete_multipart_upload_days = 7
        enabled                                = true
        prefix                                 = null
        expiration = [
          {
            # TODO: need to change days. default 3years.
            days                         = 1095
            expired_object_delete_marker = false
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
    replication_configuration = []
    server_side_encryption_configuration = [
      {
        rule = [
          {
            apply_server_side_encryption_by_default = [
              {
                sse_algorithm     = "AES256"
                kms_master_key_id = null
              }
            ]
          }
        ]
      }
    ]
    object_lock_configuration = []
  }
  aws_config_delivery_channel = {
    name          = "aws-config-delivery-channel"
    sns_topic_arn = null
    snapshot_delivery_properties = [
      {
        delivery_frequency = "Three_Hours"
      }
    ]
  }
  aws_config_configuration_recorder_status = {
    is_enabled = true
  }
}
#--------------------------------------------------------------
# Security:SecurityHub
#--------------------------------------------------------------
security_securityhub = {
  aws_securityhub_member = {
    securityhub_member = {
    }
  }
  aws_securityhub_product_subscription = {
    product_subscription = {
    }
  }
}
#--------------------------------------------------------------
# Security:GuardDuty
#--------------------------------------------------------------
security_guardduty = {
  aws_guardduty_detector = {
    enable                       = true
    finding_publishing_frequency = "FIFTEEN_MINUTES"
  }
  aws_guardduty_member = [
  ]
  aws_cloudwatch_log_group_lambda = {
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_cloudwatch_event_rule = {
    name        = "security-guardduty-cloudwatch-event-rule"
    description = "This cloudwatch event used for GuardDuty."
  }
  aws_lambda_function = {
    environment = {
      # need to change REGION.
      REGION = "ap-northeast-1"
      # TODO: need to change SERVICE.
      # SERVICE is project name or job name or product name.
      SERVICE = "test"
      # TODO: need to change ENV.
      ENV = "dev"
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.
      SLACK_OAUTH_ACCESS_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "xxxxxxxxxx"
      LOGGER_FORMATTER = "json"
      LOGGER_OUT       = "stdout"
      LOGGER_LEVEL     = "warn"
    }
  }
}

#--------------------------------------------------------------
# Security:Access Analyzer
#--------------------------------------------------------------
security_access_analyzer = {
  aws_accessanalyzer_analyzer = {
    analyzer_name = "aws-access-analyzer"
    type          = "ACCOUNT"
  }
}

#--------------------------------------------------------------
# Security:CloudTrail
#--------------------------------------------------------------
security_cloudtrail = {
  aws_kms_key = {
    cloudtrail = {
      description         = "This key used for CloudTrail."
      is_enabled          = true
      enable_key_rotation = true
      alias_name          = "cloudtrail"
    }
    sns = {
      description         = "This key used for SNS."
      is_enabled          = true
      enable_key_rotation = true
      alias_name          = "sns-cloudtrail"
    }
  }
  aws_iam_role = {
    description = null
    name        = "security-cloudtrail-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = null
    name        = "security-cloudtrail-policy"
    path        = "/"
  }
  aws_cloudwatch_log_group = {
    name              = "aws-cloudtrail-logs"
    retention_in_days = 30
  }
  aws_cloudwatch_log_metric_filter = [
    {
      name    = "aws-cloudtrail-logs-terminate"
      pattern = <<PATTERN
{ $.eventName = "Terminate*" }
PATTERN
      metric_transformation = [
        {
          name      = "aws-cloudtrail-logs-terminate"
          namespace = "CloudTrail"
          value     = "1"
        }
      ]
    },
  ]
  aws_cloudwatch_metric_alarm = [
    {
      alarm_name          = "aws-cloudtrail-logs-terminate"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      period              = 300
      statistic           = "Sum"
      threshold           = 1
      threshold_metric_id = null
      actions_enabled     = true
      alarm_description   = "Alert Security Notification"
      datapoints_to_alarm = null
      dimensions          = null
      #  insufficient_data_actions             = null
      #  ok_actions                            = null
      #  unit                                  = null
      #  extended_statistic                    = null
      treat_missing_data = "notBreaching"
      #  evaluate_low_sample_count_percentiles = null
      #  metric_query                           = null
    },
  ]
  aws_s3_bucket = {
    bucket        = "aws-cloudtrail"
    acl           = null
    force_destroy = true
    versioning = [
      {
        enabled = true
      }
    ]
    #    logging               = []
    lifecycle_rule = [
      {
        id                                     = "default"
        abort_incomplete_multipart_upload_days = 7
        enabled                                = true
        prefix                                 = null
        expiration = [
          {
            # TODO: need to change days. default 3years.
            days                         = 1095
            expired_object_delete_marker = false
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
    replication_configuration = []
    server_side_encryption_configuration = [
      {
        rule = [
          {
            apply_server_side_encryption_by_default = [
              {
                sse_algorithm     = "AES256"
                kms_master_key_id = null
              }
            ]
          }
        ]
      }
    ]
    object_lock_configuration = []
  }
  aws_cloudwatch_log_group_lambda = {
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
      # need to change REGION.
      REGION = "ap-northeast-1"
      # TODO: need to change SERVICE.
      # SERVICE is project name or job name or product name.
      SERVICE = "test"
      # TODO: need to change ENV.
      ENV = "dev"
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.
      SLACK_OAUTH_ACCESS_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "xxxxxxxxxx"
      LOGGER_FORMATTER = "json"
      LOGGER_OUT       = "stdout"
      LOGGER_LEVEL     = "warn"
    }
  }
  aws_sns_topic = {
    name                                     = "aws-cloudtrail-logs"
    name_prefix                              = null
    display_name                             = null
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
  aws_sns_topic_subscription = {
    protocol                        = "lambda"
    endpoint_auto_confirms          = false
    confirmation_timeout_in_minutes = null
    raw_message_delivery            = null
    filter_policy                   = null
    delivery_policy                 = null
    redrive_policy                  = null
  }
  aws_cloudtrail = {
    name                          = "management-events"
    enable_logging                = true
    include_global_service_events = true
    is_multi_region_trail         = true
    is_organization_trail         = false
    enable_log_file_validation    = true
    event_selector                = []
    insight_selector = [
      {
        insight_type = "ApiCallRateInsight"
      }
    ]
  }
}
#--------------------------------------------------------------
# Application Log
#--------------------------------------------------------------
application_log = {
  aws_kms_key = {
    description         = "This key used for SNS."
    is_enabled          = true
    enable_key_rotation = true
    alias_name          = "sns-application"
  }
  aws_sns_topic = {
    name                                     = "application-logs"
    name_prefix                              = null
    display_name                             = null
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
  aws_sns_topic_subscription = {
    protocol                        = "lambda"
    endpoint_auto_confirms          = false
    confirmation_timeout_in_minutes = null
    raw_message_delivery            = null
    filter_policy                   = null
    delivery_policy                 = null
    redrive_policy                  = null
  }
  #--------------------------------------------------------------
  # Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
  #--------------------------------------------------------------
  aws_kinesis_firehose_delivery_stream = {
    buffer_size        = 5
    buffer_interval    = 60
    prefix             = "Application/"
    compression_format = "GZIP"
    cloudwatch_logging_options = [
      {
        enabled = false
      }
    ]
  }
  aws_iam_role_kinesis_firehose = {
    description = null
    name        = "application-kinesis-firehose-role"
    path        = "/"
  }
  aws_iam_policy_kinesis_firehose = {
    description = null
    name        = "application-kinesis-firehose-policy"
    path        = "/"
  }

  # TODO: need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  log_group_name = [
    # example)
    #    "/aws/lambda/base-cloudwatch-alert-application-log",
  ]

  aws_cloudwatch_log_metric_filter = {
    name = "application-logs-error"
    # TODO: need to change pattern for application log.
    pattern = <<PATTERN
{ $.level = "ERROR*" }
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
    period              = 300
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Alert log notification."
    datapoints_to_alarm = null
    dimensions          = null
    #  insufficient_data_actions             = null
    #  ok_actions                            = null
    #  unit                                  = null
    #  extended_statistic                    = null
    treat_missing_data = "notBreaching"
    #  evaluate_low_sample_count_percentiles = null
    #  metric_query                           = null
  }
  aws_iam_role_cloudwatch_logs = {
    description = null
    name        = "application-cloudwatch-logs-kinesis-firehose-role"
    path        = "/"
  }
  aws_iam_policy_cloudwatch_logs = {
    description = null
    name        = "application-cloudwatch-logs-kinesis-firehose-policy"
    path        = "/"
  }
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
      # need to change REGION.
      REGION = "ap-northeast-1"
      # TODO: need to change SERVICE.
      # SERVICE is project name or job name or product name.
      SERVICE = "test"
      # TODO: need to change ENV.
      ENV = "dev"
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.
      SLACK_OAUTH_ACCESS_TOKEN = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "xxxxxxxxxx"
      LOGGER_FORMATTER = "json"
      LOGGER_OUT       = "stdout"
      LOGGER_LEVEL     = "warn"
    }
  }
}
