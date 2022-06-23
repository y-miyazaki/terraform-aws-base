#--------------------------------------------------------------
# Locals
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}
#--------------------------------------------------------------
# Provides a CloudWatch Log Group resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_log_group" "this" {
  count             = var.is_enabled ? 1 : 0
  name              = "/aws/lambda/${aws_lambda_function.this[0].function_name}"
  retention_in_days = lookup(var.aws_cloudwatch_log_group, "retention_in_days")
  kms_key_id        = lookup(var.aws_cloudwatch_log_group, "kms_key_id", null)
  tags              = local.tags
}
#--------------------------------------------------------------
# Provides a Lambda Function resource.
# Lambda allows you to trigger execution of code in response to events in AWS, enabling serverless backend solutions. The Lambda Function itself includes source code and runtime configuration.
#--------------------------------------------------------------
#tfsec:ignore:aws-lambda-enable-tracing
resource "aws_lambda_function" "this" {
  count             = var.is_enabled ? 1 : 0
  filename          = lookup(var.aws_lambda_function, "filename", null)
  s3_bucket         = lookup(var.aws_lambda_function, "s3_bucket", null)
  s3_key            = lookup(var.aws_lambda_function, "s3_key", null)
  s3_object_version = lookup(var.aws_lambda_function, "s3_object_version", null)
  function_name     = lookup(var.aws_lambda_function, "function_name", null)
  dynamic "dead_letter_config" {
    for_each = lookup(var.aws_lambda_function, "dead_letter_config", [])
    content {
      target_arn = lookup(dead_letter_config.value, "target_arn", null)
    }
  }
  handler                        = lookup(var.aws_lambda_function, "handler", null)
  role                           = lookup(var.aws_lambda_function, "role", null)
  description                    = lookup(var.aws_lambda_function, "description", null)
  layers                         = lookup(var.aws_lambda_function, "layers", null)
  memory_size                    = lookup(var.aws_lambda_function, "memory_size", null)
  runtime                        = lookup(var.aws_lambda_function, "runtime", null)
  timeout                        = lookup(var.aws_lambda_function, "timeout", null)
  reserved_concurrent_executions = lookup(var.aws_lambda_function, "reserved_concurrent_executions", null)
  publish                        = lookup(var.aws_lambda_function, "publish", null)
  dynamic "tracing_config" {
    for_each = lookup(var.aws_lambda_function, "tracing_config", [])
    content {
      mode = lookup(tracing_config.value, "mode", "Active")
    }
  }
  dynamic "vpc_config" {
    for_each = lookup(var.aws_lambda_function, "vpc_config", [])
    content {
      subnet_ids         = lookup(vpc_config.value, "subnet_ids", null)
      security_group_ids = lookup(vpc_config.value, "security_group_ids", null)
    }
  }
  environment {
    variables = lookup(var.aws_lambda_function, "environment", null)
  }
  kms_key_arn      = lookup(var.aws_lambda_function, "kms_key_arn", null)
  source_code_hash = lookup(var.aws_lambda_function, "source_code_hash", null)
  tags             = local.tags
}

#--------------------------------------------------------------
# Creates a Lambda permission to allow external sources invoking the Lambda function (e.g. CloudWatch Events Rule, SNS or S3).
#--------------------------------------------------------------
resource "aws_lambda_permission" "this" {
  count               = var.is_enabled && var.aws_lambda_permission != null ? 1 : 0
  action              = lookup(var.aws_lambda_permission, "action", null)
  event_source_token  = lookup(var.aws_lambda_permission, "event_source_token", null)
  function_name       = aws_lambda_function.this[0].function_name
  principal           = lookup(var.aws_lambda_permission, "principal", null)
  qualifier           = lookup(var.aws_lambda_permission, "qualifier", null)
  source_account      = lookup(var.aws_lambda_permission, "source_account", null)
  source_arn          = lookup(var.aws_lambda_permission, "source_arn", null)
  statement_id        = lookup(var.aws_lambda_permission, "statement_id", null)
  statement_id_prefix = lookup(var.aws_lambda_permission, "statement_id_prefix", null)
  depends_on = [
    aws_lambda_function.this
  ]
}
