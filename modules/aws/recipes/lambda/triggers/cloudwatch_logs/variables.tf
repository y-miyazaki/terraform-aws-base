#--------------------------------------------------------------
# module variables
#-------------------------------------------------------------
variable "aws_cloudwatch_log_subscription_filter" {
  type = list(object({
    # (Optional, Forces new resource) The name of the log group. If omitted, Terraform will assign a random, unique name.
    name = string
    # (Required) The ARN of the destination to deliver matching log events to. Kinesis stream or Lambda function ARN.
    destination_arn = string
    # (Required) A valid CloudWatch Logs filter pattern for subscribing to a filtered stream of log events.
    filter_pattern = string
    # (Required) The name of the log group to associate the subscription filter with
    log_group_name = string
    # (Optional) The method used to distribute log data to the destination. By default log data is grouped by log stream, but the grouping can be set to random for a more even distribution. This property is only applicable when the destination is an Amazon Kinesis stream. Valid values are Random and ByLogStream.
    distribution = string
    }
    )
  )
  description = "(Required) Provides a CloudWatch Logs subscription filter resource."
  default     = []
}
#--------------------------------------------------------------
# module variables(aws_lambda_permission)
#--------------------------------------------------------------
variable "region" {
  type        = string
  description = "(Required)"
  default     = null
}
variable "function_name" {
  type        = string
  description = "(Required) Name of the Lambda function whose resource policy you are updating"
  default     = null
}
variable "qualifier" {
  type        = string
  description = "(Optional) Query parameter to specify function version or alias name. The permission will then apply to the specific qualified ARN. e.g. arn:aws:lambda:aws-region:acct-id:function:function-name:2"
  default     = null
}
