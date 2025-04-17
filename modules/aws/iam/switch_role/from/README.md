<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_group_policy_attachment.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_group_policy_attachment) | resource |
| [aws_iam_policy.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input\_aws\_iam\_policy) | (Optional) Provides an IAM policy. | <pre>object(<br>    {<br>      # Description of the IAM policy.<br>      description = optional(string)<br>      # The name of the policy. If omitted, Terraform will assign a random, unique name.<br>      name = string<br>      # Path in which to create the policy. See IAM Identifiers for more information.<br>      path = optional(string)<br>      # The policy document. This is a JSON formatted string. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.<br>      statement = list(any)<br>    }<br>  )</pre> | `null` | no |
| <a name="input_group"></a> [group](#input\_group) | (Required) Specify the group name to which the IAM policy is attached. | `string` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable Trusted Advisor. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Prefix of policy name . | `string` | `""` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value mapping of tags for the IAM role | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
