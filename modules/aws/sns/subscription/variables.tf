#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "aws_sns_topic" {
  type = object(
    {
      # The name of the topic. Topic names must be made up of only uppercase and lowercase ASCII letters, numbers, underscores, and hyphens, and must be between 1 and 256 characters long. For a FIFO (first-in-first-out) topic, the name must end with the .fifo suffix. If omitted, Terraform will assign a random, unique name. Conflicts with name_prefix
      name = string
      # Creates a unique name beginning with the specified prefix. Conflicts with name
      name_prefix = string
      # The display name for the topic
      display_name = string
      # The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
      policy = string
      # The fully-formed AWS policy as JSON. For more information about building AWS IAM policy documents with Terraform, see the AWS IAM Policy Document Guide.
      delivery_policy = string
      # The IAM role permitted to receive success feedback for this topic
      application_success_feedback_role_arn = string
      # Percentage of success to sample
      application_success_feedback_sample_rate = string
      # IAM role for failure feedback
      application_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      http_success_feedback_role_arn = string
      # Percentage of success to sample
      http_success_feedback_sample_rate = string
      # IAM role for failure feedback
      http_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      lambda_success_feedback_role_arn = string
      # Percentage of success to sample
      lambda_success_feedback_sample_rate = string
      # IAM role for failure feedback
      lambda_failure_feedback_role_arn = string
      # The IAM role permitted to receive success feedback for this topic
      sqs_success_feedback_role_arn = string
      # Percentage of success to sample
      sqs_success_feedback_sample_rate = string
      # IAM role for failure feedback
      sqs_failure_feedback_role_arn = string
    }
  )
  description = "(Required) The resource of aws_sns_topic."
}
variable "aws_sns_topic_subscription" {
  type = object(
    {
      # Endpoint to send data to. The contents vary with the protocol. See details below.
      endpoint = string
      # Protocol to use. Valid values are: sqs, sms, lambda, firehose, and application. Protocols email, email-json, http and https are also valid but partially supported. See details below.
      protocol = string
      # Integer indicating number of minutes to wait in retrying mode for fetching subscription arn before marking it as failure. Only applicable for http and https protocols. Default is 1.
      confirmation_timeout_in_minutes = number
      # JSON String with the delivery policy (retries, backoff, etc.) that will be used in the subscription - this only applies to HTTP/S subscriptions. Refer to the SNS docs for more details.
      delivery_policy = string
      # Whether the endpoint is capable of auto confirming subscription (e.g., PagerDuty). Default is false.
      endpoint_auto_confirms = bool
      # JSON String with the filter policy that will be used in the subscription to filter messages seen by the target resource. Refer to the SNS docs for more details.
      filter_policy = string
      # Whether to enable raw message delivery (the original message is directly passed, not wrapped in JSON with the original message in the message property). Default is false.
      raw_message_delivery = string
      # JSON String with the redrive policy that will be used in the subscription. Refer to the SNS docs for more details.
      redrive_policy = string
    }
  )
  description = "(Required) The resource of aws_sns_topic_subscription."
}
variable "kms_master_key_id" {
  type        = string
  description = "(Optional) The KMS master key."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
