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
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) AWS account ID for member account. | `string` | n/a | yes |
| <a name="input_attach_bucket_policy"></a> [attach\_bucket\_policy](#input\_attach\_bucket\_policy) | (Optional) Specify true to attach to S3BucketPolicy. | `bool` | `false` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | (Optional) The S3 bucket name. | `string` | `null` | no |
| <a name="input_bucket_arn"></a> [bucket\_arn](#input\_bucket\_arn) | (Required) The S3 bucket arn. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy_json"></a> [policy\_json](#output\_policy\_json) | S3 bucket policy output as string. |
<!-- END_TF_DOCS -->
