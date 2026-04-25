<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.23.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_guardduty_detector.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_detector) | resource |
| [aws_guardduty_organization_admin_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_admin_account) | resource |
| [aws_guardduty_organization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration) | resource |
| [aws_guardduty_organization_configuration_feature.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/guardduty_organization_configuration_feature) | resource |
| [aws_guardduty_detector.existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/guardduty_detector) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_account_id"></a> [admin\_account\_id](#input\_admin\_account\_id) | AWS account ID to designate as the GuardDuty organization admin account | `string` | n/a | yes |
| <a name="input_auto_enable_organization_members"></a> [auto\_enable\_organization\_members](#input\_auto\_enable\_organization\_members) | Whether to auto-enable GuardDuty for new organization members | `string` | `"ALL"` | no |
| <a name="input_create_detector"></a> [create\_detector](#input\_create\_detector) | Whether to create a new GuardDuty detector. Set to true when no detector exists in the target region. | `bool` | `false` | no |
| <a name="input_features"></a> [features](#input\_features) | GuardDuty organization configuration features | <pre>map(object({<br/>    auto_enable = string<br/>    additional_configurations = optional(list(object({<br/>      name        = string<br/>      auto_enable = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether to enable GuardDuty organization configuration | `bool` | `false` | no |
| <a name="input_is_enabled_admin"></a> [is\_enabled\_admin](#input\_is\_enabled\_admin) | Whether to enable GuardDuty organization admin account designation | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to created resources | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_admin_account_id"></a> [admin\_account\_id](#output\_admin\_account\_id) | The account ID of the GuardDuty organization admin account |
| <a name="output_detector_id"></a> [detector\_id](#output\_detector\_id) | The ID of the GuardDuty detector |
| <a name="output_organization_configuration_feature_ids"></a> [organization\_configuration\_feature\_ids](#output\_organization\_configuration\_feature\_ids) | The IDs of the GuardDuty organization configuration features |
| <a name="output_organization_configuration_id"></a> [organization\_configuration\_id](#output\_organization\_configuration\_id) | The ID of the GuardDuty organization configuration |
<!-- END_TF_DOCS -->
