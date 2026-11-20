<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0, < 7.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.0.0, < 7.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_api_gateway_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.kms](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | (Optional) KMS key ARN used to encrypt the CloudWatch Logs for API Gateway. When set, kms:Decrypt and kms:GenerateDataKey on the key are granted to the CloudWatch role. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Prefix for resource names. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to assign to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_cloudwatch_role_arn"></a> [cloudwatch\_role\_arn](#output\_cloudwatch\_role\_arn) | The ARN of the IAM role used by API Gateway for CloudWatch Logs. |
<!-- END_TF_DOCS -->
