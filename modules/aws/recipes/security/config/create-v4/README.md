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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_s3"></a> [s3](#module\_s3) | terraform-aws-modules/s3-bucket/aws | 3.6.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_event_rule.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_rule) | resource |
| [aws_cloudwatch_event_target.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_event_target) | resource |
| [aws_config_configuration_recorder.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder) | resource |
| [aws_config_configuration_recorder_status.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_configuration_recorder_status) | resource |
| [aws_config_delivery_channel.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/config_delivery_channel) | resource |
| [aws_iam_role.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.config](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloudwatch_event_rule"></a> [aws\_cloudwatch\_event\_rule](#input\_aws\_cloudwatch\_event\_rule) | (Optional) Provides an EventBridge Rule resource. | <pre>object(<br>    {<br>      # (Required) The name of the rule. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix.<br>      name = string<br>      # (Optional) The description of the rule.<br>      description = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "This cloudwatch event used for Config.",<br>  "name": "security-config-cloudwatch-event-rule"<br>}</pre> | no |
| <a name="input_aws_cloudwatch_event_target"></a> [aws\_cloudwatch\_event\_target](#input\_aws\_cloudwatch\_event\_target) | (Required) Provides an EventBridge Target resource. | <pre>object(<br>    {<br>      # (Required) The Amazon Resource Name (ARN) associated of the target.<br>      arn = string<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_config_configuration_recorder"></a> [aws\_config\_configuration\_recorder](#input\_aws\_config\_configuration\_recorder) | (Required) The aws\_config\_configuration\_recorder resource. | <pre>object(<br>    {<br>      name            = string<br>      recording_group = list(any)<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_config_configuration_recorder_status"></a> [aws\_config\_configuration\_recorder\_status](#input\_aws\_config\_configuration\_recorder\_status) | (Required) The aws\_config\_configuration\_recorder\_status resource. | <pre>object(<br>    {<br>      is_enabled = bool<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_config_delivery_channel"></a> [aws\_config\_delivery\_channel](#input\_aws\_config\_delivery\_channel) | (Required) The aws\_config\_delivery\_channel resource. | <pre>object(<br>    {<br>      name                         = string<br>      sns_topic_arn                = string<br>      snapshot_delivery_properties = list(any)<br>    }<br>  )</pre> | n/a | yes |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) The aws\_iam\_role resource. | <pre>object(<br>    {<br>      # (Optional) Description of the role.<br>      description = string<br>      # (Optional, Forces new resource) Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # (Optional) Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Role for AWS Config.",<br>  "name": "security-config-role",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_aws_s3_bucket_existing"></a> [aws\_s3\_bucket\_existing](#input\_aws\_s3\_bucket\_existing) | (Optional) If you have an S3 that already exists, please specify this one. It is exclusive to the variable:aws\_s3\_bucket. | <pre>object(<br>    {<br>      # The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be less than or equal to 63 characters in length.<br>      bucket_id = string<br>      # The S3 bucket arn<br>      bucket_arn = string<br>    }<br>  )</pre> | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable AWS Config. Defaults true. | `bool` | `true` | no |
| <a name="input_is_s3_enabled"></a> [is\_s3\_enabled](#input\_is\_s3\_enabled) | (Optional) A boolean flag to enable/disable S3 Bucket. Defaults false. | `bool` | `false` | no |
| <a name="input_s3_bucket"></a> [s3\_bucket](#input\_s3\_bucket) | (Optional) If you have a new S3 to create, please specify this one. Yes to the variable:aws\_s3\_bucket\_exsiting. | <pre>object(<br>    {<br>      # (Optional, Forces new resource) The name of the bucket. If omitted, Terraform will assign a random, unique name. Must be lowercase and less than or equal to 63 characters in length. A full list of bucket naming rules may be found here.<br>      bucket                               = string<br>      lifecycle_rule                       = any<br>      logging                              = any<br>      server_side_encryption_configuration = any<br>      versioning                           = any<br>    }<br>  )</pre> | <pre>{<br>  "bucket": "s3-log",<br>  "lifecycle_rule": {},<br>  "logging": {},<br>  "server_side_encryption_configuration": {},<br>  "versioning": {}<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | The Amazon Resource Name (ARN) of the rule |
| <a name="output_config_role_name"></a> [config\_role\_name](#output\_config\_role\_name) | Role name of the Config |
| <a name="output_id"></a> [id](#output\_id) | Name of the recorder |
<!-- END_TF_DOCS -->
