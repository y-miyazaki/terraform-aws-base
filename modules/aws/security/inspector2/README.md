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
| [aws_inspector2_enabler.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_enabler) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable Inspector2 account configuration. Defaults true. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | AWS region where Inspector2 will be enabled | `string` | n/a | yes |
| <a name="input_resource_types"></a> [resource\_types](#input\_resource\_types) | (Required) Type of resources to scan. Valid values are EC2, ECR, LAMBDA, LAMBDA\_CODE, CODE\_REPOSITORY. | `list(string)` | <pre>[<br/>  "EC2",<br/>  "ECR",<br/>  "LAMBDA",<br/>  "LAMBDA_CODE"<br/>]</pre> | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The account ID where Inspector2 is enabled |
<!-- END_TF_DOCS -->
