<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_lambda_function.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) | resource |
| [aws_lambda_permission.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloudwatch_log_group"></a> [aws\_cloudwatch\_log\_group](#input\_aws\_cloudwatch\_log\_group) | (Optional) The aws\_cloudwatch\_log\_group. | <pre>object(<br>    {<br>      # Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.<br>      retention_in_days = number<br>      # The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.<br>      kms_key_id = string<br>    }<br>  )</pre> | <pre>{<br>  "kms_key_id": null,<br>  "retention_in_days": 14<br>}</pre> | no |
| <a name="input_aws_lambda_function"></a> [aws\_lambda\_function](#input\_aws\_lambda\_function) | (Required) The aws\_lambda\_function. | <pre>object(<br>    {<br>      # Unique name for your Lambda Function.<br>      function_name = string<br>      # Amazon Resource Name (ARN) of the function's execution role. The role provides the function's identity and access to AWS services and resources.<br>      role = string<br>      # Path to the function's deployment package within the local filesystem. Conflicts with image_uri, s3_bucket, s3_key, and s3_object_version.<br>      filename = string<br>      # S3 bucket location containing the function's deployment package. Conflicts with filename and image_uri. This bucket must reside in the same AWS region where you are creating the Lambda function.<br>      s3_bucket = string<br>      # S3 key of an object containing the function's deployment package. Conflicts with filename and image_uri.<br>      s3_key = string<br>      # Object version containing the function's deployment package. Conflicts with filename and image_uri.<br>      s3_object_version = string<br>      # Configuration block.<br>      dead_letter_config = list(any)<br>      # Function entrypoint in your code.<br>      handler = string<br>      # Description of what your Lambda Function does.<br>      description = string<br>      # List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function. See Lambda Layers<br>      layers = list(any)<br>      # Amount of memory in MB your Lambda Function can use at runtime. Defaults to 128. See Limits<br>      memory_size = number<br>      # Identifier of the function's runtime. See Runtimes for valid values.<br>      runtime = string<br>      # Amount of time your Lambda Function has to run in seconds. Defaults to 3. See Limits.<br>      timeout = number<br>      # Amount of reserved concurrent executions for this lambda function. A value of 0 disables lambda from being triggered and -1 removes any concurrency limitations. Defaults to Unreserved Concurrency Limits -1. See Managing Concurrency<br>      reserved_concurrent_executions = string<br>      # Whether to publish creation/change as new Lambda Function Version. Defaults to false.<br>      publish = bool<br>      # Configuration block.<br>      vpc_config = list(any)<br>      # Configuration block.<br>      environment = map(any)<br>      # Amazon Resource Name (ARN) of the AWS Key Management Service (KMS) key that is used to encrypt environment variables. If this configuration is not provided when environment variables are in use, AWS Lambda uses a default service key. If this configuration is provided when environment variables are not in use, the AWS Lambda API does not save this configuration and Terraform will show a perpetual difference of adding the key. To fix the perpetual difference, remove this configuration.<br>      kms_key_arn = string<br>      # Used to trigger updates. Must be set to a base64-encoded SHA256 hash of the package file specified with either filename or s3_key. The usual way to set this is filebase64sha256("file.zip") (Terraform 0.11.12 and later) or base64sha256(file("file.zip")) (Terraform 0.11.11 and earlier), where "file.zip" is the local filename of the lambda function source archive.<br>      source_code_hash = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_lambda_permission"></a> [aws\_lambda\_permission](#input\_aws\_lambda\_permission) | (Optional) The aws\_lambda\_permission. | <pre>object(<br>    {<br>      action             = string<br>      event_source_token = string<br>      # function_name       = string<br>      principal           = string<br>      qualifier           = string<br>      source_account      = string<br>      source_arn          = string<br>      statement_id        = string<br>      statement_id_prefix = string<br>    }<br>  )</pre> | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable Lambda. Defaults true. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) identifying your Lambda Function. |
| <a name="output_function_name"></a> [function\_name](#output\_function\_name) | Unique name for your Lambda Function. |
| <a name="output_invoke_arn"></a> [invoke\_arn](#output\_invoke\_arn) | ARN to be used for invoking Lambda Function from API Gateway - to be used in aws\_api\_gateway\_integration's uri. |
<!-- END_TF_DOCS -->
