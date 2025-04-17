#--------------------------------------------------------------
# Default Tags for Resources
# A tag that is set globally for the resources used.
#--------------------------------------------------------------
# TODO: need to change tags.
tags = {
  # TODO: need to change env.
  env = "example"
  # TODO: need to change service.
  # service is project name or job name or product name.
  service = "base"
  # Map Program
  # map-migrated = "xxxxxxxxxxxxx"
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
# CloudWatch Logs retention in days
#--------------------------------------------------------------
# TODO: need to change CloudWatch Logs retention in days.
cloudwatch_log_group_retention_in_days = 14
#--------------------------------------------------------------
# OpenID Connect for AWS and GitHub Actions
# Terraform module to configure GitHub Actions as an IAM OIDC identity provider in AWS.
# The target ARN is output(oidc_github_iam_role_arn) for the target ARN.
# ex) oidc_github_iam_role_arn = "arn:aws:iam::{aws_account_id}:role/{iam_role_name}"
#--------------------------------------------------------------
oidc_github = {
  # TODO: need to set is_enabled for settings of IAM OIDC for GitHub Actions.
  is_enabled = true
  # TODO: Flag to enable/disable the attachment of the AdministratorAccess policy.
  attach_admin_policy = true
  # TODO: Flag to enable/disable the attachment of the ReadOnly policy.
  attach_read_only_policy = false
  # TODO: Flag to enable/disable the creation of the GitHub OIDC provider.
  create_oidc_provider = true
  # TODO: Set the org/repo of the GitHub repository to github_repositories.
  github_repositories = [
    # "your-repository/repository-name",
  ]
  iam_role_name = "oidc-github-role"
  iam_role_path = "/"
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
      enable_flow_log                                 = true
      create_flow_log_cloudwatch_log_group            = true
      create_flow_log_cloudwatch_iam_role             = true
      flow_log_cloudwatch_log_group_retention_in_days = 3
      flow_log_file_format                            = "plain-text"
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
}
#--------------------------------------------------------------
# Organizations policy
# TODO: WIP
#--------------------------------------------------------------
organizations_policy = {
  policy = {
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowSpecificRegions"
        Effect = "Deny"
        NotAction = [
          "a4b:*",
          "acm:*",
          "aws-marketplace-management:*",
          "aws-marketplace:*",
          "batch:*",
          "budgets:*",
          "ce:*",
          "chime:*",
          "cloudfront:*",
          "config:*",
          "cognito-identity:*",
          "cognito-idp:*",
          "cognito-sync:*",
          "cur:*",
          "directconnect:*",
          "ec2:*",
          "ecs:*",
          "fms:*",
          "globalaccelerator:*",
          "glue:*",
          "health:*",
          "iam:*",
          "importexport:*",
          "kinesis:*",
          "kms:*",
          "lambda:*",
          "lightsail:*",
          "logs:*",
          "organizations:*",
          "pricing:*",
          "rds-data:*",
          "route53:*",
          "route53domains:*",
          "s3:*",
          "secretsmanager:*",
          "ses:*",
          "shield:*",
          "sns:*",
          "sqs:*",
          "states:*",
          "sts:*",
          "support:*",
          "trustedadvisor:*",
          "waf-regional:*",
          "waf:*",
          "wafv2:*",
          "wellarchitected:*",
          "xray:*",
        ],
        Resource = "*",
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = [
              "ap-northeast-1",
              "us-east-1",
            ]
          }
        }
      }
    ]
  }
}
#--------------------------------------------------------------
# Security:CloudTrail
#--------------------------------------------------------------
security_cloudtrail = {
  # TODO: need to set is_enabled for settings of CloudTrail.
  is_enabled = false
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
  aws_cloudwatch_log = {
    cloudtrail_logs_terminate = {
      aws_cloudwatch_log_metric_filter = {
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
      }
      aws_cloudwatch_metric_alarm = {
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
      }
    }
  }
  aws_cloudwatch_log_group_lambda = {
    kms_key_id = null
  }
  aws_lambda_function = {
    environment = {
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.(bot token xoxb-xxxxxx....)
      SLACK_OAUTH_ACCESS_TOKEN = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "xxxxxxxxxxx"
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
}
