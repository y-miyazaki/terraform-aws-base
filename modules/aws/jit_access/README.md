<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.47.0 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_dynamodb_table_requests"></a> [dynamodb\_table\_requests](#module\_dynamodb\_table\_requests) | terraform-aws-modules/dynamodb-table/aws | 5.5.0 |
| <a name="module_lambda_jit_access"></a> [lambda\_jit\_access](#module\_lambda\_jit\_access) | terraform-aws-modules/lambda/aws | 8.8.0 |
| <a name="module_step_functions"></a> [step\_functions](#module\_step\_functions) | terraform-aws-modules/step-functions/aws | 5.1.0 |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_apigatewayv2_api.slack](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_api) | resource |
| [aws_apigatewayv2_integration.slack_handler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_integration) | resource |
| [aws_apigatewayv2_route.slack_commands](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_route.slack_interactions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_route.workflow_request](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_route) | resource |
| [aws_apigatewayv2_stage.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/apigatewayv2_stage) | resource |
| [aws_cloudwatch_metric_alarm.dlq_messages](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_iam_role.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.lambda](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.scheduler](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy.sfn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.lambda_vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_scheduler_schedule.cleanup](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_sqs_queue.dlq](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sqs_queue) | resource |
| [aws_ssm_parameter.approver_channel](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.profiles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.state_machine_arn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssm_parameter.user_mapping](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_parameter) | resource |
| [aws_ssoadmin_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cleanup_schedule_expression"></a> [cleanup\_schedule\_expression](#input\_cleanup\_schedule\_expression) | (Optional) EventBridge schedule expression for the cleanup checker. | `string` | `"rate(15 minutes)"` | no |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | (Optional) KMS key ARN for encrypting CloudWatch Logs and DynamoDB. | `string` | `null` | no |
| <a name="input_lambda_log_retention_days"></a> [lambda\_log\_retention\_days](#input\_lambda\_log\_retention\_days) | (Optional) CloudWatch Logs retention in days for Lambda functions. | `number` | `30` | no |
| <a name="input_lambda_memory_size"></a> [lambda\_memory\_size](#input\_lambda\_memory\_size) | (Optional) Memory size in MB for Lambda functions. | `number` | `128` | no |
| <a name="input_lambda_timeout"></a> [lambda\_timeout](#input\_lambda\_timeout) | (Optional) Timeout in seconds for Lambda functions. | `number` | `300` | no |
| <a name="input_lambda_zip_base_path"></a> [lambda\_zip\_base\_path](#input\_lambda\_zip\_base\_path) | (Required) Base path to Lambda zip files (e.g., ../../lambda/outputs). | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Prefix for all resource names. | `string` | n/a | yes |
| <a name="input_profiles"></a> [profiles](#input\_profiles) | (Required) Map of JIT access profiles. Key is the profile name. | <pre>map(object({<br/>    # (Required) AWS account ID for the permission set assignment.<br/>    account_id = string<br/>    # (Required) Permission Set ARN to assign.<br/>    permission_set_arn = string<br/>    # (Required) Maximum allowed duration in minutes.<br/>    max_duration_minutes = number<br/>    # (Required) List of Slack user IDs who can approve requests for this profile.<br/>    approvers = list(string)<br/>    # (Optional) Human-readable description of this profile.<br/>    description = optional(string, "")<br/>  }))</pre> | n/a | yes |
| <a name="input_slack"></a> [slack](#input\_slack) | (Required) Slack App credentials and configuration. | <pre>object({<br/>    # (Required) Slack signing secret for request verification.<br/>    signing_secret = string<br/>    # (Required) Slack bot OAuth token.<br/>    bot_token = string<br/>    # (Required) Slack channel ID for approval notifications.<br/>    approver_channel_id = string<br/>    # (Optional) Shared secret for authenticating Slack Workflow Builder webhook requests via x-workflow-secret header. When null, the /workflow/request endpoint is not created.<br/>    workflow_secret = optional(string)<br/>    # (Optional) Slack User ID → Identity Center User ID mapping. Required only for users whose Slack email does not match Identity Center UserName.<br/>    user_mappings = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_ssm_parameter_prefix"></a> [ssm\_parameter\_prefix](#input\_ssm\_parameter\_prefix) | (Optional) SSM Parameter Store prefix for JIT access configuration. | `string` | `"/jit-access"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | (Optional) VPC configuration for Lambda functions. Set to null to disable VPC. | <pre>object({<br/>    # (Required) List of subnet IDs for Lambda VPC configuration.<br/>    subnet_ids = list(string)<br/>    # (Required) List of security group IDs for Lambda VPC configuration.<br/>    security_group_ids = list(string)<br/>  })</pre> | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_api_gateway_endpoint"></a> [api\_gateway\_endpoint](#output\_api\_gateway\_endpoint) | The API Gateway endpoint URL for Slack webhook configuration |
| <a name="output_dlq_arn"></a> [dlq\_arn](#output\_dlq\_arn) | The ARN of the Dead Letter Queue for revoke failures |
| <a name="output_dlq_url"></a> [dlq\_url](#output\_dlq\_url) | The URL of the Dead Letter Queue |
| <a name="output_dynamodb_table_arn"></a> [dynamodb\_table\_arn](#output\_dynamodb\_table\_arn) | The ARN of the DynamoDB requests table |
| <a name="output_dynamodb_table_name"></a> [dynamodb\_table\_name](#output\_dynamodb\_table\_name) | The name of the DynamoDB requests table |
| <a name="output_lambda_function_arn"></a> [lambda\_function\_arn](#output\_lambda\_function\_arn) | The ARN of the JIT Access Lambda function |
| <a name="output_lambda_function_name"></a> [lambda\_function\_name](#output\_lambda\_function\_name) | The name of the JIT Access Lambda function |
| <a name="output_lambda_role_arn"></a> [lambda\_role\_arn](#output\_lambda\_role\_arn) | The ARN of the Lambda execution IAM role |
| <a name="output_state_machine_arn"></a> [state\_machine\_arn](#output\_state\_machine\_arn) | The ARN of the Step Functions state machine |
<!-- END_TF_DOCS -->
