<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0, < 7.0.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | >= 3.3.0, < 3.4.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_null"></a> [null](#provider\_null) | >= 3.3.0, < 3.4.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [null_resource.this](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Compute Optimizer. Defaults true. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Accepted for a uniform module interface; this module manages only global resources (account-level Compute Optimizer enrollment via the AWS CLI), so the value is not used. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
