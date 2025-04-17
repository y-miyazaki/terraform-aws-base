#--------------------------------------------------------------
# Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Events Rule, SNS or S3).
#--------------------------------------------------------------
resource "aws_lambda_permission" "this" {
  count               = var.is_enabled && var.aws_lambda_permission != null ? 1 : 0
  action              = lookup(var.aws_lambda_permission, "action", null)
  event_source_token  = lookup(var.aws_lambda_permission, "event_source_token", null)
  function_name       = lookup(var.aws_lambda_permission, "function_name", null)
  principal           = lookup(var.aws_lambda_permission, "principal", null)
  qualifier           = lookup(var.aws_lambda_permission, "qualifier", null)
  source_account      = lookup(var.aws_lambda_permission, "source_account", null)
  source_arn          = lookup(var.aws_lambda_permission, "source_arn", null)
  statement_id        = lookup(var.aws_lambda_permission, "statement_id", null)
  statement_id_prefix = lookup(var.aws_lambda_permission, "statement_id_prefix", null)
}
