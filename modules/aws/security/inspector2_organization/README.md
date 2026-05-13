<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.22.1 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_inspector2_delegated_admin_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_delegated_admin_account) | resource |
| [aws_inspector2_enabler.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_enabler) | resource |
| [aws_inspector2_member_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_member_association) | resource |
| [aws_inspector2_organization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/inspector2_organization_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_configuration"></a> [configuration](#input\_configuration) | (Optional) Map of auto-enable configurations for new accounts. | <pre>object({<br/>    auto_enable_ec2             = bool<br/>    auto_enable_ecr             = bool<br/>    auto_enable_lambda          = bool<br/>    auto_enable_lambda_code     = bool<br/>    auto_enable_code_repository = bool<br/>  })</pre> | <pre>{<br/>  "auto_enable_code_repository": false,<br/>  "auto_enable_ec2": false,<br/>  "auto_enable_ecr": false,<br/>  "auto_enable_lambda": false,<br/>  "auto_enable_lambda_code": false<br/>}</pre> | no |
| <a name="input_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#input\_delegated\_admin\_account\_id) | (Optional) Account ID to designate as delegated admin for Inspector2. Leave empty to skip. | `string` | `""` | no |
| <a name="input_enabler"></a> [enabler](#input\_enabler) | (Optional) Map of enabler configurations for specified accounts and resource types. | <pre>map(object({<br/>    account_ids    = list(string)<br/>    resource_types = list(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) Module-level toggle. Default false to prevent accidental org-wide enablement. | `bool` | `true` | no |
| <a name="input_is_enabled_configuration"></a> [is\_enabled\_configuration](#input\_is\_enabled\_configuration) | (Optional) Enable organization-level configurations for auto-enabling new accounts. | `bool` | `false` | no |
| <a name="input_is_enabled_delegated_admin"></a> [is\_enabled\_delegated\_admin](#input\_is\_enabled\_delegated\_admin) | (Optional) Enable delegated admin account configuration for Inspector2. | `bool` | `false` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_delegated_admin_account_id"></a> [delegated\_admin\_account\_id](#output\_delegated\_admin\_account\_id) | The account ID of the delegated admin for Inspector2 |
| <a name="output_enabler_id"></a> [enabler\_id](#output\_enabler\_id) | The ID of the Inspector2 enabler |
| <a name="output_organization_configuration_id"></a> [organization\_configuration\_id](#output\_organization\_configuration\_id) | The ID of the Inspector2 organization configuration |
<!-- END_TF_DOCS -->
