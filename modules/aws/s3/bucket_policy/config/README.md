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
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) AWS account ID for member account. | `string` | n/a | yes |
| <a name="input_attach_bucket_policy"></a> [attach\_bucket\_policy](#input\_attach\_bucket\_policy) | (Optional) Controls if S3 bucket should have bucket policy attached (set to true to use value of policy as bucket policy). | `bool` | `false` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | (Optional) The S3 bucket name. | `string` | `null` | no |
| <a name="input_config_role_names"></a> [config\_role\_names](#input\_config\_role\_names) | (Required) List of the AWS Config role name. | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_json"></a> [policy\_json](#output\_policy\_json) | S3 bucket policy output as string. |
<!-- END_TF_DOCS -->
