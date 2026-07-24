<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.56.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_athena"></a> [athena](#module\_athena) | ../../modules/aws/athena | n/a |
| <a name="module_aws_api_gateway_create"></a> [aws\_api\_gateway\_create](#module\_aws\_api\_gateway\_create) | ../../modules/aws/api_gateway/create | n/a |
| <a name="module_aws_api_gateway_report_csp"></a> [aws\_api\_gateway\_report\_csp](#module\_aws\_api\_gateway\_report\_csp) | ../../modules/aws/api_gateway/report_csp | n/a |
| <a name="module_aws_cloudwatch_alarm_log_application"></a> [aws\_cloudwatch\_alarm\_log\_application](#module\_aws\_cloudwatch\_alarm\_log\_application) | ../../modules/aws/cloudwatch/alarm/log | n/a |
| <a name="module_aws_cloudwatch_alarm_log_mysql_query"></a> [aws\_cloudwatch\_alarm\_log\_mysql\_query](#module\_aws\_cloudwatch\_alarm\_log\_mysql\_query) | ../../modules/aws/cloudwatch/alarm/log | n/a |
| <a name="module_aws_cloudwatch_alarm_log_postgresql"></a> [aws\_cloudwatch\_alarm\_log\_postgresql](#module\_aws\_cloudwatch\_alarm\_log\_postgresql) | ../../modules/aws/cloudwatch/alarm/log | n/a |
| <a name="module_aws_cloudwatch_alarm_log_postgresql_slowquery"></a> [aws\_cloudwatch\_alarm\_log\_postgresql\_slowquery](#module\_aws\_cloudwatch\_alarm\_log\_postgresql\_slowquery) | ../../modules/aws/cloudwatch/alarm/log | n/a |
| <a name="module_aws_cloudwatch_alarm_log_step_functions"></a> [aws\_cloudwatch\_alarm\_log\_step\_functions](#module\_aws\_cloudwatch\_alarm\_log\_step\_functions) | ../../modules/aws/cloudwatch/alarm/log | n/a |
| <a name="module_aws_cloudwatch_alarm_log_waf"></a> [aws\_cloudwatch\_alarm\_log\_waf](#module\_aws\_cloudwatch\_alarm\_log\_waf) | ../../modules/aws/cloudwatch/alarm/log | n/a |
| <a name="module_aws_cloudwatch_alarm_log_waf_us_east_1"></a> [aws\_cloudwatch\_alarm\_log\_waf\_us\_east\_1](#module\_aws\_cloudwatch\_alarm\_log\_waf\_us\_east\_1) | ../../modules/aws/cloudwatch/alarm/log | n/a |
| <a name="module_aws_cloudwatch_events_ec2"></a> [aws\_cloudwatch\_events\_ec2](#module\_aws\_cloudwatch\_events\_ec2) | ../../modules/aws/cloudwatch/events/ec2 | n/a |
| <a name="module_aws_iam_role_eventbridge"></a> [aws\_iam\_role\_eventbridge](#module\_aws\_iam\_role\_eventbridge) | ../../modules/aws/iam/role/eventbridge | n/a |
| <a name="module_aws_iam_role_lambda"></a> [aws\_iam\_role\_lambda](#module\_aws\_iam\_role\_lambda) | ../../modules/aws/iam/role/lambda | n/a |
| <a name="module_aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor"></a> [aws\_lambda\_create\_lambda\_kinesis\_data\_firehose\_cloudwatch\_logs\_processor](#module\_aws\_lambda\_create\_lambda\_kinesis\_data\_firehose\_cloudwatch\_logs\_processor) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_kinesis_data_firehose_cloudwatch_logs_processor_us_east_1"></a> [aws\_lambda\_create\_lambda\_kinesis\_data\_firehose\_cloudwatch\_logs\_processor\_us\_east\_1](#module\_aws\_lambda\_create\_lambda\_kinesis\_data\_firehose\_cloudwatch\_logs\_processor\_us\_east\_1) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_log"></a> [aws\_lambda\_create\_lambda\_log](#module\_aws\_lambda\_create\_lambda\_log) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_log_us_east_1"></a> [aws\_lambda\_create\_lambda\_log\_us\_east\_1](#module\_aws\_lambda\_create\_lambda\_log\_us\_east\_1) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_metric"></a> [aws\_lambda\_create\_lambda\_metric](#module\_aws\_lambda\_create\_lambda\_metric) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_metric_us_east_1"></a> [aws\_lambda\_create\_lambda\_metric\_us\_east\_1](#module\_aws\_lambda\_create\_lambda\_metric\_us\_east\_1) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_s3_notification_s3_object_created_for_athena"></a> [aws\_lambda\_create\_lambda\_s3\_notification\_s3\_object\_created\_for\_athena](#module\_aws\_lambda\_create\_lambda\_s3\_notification\_s3\_object\_created\_for\_athena) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_s3_notification_s3_object_created_for_athena_us_east_1"></a> [aws\_lambda\_create\_lambda\_s3\_notification\_s3\_object\_created\_for\_athena\_us\_east\_1](#module\_aws\_lambda\_create\_lambda\_s3\_notification\_s3\_object\_created\_for\_athena\_us\_east\_1) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_ses"></a> [aws\_lambda\_create\_lambda\_ses](#module\_aws\_lambda\_create\_lambda\_ses) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_ses_us_east_1"></a> [aws\_lambda\_create\_lambda\_ses\_us\_east\_1](#module\_aws\_lambda\_create\_lambda\_ses\_us\_east\_1) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_lambda_create_lambda_step_functions_log"></a> [aws\_lambda\_create\_lambda\_step\_functions\_log](#module\_aws\_lambda\_create\_lambda\_step\_functions\_log) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_aws_metric_api_gateway"></a> [aws\_metric\_api\_gateway](#module\_aws\_metric\_api\_gateway) | ../../modules/aws/metric/api_gateway | n/a |
| <a name="module_aws_metric_cloudfront"></a> [aws\_metric\_cloudfront](#module\_aws\_metric\_cloudfront) | ../../modules/aws/metric/cloudfront | n/a |
| <a name="module_aws_metric_ec2"></a> [aws\_metric\_ec2](#module\_aws\_metric\_ec2) | ../../modules/aws/metric/ec2 | n/a |
| <a name="module_aws_metric_ecs_container_insights"></a> [aws\_metric\_ecs\_container\_insights](#module\_aws\_metric\_ecs\_container\_insights) | ../../modules/aws/metric/ecs_container_insights | n/a |
| <a name="module_aws_metric_elasticache"></a> [aws\_metric\_elasticache](#module\_aws\_metric\_elasticache) | ../../modules/aws/metric/elasticache | n/a |
| <a name="module_aws_metric_elb"></a> [aws\_metric\_elb](#module\_aws\_metric\_elb) | ../../modules/aws/metric/elb | n/a |
| <a name="module_aws_metric_eventbridge_scheduler"></a> [aws\_metric\_eventbridge\_scheduler](#module\_aws\_metric\_eventbridge\_scheduler) | ../../modules/aws/metric/eventbridge_scheduler | n/a |
| <a name="module_aws_metric_lambda"></a> [aws\_metric\_lambda](#module\_aws\_metric\_lambda) | ../../modules/aws/metric/lambda | n/a |
| <a name="module_aws_metric_nat_gateway"></a> [aws\_metric\_nat\_gateway](#module\_aws\_metric\_nat\_gateway) | ../../modules/aws/metric/nat_gateway | n/a |
| <a name="module_aws_metric_rds_cluster"></a> [aws\_metric\_rds\_cluster](#module\_aws\_metric\_rds\_cluster) | ../../modules/aws/metric/rds_cluster | n/a |
| <a name="module_aws_metric_redshift"></a> [aws\_metric\_redshift](#module\_aws\_metric\_redshift) | ../../modules/aws/metric/redshift | n/a |
| <a name="module_aws_metric_ses"></a> [aws\_metric\_ses](#module\_aws\_metric\_ses) | ../../modules/aws/metric/ses | n/a |
| <a name="module_aws_metric_ses_us_east_1"></a> [aws\_metric\_ses\_us\_east\_1](#module\_aws\_metric\_ses\_us\_east\_1) | ../../modules/aws/metric/ses | n/a |
| <a name="module_aws_metric_sns"></a> [aws\_metric\_sns](#module\_aws\_metric\_sns) | ../../modules/aws/metric/sns | n/a |
| <a name="module_aws_metric_sqs"></a> [aws\_metric\_sqs](#module\_aws\_metric\_sqs) | ../../modules/aws/metric/sqs | n/a |
| <a name="module_aws_metric_synthetics_canary"></a> [aws\_metric\_synthetics\_canary](#module\_aws\_metric\_synthetics\_canary) | ../../modules/aws/metric/synthetics_canary | n/a |
| <a name="module_aws_sns_subscription_lambda_log"></a> [aws\_sns\_subscription\_lambda\_log](#module\_aws\_sns\_subscription\_lambda\_log) | ../../modules/aws/sns/subscription | n/a |
| <a name="module_aws_sns_subscription_lambda_log_us_east_1"></a> [aws\_sns\_subscription\_lambda\_log\_us\_east\_1](#module\_aws\_sns\_subscription\_lambda\_log\_us\_east\_1) | ../../modules/aws/sns/subscription | n/a |
| <a name="module_aws_sns_subscription_lambda_metric"></a> [aws\_sns\_subscription\_lambda\_metric](#module\_aws\_sns\_subscription\_lambda\_metric) | ../../modules/aws/sns/subscription | n/a |
| <a name="module_aws_sns_subscription_lambda_metric_us_east_1"></a> [aws\_sns\_subscription\_lambda\_metric\_us\_east\_1](#module\_aws\_sns\_subscription\_lambda\_metric\_us\_east\_1) | ../../modules/aws/sns/subscription | n/a |
| <a name="module_aws_sns_subscription_lambda_ses"></a> [aws\_sns\_subscription\_lambda\_ses](#module\_aws\_sns\_subscription\_lambda\_ses) | ../../modules/aws/sns/subscription | n/a |
| <a name="module_aws_sns_subscription_lambda_ses_us_east_1"></a> [aws\_sns\_subscription\_lambda\_ses\_us\_east\_1](#module\_aws\_sns\_subscription\_lambda\_ses\_us\_east\_1) | ../../modules/aws/sns/subscription | n/a |
| <a name="module_aws_sns_subscription_lambda_step_functions_log"></a> [aws\_sns\_subscription\_lambda\_step\_functions\_log](#module\_aws\_sns\_subscription\_lambda\_step\_functions\_log) | ../../modules/aws/sns/subscription | n/a |
| <a name="module_aws_synthetics_canary"></a> [aws\_synthetics\_canary](#module\_aws\_synthetics\_canary) | ../../modules/aws/synthetics_canary | n/a |
| <a name="module_dynamodb_table_monitor_log"></a> [dynamodb\_table\_monitor\_log](#module\_dynamodb\_table\_monitor\_log) | terraform-aws-modules/dynamodb-table/aws | 5.5.0 |
| <a name="module_eventbridge_batch"></a> [eventbridge\_batch](#module\_eventbridge\_batch) | ../../modules/aws/eventbridge/batch | n/a |
| <a name="module_eventbridge_ec2"></a> [eventbridge\_ec2](#module\_eventbridge\_ec2) | ../../modules/aws/eventbridge/ec2 | n/a |
| <a name="module_eventbridge_ecs_scheduled_task"></a> [eventbridge\_ecs\_scheduled\_task](#module\_eventbridge\_ecs\_scheduled\_task) | ../../modules/aws/eventbridge/ecs_scheduled_task | n/a |
| <a name="module_eventbridge_ecs_service"></a> [eventbridge\_ecs\_service](#module\_eventbridge\_ecs\_service) | ../../modules/aws/eventbridge/ecs_service | n/a |
| <a name="module_eventbridge_rds_cluster"></a> [eventbridge\_rds\_cluster](#module\_eventbridge\_rds\_cluster) | ../../modules/aws/eventbridge/rds_cluster | n/a |
| <a name="module_eventbridge_redshift"></a> [eventbridge\_redshift](#module\_eventbridge\_redshift) | ../../modules/aws/eventbridge/redshift | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | terraform-aws-modules/kms/aws | 4.2.0 |
| <a name="module_lambda_function_application_errors"></a> [lambda\_function\_application\_errors](#module\_lambda\_function\_application\_errors) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_lambda_function_cloudwatch_event_ec2"></a> [lambda\_function\_cloudwatch\_event\_ec2](#module\_lambda\_function\_cloudwatch\_event\_ec2) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_lambda_function_postgresql_slowquery"></a> [lambda\_function\_postgresql\_slowquery](#module\_lambda\_function\_postgresql\_slowquery) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_lambda_vpc"></a> [lambda\_vpc](#module\_lambda\_vpc) | terraform-aws-modules/vpc/aws | 6.6.1 |
| <a name="module_log_delivery_application"></a> [log\_delivery\_application](#module\_log\_delivery\_application) | ../../modules/aws/cloudwatch/delivery | n/a |
| <a name="module_log_delivery_application_us_east_1"></a> [log\_delivery\_application\_us\_east\_1](#module\_log\_delivery\_application\_us\_east\_1) | ../../modules/aws/cloudwatch/delivery | n/a |
| <a name="module_s3_application_log"></a> [s3\_application\_log](#module\_s3\_application\_log) | terraform-aws-modules/s3-bucket/aws | 5.14.1 |
| <a name="module_s3_application_log_notification_cloudfront"></a> [s3\_application\_log\_notification\_cloudfront](#module\_s3\_application\_log\_notification\_cloudfront) | terraform-aws-modules/s3-bucket/aws//modules/notification | 5.14.1 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_scheduler_schedule.application_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.postgresql_slowquery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/canonical_user_id) | data source |
| [aws_cloudfront_log_delivery_canonical_user_id.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudfront_log_delivery_canonical_user_id) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_athena"></a> [athena](#input\_athena) | Athena resources on AWS | `any` | n/a | yes |
| <a name="input_cloudwatch_event_ec2"></a> [cloudwatch\_event\_ec2](#input\_cloudwatch\_event\_ec2) | CloudWatch event(EC2) resources on AWS | `any` | n/a | yes |
| <a name="input_cloudwatch_log_group"></a> [cloudwatch\_log\_group](#input\_cloudwatch\_log\_group) | Common CloudWatch Log Group configuration for all services.<br/><br/>Priority order (higher priority overrides lower):<br/>1. var.cloudwatch\_log\_group.override.<service\_name>.retention\_in\_days (highest priority)<br/>2. var.cloudwatch\_log\_group.retention\_in\_days (lowest priority - common default)<br/><br/>Example:<br/>  cloudwatch\_log\_group = {<br/>    retention\_in\_days = 14  # Default for all services<br/>    override = {<br/>      cloudwatch\_event\_ec2 = {<br/>        retention\_in\_days = 7  # Override for EC2 events<br/>      }<br/>      metric\_log\_postgresql\_slowquery = {<br/>        retention\_in\_days = 30  # Override for PostgreSQL slow query<br/>      }<br/>    }<br/>  } | <pre>object({<br/>    retention_in_days = number<br/>    override = optional(object({<br/>      cloudwatch_event_ec2 = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      common_lambda_log = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      common_lambda_metric = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      common_lambda_ses = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      common_lambda_step_functions = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      common_lambda_step_functions_us_east_1 = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      common_lambda_vpc_flow_log = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      metric_log_application = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>      metric_log_postgresql_slowquery = optional(object({<br/>        retention_in_days = optional(number)<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_common_lambda"></a> [common\_lambda](#input\_common\_lambda) | n/a | `any` | n/a | yes |
| <a name="input_common_log"></a> [common\_log](#input\_common\_log) | n/a | `any` | n/a | yes |
| <a name="input_delivery_log"></a> [delivery\_log](#input\_delivery\_log) | n/a | `any` | n/a | yes |
| <a name="input_delivery_log_us_east_1"></a> [delivery\_log\_us\_east\_1](#input\_delivery\_log\_us\_east\_1) | n/a | `any` | n/a | yes |
| <a name="input_eventbridge"></a> [eventbridge](#input\_eventbridge) | EventBridge resources on AWS | `any` | n/a | yes |
| <a name="input_kms"></a> [kms](#input\_kms) | n/a | `any` | n/a | yes |
| <a name="input_metric_log_application"></a> [metric\_log\_application](#input\_metric\_log\_application) | CloudWatch Logs (Application) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_log_application_report"></a> [metric\_log\_application\_report](#input\_metric\_log\_application\_report) | CloudWatch Logs (Application) errors report resources on AWS | `any` | n/a | yes |
| <a name="input_metric_log_mysql_slowquery"></a> [metric\_log\_mysql\_slowquery](#input\_metric\_log\_mysql\_slowquery) | CloudWatch Logs (MySQL slow query) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_log_postgresql"></a> [metric\_log\_postgresql](#input\_metric\_log\_postgresql) | CloudWatch Logs (PostgreSQL) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_log_postgresql_slowquery"></a> [metric\_log\_postgresql\_slowquery](#input\_metric\_log\_postgresql\_slowquery) | CloudWatch Logs (PostgreSQL slow query) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_log_postgresql_slowquery_report"></a> [metric\_log\_postgresql\_slowquery\_report](#input\_metric\_log\_postgresql\_slowquery\_report) | CloudWatch Logs (PostgreSQL slow query) report resources on AWS | `any` | n/a | yes |
| <a name="input_metric_log_step_functions"></a> [metric\_log\_step\_functions](#input\_metric\_log\_step\_functions) | CloudWatch Logs (Step Functions) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_log_waf"></a> [metric\_log\_waf](#input\_metric\_log\_waf) | CloudWatch Logs (WAF) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_log_waf_us_east_1"></a> [metric\_log\_waf\_us\_east\_1](#input\_metric\_log\_waf\_us\_east\_1) | CloudWatch Logs (WAF) resources on AWS in us-east-1 | `any` | n/a | yes |
| <a name="input_metric_resource_api_gateway"></a> [metric\_resource\_api\_gateway](#input\_metric\_resource\_api\_gateway) | CloudWatch metric resource(API Gateway) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_cloudfront"></a> [metric\_resource\_cloudfront](#input\_metric\_resource\_cloudfront) | CloudWatch metric resource(CloudFront) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_ec2"></a> [metric\_resource\_ec2](#input\_metric\_resource\_ec2) | CloudWatch metric resource(EC2) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_ecs_container_insights"></a> [metric\_resource\_ecs\_container\_insights](#input\_metric\_resource\_ecs\_container\_insights) | CloudWatch metric resource(ECS/ContainerInsights) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_elasticache"></a> [metric\_resource\_elasticache](#input\_metric\_resource\_elasticache) | CloudWatch event(ElastiCache) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_elb"></a> [metric\_resource\_elb](#input\_metric\_resource\_elb) | CloudWatch metric resource(ELB - ALB/NLB) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_eventbridge_scheduler"></a> [metric\_resource\_eventbridge\_scheduler](#input\_metric\_resource\_eventbridge\_scheduler) | CloudWatch event(EventBridge Scheduler) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_lambda"></a> [metric\_resource\_lambda](#input\_metric\_resource\_lambda) | CloudWatch event(Lambda) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_nat_gateway"></a> [metric\_resource\_nat\_gateway](#input\_metric\_resource\_nat\_gateway) | CloudWatch metric resource(NAT Gateway) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_rds_cluster"></a> [metric\_resource\_rds\_cluster](#input\_metric\_resource\_rds\_cluster) | CloudWatch metric resource(RDS) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_redshift"></a> [metric\_resource\_redshift](#input\_metric\_resource\_redshift) | CloudWatch event(Redshift) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_ses"></a> [metric\_resource\_ses](#input\_metric\_resource\_ses) | CloudWatch event(SES) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_sns"></a> [metric\_resource\_sns](#input\_metric\_resource\_sns) | CloudWatch event(SNS) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_resource_sqs"></a> [metric\_resource\_sqs](#input\_metric\_resource\_sqs) | CloudWatch event(SQS) resources on AWS | `any` | n/a | yes |
| <a name="input_metric_synthetics_canary"></a> [metric\_synthetics\_canary](#input\_metric\_synthetics\_canary) | Synthetics canary resources on AWS. Map of function name to configuration (e.g., heartbeat, linkcheck) | `any` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | n/a | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | Region configuration for multi-region deployment | <pre>object({<br/>    global  = string<br/>    primary = string<br/>    targets = list(string)<br/>  })</pre> | n/a | yes |
| <a name="input_report_csp"></a> [report\_csp](#input\_report\_csp) | API Gateway resources on AWS | `any` | n/a | yes |
| <a name="input_slack"></a> [slack](#input\_slack) | Common Slack configuration for all Lambda functions.<br/><br/>Priority order (higher priority overrides lower):<br/>1. var.slack.override.<function\_name> (highest priority)<br/>2. var.slack (lowest priority - common defaults)<br/><br/>Example:<br/>  slack = {<br/>    oauth\_access\_token = "xoxb-common-token"<br/>    channel\_id         = "C-common-channel"<br/>    override = {<br/>      common\_lambda\_log = {<br/>        channel\_id = "C-log-specific-channel"<br/>      }<br/>    }<br/>  } | <pre>object({<br/>    oauth_access_token = string<br/>    channel_id         = string<br/>    override = optional(object({<br/>      apigateway_report_csp = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      cloudwatch_event_ec2 = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      common_lambda_log = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      common_lambda_metric = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      common_lambda_ses = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      common_lambda_step_functions = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      metric_log_application = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>      metric_log_postgresql_slowquery = optional(object({<br/>        oauth_access_token = optional(string)<br/>        channel_id         = optional(string)<br/>      }))<br/>    }))<br/>  })</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(any)` | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_report_csp_endpoint"></a> [report\_csp\_endpoint](#output\_report\_csp\_endpoint) | Endpoint to report CSP. method is POST. |
<!-- END_TF_DOCS -->
