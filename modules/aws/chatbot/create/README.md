<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_chatbot_slack_channel_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/chatbot_slack_channel_configuration) | resource |
| [aws_iam_policy.securityhub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.aws_resource_explorer_read_only_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.securityhub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_policy_document.securityhub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | (Optional) Specifies the logging level for this configuration: ERROR, INFO or NONE. | `string` | `"ERROR"` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Base name prefix for all Chatbot related resources. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_slack_channel_id"></a> [slack\_channel\_id](#input\_slack\_channel\_id) | (Required) Set the Slack channel ID. | `string` | n/a | yes |
| <a name="input_slack_team_id"></a> [slack\_team\_id](#input\_slack\_team\_id) | (Required) Set the Slack workspace ID. | `string` | n/a | yes |
| <a name="input_sns_topic_arns"></a> [sns\_topic\_arns](#input\_sns\_topic\_arns) | (Required) Specify the SNS topic ARNs to notify Chatbot. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_chatbot_iam_role_arn"></a> [chatbot\_iam\_role\_arn](#output\_chatbot\_iam\_role\_arn) | ARN of the IAM role assumed by AWS Chatbot. |
| <a name="output_chatbot_securityhub_policy_arn"></a> [chatbot\_securityhub\_policy\_arn](#output\_chatbot\_securityhub\_policy\_arn) | ARN of the custom SecurityHub IAM policy attached to the Chatbot role. |
| <a name="output_slack_channel_configuration_name"></a> [slack\_channel\_configuration\_name](#output\_slack\_channel\_configuration\_name) | Name of the Chatbot Slack channel configuration. |
<!-- END_TF_DOCS -->
