<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_ebs_encryption_by_default.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_encryption_by_default) | resource |
| [aws_ebs_snapshot_block_public_access.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_snapshot_block_public_access) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of EBS. Defaults true. | `bool` | `true` | no |
| <a name="input_is_enabled_ebs_encryption_by_default"></a> [is\_enabled\_ebs\_encryption\_by\_default](#input\_is\_enabled\_ebs\_encryption\_by\_default) | (Optional) A boolean flag to enable/disable default EBS encryption at the account level. Defaults false. | `bool` | `true` | no |
| <a name="input_is_enabled_ebs_public_snapshot_block_access"></a> [is\_enabled\_ebs\_public\_snapshot\_block\_access](#input\_is\_enabled\_ebs\_public\_snapshot\_block\_access) | (Optional) A boolean flag to enable/disable blocking public access to EBS snapshots. Defaults false. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region for EBS resources. | `string` | `null` | no |
| <a name="input_state"></a> [state](#input\_state) | (Optional) The desired state of the EBS snapshot block public access settings. Valid values are: 'block-all-sharing', 'unblock'. Defaults to 'block-all-sharing'. | `string` | `"block-all-sharing"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
