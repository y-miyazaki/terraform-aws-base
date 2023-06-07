<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~>3.2.1 |
| <a name="requirement_template"></a> [template](#requirement\_template) | ~>2.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |
| <a name="provider_template"></a> [template](#provider\_template) | 2.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_athena_database.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_database) | resource |
| [aws_athena_named_query.cloudfront_query_1week_error](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_named_query.ses_query_bounce_all_1week](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_named_query.ses_query_bounce_hard_1week](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_named_query.ses_query_bounce_soft_1week](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_named_query) | resource |
| [aws_athena_workgroup.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/athena_workgroup) | resource |
| [null_resource.cloudfront_create_table](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ses_create_table](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [null_resource.ses_create_view](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [template_file.cloudfront_create_table](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.cloudfront_drop_table](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.cloudfront_query_1week_error](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.ses_create_table](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.ses_create_view](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.ses_drop_table](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.ses_query_bounce_all_1week](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.ses_query_bounce_hard_1week](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |
| [template_file.ses_query_bounce_soft_1week](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cloudfront_log_bucket"></a> [cloudfront\_log\_bucket](#input\_cloudfront\_log\_bucket) | (Required) Specify the bucket where the CloudFront logs are located. s3://{bucket name}/{bucket prefix} | `string` | n/a | yes |
| <a name="input_cloudfront_table_name"></a> [cloudfront\_table\_name](#input\_cloudfront\_table\_name) | (Optional) Specify the name of the CloudFront table to be created in Athena. | `string` | `"cloudfront_logs"` | no |
| <a name="input_database_acl_configuration"></a> [database\_acl\_configuration](#input\_database\_acl\_configuration) | (Optional) That an Amazon S3 canned ACL should be set to control ownership of stored query results. See ACL Configuration below. | `any` | `{}` | no |
| <a name="input_database_bucket"></a> [database\_bucket](#input\_database\_bucket) | (Required) Name of S3 bucket to save the results of the query execution. | `string` | n/a | yes |
| <a name="input_database_comment"></a> [database\_comment](#input\_database\_comment) | (Optional) Description of the database. | `string` | `null` | no |
| <a name="input_database_encryption_configuration"></a> [database\_encryption\_configuration](#input\_database\_encryption\_configuration) | (Optional) Encryption key block AWS Athena uses to decrypt the data in S3, such as an AWS Key Management Service (AWS KMS) key. See Encryption Configuration below. | `any` | `{}` | no |
| <a name="input_database_expected_bucket_owner"></a> [database\_expected\_bucket\_owner](#input\_database\_expected\_bucket\_owner) | (Optional) AWS account ID that you expect to be the owner of the Amazon S3 bucket. | `string` | `null` | no |
| <a name="input_database_name"></a> [database\_name](#input\_database\_name) | (Required) Name of the database to create. | `string` | n/a | yes |
| <a name="input_database_properties"></a> [database\_properties](#input\_database\_properties) | (Optional) Key-value map of custom metadata properties for the database definition. | `any` | `null` | no |
| <a name="input_enabled_cloudfront"></a> [enabled\_cloudfront](#input\_enabled\_cloudfront) | (Optional) To check CloudFront logs with Athena, specify true. | `bool` | `false` | no |
| <a name="input_enabled_ses"></a> [enabled\_ses](#input\_enabled\_ses) | (Optional) To check SES logs with Athena, specify true. | `bool` | `false` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Name prefix of all resources. | `string` | `""` | no |
| <a name="input_ses_log_bucket"></a> [ses\_log\_bucket](#input\_ses\_log\_bucket) | (Required) Specify the bucket where the SES logs are located. s3://{bucket name}/{bucket prefix} | `string` | n/a | yes |
| <a name="input_ses_table_name"></a> [ses\_table\_name](#input\_ses\_table\_name) | (Optional) Specify the name of the SES table to be created in Athena. | `string` | `"ses_logs"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags for the workgroup. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(any)` | `null` | no |
| <a name="input_workgroup_configuration"></a> [workgroup\_configuration](#input\_workgroup\_configuration) | (Optional) Configuration block with various settings for the workgroup. Documented below. | `any` | `{}` | no |
| <a name="input_workgroup_description"></a> [workgroup\_description](#input\_workgroup\_description) | (Optional) Description of the workgroup. | `string` | `null` | no |
| <a name="input_workgroup_name"></a> [workgroup\_name](#input\_workgroup\_name) | (Required) Name of the workgroup. | `string` | n/a | yes |
| <a name="input_workgroup_state"></a> [workgroup\_state](#input\_workgroup\_state) | (Optional) State of the workgroup. Valid values are DISABLED or ENABLED. Defaults to ENABLED. | `string` | `"ENABLED"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->