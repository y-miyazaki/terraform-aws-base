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
| [aws_resourcegroups_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/resourcegroups_group) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | (Optional) A description of the resource group. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The resource group's name. A resource group name can have a maximum of 127 characters, including letters, numbers, hyphens, dots, and underscores. The name cannot start with AWS or aws. | `string` | n/a | yes |
| <a name="input_resource_query"></a> [resource\_query](#input\_resource\_query) | (Required) A resource\_query block. Resource queries are documented below. | `any` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN assigned by AWS for this resource group. |
<!-- END_TF_DOCS -->
