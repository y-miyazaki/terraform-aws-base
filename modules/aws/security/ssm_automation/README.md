# SSM Automation Module

This module configures AWS Systems Manager (SSM) Automation settings for security compliance, specifically enabling CloudWatch logging for SSM Automation (SSM.6 control).

## Features

- Creates CloudWatch Log Group for SSM Automation logs
- Enables CloudWatch logging for SSM Automation executions
- Disables public sharing of SSM Automation documents
- Configurable log retention and encryption

## Usage

```hcl
module "ssm_automation" {
  source = "../../modules/aws/security/ssm_automation"

  is_enabled        = true
  log_group_name    = "/aws/ssm/automation/executeScript"
  retention_in_days = 14
  kms_key_id        = null
  tags              = var.tags
}
```

## Requirements

- Terraform >= 1.4
- AWS Provider >= 6.0

## Inputs

| Name              | Description                            | Type       | Default                               | Required |
| ----------------- | -------------------------------------- | ---------- | ------------------------------------- | :------: |
| is_enabled        | Enable/disable SSM Automation settings | `bool`     | `true`                                |    no    |
| log_group_name    | Name of the CloudWatch Log Group       | `string`   | `"/aws/ssm/automation/executeScript"` |    no    |
| retention_in_days | Log retention period in days           | `number`   | `14`                                  |    no    |
| kms_key_id        | KMS key ARN for log encryption         | `string`   | `null`                                |    no    |
| tags              | Resource tags                          | `map(any)` | `null`                                |    no    |

## Outputs

| Name           | Description                      |
| -------------- | -------------------------------- |
| log_group_name | Name of the CloudWatch Log Group |
| log_group_arn  | ARN of the CloudWatch Log Group  |

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.ssm_automation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_ssm_service_setting.automation_log_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_service_setting) | resource |
| [aws_ssm_service_setting.automation_log_group_name](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_service_setting) | resource |
| [aws_ssm_service_setting.automation_public_sharing_permission](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssm_service_setting) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_cloudwatch_log_group_kms_key_id"></a> [cloudwatch\_log\_group\_kms\_key\_id](#input\_cloudwatch\_log\_group\_kms\_key\_id) | (Optional) The ARN of the KMS Key to use when encrypting log data. Defaults to null. | `string` | `null` | no |
| <a name="input_cloudwatch_log_group_name"></a> [cloudwatch\_log\_group\_name](#input\_cloudwatch\_log\_group\_name) | (Optional) Name of the CloudWatch Log Group for SSM Automation. Defaults to '/aws/ssm/automation/executeScript'. | `string` | `"/aws/ssm/automation/executeScript"` | no |
| <a name="input_cloudwatch_log_group_retention_in_days"></a> [cloudwatch\_log\_group\_retention\_in\_days](#input\_cloudwatch\_log\_group\_retention\_in\_days) | (Optional) Specifies the number of days you want to retain log events in the specified log group. Defaults to 14. | `number` | `14` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of SSM Automation. Defaults true. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region for SSM Service Settings. Uses current region if not specified. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of the CloudWatch Log Group for SSM Automation. |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch Log Group for SSM Automation. |
<!-- END_TF_DOCS -->
