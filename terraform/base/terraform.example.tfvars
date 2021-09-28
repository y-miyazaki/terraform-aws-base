#--------------------------------------------------------------
# Basically, it is already set so that the setting is completed only by changing tfvars.
# All parameters that need to be changed for each environment are described in TODO comments.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Deploy IAM user
#--------------------------------------------------------------
# TODO: need to change deploy IAM user.
deploy_user = "terraform"
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
  # TODO: need to set is_enabled for settings of budgets.
  is_enabled = true
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
          # "youremail@yourtest.test.hogehoge.com"
        ]
        subscriber_sns_topic_arns = null
      }
    ]
  }
  aws_cloudwatch_event_rule = {
    name = "budgets-cloudwatch-event-rule"
    # TODO: need to change schedule_expression.
    # schedule_expression when Budgets will be notified.
    schedule_expression = "cron(0 9 * * ? *)"
    description         = "This cloudwatch event used for Budgets."
    is_enabled          = true
  }
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
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
      MONTHLY_TARGET_COST = 100
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
# Compute Optimizer
# AWS Compute Optimizer recommends optimal AWS resources for your workloads to reduce
# costs and improve performance by using machine learning to analyze historical utilization metrics.
# Over-provisioning resources can lead to unnecessary infrastructure cost, and under-provisioning resources
# can lead to poor application performance. Compute Optimizer helps you choose optimal configurations
# for three types of AWS resources: Amazon EC2 instances, Amazon EBS volumes, and AWS Lambda functions,
# based on your utilization data.
#--------------------------------------------------------------
compute_optimizer = {
  # TODO: need to set is_enabled for settings of Compute Optimizer.
  is_enabled = true
}
#--------------------------------------------------------------
# Health
#--------------------------------------------------------------
health = {
  # TODO: need to set is_enabled for settings of AWS Health.
  is_enabled = true
  aws_cloudwatch_event_rule = {
    name                = "health-cloudwatch-event-rule"
    schedule_expression = "cron(0 0 * * ? *)"
    description         = "This cloudwatch event used for Health."
    is_enabled          = true
  }
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
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
  # TODO: need to set is_enabled for settings of Trusted Advisor.
  // If you are not in a business or enterprise plan with a support plan, set is_enable to false as notifications will fail. If not, set it to true.
  is_enabled = false
  aws_cloudwatch_event_rule = {
    name                = "trusted-advisor-cloudwatch-event-rule"
    schedule_expression = "cron(0 0 * * ? *)"
    description         = "This cloudwatch event used for Trusted Advisor."
    is_enabled          = true
  }
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
      LANGUAGE = "en"
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
  # TODO: need to set is_enabled for settings of IAM.
  is_enabled = true
  # TODO: need to change IAM User.
  user = [
    "test1",
    "test2",
    "test3",
  ]
  #--------------------------------------------------------------
  # TODO: need to change IAM Group.
  # Please specify the user with the same name that has been set in users.
  #--------------------------------------------------------------
  group = {
    # TODO: need to change IAM Group name.
    # This name will be used as the group name.
    administrator = {
      # TODO: need to set is_enabled_mfa.
      # If true, force MFA settings and login.
      is_enabled_mfa = true
      # TODO: need to set users.
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
    # TODO: need to change IAM Group name.
    # This name will be used as the group name.
    developer = {
      # TODO: need to set is_enabled_mfa.
      # If true, force MFA settings and login.
      is_enabled_mfa = true
      # TODO: need to set users.
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
            sid    = "AllowHealth"
            effect = "Allow"
            actions = [
              "health:DescribeEventAggregates",
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
      policy = [
        {
          policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
        },
      ]
    }
    # TODO: need to change IAM Group name.
    # This name will be used as the group name.
    operator = {
      # TODO: need to set is_enabled_mfa.
      # If true, force MFA settings and login.
      is_enabled_mfa = true
      # TODO: need to set users.
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
          {
            sid    = "AllowHealth"
            effect = "Allow"
            actions = [
              "health:DescribeEventAggregates",
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
  #--------------------------------------------------------------
  # Variable settings for SwitchRole.
  # This role is used when switching from another AWS environment and not registering an IAM user.
  # https://docs.aws.amazon.com/IAM/latest/UserGuide/id_roles_use_switch-role-console.html
  #--------------------------------------------------------------
  switch_role = {
    # These are the settings for the original AWS account that will use SwitchRole.
    from = {
      # TODO: need to set is_enabled for switch role(from).
      is_enabled = false
      group = {
        # TODO: need to change IAM Group name.
        # An IAM policy for the SwitchRole will be attached to the group with the specified name.
        administrator = {
          aws_iam_policy = {
            name        = "iam-switch-from-administrator-policy"
            path        = "/"
            description = ""
            statement = [
              {
                sid    = "AllowSwitchFromAccountAdministrator"
                effect = "Allow"
                actions = [
                  "sts:AssumeRole",
                ]
                resources = [
                  # TODO: need to change AWS accound ID(99999999999) and role name
                  # Specify the original AWS account ID that will use the IAM Switch role.
                  "arn:aws:iam::99999999999:role/base-iam-switch-to-administrator-role",
                ]
              },
            ]
          }
        }
        # TODO: need to change IAM Group name.
        # An IAM policy for the SwitchRole will be attached to the group with the specified name.
        developer = {
          aws_iam_policy = {
            name        = "iam-switch-from-developer-policy"
            path        = "/"
            description = ""
            statement = [
              {
                sid    = "AllowSwitchFromAccountDeveloper"
                effect = "Allow"
                actions = [
                  "sts:AssumeRole",
                ]
                resources = [
                  # TODO: need to change AWS accound ID(99999999999) and role name
                  # Specify the original AWS account ID that will use the IAM Switch role.
                  "arn:aws:iam::99999999999:role/base-iam-switch-to-developer-role",
                ]
              },
            ]
          }
        }
        # TODO: need to change IAM Group name.
        # An IAM policy for the SwitchRole will be attached to the group with the specified name.
        operator = {
          aws_iam_policy = {
            name        = "iam-switch-from-operator-policy"
            path        = "/"
            description = ""
            statement = [
              {
                sid    = "AllowSwitchFromAccountOperator"
                effect = "Allow"
                actions = [
                  "sts:AssumeRole",
                ]
                resources = [
                  # TODO: need to change AWS accound ID(99999999999) and role name
                  # Specify the original AWS account ID that will use the IAM Switch role.
                  "arn:aws:iam::99999999999:role/base-iam-switch-to-operator-role",
                ]
              },
            ]
          }
        }
      }
    }
    # These are the settings for the AWS account to which the SwitchRole is to be used.
    to = {
      # TODO: need to set is_enabled for switch role(to).
      is_enabled = false
      role = {
        # TODO: need to change IAM switch role name.
        # Part of this name will be used as the switch role name.
        administrator = {
          # TODO: need to change IAM switch role.
          aws_iam_role = {
            name        = "iam-switch-to-administrator-role"
            path        = "/"
            description = ""
            # TODO: need to change AWS accound ID(99999999999)
            # Specify the original AWS account ID that will use the IAM Switch role.
            account_id    = "99999999999"
            assume_policy = null
          }
          # TODO: need to set base policy.
          # Please specify the base policy to provide.
          # default null.
          # You need to check this document.
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          aws_iam_policy = null
          # TODO: need to add policy arn. group policy limit is 10.
          # You need to check this document.
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          policy = [
            {
              policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
            }
          ]
        }
        # TODO: need to change IAM switch role name.
        # Part of this name will be used as the switch role name.
        developer = {
          # TODO: need to change IAM switch role.
          aws_iam_role = {
            name        = "iam-switch-to-developer-role"
            path        = "/"
            description = ""
            # TODO: need to change AWS accound ID(99999999999)
            # Specify the original AWS account ID that will use the IAM Switch role.
            account_id    = "99999999999"
            assume_policy = null
          }
          # TODO: need to set base policy.
          # Please specify the base policy to provide.
          # default null.
          # You need to check this document.
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          aws_iam_policy = {
            name        = "iam-switch-to-developer-policy"
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
                sid    = "AllowHealth"
                effect = "Allow"
                actions = [
                  "health:DescribeEventAggregates",
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
          policy = [
            {
              policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
            },
          ]
        }
        # TODO: need to change IAM switch role name.
        # Part of this name will be used as the switch role name.
        operator = {
          # TODO: need to change IAM switch role.
          aws_iam_role = {
            name        = "iam-switch-to-operator-role"
            path        = "/"
            description = ""
            # TODO: need to change AWS accound ID(99999999999)
            # Specify the original AWS account ID that will use the IAM Switch role.
            account_id    = "99999999999"
            assume_policy = null
          }
          # TODO: need to set base policy.
          # Please specify the base policy to provide.
          # default null.
          # You need to check this document.
          # https://aws.amazon.com/jp/premiumsupport/knowledge-center/iam-increase-policy-size/
          aws_iam_policy = {
            name        = "iam-switch-to-operator-policy"
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
              {
                sid    = "AllowHealth"
                effect = "Allow"
                actions = [
                  "health:DescribeEventAggregates",
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
  }
}
#--------------------------------------------------------------
# Common:Lambda
#--------------------------------------------------------------
common_lambda = {
  aws_iam_role = {
    description = ""
    name        = "security-lambda-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = ""
    name        = "security-lambda-policy"
    path        = "/"
  }
}
#--------------------------------------------------------------
# Common:Logging Bucket
#--------------------------------------------------------------
common_logging = {
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
# Security:Access Analyzer
#--------------------------------------------------------------
security_access_analyzer = {
  # TODO: need to set is_enabled for settings of Access Analyzer.
  is_enabled = true
  aws_accessanalyzer_analyzer = {
    analyzer_name = "aws-access-analyzer"
    type          = "ACCOUNT"
  }
}
#--------------------------------------------------------------
# Security:CloudTrail
#--------------------------------------------------------------
security_cloudtrail = {
  # TODO: need to set is_enabled for settings of CloudTrail.
  is_enabled = true
  # TODO: need to set is_s3_enabled for settings of New S3 Bucket.
  is_s3_enabled = false
  aws_kms_key = {
    cloudtrail = {
      description             = "This key used for CloudTrail."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "cloudtrail"
    }
    sns = {
      description             = "This key used for SNS."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "sns-cloudtrail"
    }
  }
  aws_iam_role = {
    description = ""
    name        = "security-cloudtrail-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = ""
    name        = "security-cloudtrail-policy"
    path        = "/"
  }
  aws_cloudwatch_log_group = {
    name = "aws-cloudtrail-logs"
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 30
  }
  aws_cloudwatch_log_metric_filter = [
    {
      name    = "cloudtrail-logs-terminate"
      pattern = <<PATTERN
{ $.eventName = "Terminate*" }
PATTERN
      metric_transformation = [
        {
          name      = "cloudtrail-logs-terminate"
          namespace = "CloudTrail"
          value     = "1"
        }
      ]
    },
  ]
  aws_cloudwatch_metric_alarm = [
    {
      alarm_name          = "cloudtrail-logs-terminate"
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      period              = 300
      statistic           = "Sum"
      threshold           = 1
      threshold_metric_id = null
      actions_enabled     = true
      alarm_description   = "Alert Security Notification"
      datapoints_to_alarm = 1
      dimensions          = null
      treat_missing_data  = "notBreaching"
    },
  ]
  #   aws_s3_bucket = {
  #     bucket        = "aws-cloudtrail"
  #     force_destroy = true
  #     versioning = [
  #       {
  #         enabled = true
  #       }
  #     ]
  #     #    logging               = []
  #     lifecycle_rule = [
  #       {
  #         id                                     = "default"
  #         abort_incomplete_multipart_upload_days = 7
  #         enabled                                = true
  #         prefix                                 = null
  #         expiration = [
  #           {
  #             # TODO: need to change days. default 3years.
  #             days                         = 1095
  #             expired_object_delete_marker = false
  #           }
  #         ]
  #         transition = [
  #           {
  #             days          = 30
  #             storage_class = "ONEZONE_IA"
  #           }
  #         ]
  #         noncurrent_version_expiration = [
  #           {
  #             days = 30
  #           }
  #         ]
  #       }
  #     ]
  #     replication_configuration = []
  #     server_side_encryption_configuration = [
  #       {
  #         rule = [
  #           {
  #             apply_server_side_encryption_by_default = [
  #               {
  #                 sse_algorithm     = "AES256"
  #                 kms_master_key_id = null
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     ]
  #     object_lock_configuration = []
  #   }
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
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
    name                          = "cloudtrail"
    enable_logging                = true
    include_global_service_events = true
    is_multi_region_trail         = true
    is_organization_trail         = false
    enable_log_file_validation    = true
    event_selector = [
      {
        read_write_type           = "All"
        include_management_events = true
        data_resource = [
          {
            type   = "AWS::S3::Object"
            values = ["arn:aws:s3:::"]
          }
        ]
      }
    ]
    insight_selector = [
      {
        insight_type = "ApiCallRateInsight"
      }
    ]
  }
}
#--------------------------------------------------------------
# Security:AWS Config
#--------------------------------------------------------------
security_config = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = true
  # TODO: need to set is_s3_enabled for settings of New S3 Bucket.
  is_s3_enabled = false
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
    description = "Role for AWS Config."
    name        = "security-config-role"
    path        = "/"
  }
  #   aws_s3_bucket = {
  #     # Random suffix is automatically added to the bucket name.
  #     bucket        = "aws-config"
  #     force_destroy = true
  #     versioning = [
  #       {
  #         enabled = true
  #       }
  #     ]
  #     logging = []
  #     lifecycle_rule = [
  #       {
  #         id                                     = "default"
  #         abort_incomplete_multipart_upload_days = 7
  #         enabled                                = true
  #         prefix                                 = null
  #         expiration = [
  #           {
  #             # TODO: need to change days. default 3years.
  #             days                         = 1095
  #             expired_object_delete_marker = false
  #           }
  #         ]
  #         transition = [
  #           {
  #             days          = 30
  #             storage_class = "ONEZONE_IA"
  #           }
  #         ]
  #         noncurrent_version_expiration = [
  #           {
  #             days = 30
  #           }
  #         ]
  #       }
  #     ]
  #     replication_configuration = []
  #     server_side_encryption_configuration = [
  #       {
  #         rule = [
  #           {
  #             apply_server_side_encryption_by_default = [
  #               {
  #                 sse_algorithm     = "AES256"
  #                 kms_master_key_id = null
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     ]
  #     object_lock_configuration = []
  #   }
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
  aws_cloudwatch_event_rule = {
    name        = "security-config-cloudwatch-event-rule"
    description = "This cloudwatch event used for Config."
  }
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
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
# Security:AWS Config(us-east-1(CloudFront))
#--------------------------------------------------------------
security_config_us_east_1 = {
  # TODO: need to set is_enabled for settings of AWS Config.
  is_enabled = false
  # TODO: need to set is_s3_enabled for settings of New S3 Bucket.
  is_s3_enabled = false
  aws_config_configuration_recorder = {
    name = "aws-config-us-east-1-configuration-recorder"
    recording_group = [
      {
        all_supported                 = true
        include_global_resource_types = true
      }
    ]
  }
  aws_iam_role = {
    description = "Role for AWS Config."
    name        = "security-config-us-east-1-role"
    path        = "/"
  }
  #   aws_s3_bucket = {
  #     # Random suffix is automatically added to the bucket name.
  #     bucket        = "aws-config"
  #     force_destroy = true
  #     versioning = [
  #       {
  #         enabled = true
  #       }
  #     ]
  #     logging = []
  #     lifecycle_rule = [
  #       {
  #         id                                     = "default"
  #         abort_incomplete_multipart_upload_days = 7
  #         enabled                                = true
  #         prefix                                 = null
  #         expiration = [
  #           {
  #             # TODO: need to change days. default 3years.
  #             days                         = 1095
  #             expired_object_delete_marker = false
  #           }
  #         ]
  #         transition = [
  #           {
  #             days          = 30
  #             storage_class = "ONEZONE_IA"
  #           }
  #         ]
  #         noncurrent_version_expiration = [
  #           {
  #             days = 30
  #           }
  #         ]
  #       }
  #     ]
  #     replication_configuration = []
  #     server_side_encryption_configuration = [
  #       {
  #         rule = [
  #           {
  #             apply_server_side_encryption_by_default = [
  #               {
  #                 sse_algorithm     = "AES256"
  #                 kms_master_key_id = null
  #               }
  #             ]
  #           }
  #         ]
  #       }
  #     ]
  #     object_lock_configuration = []
  #   }
  aws_config_delivery_channel = {
    name          = "aws-config-us-east-1-delivery-channel"
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
  aws_cloudwatch_event_rule = {
    name        = "security-config-us-east-1-cloudwatch-event-rule"
    description = "This cloudwatch event used for Config."
  }
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
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
# Security:Default VPC
#--------------------------------------------------------------
security_default_vpc = {
  # TODO: need to set is_enabled for settings of default VPC security.
  is_enabled           = true
  is_enabled_flow_logs = true
  # A boolean flag to enable/disable VPC Endpoint for [EC2.10]. Defaults true."
  # https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-standards-fsbp-controls.html#ec2-10-remediation
  # If true, the EC2-10 indication will be resolved.
  # If false, Security Hub will point out Severity: Medium on EC2-10.
  # This flag will set the VPC Endpoint for the default VPC in each region.
  # Normally, it costs more than 10 USD a month for the default VPC that you do not use, so the initial value is set to false.
  is_enabled_vpc_end_point = false
  aws_cloudwatch_log_group = {
    name_prefix = "flow-log-"
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 30
  }
  aws_iam_role = {
    description = ""
    name        = "security-vpc-flow-log-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = ""
    name        = "security-vpc-flow-log-policy"
    path        = "/"
  }
}
#--------------------------------------------------------------
# Security:EBS
#--------------------------------------------------------------
security_ebs = {
  # TODO: need to set is_enabled for settings of EBS.
  is_enabled = true
}
#--------------------------------------------------------------
# Security:GuardDuty
#--------------------------------------------------------------
security_guardduty = {
  # TODO: need to set is_enabled for settings of GuardDuty.
  is_enabled = true
  aws_guardduty_detector = {
    enable                       = true
    finding_publishing_frequency = "FIFTEEN_MINUTES"
  }
  aws_guardduty_member = [
  ]
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 7
    kms_key_id        = null
  }
  aws_cloudwatch_event_rule = {
    name        = "security-guardduty-cloudwatch-event-rule"
    description = "This cloudwatch event used for GuardDuty."
  }
  aws_lambda_function = {
    environment = {
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
# Security:IAM
#--------------------------------------------------------------
security_iam = {
  # TODO: need to set is_enabled for settings of IAM security.
  is_enabled = true
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
    "arn:aws:iam::99999999999:root"
  ]
  aws_iam_role = {
    description = ""
    name        = "security-support-role"
    path        = "/"
  }
}
#--------------------------------------------------------------
# Security:S3
#--------------------------------------------------------------
security_s3 = {
  # TODO: need to set is_enabled for settings of S3 security.
  is_enabled = true
  # Manages S3 account-level Public Access Block configuration. For more information about these settings, see the AWS S3 Block Public Access documentation.
  aws_s3_account_public_access_block = {
    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
  }
}
#--------------------------------------------------------------
# Security:SecurityHub
#--------------------------------------------------------------
security_securityhub = {
  # TODO: need to set is_enabled for settings of SecurityHub.
  is_enabled = true
  aws_securityhub_member = {
  }
  # TODO: need to change product_subscription.
  aws_securityhub_product_subscription = {
  }
  aws_securityhub_action_target = {
    name        = "Send notification"
    identifier  = "SendToEvent"
    description = "This is custom action sends selected findings to event"
  }
}
