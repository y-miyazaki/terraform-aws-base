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
| [aws_iam_instance_profile.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_instance_profile"></a> [aws\_iam\_instance\_profile](#input\_aws\_iam\_instance\_profile) | (Optional) Provides an IAM instance profile. | <pre>object(<br>    {<br>      # (Optional, Forces new resource) Name of the instance profile. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix. Can be a string of characters consisting of upper and lowercase alphanumeric characters and these special characters: _, +, =, ,, ., @, -. Spaces are not allowed.<br>      name = string<br>      # (Optional, default "/") Path to the instance profile. For more information about paths, see IAM Identifiers in the IAM User Guide. Can be a string of characters consisting of either a forward slash (/) by itself or a string that must begin and end with forward slashes. Can include any ASCII character from the ! (\u0021) through the DEL character (\u007F), including most punctuation characters, digits, and upper and lowercase letters.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "name": "ec2-profile",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) Provides an IAM role. | <pre>object(<br>    {<br>      # Description of the role.<br>      description = string<br>      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Role for EC2.",<br>  "name": "ec2-role",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value mapping of tags for the IAM role | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_name"></a> [name](#output\_name) | Name of the role. |
<!-- END_TF_DOCS -->
