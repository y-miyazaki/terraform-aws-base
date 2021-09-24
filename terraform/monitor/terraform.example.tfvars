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
# Common:Logging Bucket
#--------------------------------------------------------------
common_logging = {
  aws_s3_bucket = {
    bucket        = "aws-logging-application"
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
# Common settings for notifying metrics
#--------------------------------------------------------------
common_lambda = {
  aws_iam_role = {
    description = null
    name        = "metric-lambda-role"
    path        = "/"
  }
  aws_iam_policy = {
    description = null
    name        = "metric-lambda-policy"
    path        = "/"
  }
  aws_kms_key = {
    description             = "This key used for SNS(Metric)."
    deletion_window_in_days = 7
    is_enabled              = true
    enable_key_rotation     = true
    alias_name              = "sns-metric-lambda"
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
  aws_sns_topic = {
    name                                     = "aws-metric"
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
#--------------------------------------------------------------
# Log:Application
#--------------------------------------------------------------
metric_log_application = {
  # TODO: need to set is_enabled for settings of application log.
  is_enabled = false
  aws_kms_key = {
    description             = "This key used for SNS(Application Log)."
    deletion_window_in_days = 7
    is_enabled              = true
    enable_key_rotation     = true
    alias_name              = "sns-application"
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
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/lambda | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_name = []

  aws_cloudwatch_log_metric_filter = {
    name = "application-logs-error"
    # TODO: need to change pattern for application log.
    pattern = <<PATTERN
?error ?Error ?ERROR ?fatal ?Fatal ?FATAL ?exception ?Exception ?EXCEPTION
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
# Log:Postgres
#--------------------------------------------------------------
metric_log_postgres = {
  # TODO: need to set is_enabled for settings of postgres log.
  is_enabled = false
  aws_kms_key = {
    description             = "This key used for SNS(Postgres Log)."
    deletion_window_in_days = 7
    is_enabled              = true
    enable_key_rotation     = true
    alias_name              = "sns-postgres"
  }
  aws_sns_topic = {
    name                                     = "postgres-logs"
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
    prefix             = "Postgres/"
    compression_format = "GZIP"
    cloudwatch_logging_options = [
      {
        enabled = false
      }
    ]
  }
  aws_iam_role_kinesis_firehose = {
    description = null
    name        = "postgres-kinesis-firehose-role"
    path        = "/"
  }
  aws_iam_policy_kinesis_firehose = {
    description = null
    name        = "postgres-kinesis-firehose-policy"
    path        = "/"
  }

  # TODO: need to add log_group_name for postgres.
  #       check log group name for postgres.
  # check CloudWatch Group name list command.
  # ex1) aws logs describe-log-groups --log-group-name-prefix hogehoge | jq -r ".logGroups[].logGroupName"
  # ex2) aws logs describe-log-groups --log-group-name-prefix /aws/rds/ | jq -r '.logGroups[] | .logGroupName = "\"" + .logGroupName + "\"," | .logGroupName'
  log_group_name = [
  ]

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
    alarm_description   = "Alert postgres log notification."
    datapoints_to_alarm = 1
    dimensions          = null
    treat_missing_data  = "notBreaching"
  }
  aws_iam_role_cloudwatch_logs = {
    description = null
    name        = "postgres-cloudwatch-logs-kinesis-firehose-role"
    path        = "/"
  }
  aws_iam_policy_cloudwatch_logs = {
    description = null
    name        = "postgres-cloudwatch-logs-kinesis-firehose-policy"
    path        = "/"
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
# Metric:ALB
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
# Metric:API Gateway
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
# Metric:CloudFront
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
    enabled_error_403_rate = true
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
# Metric:EC2
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
# Metric:ElastiCache
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
# Metric:Lambda
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
# Metric:RDS
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
  is_postgres = true
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
# Metric:SES
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
  # TODO: need to set dimensions for monitor of SES.
  dimensions = [
  ]
}
