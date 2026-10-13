<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.0.0, < 7.0.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.68.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_iam_policy.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.service_linked_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) AWS account ID of this (secondary) account. | `string` | n/a | yes |
| <a name="input_additional_policy_statements"></a> [additional\_policy\_statements](#input\_additional\_policy\_statements) | (Optional) Extra IAM policy statements attached to the role on top of AIDevOpsAgentAccessPolicy (e.g. read actions the managed policy lacks). Keep them least privilege. | <pre>list(object({<br/>    # (Required) IAM actions, e.g. ["lambda:GetFunction"].<br/>    actions = list(string)<br/>    # (Optional) Allow or Deny.<br/>    effect = optional(string, "Allow")<br/>    # (Required) Resource ARNs the statement applies to.<br/>    resources = list(string)<br/>    # (Required) Statement ID (alphanumeric, unique within the list).<br/>    sid = string<br/>  }))</pre> | `[]` | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Required) IAM role configuration. | <pre>object({<br/>    # (Optional) Description of the IAM role.<br/>    description = optional(string, "Cross-account role assumed by AWS DevOps Agent in the primary account to investigate this account.")<br/>    # (Required) Name of the IAM role. The primary account derives the role ARN from this name.<br/>    name = string<br/>    # (Optional) Path of the IAM role.<br/>    path = optional(string, "/")<br/>  })</pre> | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) Whether to create the secondary account role. | `bool` | `true` | no |
| <a name="input_primary"></a> [primary](#input\_primary) | (Required) Primary account and the Agent Space that is trusted. | <pre>object({<br/>    # (Required) AWS account ID that hosts the Agent Space.<br/>    account_id = string<br/>    # (Required) ARN of the Agent Space allowed to assume the role (no wildcard).<br/>    agent_space_arn = string<br/>  })</pre> | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Accepted for a uniform module interface; this module manages only global resources (IAM), so the value is not used. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to apply to resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_additional_policy_name"></a> [additional\_policy\_name](#output\_additional\_policy\_name) | Name of the additional IAM policy attached to the role (null when additional\_policy\_statements is empty). |
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | ARN of the cross-account role (null when disabled). |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | Name of the cross-account role (null when disabled). |
<!-- END_TF_DOCS -->
