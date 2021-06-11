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
# Application Log
#--------------------------------------------------------------
metric_application_log = {
  # TODO: need to set is_enabled for settings of application log.
  is_enabled = true
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
    active_connection_count = 10000
    # (Required) ClientTLSNegotiationErrorCount threshold (unit=Count)
    client_tls_negotiation_error_count = 10
    # (Required) ConsumedLCUs threshold (unit=Count)
    consumed_lcus = 5
    # (Required) HTTPCode_4XX_Count	threshold (unit=Count)
    httpcode_4xx_count = 1
    # (Required) HTTPCode_5XX_Count	threshold (unit=Count)
    httpcode_5xx_count = 1
    # (Required) HTTPCode_ELB_4XX_Count	threshold (unit=Count)
    httpcode_elb_4xx_count = 1
    # (Required) HTTPCode_ELB_5XX_Count	threshold (unit=Count)
    httpcode_elb_5xx_count = 1
    # (Required) TargetResponseTime	threshold (unit=)
    target_response_time = 10
    # (Required) TargetTLSNegotiationErrorCount	threshold (unit=Count)
    target_tls_negotiation_error_count = 10
    # (Required) UnHealthyHostCount	threshold (unit=Count)
    unhealthy_host_count = 1
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
    error4XX = 1
    # (Required) 5XXerror threshold (unit=%)
    error5XX = 1
    # (Required) Error threshold (unit=Milliseconds)
    latency = 10000
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
    error_401_rate = 1
    # (Required) Error403Rate threshold (unit=%)
    error_403_rate = 1
    # (Required) Error404Rate threshold (unit=%)
    error_404_rate = 1
    # (Required) Error502Rate threshold (unit=%)
    error_502_rate = 1
    # (Required) Error503Rate threshold (unit=%)
    error_503_rate = 1
    # (Required) Error504Rate threshold (unit=%)
    error_504_rate = 1
    # (Required) CacheHitRate threshold (unit=%)
    cache_hit_rate = 70
    # (Required) OriginLatency threshold (unit=Milliseconds)
    origin_latency = 10000
  }
  # TODO: need to set dimensions for monitor of CloudFront.
  # Specify the instance of the target CloudFront name to be monitored by Map.
  # check CloudFront distribution name list command.
  # ex) aws cloudfront list-distributions | jq -r '.DistributionList.Items[] | .Dimensions = "{\n  \"DistributionId\" = \"" + .Id + "\" # " + .DomainName + "(" +.Aliases.Items[0] +")\n  \"Region\" = \"Global\"\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "DistributionId" = "ABCDEFG12345"
  #       "Region"         = "Global"
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
    cpu_utilization = 80
    # (Required) MetadataNoToken threshold (unit=Count)
    metadata_no_token = 1
    # (Required) CPUCreditUsage threshold (unit=Count)
    cpu_credit_usage = 5
    # (Required) StatusCheckFailed threshold (unit=Count)
    status_check_failed = 1
  }
  # TODO: need to set dimensions for monitor of CloudFront.
  # Specify the instance of the target CloudFront name to be monitored by Map.
  # check CloudFront distribution name list command.
  # ex) aws ec2 describe-instances | jq -r '.Reservations[].Instances[] | .Dimensions = "{\n  \"InstanceId\" = \"" + .InstanceId + "\" # " + .InstanceType + "\n}," | .Dimensions'
  #   ex)
  #   dimensions = [
  #     {
  #       "DistributionId" = "ABCDEFG12345"
  #       "Region"         = "Global"
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
    authentication_failures = 1
    # (Required) CacheHitRate threshold (unit=Percent)
    cache_hit_rate = 10
    # (Required) CommandAuthorizationFailures threshold (unit=Count)
    command_authorization_failures = 1
    # (Required) CurrConnections threshold (unit=Count)
    curr_connections = 50
    # (Required) DatabaseMemoryUsagePercentage threshold (unit=Percent)
    database_memory_usage_percentage = 80
    # (Required) EngineCPUUtilization threshold (unit=Percent)
    engine_cpu_utilization = 90
    # (Required) KeyAuthorizationFailures threshold (unit=Count)
    key_authorization_failures = 1
    # (Required) NewConnections threshold (unit=Count)
    new_connections = 100
    # (Required) SwapUsage threshold (unit=Bytes)
    swap_usage = 52428800 # 50MB
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
    concurrent_executions = 500
    # (Required) Duration threshold (unit=Milliseconds)
    duration = 10000
    # (Required) Errors threshold (unit=Count)
    errors = 1
    # (Required) Throttles threshold (unit=Count)
    throttles = 10
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
    commit_latency = 10
    # (Required) CPUCreditBalance threshold (unit=Count)
    cpu_creadit_balance = 100
    # (Required) CPUUtilization threshold (unit=%)
    cpu_utilization = 80
    # (Required) DatabaseConnections threshold (unit=Count)
    database_connections = 100
    # (Required) Deadlocks threshold (unit=Count)
    deadlocks = 1
    # (Required) DeleteLatency threshold (unit=Count)
    delete_latency = 10
    # (Required) DiskQueueDepth threshold (unit=Count)
    disk_queue_depth = 64
    # (Required) FreeableMemory threshold (unit=Megabytes)
    freeable_memory = 512
    # (Required) ReadLatency threshold (unit=Seconds)
    read_latency = 10
    # (Required) WriteLatency threshold (unit=Seconds)
    write_latency = 10
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
