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
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_route_table_association"></a> [aws\_route\_table\_association](#input\_aws\_route\_table\_association) | (Required) Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway. | <pre>object({<br>    # The ID of the routing table to associate with.<br>    route_table_id = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_subnet"></a> [aws\_subnet](#input\_aws\_subnet) | (Required) Provides an VPC subnet resource. | <pre>list(object({<br>    # The AZ for the subnet.<br>    availability_zone = string<br>    # The CIDR block for the subnet.<br>    cidr_block = string<br>    # Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.<br>    map_public_ip_on_launch = bool<br>    # The Amazon Resource Name (ARN) of the Outpost.<br>    outpost_arn = string<br>    # The VPC ID.<br>    vpc_id = string<br>    }<br>    )<br>  )</pre> | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required, Forces new resource) Creates a tag name beginning with the specified prefix. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The IDs of the subnet |
<!-- END_TF_DOCS -->
