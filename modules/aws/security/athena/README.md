<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.3.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |
| <a name="provider_null"></a> [null](#provider\_null) | ~> 3.3.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [null_resource.athena_primary_workgroup_encryptionoption](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Athena. Defaults true. | `bool` | `true` | no |
| <a name="input_output_location"></a> [output\_location](#input\_output\_location) | (Optional) The location in Amazon S3 where your query results are stored, such as s3://path/to/query/bucket/. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region for Athena resources. | `string` | `null` | no |
| <a name="input_workgroup"></a> [workgroup](#input\_workgroup) | (Option) Name of the WorkGroup(primary). | `string` | `"primary"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
