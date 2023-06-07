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
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) AWS account ID for member account. | `string` | n/a | yes |
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input\_aws\_iam\_policy) | (Optional) Provides an IAM policy. | <pre>object(<br>    {<br>      # Description of the IAM policy.<br>      description = string<br>      # The name of the policy. If omitted, Terraform will assign a random, unique name.<br>      name = string<br>      # Path in which to create the poliwcy. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Policy for CloudWatch.",<br>  "name": "cloudwatch-policy",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) Provides an IAM role. | <pre>object(<br>    {<br>      # Description of the role.<br>      description = string<br>      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Role for CloudWatch.",<br>  "name": "cloudwatch-role",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | (Required) Specify the region. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_name"></a> [name](#output\_name) | Name of the role. |
<!-- END_TF_DOCS -->
