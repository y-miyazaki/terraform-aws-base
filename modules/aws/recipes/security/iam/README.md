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
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.support_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_account_password_policy"></a> [aws\_iam\_account\_password\_policy](#input\_aws\_iam\_account\_password\_policy) | (Optional) The resource of aws\_iam\_account\_password\_policy. | <pre>object(<br>    {<br>      # Whether to allow users to change their own password<br>      allow_users_to_change_password = bool<br>      # Whether users are prevented from setting a new password after their password has expired (i.e. require administrator reset)<br>      hard_expiry = bool<br>      # The number of days that an user password is valid.<br>      max_password_age = number<br>      # Minimum length to require for user passwords.<br>      minimum_password_length = number<br>      # The number of previous passwords that users are prevented from reusing.<br>      password_reuse_prevention = number<br>      # Whether to require lowercase characters for user passwords.<br>      require_lowercase_characters = bool<br>      # Whether to require numbers for user passwords.<br>      require_numbers = bool<br>      # Whether to require symbols for user passwords.<br>      require_symbols = bool<br>      # Whether to require uppercase characters for user passwords.<br>      require_uppercase_characters = bool<br>    }<br>  )</pre> | <pre>{<br>  "allow_users_to_change_password": true,<br>  "hard_expiry": true,<br>  "max_password_age": 90,<br>  "minimum_password_length": 14,<br>  "password_reuse_prevention": 24,<br>  "require_lowercase_characters": true,<br>  "require_numbers": true,<br>  "require_symbols": true,<br>  "require_uppercase_characters": true<br>}</pre> | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) The resource of aws\_iam\_role. | <pre>object(<br>    {<br>      # (Optional) Description of the role.<br>      description = string<br>      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # (Optional) Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Role for IAM Role.",<br>  "name": "security-iam-role",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable IAM security. Defaults true. | `bool` | `true` | no |
| <a name="input_support_iam_role_principal_arns"></a> [support\_iam\_role\_principal\_arns](#input\_support\_iam\_role\_principal\_arns) | (Required) iam role principal arn. | `list(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_iam_role_id"></a> [iam\_role\_id](#output\_iam\_role\_id) | The id of IAM role. |
<!-- END_TF_DOCS -->
