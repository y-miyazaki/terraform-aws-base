<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >=0.14 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>3.75 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.75.1 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [random_id.this](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acceleration_status"></a> [acceleration\_status](#input\_acceleration\_status) | (Optional) Sets the accelerate configuration of an existing bucket. Can be Enabled or Suspended. | `string` | `null` | no |
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Required) AWS account ID for member account. | `string` | n/a | yes |
| <a name="input_acl"></a> [acl](#input\_acl) | (Optional) The canned ACL to apply. Defaults to private. | `string` | `"private"` | no |
| <a name="input_bucket"></a> [bucket](#input\_bucket) | (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. | `string` | `null` | no |
| <a name="input_bucket_prefix"></a> [bucket\_prefix](#input\_bucket\_prefix) | (Optional, Forces new resource) Creates a unique bucket name beginning with the specified prefix. Conflicts with bucket. | `string` | `null` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | (Optional, Default:false) A boolean that indicates all objects (including any locked objects) should be deleted from the bucket so that the bucket can be destroyed without error. These objects are not recoverable. | `bool` | `false` | no |
| <a name="input_is_random_name_suffix"></a> [is\_random\_name\_suffix](#input\_is\_random\_name\_suffix) | (Optional) The random name suffix of the bucket. | `bool` | `false` | no |
| <a name="input_lifecycle_rule"></a> [lifecycle\_rule](#input\_lifecycle\_rule) | (Optional) A configuration of object lifecycle management (documented below). | `list` | `[]` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | (Optional) A settings of bucket logging (documented below). | `list` | `[]` | no |
| <a name="input_object_lock_configuration"></a> [object\_lock\_configuration](#input\_object\_lock\_configuration) | (Optional) A configuration of S3 object locking (documented below) | `list` | `[]` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) If specified, the AWS region this bucket should reside in. Otherwise, the region used by the callee. | `string` | `null` | no |
| <a name="input_replication_configuration"></a> [replication\_configuration](#input\_replication\_configuration) | (Optional) A configuration of replication configuration (documented below). | `list` | `[]` | no |
| <a name="input_request_payer"></a> [request\_payer](#input\_request\_payer) | (Optional) Specifies who should bear the cost of Amazon S3 data transfer. Can be either BucketOwner or Requester. By default, the owner of the S3 bucket would incur the costs of any data transfer. See Requester Pays Buckets developer guide for more information. | `string` | `null` | no |
| <a name="input_server_side_encryption_configuration"></a> [server\_side\_encryption\_configuration](#input\_server\_side\_encryption\_configuration) | (Optional) A configuration of server-side encryption configuration (documented below) | `list` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the bucket. | `map(any)` | `null` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | (Optional) A state of versioning (documented below) | `list` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the bucket. Will be of format arn:aws:s3:::bucketname. |
| <a name="output_bucket"></a> [bucket](#output\_bucket) | The name of the bucket. |
| <a name="output_id"></a> [id](#output\_id) | The name of the bucket. |
<!-- END_TF_DOCS -->
