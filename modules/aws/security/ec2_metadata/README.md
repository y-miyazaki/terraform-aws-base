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
| [aws_ec2_instance_metadata_defaults.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ec2_instance_metadata_defaults) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_http_endpoint"></a> [http\_endpoint](#input\_http\_endpoint) | (Optional) Whether the IMDS endpoint is enabled. Valid values: enabled, disabled, no-preference. Defaults to enabled. | `string` | `"enabled"` | no |
| <a name="input_http_put_response_hop_limit"></a> [http\_put\_response\_hop\_limit](#input\_http\_put\_response\_hop\_limit) | (Optional) The maximum number of hops that the metadata token can travel. Valid values: -1 (no-preference), 1-64. Defaults to 2. | `number` | `2` | no |
| <a name="input_http_tokens"></a> [http\_tokens](#input\_http\_tokens) | (Optional) Whether IMDSv2 is required. Valid values: required, optional, no-preference. Defaults to required. | `string` | `"required"` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable EC2 metadata defaults. Defaults true. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region for EC2 metadata resources. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
