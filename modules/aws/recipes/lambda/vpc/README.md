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
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_route_table_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input\_aws\_iam\_policy) | (Required) The resource of aws\_iam\_policy. | <pre>object(<br>    {<br>      # Description of the IAM policy.<br>      description = string<br>      # The name of the policy. If omitted, Terraform will assign a random, unique name.<br>      name = string<br>      # Path in which to create the policy. See IAM Identifiers for more information.<br>      path = string<br>      # The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.<br>      policy = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Required) The resource of aws\_iam\_role. | <pre>object(<br>    {<br>      # Policy that grants an entity permission to assume the role.<br>      assume_role_policy = string<br>      # Description of the role.<br>      description = string<br>      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_route_table_association"></a> [aws\_route\_table\_association](#input\_aws\_route\_table\_association) | (Required) Provides a resource to create an association between a route table and a subnet or a route table and an internet gateway or virtual private gateway. | <pre>object({<br>    # The ID of the routing table to associate with.<br>    route_table_id = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_security_group"></a> [aws\_security\_group](#input\_aws\_security\_group) | (Required) Provides a security group resource. | <pre>object(<br>    {<br>      # The name of the security group. If omitted, Terraform will assign a random, unique name.<br>      name = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_subnet"></a> [aws\_subnet](#input\_aws\_subnet) | (Required) Provides an VPC subnet resource. | <pre>list(object({<br>    # The AZ for the subnet.<br>    availability_zone = string<br>    # The CIDR block for the subnet.<br>    cidr_block = string<br>    # Specify true to indicate that instances launched into the subnet should be assigned a public IP address. Default is false.<br>    map_public_ip_on_launch = bool<br>    # The Amazon Resource Name (ARN) of the Outpost.<br>    outpost_arn = string<br>    # The VPC ID.<br>    vpc_id = string<br>    }<br>    )<br>  )</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The Amazon Resource Name (ARN) specifying the role. |
| <a name="output_role_id"></a> [role\_id](#output\_role\_id) | The name of the role. |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the role. |
| <a name="output_securty_group_id"></a> [securty\_group\_id](#output\_securty\_group\_id) | The ID of the security group |
<!-- END_TF_DOCS -->
