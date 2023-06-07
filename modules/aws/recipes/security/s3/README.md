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
| [aws_s3_account_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_account_public_access_block) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Optional) AWS account ID to configure. Defaults to automatically determined account ID of the Terraform AWS provider. | `string` | `null` | no |
| <a name="input_block_public_acls"></a> [block\_public\_acls](#input\_block\_public\_acls) | (Optional) Whether Amazon S3 should block public ACLs for buckets in this account. Defaults to false. Enabling this setting does not affect existing policies or ACLs. When set to true causes the following behavior: PUT Bucket acl and PUT Object acl calls will fail if the specified ACL allows public access. PUT Object calls will fail if the request includes an object ACL. | `bool` | `false` | no |
| <a name="input_block_public_policy"></a> [block\_public\_policy](#input\_block\_public\_policy) | (Optional) Whether Amazon S3 should block public bucket policies for buckets in this account. Defaults to false. Enabling this setting does not affect existing bucket policies. When set to true causes Amazon S3 to: Reject calls to PUT Bucket policy if the specified bucket policy allows public access. | `bool` | `false` | no |
| <a name="input_ignore_public_acls"></a> [ignore\_public\_acls](#input\_ignore\_public\_acls) | (Optional) Whether Amazon S3 should ignore public ACLs for buckets in this account. Defaults to false. Enabling this setting does not affect the persistence of any existing ACLs and doesn't prevent new public ACLs from being set. When set to true causes Amazon S3 to: Ignore all public ACLs on buckets in this account and any objects that they contain. | `bool` | `false` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of S3 account public access block. Defaults true. | `bool` | `true` | no |
| <a name="input_restrict_public_buckets"></a> [restrict\_public\_buckets](#input\_restrict\_public\_buckets) | (Optional) Whether Amazon S3 should restrict public bucket policies for buckets in this account. Defaults to false. Enabling this setting does not affect previously stored bucket policies, except that public and cross-account access within any public bucket policy, including non-public delegation to specific accounts, is blocked. When set to true: Only the bucket owner and AWS Services can access buckets with public policies. | `bool` | `false` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
