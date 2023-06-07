<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >=2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [template_file.this](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | (Optional, Forces new resource) Description of the IAM policy. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Optional, Forces new resource) The name of the policy. If omitted, Terraform will assign a random, unique name. | `string` | `null` | no |
| <a name="input_path"></a> [path](#input\_path) | (Optional, default  / ) Path in which to create the policy. See IAM Identifiers for more information. | `string` | `"/"` | no |
| <a name="input_policy_id"></a> [policy\_id](#input\_policy\_id) | (Optional) - An ID for the policy document. | `string` | `null` | no |
| <a name="input_statement"></a> [statement](#input\_statement) | (Optional) - A nested configuration block (described below) configuring one statement to be included in the policy document. | `list(any)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |
| <a name="input_template"></a> [template](#input\_template) | (Optional) The contents of the template, as a string using Terraform template syntax. Use the file function to load the template source from a separate file on disk. | `string` | `null` | no |
| <a name="input_vars"></a> [vars](#input\_vars) | (Optional) Variables for interpolation within the template. Note that variables must all be primitives. Direct references to lists or maps will cause a validation error. | `map(any)` | `null` | no |
| <a name="input_ver"></a> [ver](#input\_ver) | (Optional) - IAM policy document version. Valid values: 2008-10-17, 2012-10-17. Defaults to 2012-10-17. For more information, see the AWS IAM User Guide. | `string` | `"2012-10-17"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN assigned by AWS to this policy. |
| <a name="output_description"></a> [description](#output\_description) | The description of the policy. |
| <a name="output_id"></a> [id](#output\_id) | The policy's ID. |
| <a name="output_name"></a> [name](#output\_name) | The name of the policy. |
| <a name="output_path"></a> [path](#output\_path) | The path of the policy in IAM. |
| <a name="output_policy"></a> [policy](#output\_policy) | The policy document. |
<!-- END_TF_DOCS -->
