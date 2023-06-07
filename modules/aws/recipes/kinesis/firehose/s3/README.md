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
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_kinesis_firehose_delivery_stream.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kinesis_firehose_delivery_stream) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input\_aws\_iam\_policy) | (Optional) The resource of aws\_iam\_policy. | <pre>object(<br>    {<br>      # Description of the IAM policy.<br>      description = string<br>      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Policy for Kinesis Firehose to S3.",<br>  "name": "firehose-s3-policy",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) The resource of aws\_iam\_role. | <pre>object(<br>    {<br>      # Description of the role.<br>      description = string<br>      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Role for Kinesis Firehose to S3.",<br>  "name": "firehose-s3-role",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_aws_kinesis_firehose_delivery_stream"></a> [aws\_kinesis\_firehose\_delivery\_stream](#input\_aws\_kinesis\_firehose\_delivery\_stream) | (Required) The resource of aws\_kinesis\_firehose\_delivery\_stream. | <pre>list(object(<br>    {<br>      # A name to identify the stream. This is unique to the AWS account and region the Stream is created in.<br>      name = string<br>      # Encrypt at rest options. Server-side encryption should not be enabled when a kinesis stream is configured as the source of the firehose delivery stream.<br>      server_side_encryption = list(any)<br>      # Enhanced configuration options for the s3 destination. More details are given below.<br>      extended_s3_configuration = list(any)<br>    }<br>  ))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_iam_role_arn"></a> [aws\_iam\_role\_arn](#output\_aws\_iam\_role\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_aws_kinesis_firehose_delivery_stream_arn"></a> [aws\_kinesis\_firehose\_delivery\_stream\_arn](#output\_aws\_kinesis\_firehose\_delivery\_stream\_arn) | arn of the role. |
<!-- END_TF_DOCS -->
