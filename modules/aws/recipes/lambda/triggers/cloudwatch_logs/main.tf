#--------------------------------------------------------------
# Provides a CloudWatch Logs subscription filter resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_subscription_filter" "this" {
  count           = length(var.aws_cloudwatch_log_subscription_filter)
  name            = var.name
  destination_arn = var.destination_arn
  filter_pattern  = var.filter_pattern
  log_group_name  = element(data.aws_cloudwatch_log_group.this.*.name, count.index)
  distribution    = var.distribution
}

#--------------------------------------------------------------
# Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Event Rule, SNS or S3).
#--------------------------------------------------------------
resource "aws_lambda_permission" "this" {
  count               = length(var.log_group_names)
  action              = "lambda:InvokeFunction"
  function_name       = var.function_name
  principal           = "logs.${var.region}.amazonaws.com"
  qualifier           = var.qualifier
  source_arn          = element(data.aws_cloudwatch_log_group.this.*.arn, count.index)
  statement_id_prefix = "AllowExecutionFromCloudWatchLog-"
}
