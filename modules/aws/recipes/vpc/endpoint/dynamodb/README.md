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
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_accept"></a> [auto\_accept](#input\_auto\_accept) | (Optional) Accept the VPC endpoint (the VPC endpoint and service need to be in the same AWS account). | `bool` | `true` | no |
| <a name="input_policy"></a> [policy](#input\_policy) | (Optional) A policy to attach to the endpoint that controls access to the service. Defaults to full access. All Gateway and some Interface endpoints support policies - see the relevant AWS documentation for more details. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide. | `string` | `null` | no |
| <a name="input_private_dns_enabled"></a> [private\_dns\_enabled](#input\_private\_dns\_enabled) | (Optional; AWS services and AWS Marketplace partner services only) Whether or not to associate a private hosted zone with the specified VPC. Applicable for endpoints of type Interface. Defaults to false. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | (Required) The region name, in the form com.amazonaws.region.service for AWS services. | `string` | n/a | yes |
| <a name="input_route_table_ids"></a> [route\_table\_ids](#input\_route\_table\_ids) | (Optional) One or more route table IDs. Applicable for endpoints of type Gateway. | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | (Required) The ID of the VPC in which the endpoint will be used. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dns_entry"></a> [dns\_entry](#output\_dns\_entry) | The DNS entries for the VPC Endpoint. Applicable for endpoints of type Interface. DNS blocks are documented below. |
| <a name="output_id"></a> [id](#output\_id) | The ID of the VPC endpoint. |
<!-- END_TF_DOCS -->
