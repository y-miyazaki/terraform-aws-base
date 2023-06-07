<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >=3.70.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.8.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_config_config_rule.cloudtrail-s3-dataevents-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.s3-account-level-public-access-blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.s3-bucket-level-public-access-prohibited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.s3-bucket-public-read-prohibited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.s3-bucket-public-write-prohibited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.s3-bucket-server-side-encryption-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.s3-bucket-ssl-requests-only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_config_rule.s3-bucket-versioning-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_config_rule) | resource |
| [aws_config_remediation_configuration.s3-account-level-public-access-blocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_config_remediation_configuration.s3-bucket-level-public-access-prohibited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_config_remediation_configuration.s3-bucket-public-read-prohibited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_config_remediation_configuration.s3-bucket-public-write-prohibited](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_config_remediation_configuration.s3-bucket-server-side-encryption-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_config_remediation_configuration.s3-bucket-ssl-requests-only](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_config_remediation_configuration.s3-bucket-versioning-enabled](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_remediation_configuration) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_configure_s3_bucket_public_access_block"></a> [configure\_s3\_bucket\_public\_access\_block](#input\_configure\_s3\_bucket\_public\_access\_block) | (Optional) If true, configures the Amazon Simple Storage Service (Amazon S3) public access block settings for an Amazon S3 bucket based on the values you specify. | <pre>object(<br>    {<br>      # If set to True, Amazon S3 blocks public access control lists (ACLs) for the S3 bucket, and objects stored in the S3 bucket you specify in the BucketName parameter.<br>      block_public_acls = bool<br>      # If set to True, Amazon S3 blocks public bucket policies for the S3 bucket you specify in the BucketName parameter.<br>      block_public_policy = bool<br>      # If set to True, Amazon S3 ignores all public ACLs for the S3 bucket you specify in the BucketName parameter.<br>      ignore_public_acls = bool<br>      # If set to True, Amazon S3 restricts public bucket policies for the S3 bucket you specify in the BucketName parameter.<br>      restrict_public_buckets = bool<br>    }<br>  )</pre> | <pre>{<br>  "block_public_acls": true,<br>  "block_public_policy": true,<br>  "ignore_public_acls": true,<br>  "restrict_public_buckets": true<br>}</pre> | no |
| <a name="input_enabled_s3_bucket_encryption_sse_algorithm"></a> [enabled\_s3\_bucket\_encryption\_sse\_algorithm](#input\_enabled\_s3\_bucket\_encryption\_sse\_algorithm) | (Optional) Server-side encryption algorithm to use for the default encryption. | `string` | `"AES256"` | no |
| <a name="input_is_configure_s3_bucket_public_access_block"></a> [is\_configure\_s3\_bucket\_public\_access\_block](#input\_is\_configure\_s3\_bucket\_public\_access\_block) | (Optional) If true, configures the Amazon Simple Storage Service (Amazon S3) public access block settings for an Amazon S3 bucket based on the values you specify. | `bool` | `false` | no |
| <a name="input_is_configure_s3_bucket_versioning"></a> [is\_configure\_s3\_bucket\_versioning](#input\_is\_configure\_s3\_bucket\_versioning) | (Optional) If true, it will enable S3 bucket versioning. | `bool` | `false` | no |
| <a name="input_is_disable_s3_bucket_public_read_write"></a> [is\_disable\_s3\_bucket\_public\_read\_write](#input\_is\_disable\_s3\_bucket\_public\_read\_write) | (Optional) If true, public read/write of the S3 bucket will be disabled. | `bool` | `false` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable AWS Config. Defaults true. | `bool` | `true` | no |
| <a name="input_is_enabled_s3_bucket_encryption"></a> [is\_enabled\_s3\_bucket\_encryption](#input\_is\_enabled\_s3\_bucket\_encryption) | (Optional) If true, Enable encryption for an Amazon Simple Storage Service (Amazon S3) bucket (encrypt the contents of the bucket). | `bool` | `false` | no |
| <a name="input_is_restrict_bucket_ssl_requests_only"></a> [is\_restrict\_bucket\_ssl\_requests\_only](#input\_is\_restrict\_bucket\_ssl\_requests\_only) | (Optional) If true, bucket policy statement that explicitly denies HTTP requests to the Amazon S3 bucket you specify. | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Prefix of config name. | `string` | `""` | no |
| <a name="input_ssm_automation_assume_role_arn"></a> [ssm\_automation\_assume\_role\_arn](#input\_ssm\_automation\_assume\_role\_arn) | (Required) AssumeRole arn in SSM Automation | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
