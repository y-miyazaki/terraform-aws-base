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
# Common:Log Bucket
#--------------------------------------------------------------
common_log = {
  #--------------------------------------------------------------
  # S3 for application log
  # https://registry.terraform.io/modules/terraform-aws-modules/s3-bucket/aws/latest
  #--------------------------------------------------------------
  s3_application_log = {
    bucket                                = "aws-log-application"
    create_bucket                         = true
    acl                                   = "log-delivery-write"
    attach_deny_insecure_transport_policy = true
    attach_elb_log_delivery_policy        = false
    attach_lb_log_delivery_policy         = false
    attach_policy                         = false
    attach_public_policy                  = true
    attach_require_latest_tls_policy      = true
    block_public_acls                     = true
    block_public_policy                   = true
    force_destroy                         = true
    ignore_public_acls                    = true
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
    # TODO: need to change for logging.
    # example)
    #    logging = {
    #      target_bucket = "{your bucket}"
    #      target_prefix = "AccessLogs/{your account id}/{your bucket}/"
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
    exsits = {
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
      flow_log_cloudwatch_log_group_retention_in_days = 14
      flow_log_file_format                            = "plain-text"
    }
  }
  metric = {
    aws_kms_key = {
      description             = "This key used for SNS(for Metrics)."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "sns-lambda-metric"
    }
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
        # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.(bot token xoxb-xxxxxx....)
        SLACK_OAUTH_ACCESS_TOKEN = "xxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
        # TODO: need to change SLACK_CHANNEL_ID.
        SLACK_CHANNEL_ID = "XXXXXXXXXXXXXX"
        LOGGER_FORMATTER = "json"
        LOGGER_OUT       = "stdout"
        LOGGER_LEVEL     = "warn"
      }
    }
  }
  log = {
    aws_kms_key = {
      description             = "This key used for SNS(for Log)."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "sns-lambda-log"
    }
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
        # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.(bot token xoxb-xxxxxx....)
        SLACK_OAUTH_ACCESS_TOKEN = "xxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
        # TODO: need to change SLACK_CHANNEL_ID.
        SLACK_CHANNEL_ID = "XXXXXXXXXXXXXX"
        LOGGER_FORMATTER = "json"
        LOGGER_OUT       = "stdout"
        LOGGER_LEVEL     = "warn"
      }
    }
  }
  ses = {
    aws_kms_key = {
      description             = "This key used for SNS(for SES)."
      deletion_window_in_days = 7
      is_enabled              = true
      enable_key_rotation     = true
      alias_name              = "sns-lambda-ses"
    }
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
        # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.(bot token xoxb-xxxxxx....)
        SLACK_OAUTH_ACCESS_TOKEN = "xxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
        # TODO: need to change SLACK_CHANNEL_ID.
        SLACK_CHANNEL_ID            = "XXXXXXXXXXXXXX"
        LOGGER_FORMATTER            = "json"
        LOGGER_OUT                  = "stdout"
        LOGGER_LEVEL                = "warn"
        LOG_GROUP_NAME              = "/aws/ses/log"
        LOG_GROUP_RETENTION_IN_DAYS = 14
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
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 14
    kms_key_id        = null
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
  #--------------------------------------------------------------
  # Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
  #--------------------------------------------------------------
  aws_kinesis_firehose_delivery_stream = {
    buffer_size        = 5
    buffer_interval    = 60
    prefix             = "Logs/"
    compression_format = "GZIP"
    cloudwatch_logging_options = [
      {
        enabled = false
      }
    ]
  }
  # TODO: need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/lambda | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  # ex3) aws logs describe-log-groups | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []

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
  #--------------------------------------------------------------
  # Provides a Kinesis Firehose Delivery Stream resource. Amazon Kinesis Firehose is a fully managed, elastic service to easily deliver real-time data streams to destinations such as Amazon S3 and Amazon Redshift.
  #--------------------------------------------------------------
  aws_kinesis_firehose_delivery_stream = {
    buffer_size        = 5
    buffer_interval    = 60
    prefix             = "Logs/"
    compression_format = "GZIP"
    cloudwatch_logging_options = [
      {
        enabled = false
      }
    ]
  }
  # TODO: need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --region us-east-1 --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --region us-east-1 --log-group-name-prefix /aws/lambda | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  # ex3) aws logs describe-log-groups --region us-east-1 | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []

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
  # TODO: need to add log_group_name for application.
  #       check log group name for application.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/lambda | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []
  aws_cloudwatch_log_metric_filter = {
    name = "application-logs-error"
    # TODO: need to change pattern for application log.
    # ex1) ?error ?Error ?ERROR ?fatal ?Fatal ?FATAL ?exception ?Exception ?EXCEPTION
    # ex2) ?"\"level\":\"error\""  ?"\"level\":\"fatal\""  ?"\"level\":\"panic\""
    pattern = <<PATTERN
?"\"level\":\"error\""  ?"\"level\":\"fatal\""  ?"\"level\":\"panic\""
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
  # TODO: need to set is_enabled for settings of postgres log.
  is_enabled = false
  # TODO: need to add log_group_name for postgres.
  #       check log group name for postgres.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []

  aws_cloudwatch_log_metric_filter = {
    name = "mysql-slowquery-logs-error"
    # TODO: need to change pattern for postgres log.
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
# Log:Postgres
# The filter function of CloudWatchLogs can be used to check specified logs
# with specified filter patterns. Those that hit the filter pattern will be
# notified by Slack via Lambda.
#
# Filter logs related to Postgres.
#--------------------------------------------------------------
metric_log_postgres = {
  # TODO: need to set is_enabled for settings of postgres log.
  is_enabled = false
  # TODO: need to add log_group_name for postgres.
  #       check log group name for postgres.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_names = []

  aws_cloudwatch_log_metric_filter = {
    name = "postgres-logs-error"
    # TODO: need to change pattern for postgres log.
    pattern = <<PATTERN
?ERROR
PATTERN
    metric_transformation = [
      {
        name      = "postgres-logs-error"
        namespace = "Postgres"
        value     = "1"
      }
    ]
  }
  aws_cloudwatch_metric_alarm = {
    alarm_name          = "postgres-logs-error"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 1
    period              = 300
    statistic           = "Sum"
    threshold           = 1
    threshold_metric_id = null
    actions_enabled     = true
    alarm_description   = "Alert Postgres log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
}

#--------------------------------------------------------------
# Metrics:ALB
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
metric_resource_alb = {
  # TODO: need to set is_enabled for Metric of ALB.
  is_enabled = false
  # TODO: need to set period for ALB.
  period = 1800
  # TODO: need to set threshold for ALB.
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
  # TODO: need to set dimensions for monitor of ALB.
  # Specify the instance of the target ALB name to be monitored by Map.
  #   ex)
  #   dimensions = [
  #     {
  #       "LoadBalancer" = "example-alb"
  #     }
  #   ]
  dimensions = []
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
    enabled_error4XX = true
    error4XX         = 1
    # (Required) 5XXerror threshold (unit=%)
    enabled_error5XX = true
    error5XX         = 1
    # (Required) Error threshold (unit=Milliseconds)
    enabled_latency = true
    latency         = 10000
  }
  # TODO: need to set dimensions for monitor of API Gateway.
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
    enabled_error_404_rate = true
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
    enabled_cache_hit_rate = true
    cache_hit_rate         = 70
    # (Required) OriginLatency threshold (unit=Milliseconds)
    enabled_origin_latency = true
    origin_latency         = 10000
  }
  # TODO: need to set dimensions for monitor of CloudFront.
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
    # (Required) CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = true
    cpu_utilization         = 80
    # (Required) MetadataNoToken threshold (unit=Count)
    enabled_metadata_no_token = true
    metadata_no_token         = 1
    # (Required) CPUCreditUsage threshold (unit=Count)
    enabled_cpu_credit_usage = true
    cpu_credit_usage         = 5
    # (Required) StatusCheckFailed threshold (unit=Count)
    enabled_status_check_failed = true
    status_check_failed         = 1
  }
  # TODO: need to set dimensions for monitor of EC2.
  # Specify the instance of the target CloudFront name to be monitored by Map.
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
    # (Required) KeyAuthorizationFailures threshold (unit=Count)
    enabled_key_authorization_failures = true
    key_authorization_failures         = 1
    # (Required) NewConnections threshold (unit=Count)
    enabled_new_connections = true
    new_connections         = 100
    # (Required) SwapUsage threshold (unit=Bytes)
    enabled_swap_usage = true
    swap_usage         = 52428800 # 50MB
  }
  # TODO: need to set dimensions for monitor of ElastiCache.
  # Specify the instance of the target ElastiCache name to be monitored by Map.
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
    # (Required) ConcurrentExecutions threshold (unit=Count)
    enabled_concurrent_executions = true
    concurrent_executions         = 500
    # (Required) Duration threshold (unit=Milliseconds)
    enabled_duration = true
    duration         = 10000
    # (Required) Errors threshold (unit=Count)
    enabled_errors = true
    errors         = 1
    # (Required) Throttles threshold (unit=Count)
    enabled_throttles = true
    throttles         = 10
  }
  # TODO: need to set dimensions for monitor of Lambda.
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
# Metrics:RDS
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
metric_resource_rds = {
  # TODO: need to set is_enabled for monitor of RDS.
  is_enabled = false
  # TODO: need to set is_aurora for monitor of RDS(Aurora).
  # If the target DB to be monitored is Aurora, set to true.
  is_aurora = true
  # TODO: need to set is_aurora for monitor of RDS(MySQL).
  # If the target DB to be monitored is MySQL, set to true.
  is_mysql = false
  # TODO: need to set is_aurora for monitor of RDS(Postgres).
  # If the target DB to be monitored is Postgres, set to true.
  is_postgres = false
  # TODO: need to set period for RDS.
  period = 300
  # TODO: need to set threshold for RDS.
  threshold = {
    # (Required) CommitRatency threshold (unit=Seconds)
    enabled_commit_latency = true
    commit_latency         = 10
    # (Required) CPUCreditBalance threshold (unit=Count)
    enabled_cpu_creadit_balance = true
    cpu_creadit_balance         = 100
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
    # (Required) FreeableMemory threshold (unit=Megabytes)
    enabled_freeable_memory = true
    freeable_memory         = 512
    # (Required) ReadLatency threshold (unit=Seconds)
    enabled_read_latency = true
    read_latency         = 10
    # (Required) WriteLatency threshold (unit=Seconds)
    enabled_write_latency = true
    write_latency         = 10
  }
  # TODO: need to set dimensions for monitor of RDS.
  # Specify the instance of the target DB to be monitored by Map.
  # check DB Cluster Identifier list command.
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
    is_enabled  = true
  }
  aws_cloudwatch_log_group_lambda = {
    # TODO: need to change retention_in_days for each services.
    retention_in_days = 14
    kms_key_id        = null
  }
  aws_lambda_function = {
    environment = {
      LANGUAGE = "en"
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.(bot token xoxb-xxxxxx....)
      SLACK_OAUTH_ACCESS_TOKEN = "xxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "XXXXXXXXXXXXXX"
      LOGGER_FORMATTER = "json"
      LOGGER_OUT       = "stdout"
      LOGGER_LEVEL     = "warn"
    }
  }
}

#--------------------------------------------------------------
# Metrics: Synthetics Canary: Heartbeat
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
metric_synthetics_canary_heartbeat = {
  # TODO: need to set is_enabled for Metric of Synthetics Canary.
  is_enabled = false
  # TODO: need to set period for Synthetics Canary.
  period = 300
  # TODO: need to set threshold for Synthetics Canary.
  threshold = {
    # (Required) SuccessPercent threshold (unit=Percent)
    enabled_success_percent = true
    success_percent         = 99
  }
  # Specify the instance of the target Synthetics Canary Name to be monitored by Map.
  dimensions = [
    {
      "CanaryName" = "base-heartbeat"
    }
  ]
  synthetics_canary = {
    aws_iam_role = {
      description = "Role for Synthetics Canaly heartbeat."
      name        = "monitor-synthetics-canary-heartbeat-role"
      path        = "/"
    }
    aws_iam_policy = {
      description = "Policy for Synthetics Canaly heartbeat."
      name        = "monitor-synthetics-canary-heartbeat-policy"
      path        = "/"
    }
    aws_synthetics_canary = {
      # Location in Amazon S3 where Synthetics stores artifacts from the test runs of this canary.
      # If not specified, the log bucket is automatically specified.
      artifact_s3_location = null
      # ARN of the IAM role to be used to run the canary. see AWS Docs for permissions needs for IAM Role.
      # If not specified, a role policy is automatically created.
      execution_role_arn = null
      # (Required) Name for this canary. Has a maximum length of 21 characters. Valid characters are lowercase alphanumeric, hyphen, or underscore.
      name = "heartbeat"
      # (Required) Runtime version to use for the canary. Versions change often so consult the Amazon CloudWatch documentation for the latest valid versions. Values include syn-python-selenium-1.0, syn-nodejs-puppeteer-3.0, syn-nodejs-2.2, syn-nodejs-2.1, syn-nodejs-2.0, and syn-1.0.
      runtime_version = "syn-nodejs-puppeteer-3.9"
      # (Required) Configuration block providing how often the canary is to run and when these test runs are to stop. Detailed below.
      schedule = [
        {
          expression = "cron(*/5 * * * ? *)"
        }
      ]
      # (Optional) Configuration block. Detailed below.
      # TODO: need to set vpc_config bypass WAF.
      #       When a request must be made from a fixed IP, such as in the case of a site with restricted access.
      vpc_config = [
        # {
        #   subnet_ids = [
        #     "subnet-xxxxxxxxxxxxxxxxx",
        #     "subnet-xxxxxxxxxxxxxxxxx",
        #     "subnet-xxxxxxxxxxxxxxxxx",
        #   ]
        #   security_group_ids = [
        #     "sg-xxxxxxxxxxxxxxxxx",
        #   ]
        # }
      ]
      # (Optional) Number of days to retain data about failed runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
      failure_retention_period = 7
      # (Optional) Configuration block for individual canary runs. Detailed below.
      run_config = [
        {
          timeout_in_seconds = 60
          memory_in_mb       = 960
          active_tracing     = false
        }
      ]
      # (Optional) Full bucket name which is used if your canary script is located in S3. The bucket must already exist. Specify the full bucket name including s3:// as the start of the bucket name. Conflicts with zip_file.
      s3_bucket = null
      # (Optional) S3 key of your script. Conflicts with zip_file.
      s3_key = null
      # (Optional) S3 version ID of your script. Conflicts with zip_file.
      s3_version = null
      # (Optional) Whether to run or stop the canary.
      start_canary = true
      # (Optional) Number of days to retain data about successful runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
      success_retention_period = 7
      # (Optional) configuration for canary artifacts, including the encryption-at-rest settings for artifacts that the canary uploads to Amazon S3. See Artifact Config.
      artifact_config = [
        {
          s3_encryption = [
            {
              encryption_mode = "SSE-S3"
            }
          ]
        }
      ]
      # TODO: Set the Heartbeat URL and list of acceptable status codes.
      # (Optional) URLS/STATUS_CODE_RANGES is an environment variable that can be specified as a delimited string to allow heart beats to be thrown to multiple URLs.
      env = {
        URLS               = "https://yahoo.co.jp/,https://google.com/"
        STATUS_CODE_RANGES = "200-299,200-299"
      }
    }
  }
}

#--------------------------------------------------------------
# Metrics: Synthetics Canary: Linkcheck
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
metric_synthetics_canary_linkcheck = {
  # TODO: need to set is_enabled for Metric of Synthetics Canary.
  is_enabled = false
  # TODO: need to set period for Synthetics Canary.
  period = 300
  # TODO: need to set threshold for Synthetics Canary.
  threshold = {
    # (Required) SuccessPercent threshold (unit=Percent)
    enabled_success_percent = true
    success_percent         = 99
  }
  # Specify the instance of the target Synthetics Canary Name to be monitored by Map.
  dimensions = [
    {
      "CanaryName" = "base-linkcheck"
    }
  ]

  synthetics_canary = {
    aws_iam_role = {
      description = "Role for Synthetics Canaly."
      name        = "monitor-synthetics-canary-linkcheck-role"
      path        = "/"
    }
    aws_iam_policy = {
      description = "Policy for Synthetics Canaly."
      name        = "monitor-synthetics-canary-linkcheck-policy"
      path        = "/"
    }
    aws_synthetics_canary = {
      # Location in Amazon S3 where Synthetics stores artifacts from the test runs of this canary.
      # If not specified, the log bucket is automatically specified.
      artifact_s3_location = null
      # ARN of the IAM role to be used to run the canary. see AWS Docs for permissions needs for IAM Role.
      # If not specified, a role policy is automatically created.
      execution_role_arn = null
      # (Required) Name for this canary. Has a maximum length of 21 characters. Valid characters are lowercase alphanumeric, hyphen, or underscore.
      name = "linkcheck"
      # (Required) Runtime version to use for the canary. Versions change often so consult the Amazon CloudWatch documentation for the latest valid versions. Values include syn-python-selenium-1.0, syn-nodejs-puppeteer-3.0, syn-nodejs-2.2, syn-nodejs-2.1, syn-nodejs-2.0, and syn-1.0.
      runtime_version = "syn-nodejs-puppeteer-3.9"
      # (Required) Configuration block providing how often the canary is to run and when these test runs are to stop. Detailed below.
      schedule = [
        {
          expression = "cron(0 0 * * ? *)"
        }
      ]
      # (Optional) Configuration block. Detailed below.
      # TODO: need to set vpc_config bypass WAF.
      #       When a request must be made from a fixed IP, such as in the case of a site with restricted access.
      vpc_config = [
        # {
        #   subnet_ids = [
        #     "subnet-xxxxxxxxxxxxxxxxx",
        #     "subnet-xxxxxxxxxxxxxxxxx",
        #     "subnet-xxxxxxxxxxxxxxxxx",
        #   ]
        #   security_group_ids = [
        #     "sg-xxxxxxxxxxxxxxxxx",
        #   ]
        # }
      ]
      # (Optional) Number of days to retain data about failed runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
      failure_retention_period = 7
      # (Optional) Configuration block for individual canary runs. Detailed below.
      run_config = [
        {
          timeout_in_seconds = 60
          memory_in_mb       = 960
          active_tracing     = false
        }
      ]
      # (Optional) Full bucket name which is used if your canary script is located in S3. The bucket must already exist. Specify the full bucket name including s3:// as the start of the bucket name. Conflicts with zip_file.
      s3_bucket = null
      # (Optional) S3 key of your script. Conflicts with zip_file.
      s3_key = null
      # (Optional) S3 version ID of your script. Conflicts with zip_file.
      s3_version = null
      # (Optional) Whether to run or stop the canary.
      start_canary = true
      # (Optional) Number of days to retain data about successful runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.
      success_retention_period = 7
      # (Optional) configuration for canary artifacts, including the encryption-at-rest settings for artifacts that the canary uploads to Amazon S3. See Artifact Config.
      artifact_config = [
        {
          s3_encryption = [
            {
              encryption_mode = "SSE-S3"
            }
          ]
        }
      ]
      # TODO: Set the URL for the link check and the maximum number of links to follow.
      # (Optional) URLS/LIMIT is an environment variable that can be specified as a delimited string to allow heart beats to be thrown to multiple URLs.
      env = {
        URLS  = "https://www.google.com/"
        LIMIT = 10
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
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false
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
  enabled_cloudfront = false
  # TODO: Specify the S3 bucket where CloudFront logs are stored. s3://{bucket name}/{bucket prefix}
  # ex1) cloudfront_log_bucket = "s3://base-aws-log-application-xxxxxxxxxxxx/Logs/CloudFront/"
  cloudfront_log_bucket = ""
  # TODO: To check SES logs with Athena, specify true.
  enabled_ses = false
  # TODO: Specify the S3 bucket where SES logs are stored. s3://{bucket name}/{bucket prefix}
  # ex1) ses_log_bucket = "s3://base-aws-log-application-xxxxxxxxxxx/Logs/base-aws-ses-log/"
  ses_log_bucket = ""
}
#--------------------------------------------------------------
# Report CSP
# Note: Custom domains are not yet supported.
# If enabled, report_csp_url will be displayed as the Endpoint in the output.
#--------------------------------------------------------------
report_csp = {
  # TODO: need to set is_enabled for report CSP.
  is_enabled = true
  aws_lambda_function = {
    environment = {
      # TODO: need to change SLACK_OAUTH_ACCESS_TOKEN.(bot token xoxb-xxxxxx....)
      SLACK_OAUTH_ACCESS_TOKEN = "xxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
      # TODO: need to change SLACK_CHANNEL_ID.
      SLACK_CHANNEL_ID = "XXXXXXXXXXXXXX"
      LOGGER_FORMATTER = "json"
      LOGGER_OUT       = "stdout"
      LOGGER_LEVEL     = "warn"
    }
  }
}
