<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~>3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [null_resource.athena_primary_workgroup_encryptionoption](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Athena. Defaults true. | `bool` | `true` | no |
| <a name="input_workgroup"></a> [workgroup](#input\_workgroup) | (Option) Name of the WorkGroup(primary). | `string` | `"primary"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
