# CloudWatch Log Delivery Module

## Overview
This module creates CloudWatch Logs subscription filters and Kinesis Firehose delivery streams for delivering logs to S3.

## Features
- CloudWatch Logs subscription filters with configurable filter patterns
- Kinesis Firehose delivery streams with S3 destination
- Optional Lambda processing for log transformation
- Optional server-side encryption with KMS
- Automatic name transformation for log groups

## Usage

### Basic Example (Manual Log Group Specification)
```terraform
module "log_delivery" {
  source = "../../modules/aws/cloudwatch/delivery"

  is_enabled              = true
  name_prefix             = "example-"
  create_auto_log_group_names = false
  log_group_names = [
    "/aws/lambda/my-function",
    "/aws/rds/cluster/my-db/slowquery"
  ]

  s3_bucket_arn = "arn:aws:s3:::my-log-bucket"

  aws_kinesis_firehose_delivery_stream = {
    buffering_size     = 5
    buffering_interval = 60
    prefix             = "Log/"
    compression_format = "GZIP"
    server_side_encryption = {
      enabled  = true
      key_type = "AWS_OWNED_CMK"
    }
  }

  aws_iam_role_cloudwatch_logs = {
    name = "cloudwatch-logs-role"
  }

  aws_iam_policy_cloudwatch_logs = {
    name = "cloudwatch-logs-policy"
  }

  aws_iam_role_kinesis_firehose = {
    name = "kinesis-firehose-role"
  }

  aws_iam_policy_kinesis_firehose = {
    name = "kinesis-firehose-policy"
  }

  account_id = "123456789012"
  region     = "ap-northeast-1"

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

### Auto-Discovery of Log Groups
```terraform
module "log_delivery_auto" {
  source = "../../modules/aws/cloudwatch/delivery"

  is_enabled              = true
  name_prefix             = "example-"
  create_auto_log_group_names = true

  # Optional: Include only log groups matching these patterns
  auto_log_group_names_include_list = [
    "/aws/lambda/",
    "/aws/rds/"
  ]

  # Optional: Exclude log groups matching these patterns
  auto_log_group_names_exclude_list = [
    "/aws/lambda/test-",
    "/aws/rds/audit"
  ]

  s3_bucket_arn = "arn:aws:s3:::my-log-bucket"

  aws_kinesis_firehose_delivery_stream = {
    buffering_size     = 5
    buffering_interval = 60
    prefix             = "Log/"
    compression_format = "GZIP"
    server_side_encryption = {
      enabled  = true
      key_type = "AWS_OWNED_CMK"
    }
  }

  aws_iam_role_cloudwatch_logs = {
    name = "cloudwatch-logs-role"
  }

  aws_iam_policy_cloudwatch_logs = {
    name = "cloudwatch-logs-policy"
  }

  aws_iam_role_kinesis_firehose = {
    name = "kinesis-firehose-role"
  }

  aws_iam_policy_kinesis_firehose = {
    name = "kinesis-firehose-policy"
  }

  account_id = "123456789012"
  region     = "ap-northeast-1"

  tags = {
    Environment = "production"
    Terraform   = "true"
  }
}
```

### With Lambda Processing
```terraform
module "log_delivery_with_processing" {
  source = "../../modules/aws/cloudwatch/delivery"

  is_enabled     = true
  name_prefix    = "example-"
  log_group_names = ["/aws/lambda/my-function"]

  s3_bucket_arn        = "arn:aws:s3:::my-log-bucket"
  lambda_processor_arn = "arn:aws:lambda:ap-northeast-1:123456789012:function:log-processor"

  aws_kinesis_firehose_delivery_stream = {
    buffering_size                  = 5
    buffering_interval              = 60
    lambda_buffer_size_mb           = "2"
    lambda_buffer_interval_seconds  = 900
  }

  # ... other required variables
}
```

### With KMS Encryption
```terraform
module "log_delivery_encrypted" {
  source = "../../modules/aws/cloudwatch/delivery"

  is_enabled     = true
  name_prefix    = "example-"
  log_group_names = ["/aws/lambda/my-function"]

  s3_bucket_arn = "arn:aws:s3:::my-log-bucket"
  kms_key_arn   = "arn:aws:kms:ap-northeast-1:123456789012:key/12345678-1234-1234-1234-123456789012"

  aws_kinesis_firehose_delivery_stream = {
    server_side_encryption = {
      enabled  = true
      key_type = "CUSTOMER_MANAGED_CMK"
    }
  }

  # ... other required variables
}
```

## Requirements

| Name      | Version |
| --------- | ------- |
| terraform | >= 1.0  |
| aws       | >= 4.0  |

## Providers

| Name | Version |
| ---- | ------- |
| aws  | >= 4.0  |

## Modules

| Name                        | Source                    | Version |
| --------------------------- | ------------------------- | ------- |
| aws_cloudwatch_subscription | ../subscription           | n/a     |
| aws_kinesis_firehose_s3     | ../../kinesis/firehose/s3 | n/a     |

## Resources

No direct resources are created by this module. All resources are managed by sub-modules.

## Inputs

| Name                                 | Description                                                                                                                                                                                     | Type           | Default    | Required |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------- | ---------- | :------: |
| account_id                           | AWS account ID.                                                                                                                                                                                 | `string`       | n/a        |   yes    |
| aws_iam_policy_cloudwatch_logs       | IAM policy configuration for CloudWatch Logs.                                                                                                                                                   | `any`          | n/a        |   yes    |
| aws_iam_policy_kinesis_firehose      | IAM policy configuration for Kinesis Firehose.                                                                                                                                                  | `any`          | n/a        |   yes    |
| aws_iam_role_cloudwatch_logs         | IAM role configuration for CloudWatch Logs.                                                                                                                                                     | `any`          | n/a        |   yes    |
| aws_iam_role_kinesis_firehose        | IAM role configuration for Kinesis Firehose.                                                                                                                                                    | `any`          | n/a        |   yes    |
| aws_kinesis_firehose_delivery_stream | Configuration for Kinesis Firehose delivery stream.                                                                                                                                             | `any`          | n/a        |   yes    |
| name_prefix                          | Name prefix for all resources.                                                                                                                                                                  | `string`       | n/a        |   yes    |
| region                               | AWS region.                                                                                                                                                                                     | `string`       | n/a        |   yes    |
| s3_bucket_arn                        | ARN of the S3 bucket where logs will be delivered.                                                                                                                                              | `string`       | n/a        |   yes    |
| auto_log_group_names_exclude_list    | If create_auto_log_group_names is set to true, a list of log group name will be automatically registered, but at that time, specify the log group name you want to exclude using partial match. | `list(string)` | `[]`       |    no    |
| auto_log_group_names_include_list    | If create_auto_log_group_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included.                                 | `list(string)` | `[]`       |    no    |
| create_auto_log_group_names          | Builds a list of log group name to automatically set log_group_names. If this is true, the log_group_names setting will be ignored.                                                             | `bool`         | `false`    |    no    |
| distribution                         | Distribution method for the subscription filter.                                                                                                                                                | `string`       | `"Random"` |    no    |
| filter_pattern                       | Filter pattern for the CloudWatch Logs subscription filter.                                                                                                                                     | `string`       | `""`       |    no    |
| is_enabled                           | Enable or disable the log delivery resources.                                                                                                                                                   | `bool`         | `true`     |    no    |
| kms_key_arn                          | ARN of the KMS key for server-side encryption. Required if encryption is enabled with CUSTOMER_MANAGED_CMK.                                                                                     | `string`       | `null`     |    no    |
| lambda_processor_arn                 | ARN of the Lambda function for processing logs in Kinesis Firehose. If null, processing is disabled.                                                                                            | `string`       | `null`     |    no    |
| log_group_names                      | If create_auto_log_group_names is set to false, List of CloudWatch Log Group names to subscribe.                                                                                                | `list(string)` | `[]`       |    no    |
| tags                                 | A mapping of tags to assign to the resources.                                                                                                                                                   | `map(any)`     | `{}`       |    no    |

## Outputs

| Name                                   | Description                                        |
| -------------------------------------- | -------------------------------------------------- |
| cloudwatch_subscription_filter_names   | Names of the CloudWatch Logs subscription filters. |
| iam_role_cloudwatch_logs_arn           | ARN of the IAM role for CloudWatch Logs.           |
| iam_role_kinesis_firehose_arn          | ARN of the IAM role for Kinesis Firehose.          |
| kinesis_firehose_delivery_stream_arns  | ARNs of the Kinesis Firehose delivery streams.     |
| kinesis_firehose_delivery_stream_names | Names of the Kinesis Firehose delivery streams.    |

## Notes
- **Auto-Discovery**: Set `create_auto_log_group_names = true` to automatically discover all log groups in the region
  - Use `auto_log_group_names_include_list` to filter by patterns (partial match)
  - Use `auto_log_group_names_exclude_list` to exclude specific patterns (partial match)
  - If both filters are specified, include filter is applied first, then exclude filter
  - **Default Exclusions**: The following patterns are always excluded to prevent log loops:
    - `kinesis-data-firehose-cloudwatch-logs-processor`
- Log group names are automatically transformed to valid resource names by replacing "/" with "-"
- Kinesis Firehose delivery stream names are truncated to 63 characters due to AWS limitations
- Lambda processing is optional and can be enabled by providing a Lambda ARN
- Server-side encryption can be configured with AWS-owned or customer-managed KMS keys

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.14.1 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_aws_cloudwatch_subscription"></a> [aws\_cloudwatch\_subscription](#module\_aws\_cloudwatch\_subscription) | ../subscription | n/a |
| <a name="module_aws_kinesis_firehose_s3"></a> [aws\_kinesis\_firehose\_s3](#module\_aws\_kinesis\_firehose\_s3) | ../../kinesis/firehose/s3 | n/a |
| <a name="module_filter"></a> [filter](#module\_filter) | ../../_internal/auto_discovery_filter | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_groups.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/cloudwatch_log_groups) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) AWS account ID. | `string` | n/a | yes |
| <a name="input_auto_log_group_names_exclude_list"></a> [auto\_log\_group\_names\_exclude\_list](#input\_auto\_log\_group\_names\_exclude\_list) | (Optional) If create\_auto\_log\_group\_names is set to true, a list of log group name will be automatically registered, but at that time, specify the log group name you want to exclude using partial match. | `list(string)` | `[]` | no |
| <a name="input_auto_log_group_names_include_list"></a> [auto\_log\_group\_names\_include\_list](#input\_auto\_log\_group\_names\_include\_list) | (Optional) If create\_auto\_log\_group\_names is set to true and this list is not empty, only log group names matching any of these patterns (partial match) will be included. | `list(string)` | `[]` | no |
| <a name="input_aws_iam_policy_cloudwatch_logs"></a> [aws\_iam\_policy\_cloudwatch\_logs](#input\_aws\_iam\_policy\_cloudwatch\_logs) | (Required) IAM policy configuration for CloudWatch Logs. | `any` | n/a | yes |
| <a name="input_aws_iam_policy_kinesis_firehose"></a> [aws\_iam\_policy\_kinesis\_firehose](#input\_aws\_iam\_policy\_kinesis\_firehose) | (Required) IAM policy configuration for Kinesis Firehose. | `any` | n/a | yes |
| <a name="input_aws_iam_role_cloudwatch_logs"></a> [aws\_iam\_role\_cloudwatch\_logs](#input\_aws\_iam\_role\_cloudwatch\_logs) | (Required) IAM role configuration for CloudWatch Logs. | `any` | n/a | yes |
| <a name="input_aws_iam_role_kinesis_firehose"></a> [aws\_iam\_role\_kinesis\_firehose](#input\_aws\_iam\_role\_kinesis\_firehose) | (Required) IAM role configuration for Kinesis Firehose. | `any` | n/a | yes |
| <a name="input_aws_kinesis_firehose_delivery_stream"></a> [aws\_kinesis\_firehose\_delivery\_stream](#input\_aws\_kinesis\_firehose\_delivery\_stream) | (Required) Configuration for Kinesis Firehose delivery stream. | `any` | n/a | yes |
| <a name="input_create_auto_log_group_names"></a> [create\_auto\_log\_group\_names](#input\_create\_auto\_log\_group\_names) | (Optional) Builds a list of log group name to automatically set log\_group\_names. If this is true, the log\_group\_names setting will be ignored. | `bool` | `false` | no |
| <a name="input_distribution"></a> [distribution](#input\_distribution) | (Optional) Distribution method for the subscription filter. | `string` | `"Random"` | no |
| <a name="input_filter_pattern"></a> [filter\_pattern](#input\_filter\_pattern) | (Optional) Filter pattern for the CloudWatch Logs subscription filter. | `string` | `""` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Required) Enable or disable the log delivery resources. | `bool` | `true` | no |
| <a name="input_lambda_processor_arn"></a> [lambda\_processor\_arn](#input\_lambda\_processor\_arn) | (Optional) ARN of the Lambda function for processing logs in Kinesis Firehose. If null, processing is disabled. | `string` | `null` | no |
| <a name="input_log_group_names"></a> [log\_group\_names](#input\_log\_group\_names) | (Optional) If create\_auto\_log\_group\_names is set to false, List of CloudWatch Log Group names to subscribe. | `list(string)` | `[]` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Name prefix for all resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Required) AWS region. | `string` | n/a | yes |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | (Required) ARN of the S3 bucket where logs will be delivered. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resources. | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_iam_role_kinesis_firehose_arn"></a> [iam\_role\_kinesis\_firehose\_arn](#output\_iam\_role\_kinesis\_firehose\_arn) | ARN of the IAM role for Kinesis Firehose. |
| <a name="output_kinesis_firehose_delivery_stream_arns"></a> [kinesis\_firehose\_delivery\_stream\_arns](#output\_kinesis\_firehose\_delivery\_stream\_arns) | ARNs of the Kinesis Firehose delivery streams. |
<!-- END_TF_DOCS -->
