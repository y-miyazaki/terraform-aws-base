<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~>3.2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_synthetics_canary.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/synthetics_canary) | resource |
| [null_resource.add_environment_variables_to_canary](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_id"></a> [account\_id](#input\_account\_id) | (Optional) AWS account ID for member account. Set only if aws\_synthetics\_canary.execution\_role\_arn is not specified. | `string` | `null` | no |
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input\_aws\_iam\_policy) | (Optional) Provides an IAM policy. | <pre>object(<br>    {<br>      # Description of the IAM policy.<br>      description = string<br>      # The name of the policy. If omitted, Terraform will assign a random, unique name.<br>      name = string<br>      # Path in which to create the policy. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Policy for Synthetics Canaly.",<br>  "name": "monitor-synthetics-canary-policy",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) The aws\_iam\_role resource. | <pre>object(<br>    {<br>      # (Optional) Description of the role.<br>      description = string<br>      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # (Optional) Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Role for Synthetics Canaly.",<br>  "name": "monitor-synthetics-canary-role",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_aws_synthetics_canary"></a> [aws\_synthetics\_canary](#input\_aws\_synthetics\_canary) | (Required) aws\_synthetics\_canary. | <pre>object(<br>    {<br>      # (Required) Location in Amazon S3 where Synthetics stores artifacts from the test runs of this canary.<br>      artifact_s3_location = string<br>      # (Required) ARN of the IAM role to be used to run the canary. see AWS Docs for permissions needs for IAM Role.<br>      execution_role_arn = string<br>      # (Required) Entry point to use for the source code when running the canary. This value must end with the string .handler .<br>      handler = string<br>      # (Required) Name for this canary. Has a maximum length of 21 characters. Valid characters are lowercase alphanumeric, hyphen, or underscore.<br>      name = string<br>      # (Required) Runtime version to use for the canary. Versions change often so consult the Amazon CloudWatch documentation for the latest valid versions. Values include syn-python-selenium-1.0, syn-nodejs-puppeteer-3.0, syn-nodejs-2.2, syn-nodejs-2.1, syn-nodejs-2.0, and syn-1.0.<br>      runtime_version = string<br>      # (Required) Configuration block providing how often the canary is to run and when these test runs are to stop. Detailed below.<br>      schedule = list(any)<br>      # (Optional) Configuration block. Detailed below.<br>      vpc_config = list(any)<br>      # (Optional) Number of days to retain data about failed runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.<br>      failure_retention_period = number<br>      # (Required) Configuration block for individual canary runs. Detailed below.<br>      run_config = list(object(<br>        {<br>          timeout_in_seconds = number<br>          memory_in_mb       = number<br>          active_tracing     = bool<br>        }<br>      ))<br>      # (Optional) Full bucket name which is used if your canary script is located in S3. The bucket must already exist. Specify the full bucket name including s3:// as the start of the bucket name. Conflicts with zip_file.<br>      s3_bucket = string<br>      # (Optional) S3 key of your script. Conflicts with zip_file.<br>      s3_key = string<br>      # (Optional) S3 version ID of your script. Conflicts with zip_file.<br>      s3_version = string<br>      # (Optional) Whether to run or stop the canary.<br>      start_canary = bool<br>      # (Optional) Number of days to retain data about successful runs of this canary. If you omit this field, the default of 31 days is used. The valid range is 1 to 455 days.<br>      success_retention_period = number<br>      # (Optional) configuration for canary artifacts, including the encryption-at-rest settings for artifacts that the canary uploads to Amazon S3. See Artifact Config.<br>      #   artifact_config = list(any)<br>      # (Optional) ZIP file that contains the script, if you input your canary script directly into the canary instead of referring to an S3 location. It can be up to 5 MB. Conflicts with s3_bucket, s3_key, and s3_version.<br>      zip_file = string<br>      env      = map(string)<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable Synthetics Canary. Defaults true. | `bool` | `true` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) Specify the region in which Synthetics Canary will be run. Set only if aws\_synthetics\_canary.execution\_role\_arn is not specified. | `string` | `null` | no |
| <a name="input_s3_bucket_arn"></a> [s3\_bucket\_arn](#input\_s3\_bucket\_arn) | (Optional) Specify the ARN of the S3Bucket where the Artifact will be placed. Set only if aws\_synthetics\_canary.execution\_role\_arn is not specified. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. If configured with a provider default\_tags configuration block present, tags with matching keys will overwrite those defined at the provider-level. | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
