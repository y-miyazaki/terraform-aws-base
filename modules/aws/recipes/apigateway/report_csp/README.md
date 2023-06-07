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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_lambda_create_lambda_report_csp"></a> [lambda\_create\_lambda\_report\_csp](#module\_lambda\_create\_lambda\_report\_csp) | ../../lambda/create | n/a |
| <a name="module_lambda_permission_lambda_report_csp"></a> [lambda\_permission\_lambda\_report\_csp](#module\_lambda\_permission\_lambda\_report\_csp) | ../../lambda/permission | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_method.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_resource.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_settings"></a> [access\_log\_settings](#input\_access\_log\_settings) | (Optional) | `map(any)` | `{}` | no |
| <a name="input_aws_api_gateway_rest_api_execution_arn"></a> [aws\_api\_gateway\_rest\_api\_execution\_arn](#input\_aws\_api\_gateway\_rest\_api\_execution\_arn) | (Required) Execution ARN part to be used in lambda\_permission's source\_arn when allowing API Gateway to invoke a Lambda function. | `string` | n/a | yes |
| <a name="input_aws_api_gateway_rest_api_id"></a> [aws\_api\_gateway\_rest\_api\_id](#input\_aws\_api\_gateway\_rest\_api\_id) | (Required) ID of the REST API. | `string` | n/a | yes |
| <a name="input_aws_api_gateway_rest_api_root_resource_id"></a> [aws\_api\_gateway\_rest\_api\_root\_resource\_id](#input\_aws\_api\_gateway\_rest\_api\_root\_resource\_id) | (Required) Resource ID of the REST API's root. | `string` | n/a | yes |
| <a name="input_lambda_function_aws_cloudwatch_log_group"></a> [lambda\_function\_aws\_cloudwatch\_log\_group](#input\_lambda\_function\_aws\_cloudwatch\_log\_group) | (Optional) The aws\_cloudwatch\_log\_group. | <pre>object(<br>    {<br>      # Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.<br>      retention_in_days = number<br>      # The ARN of the KMS Key to use when encrypting log data. Please note, after the AWS KMS CMK is disassociated from the log group, AWS CloudWatch Logs stops encrypting newly ingested data for the log group. All previously ingested data remains encrypted, and AWS CloudWatch Logs requires permissions for the CMK whenever the encrypted data is requested.<br>      kms_key_id = string<br>    }<br>  )</pre> | <pre>{<br>  "kms_key_id": null,<br>  "retention_in_days": 14<br>}</pre> | no |
| <a name="input_lambda_function_environment"></a> [lambda\_function\_environment](#input\_lambda\_function\_environment) | (Optional) Configuration block. | `map(string)` | `{}` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Name prefix of all resources. | `string` | `""` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | (Required) IAM Role arn used by Lambda. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags for the workgroup. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(any)` | `null` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | (Optional) aws\_lambda\_function Configuration block. | `list(any)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Outputs the Endpoint of the API. |
<!-- END_TF_DOCS -->