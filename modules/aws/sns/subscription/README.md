<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.47.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_sns_topic.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_aws_sns_topic"></a> [aws\_sns\_topic](#input\_aws\_sns\_topic) | (Required) The resource of aws\_sns\_topic. | <pre>object(<br/>    {<br/>      # The name of the topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix<br/>      name = string<br/>      # Creates a unique name beginning with the specified prefix. Conflicts with name<br/>      name_prefix = string<br/>      # The display name for the topic<br/>      display_name = string<br/>      # The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.<br/>      policy = string<br/>      # The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.<br/>      delivery_policy = string<br/>      # The IAM role permitted to receive success feedback for this topic<br/>      application_success_feedback_role_arn = string<br/>      # Percentage of success to sample<br/>      application_success_feedback_sample_rate = string<br/>      # IAM role for failure feedback<br/>      application_failure_feedback_role_arn = string<br/>      # The IAM role permitted to receive success feedback for this topic<br/>      http_success_feedback_role_arn = string<br/>      # Percentage of success to sample<br/>      http_success_feedback_sample_rate = string<br/>      # IAM role for failure feedback<br/>      http_failure_feedback_role_arn = string<br/>      # The IAM role permitted to receive success feedback for this topic<br/>      lambda_success_feedback_role_arn = string<br/>      # Percentage of success to sample<br/>      lambda_success_feedback_sample_rate = string<br/>      # IAM role for failure feedback<br/>      lambda_failure_feedback_role_arn = string<br/>      # The IAM role permitted to receive success feedback for this topic<br/>      sqs_success_feedback_role_arn = string<br/>      # Percentage of success to sample<br/>      sqs_success_feedback_sample_rate = string<br/>      # IAM role for failure feedback<br/>      sqs_failure_feedback_role_arn = string<br/>    }<br/>  )</pre> | n/a | yes |
| <a name="input_aws_sns_topic_subscription"></a> [aws\_sns\_topic\_subscription](#input\_aws\_sns\_topic\_subscription) | (Required) The resource of aws\_sns\_topic\_subscription. | <pre>object(<br/>    {<br/>      # Endpoint to send data to. The contents vary with the protocol. See details below.<br/>      endpoint = string<br/>      # Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported. See details below.<br/>      protocol = string<br/>      # Integer indicating number of minutes to wait in retrying mode for fetching subscription arn before marking it as failure. Only applicable for http and https protocols. Default is 1.<br/>      confirmation_timeout_in_minutes = number<br/>      # JSON String with the delivery policy (retries, backoff, etc.) that will be used in the subscription - this only applies to HTTP/S subscriptions. Refer to the SNS docs for more details.<br/>      delivery_policy = string<br/>      # Whether the endpoint is capable of auto confirming subscription (e.g., PagerDuty). Default is false.<br/>      endpoint_auto_confirms = bool<br/>      # JSON String with the filter policy that will be used in the subscription to filter messages seen by the target resource. Refer to the SNS docs for more details.<br/>      filter_policy = string<br/>      # Whether to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property). Default is false.<br/>      raw_message_delivery = string<br/>      # JSON String with the redrive policy that will be used in the subscription. Refer to the SNS docs for more details.<br/>      redrive_policy = string<br/>    }<br/>  )</pre> | n/a | yes |
| <a name="input_kms_master_key_id"></a> [kms\_master\_key\_id](#input\_kms\_master\_key\_id) | (Optional) The KMS master key. | `string` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the SNS topic, as a more obvious property (clone of id) |
| <a name="output_id"></a> [id](#output\_id) | The ARN of the SNS topic |
<!-- END_TF_DOCS -->
