<!-- omit in toc -->
# Monitor Terraform Configuration Guide

The example is [terraform.example.tfvars](terraform/monitor/terraform.example.tfvars). The following is a list of things that must be modified and things that should be modified when doing terraform apply for the first time.
If you need to adjust the parameters, you can do so by yourself by searching TODO.

<!-- omit in toc -->
## Table of Contents

- [Initial setting](#initial-setting)
- [Requirements](#requirements)
  - [region](#region)
  - [cloudwatch\_log\_group](#cloudwatch_log_group)
    - [Centralized Configuration Pattern](#centralized-configuration-pattern)
    - [Available Services for Override](#available-services-for-override)
    - [Benefits of Centralized Configuration](#benefits-of-centralized-configuration)
    - [Example Configuration](#example-configuration)
- [Not Requirements](#not-requirements)
  - [tags](#tags)
  - [name\_prefix](#name_prefix)
  - [Slack](#slack)
    - [Centralized Slack Configuration](#centralized-slack-configuration)
    - [How Slack Configuration Works](#how-slack-configuration-works)
    - [Available Override Functions](#available-override-functions)
    - [Benefits of Centralized Configuration](#benefits-of-centralized-configuration-1)
    - [Environment-Specific Channel Configuration Example](#environment-specific-channel-configuration-example)
  - [is\_enabled](#is_enabled)
  - [use\_control\_tower](#use_control_tower)
  - [Environment-Specific Configuration Examples](#environment-specific-configuration-examples)
    - [Development Environment](#development-environment)
    - [Production Environment](#production-environment)
    - [Staging Environment](#staging-environment)
- [Configuration Validation](#configuration-validation)
- [Summary of Configuration Improvements](#summary-of-configuration-improvements)
  - [What We've Improved](#what-weve-improved)
  - [Key Configuration Principles](#key-configuration-principles)
  - [Quick Start Recommendations](#quick-start-recommendations)
- [Related Documents](#related-documents)

## Initial setting

This section describes the initial settings for running [monitor's Terraform](./terraform/monitor/). If an item has already been addressed, please skip to the next section.

- **Remove the access key from the root account**

  Since this is a security issue, let's remove the access key from the root account from the management console.

- **Manual creation of IAM user and IAM group to run Terraform**

  Create an IAM user and an IAM group from the management console in order to run Terraform.
  
  Create an IAM group (pseudonym: deploy). Attach AdministratorAccess as the policy.
  
  Create an IAM user (pseudonym: terraform), giving it only Programmatic access for Access Type, and add it to the IAM group (pseudonym: deploy).

- **Create an S3 to store the Terraform State**

  Create an S3 from the management console to manage the Terraform State.
  
  However, if you have an environment where you can run the aws command and profile already configured, you can create an S3 by running the following command.

```sh
$ ./scripts/terraform/aws_init_state.sh -h

This command creates a S3 Bucket for Terraform State.
You can also add random hash to bucket name suffix.

Usage:
    aws_init_state.sh -r {region} -b {bucket name} -p {profile}[<options>]
    aws_init_state.sh -r ap-northeast-1 -b terraform-state
    aws_init_state.sh -r ap-northeast-1 -b terraform-state -p default -s

Options:
    -b {bucket name}          S3 bucket name
    -p {aws profile name}     Name of AWS profile
    -r {region}               S3 region
    -s                        If set, a random hash will suffix bucket name.
    -h                        Usage aws_init_state.sh

$ ./scripts/terraform/aws_init_state.sh -r ap-northeast-1 -b base-terraform-state- -p default -s
~
~
~
~
~
~
~
~
~
~
~
~
~
--------------------------------------------------------------
bucket_name: base-terraform-state-xxxxxxxxxx
region: ap-northeast-1
--------------------------------------------------------------
```

- **terraform.{environment}.tfvars file to configure for each environment**

  You need to rename the linked file [terraform.example.tfvars](terraform/monitor/terraform.example.tfvars) and change each variable for your environment. The variables that need to be changed are marked with TODO comments; search for them in TODO.

- **Running Terraform**

  Run the terraform command: terraform init followed by terraform apply.
  
  You may find that terraform apply fails due to conflicts or other problems, so run it again and it will succeed.

```sh
bash-5.1# terraform init
There are some problems with the CLI configuration:

Error: The specified plugin cache dir /root/.terraform.d/plugin-cache cannot be opened: stat /root/.terraform.d/plugin-cache: no such file or directory


As a result of the above problems, Terraform may not behave as intended.


Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/aws from the dependency lock file
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/template from the dependency lock file
- Installing hashicorp/aws v3.29.1...
- Installed hashicorp/aws v3.29.1 (signed by HashiCorp)
- Installing hashicorp/random v3.1.0...
- Installed hashicorp/random v3.1.0 (signed by HashiCorp)
- Installing hashicorp/template v2.2.0...
- Installed hashicorp/template v2.2.0 (signed by HashiCorp)

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```sh
bash-5.1# terraform apply --auto-approve -var-file=terraform.example.tfvars
module.aws_s3_bucket_log_log.random_id.this: Creating...
random_id.this: Creating...
module.aws_s3_bucket_log_id.this: Creation complete after 0s [id=abcde]
random_id.this: Creation complete after 0s [id=uqe0bU7J]
module.aws_security_default_vpc.aws_default_subnet.this[1]: Creating...

...
...
...

Apply complete! resources: x added, x changed, 0 destroyed.
```

## Requirements

The following items must be modified; terraform apply will fail if you run it as an example.

### region

Select the region where you want to create the resource.

Specifies the primary AWS region where most resources will be deployed. Some services like CloudFront require resources in us-east-1 regardless of this setting.

Common regions: ap-northeast-1 (Tokyo), us-east-1 (N. Virginia), eu-west-1 (Ireland)

```terraform
#--------------------------------------------------------------
# Default Region for Resources
# Specifies the primary AWS region where most resources will be deployed.
# Some services like CloudFront require resources in us-east-1 regardless of this setting.
# Common regions: ap-northeast-1 (Tokyo), us-east-1 (N. Virginia), eu-west-1 (Ireland)
#--------------------------------------------------------------
# TODO: need to change region.
region = "ap-northeast-1"
```

### cloudwatch_log_group

**IMPORTANT: CloudWatch Log Group configuration has been centralized for easier management.**

Instead of configuring retention periods for each Lambda function individually, you can now manage them centrally with service-specific overrides when needed.

#### Centralized Configuration Pattern

```terraform
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
  # Default KMS key ID for log encryption (null = use AWS managed key)
  kms_key_id = null

  # Optional: Override settings for specific services
  # Uncomment and configure as needed
  override = {
    # cloudwatch_event_ec2 = {
    #   retention_in_days = 7
    # }
    # common_lambda_log = {
    #   retention_in_days = 7
    # }
    # common_lambda_log_us_east_1 = {
    #   retention_in_days = 7
    # }
    # common_lambda_metric = {
    #   retention_in_days = 14
    # }
    # common_lambda_metric_us_east_1 = {
    #   retention_in_days = 14
    # }
    # common_lambda_ses = {
    #   retention_in_days = 7
    # }
    # common_lambda_ses_us_east_1 = {
    #   retention_in_days = 7
    # }
    # common_lambda_step_functions = {
    #   retention_in_days = 14
    # }
    # common_lambda_step_functions_us_east_1 = {
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
```

#### Available Services for Override

For the monitor environment, the following services support CloudWatch Log Group configuration overrides:

| Service Name                             | Description                                     | Recommended Retention |
| ---------------------------------------- | ----------------------------------------------- | --------------------- |
| `cloudwatch_event_ec2`                   | EC2 events forwarded through EventBridge        | 7 days                |
| `common_lambda_log`                      | CloudWatch alarms routed to Slack               | 7-14 days             |
| `common_lambda_log_us_east_1`            | Same as above for us-east-1 failover            | 7-14 days             |
| `common_lambda_metric`                   | Kinesis Data Firehose metrics processing        | 14 days               |
| `common_lambda_metric_us_east_1`         | Metrics processing Lambda in us-east-1          | 14 days               |
| `common_lambda_ses`                      | CloudWatch alarms delivered via SES to Slack    | 7 days                |
| `common_lambda_ses_us_east_1`            | SES forwarding Lambda deployed in us-east-1     | 7 days                |
| `common_lambda_step_functions`           | Step Functions execution notifications          | 14 days               |
| `common_lambda_step_functions_us_east_1` | Step Functions notifications for us-east-1 jobs | 14 days               |
| `common_lambda_vpc_flow_log`             | VPC Flow Logs processing pipeline               | 7 days                |
| `metric_log_application`                 | Application errors report Lambda                | 14 days               |
| `metric_log_postgresql_slowquery`        | PostgreSQL slow query analyzer                  | 14-30 days            |

#### Benefits of Centralized Configuration

✅ **Single Source of Truth**: Define retention period once, apply everywhere

✅ **Flexible Overrides**: Set different retention for specific monitoring services

✅ **Easy Maintenance**: Update retention policies without modifying multiple configurations

✅ **Cost Optimization**: Easily identify and adjust services with long retention periods

✅ **Consistent Encryption**: Optionally use a common KMS key for all log encryption

#### Example Configuration

```terraform
# Development Environment - Short retention for cost savings
cloudwatch_log_group = {
  retention_in_days = 7
  kms_key_id = null
  override = {
    metric_log_postgresql_slowquery = {
      retention_in_days = 14  # Keep DB logs slightly longer
    }
  }
}

# Production Environment - Standard retention
cloudwatch_log_group = {
  retention_in_days = 14
  kms_key_id = "arn:aws:kms:ap-northeast-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  override = {
    metric_log_postgresql_slowquery = {
      retention_in_days = 30  # Keep DB logs for monthly analysis
    }
    common_lambda_log = {
      retention_in_days = 30  # Keep critical alarm logs longer
    }
  }
}
```

## Not Requirements

Although terraform apply will succeed without fixing the following items, the following is a list of things that should be changed for each environment.

### tags

You can leave the following as it is without any problem. However, if you want to add TAGs to the resources according to your environment, please modify the following.

These tags are automatically applied to all resources created by this Terraform configuration. Common tags help with cost allocation, resource organization, and compliance tracking.

```terraform
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
```

### name_prefix

Used as a prefix for resource names. This prefix helps identify resources belonging to this project and environment.

Example: If `name_prefix="myproject-"`, resources will be named `"myproject-vpc"`, `"myproject-lambda"`, etc.

```terraform
#--------------------------------------------------------------
# Name prefix
# It is used as a prefix attached to various resource names.
# This prefix helps identify resources belonging to this project and environment.
# Example: If name_prefix="myproject-", resources will be named "myproject-vpc", "myproject-lambda", etc.
#--------------------------------------------------------------
name_prefix = "base-"
```

### Slack

**IMPORTANT: Slack configuration has been significantly improved with centralized management.**

Instead of configuring Slack credentials for each Lambda function individually, you can now manage them centrally with function-specific overrides when needed.

#### Centralized Slack Configuration

```terraform
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
```

#### How Slack Configuration Works

**Priority System:**

1. **Override (Highest)**: Function-specific channel in `slack.override.<function_name>`
2. **Default (Lowest)**: Common channel in `slack.channel_id`

**Example Configuration:**
```terraform
slack = {
  oauth_access_token = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
  channel_id = "C0XXXXXXXXX"  # Default channel for all monitoring notifications
  
  override = {
    # Send critical log alerts to dedicated channel
    common_lambda_log = { channel_id = "C0XXXXXXXXX" }
    
    # Send SES bounces/complaints to email team
    common_lambda_ses = { channel_id = "C0XXXXXXXXX" }
    
    # Send performance metrics to monitoring channel
    common_lambda_metric = { channel_id = "C0XXXXXXXXX" }
    
    # Send workflow failures to devops channel
    common_lambda_step_functions = { channel_id = "C0XXXXXXXXX" }
    
    # Send EC2 events to infrastructure channel
    cloudwatch_event_ec2 = { channel_id = "C0XXXXXXXXX" }
  }
}
```

#### Available Override Functions

| Function Name                     | Description                                |
| --------------------------------- | ------------------------------------------ |
| `apigateway_report_csp`           | Content Security Policy violation reports  |
| `cloudwatch_event_ec2`            | EC2 instance state changes and events      |
| `common_lambda_log`               | CloudWatch Alarms routed to SNS then Slack |
| `common_lambda_metric`            | Kinesis Data Firehose metrics and logs     |
| `common_lambda_ses`               | CloudWatch Alarms via SES to Slack         |
| `common_lambda_step_functions`    | Step Functions execution logs              |
| `metric_log_application`          | Application errors report                 |
| `metric_log_postgresql_slowquery` | PostgreSQL slow query alerts               |

#### Benefits of Centralized Configuration

✅ **Single Source of Truth**: Manage OAuth token in one place

✅ **Flexible Routing**: Route different monitoring alerts to different channels

✅ **Easy Maintenance**: Update channel IDs without modifying multiple configurations

✅ **Environment-Specific**: Use different channels for dev/stg/prd environments

✅ **Type Safety**: Terraform validates configuration structure

#### Environment-Specific Channel Configuration Example

**Development Environment:**
```terraform
slack = {
  oauth_access_token = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
  channel_id = "C0XXXXXXXXX"  # General dev channel
  override = {
    common_lambda_log = { channel_id = "C0XXXXXXXXX" }
  }
}
```

**Production Environment:**
```terraform
slack = {
  oauth_access_token = "xoxb-xxxxxxxxxxxxx-xxxxxxxxxxxxx-xxxxxxxxxxxxxxxxxxxxxxxx"
  channel_id = "C0XXXXXXXXX"  # General prod channel
  override = {
    common_lambda_log = { channel_id = "C0XXXXXXXXX" }  # Critical alerts
    common_lambda_metric = { channel_id = "C0XXXXXXXXX" }
    common_lambda_step_functions = { channel_id = "C0XXXXXXXXX" }
  }
}
```

**Note**: If you don't configure Slack settings, notifications will fail but deployment will succeed.

### is_enabled

The variable for each function has is_enabled. If you do not want to use it as a function, you can disable it by specifying false.

- Log:Application

  ```terraform
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
  ```

- Log:Application Errors Report

  ```terraform
  #--------------------------------------------------------------
  # Log:Application Errors Report
  # Periodically aggregates application error logs and sends a summary report to Slack.
  # Uses EventBridge Scheduler to trigger a Lambda function that queries CloudWatch Logs.
  #--------------------------------------------------------------
  metric_log_application_report = {
    # TODO: need to set is_enabled for settings of application errors report every day.
    is_enabled = false
  ```

- Log:PostgreSQL

  ```terraform
  metric_log_postgresql = {
    # TODO: need to set is_enabled for settings of postgresql log.
    is_enabled = false
  ```

- Log:PostgreSQL slow query

  ```terraform
  metric_log_postgresql_slowquery = {
    # TODO: need to set is_enabled for settings of postgresql slow query alert every time.
    is_enabled = false
  ```

- Log:PostgreSQL slow query report

  ```terraform
  #--------------------------------------------------------------
  # Log:PostgreSQL slow query report
  # Periodically aggregates PostgreSQL slow query logs and sends a summary report to Slack.
  # Uses EventBridge Scheduler to trigger a Lambda function that queries CloudWatch Logs.
  #--------------------------------------------------------------
  metric_log_postgresql_slowquery_report = {
    # TODO: need to set is_enabled for settings of postgresql slow queries report every day.
    is_enabled = false
  ```

- Log:MySQL slow query

  ```terraform
  #--------------------------------------------------------------
  # Log:MySQL slow query
  # The filter function of CloudWatchLogs can be used to check MySQL slow query logs
  # with specified filter patterns. Those that hit the filter pattern will be
  # notified by Slack via Lambda.
  #--------------------------------------------------------------
  metric_log_mysql_slowquery = {
    # TODO: need to set is_enabled for settings of mysql slow query log.
    is_enabled = false
  ```

- Log:WAF

  ```terraform
  #--------------------------------------------------------------
  # Log:WAF
  # The filter function of CloudWatchLogs can be used to check AWS WAF logs
  # with specified filter patterns. Those that hit the filter pattern will be
  # notified by Slack via Lambda.
  # Both default region and us-east-1 configurations are available.
  #--------------------------------------------------------------
  metric_log_waf = {
    # TODO: need to set is_enabled for settings of WAF log.
    is_enabled = false
  ```

- Log:Step Functions

  ```terraform
  #--------------------------------------------------------------
  # Log:Step Functions
  # The filter function of CloudWatchLogs can be used to check Step Functions
  # execution logs with specified filter patterns. Those that hit the filter
  # pattern will be notified by Slack via Lambda.
  #--------------------------------------------------------------
  metric_log_step_functions = {
    # TODO: need to set is_enabled for settings of Step Functions log.
    is_enabled = false
  ```

- Metrics:API Gateway

  ```terraform
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
  ```

- Metrics:CloudFront

  ```terraform
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
  ```

- Metrics:EC2

  ```terraform
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
  ```

- Metrics:ECS/ContainerInsights

  ```terraform
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
  ```

- Metrics:ElastiCache

  ```terraform
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
  ```

- Metrics:ELB (ALB/NLB)

  ```terraform
  #--------------------------------------------------------------
  # Metrics:ELB (ALB/NLB)
  # Metrics are data about the performance of your systems. By default,
  # many services provide free metrics for resources (such as Amazon EC2 instances,
  # Amazon EBS volumes, and Amazon RDS DB instances).
  # You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
  # or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
  # (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
  #
  # Metrics about ELB (ALB/NLB) will be checked and you will be notified via Slack if the specified threshold is exceeded.
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-cloudwatch-metrics.html
  #--------------------------------------------------------------
  metric_resource_elb = {
    # TODO: need to set is_enabled for Metric of ELB (ALB/NLB).
    is_enabled = false
  ```

- Metrics:EventBridge Scheduler

  ```terraform
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
  ```

- Metrics:Lambda

  ```terraform
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
  ```

- Metrics: NAT Gateway

  ```terraform
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
  ```

- Metrics:RDS Cluster

  ```terraform
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
  ```

- Metrics:Redshift

  ```terraform
  #--------------------------------------------------------------
  # Metrics:Redshift
  # Metrics are data about the performance of your systems. By default,
  # many services provide free metrics for resources (such as Amazon EC2 instances,
  # Amazon EBS volumes, and Amazon RDS DB instances).
  # You can also enable detailed monitoring for some resources, such as your Amazon EC2 instances,
  # or publish your own application metrics. Amazon CloudWatch can load all the metrics in your account
  # (both AWS resource metrics and application metrics that you provide) for search, graphing, and alarms.
  #
  # Metrics about Redshift will be checked and you will be notified via Slack if the specified threshold is exceeded.
  # https://docs.aws.amazon.com/redshift/latest/mgmt/metrics-listing.html
  #--------------------------------------------------------------
  metric_resource_redshift = {
    # TODO: need to set is_enabled for monitor of Redshift.
    is_enabled = false
  ```

- Metrics:SES

  ```terraform
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
  ```

- Metrics:SQS DLQ

  ```terraform
  #--------------------------------------------------------------
  # Metrics:SQS(DLQ)
  #--------------------------------------------------------------
  metric_resource_sqs_dlq = {
    # TODO: need to set is_enabled for Metric of SQS(DLQ).
    is_enabled = false
  ```

- Metrics:SNS

  ```terraform
  #--------------------------------------------------------------
  # Metrics:SNS
  # Monitors SNS delivery failures and message counts.
  # Sends notifications via Slack if the specified threshold is exceeded.
  #--------------------------------------------------------------
  metric_resource_sns = {
    # TODO: need to set is_enabled for Metric of SNS.
    is_enabled = false
  ```

- Delivery Log

  ```terraform
  #--------------------------------------------------------------
  # Delivery Log
  # Configures CloudWatch Logs delivery to S3 for long-term storage and analysis.
  # Both default region and us-east-1 configurations are available.
  #--------------------------------------------------------------
  delivery_log = {
    # TODO: need to set is_enabled for settings of delivery log.
    is_enabled = false
  ```

- CloudWatch Events:EC2

  ```terraform
  #--------------------------------------------------------------
  # CloudWatch Events:EC2
  # The following events are monitored.
  # - EC2 Instance Rebalance Recommendation
  # - EC2 Spot Instance Interruption Warning
  #--------------------------------------------------------------
  cloudwatch_event_ec2 = {
    # TODO: need to set is_enabled for settings of EC2.
    is_enabled = false
  ```

- Metrics:Synthetics Canary: Heartbeat

  ```terraform
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
  ```

- Metrics:Synthetics Canary: Linkcheck

  ```terraform
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
  ```

- Athena

  ```terraform
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
    is_enabled = false
    # TODO: To check CloudFront logs with Athena, specify true.
    enabled_cloudfront    = true
    # TODO: Specify the S3 bucket where CloudFront logs are stored. s3://{bucket name}/{bucket prefix}
    cloudfront_log_bucket = "s3://base-aws-log-application-0123456789012/Logs/CloudFront/"
    # TODO: To check SES logs with Athena, specify true.
    enabled_ses = true
    # TODO: Specify the S3 bucket where SES logs are stored. s3://{bucket name}/{bucket prefix}
    ses_log_bucket = "s3://base-aws-log-application-0123456789012/Logs/base-aws-ses-log/"
  ```

- Report CSP

  ```terraform
  #--------------------------------------------------------------
  # Report CSP
  #--------------------------------------------------------------
  report_csp = {
    # TODO: need to set is_enabled for report CSP.
    is_enabled = false
  ```

- Metrics:Synthetics Canary

  ```terraform
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
  ...
  ...
  ...
    #--------------------------------------------------------------
    # Function: Linkcheck
    # Validates that all links on specified pages are functional.
    #--------------------------------------------------------------
    linkcheck = {
      # TODO: need to set is_enabled for Metric of Synthetics Canary.
      is_enabled = false
  ```

- Athena

  ```terraform
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
    is_enabled = false
    # TODO: To check CloudFront logs with Athena, specify true.
    enabled_cloudfront    = true
    # TODO: Specify the S3 bucket where CloudFront logs are stored. s3://{bucket name}/{bucket prefix}
    cloudfront_log_bucket = "s3://base-aws-log-application-0123456789012/Logs/CloudFront/"
    # TODO: To check SES logs with Athena, specify true.
    enabled_ses = true
    # TODO: Specify the S3 bucket where SES logs are stored. s3://{bucket name}/{bucket prefix}
    ses_log_bucket = "s3://base-aws-log-application-0123456789012/Logs/base-aws-ses-log/"
  ```

- Report CSP

  ```terraform
  #--------------------------------------------------------------
  # Report CSP
  #--------------------------------------------------------------
  report_csp = {
    # TODO: need to set is_enabled for report CSP.
    is_enabled = false
  ```

- Eventbridge

  ```terraform
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
    ...
    ...
    ...
    #--------------------------------------------------------------
    # Schedule automatic stop and start of EC2 Instance.
    #--------------------------------------------------------------
    ec2 = {
      # TODO: need to set is_enabled for stop and start ec2_instance schedule.
      is_enabled = false
    ...
    ...
    ...
    #--------------------------------------------------------------
    # Schedule automatic stop and start of ECS Service.
    #--------------------------------------------------------------
    ecs_service = {
      # TODO: need to set is_enabled for stop and start ecs_service schedule.
      is_enabled = false
    ...
    ...
    ...
    #--------------------------------------------------------------
    # Schedule automatic enable and disable of ECS Scheduled Task (EventBridge Rule).
    #--------------------------------------------------------------
    ecs_scheduled_task = {
      # TODO: need to set is_enabled for enable and disable ecs scheduled task schedule.
      is_enabled = false
    ...
    ...
    ...
    #--------------------------------------------------------------
    # Schedule automatic stop and start of RDS Cluster.
    #--------------------------------------------------------------
    rds_cluster = {
      # TODO: need to set is_enabled for stop and start rds_cluster schedule.
      is_enabled = false
    ...
    ...
    ...
    #--------------------------------------------------------------
    # Schedule automatic pause and resume of Redshift Cluster.
    #--------------------------------------------------------------
    redshift = {
      # TODO: need to set is_enabled for pause and resume redshift cluster schedule.
      is_enabled = false
    ...
    ...
    ...
  ```

### use_control_tower

This setting determines whether AWS Control Tower is being used in the environment. When set to `true`, certain services will be automatically disabled to avoid conflicts with Control Tower's governance.

**Important Notes:**
- Set to `true` if your AWS environment is managed by AWS Control Tower
- When enabled, the following services are automatically disabled:
  - AWS Config (Control Tower provides its own configuration management)
  - AWS CloudTrail (Control Tower provides organization-level trail)
  - Security Hub (Control Tower provides its own security services)
  - GuardDuty (Control Tower provides its own threat detection)
  - Trusted Advisor (Control Tower provides its own best practices checks)
- IAM user creation is NOT automatically disabled (contrary to some documentation)
- This setting ensures compatibility with Control Tower's governance framework

```terraform
# Set to true if using AWS Control Tower
use_control_tower = false
```

**Control Tower Integration Details:**
- When `use_control_tower = true`, the Terraform modules will:
  - Skip creation of conflicting services
  - Use Control Tower's existing resources where possible
  - Maintain compatibility with Control Tower's organizational units
- For more information about AWS Control Tower, see:
  <https://docs.aws.amazon.com/controltower/latest/userguide/what-is-control-tower.html>

Setting `use_control_tower=true` will automatically disable the following services to avoid conflicts:

- CloudTrail
- GuardDuty
- SecurityHub
- AWS Config (both regional and us-east-1)
- IAM password expiration notifications

This helps prevent duplicate configurations and potential conflicts between your Terraform-managed resources and those managed by AWS Control Tower.

### Environment-Specific Configuration Examples

#### Development Environment
```terraform
# Development environment - minimal monitoring, cost-effective settings

# Enable only essential monitoring
metric_resource_lambda = {
  is_enabled = false  # Disable detailed Lambda monitoring in dev
}

metric_resource_rds_cluster = {
  is_enabled = false  # Disable RDS monitoring in dev
}

# Basic log monitoring
metric_log_application = {
  is_enabled = true
  create_auto_log_group_names = true
}

# Disable expensive services
athena = {
  is_enabled = false
}
```

#### Production Environment
```terraform
# Production environment - comprehensive monitoring and alerting

# Enable all critical monitoring
metric_resource_lambda = {
  is_enabled = true
  threshold = {
    enabled_errors = true
    errors = 0  # Zero tolerance for errors in prod
  }
}

metric_resource_rds_cluster = {
  is_enabled = true
  threshold = {
    enabled_cpu_utilization = true
    cpu_utilization = 70  # Alert earlier in prod
  }
}

# Comprehensive log monitoring
metric_log_application = {
  is_enabled = true
  create_auto_log_group_names = true
}

# Enable analytics
athena = {
  is_enabled = true
  enabled_cloudfront = true
  enabled_ses = true
}
```

#### Staging Environment
```terraform
# Staging environment - moderate monitoring, testing-focused

# Selective monitoring
metric_resource_lambda = {
  is_enabled = true
  threshold = {
    enabled_errors = true
    errors = 1  # Allow some errors in staging
  }
}

metric_resource_rds_cluster = {
  is_enabled = true
  threshold = {
    enabled_cpu_utilization = true
    cpu_utilization = 80
  }
}

# Moderate log monitoring
metric_log_application = {
  is_enabled = true
  create_auto_log_group_names = true
}

# Enable for testing
athena = {
  is_enabled = false  # Enable if needed for testing
}
```

## Configuration Validation

| Category                        | Item                                                                             | Status |
| ------------------------------- | -------------------------------------------------------------------------------- | ------ |
| Monitoring Services Validation  | Enable appropriate monitoring based on your environment                          | [ ]    |
| Monitoring Services Validation  | Development: Basic log monitoring only                                           | [ ]    |
| Monitoring Services Validation  | Staging: Moderate resource monitoring                                            | [ ]    |
| Monitoring Services Validation  | Production: Comprehensive monitoring with strict thresholds                      | [ ]    |
| Monitoring Services Validation  | Configure Slack notifications for critical alerts                                | [ ]    |
| Monitoring Services Validation  | Set appropriate thresholds for your workload patterns                            | [ ]    |
| Resource Monitoring Validation  | Lambda Functions: Set error thresholds based on expected error rates             | [ ]    |
| Resource Monitoring Validation  | RDS Clusters: Configure CPU/memory thresholds appropriate for your database load | [ ]    |
| Resource Monitoring Validation  | ALB: Set response time thresholds based on your application requirements         | [ ]    |
| Resource Monitoring Validation  | EC2: Enable CPU utilization monitoring for auto-scaling scenarios                | [ ]    |
| Log Monitoring Validation       | Configure log group names or enable auto-discovery                               | [ ]    |
| Log Monitoring Validation       | Set appropriate log exclusion patterns to reduce noise                           | [ ]    |
| Log Monitoring Validation       | Configure retention periods based on compliance requirements                     | [ ]    |
| Log Monitoring Validation       | Test log parsing with sample log entries                                         | [ ]    |
| Analytics Validation (Athena)   | Enable only if you have specific analytics requirements                          | [ ]    |
| Analytics Validation (Athena)   | Configure appropriate S3 bucket locations for log sources                        | [ ]    |
| Analytics Validation (Athena)   | Set up proper database and table structures                                      | [ ]    |
| Analytics Validation (Athena)   | Consider costs for frequent queries                                              | [ ]    |
| Cost Optimization Validation    | Disable unused monitoring services                                               | [ ]    |
| Cost Optimization Validation    | Set appropriate monitoring intervals (period)                                    | [ ]    |
| Cost Optimization Validation    | Configure log retention periods                                                  | [ ]    |
| Cost Optimization Validation    | Review Synthetics Canary schedules for cost efficiency                           | [ ]    |
| Environment-Specific Validation | Development: Minimal monitoring, longer intervals, relaxed thresholds            | [ ]    |
| Environment-Specific Validation | Staging: Moderate monitoring, standard intervals, moderate thresholds            | [ ]    |
| Environment-Specific Validation | Production: Comprehensive monitoring, shorter intervals, strict thresholds       | [ ]    |
| Integration Validation          | Verify Slack integration works with test notifications                           | [ ]    |
| Integration Validation          | Confirm S3 bucket permissions for log delivery                                   | [ ]    |
| Integration Validation          | Test Kinesis Firehose delivery to S3                                             | [ ]    |
| Integration Validation          | Validate IAM permissions for all monitoring services                             | [ ]    |

## Summary of Configuration Improvements

### What We've Improved

1. **Environment-Specific Examples**: Added concrete configuration examples for Development, Staging, and Production environments
2. **Configuration Validation Checklist**: Comprehensive checklist to validate settings before deployment
3. **Enhanced Comments**: Added cost considerations, monitoring implications, and environment-specific guidance
4. **Clear Default Values**: Made it clear which settings are safe defaults and which need customization

### Key Configuration Principles

- **Monitoring Balance**

  Enable monitoring that provides value without creating alert fatigue

- **Cost Optimization**

  Disable unused services to reduce AWS costs

- **Environment Awareness**

  Use different configurations for dev/staging/prod

- **Alert Quality**

  Configure meaningful thresholds and reduce false positives

### Quick Start Recommendations

**For Development:**

- Enable basic log monitoring only
- Disable expensive analytics (Athena)
- Use relaxed thresholds and longer intervals
- Minimal resource monitoring

**For Production:**

- Enable comprehensive monitoring
- Configure strict thresholds for critical services
- Enable analytics if log analysis is required
- Set up detailed alerting with appropriate channels

**For All Environments:**

- Always configure Slack notifications for critical alerts
- Set appropriate log retention periods
- Review monitoring intervals for cost efficiency
- Test configurations in non-production first

## Related Documents

- [README-base-tfvars.md](./README-base-tfvars.md) - Base configuration documentation
- [README-management-root-tfvars.md](./README-management-root-tfvars.md) - Management root environment configuration
- [README-management-audit-tfvars.md](./README-management-audit-tfvars.md) - Management audit environment configuration
- [README.md](./README.md) - Main project documentation
- [AWS Control Tower User Guide](https://docs.aws.amazon.com/controltower/latest/userguide/)
- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [CloudWatch Monitoring Guide](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)
