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
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  name                = lookup(var.aws_cloudwatch_event_rule, "name", null)
  schedule_expression = lookup(var.aws_cloudwatch_event_rule, "schedule_expression", null)
  event_pattern       = lookup(var.aws_cloudwatch_event_rule, "event_pattern", null)
  description         = lookup(var.aws_cloudwatch_event_rule, "description", null)
  role_arn            = lookup(var.aws_cloudwatch_event_rule, "role_arn", null)
  is_enabled          = lookup(var.aws_cloudwatch_event_rule, "is_enabled", null)
  tags                = local.tags
}
#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  rule       = aws_cloudwatch_event_rule.this.name
  target_id  = lookup(var.aws_cloudwatch_event_target, "target_id", null)
  arn        = lookup(var.aws_cloudwatch_event_target, "arn", null)
  input      = lookup(var.aws_cloudwatch_event_target, "input", null)
  input_path = lookup(var.aws_cloudwatch_event_target, "input_path", null)
  # role_arn is used for ecs_target
  role_arn = lookup(var.aws_cloudwatch_event_target, "target_role_arn", null)
  dynamic "run_command_targets" {
    for_each = lookup(var.aws_cloudwatch_event_target, "run_command_targets", [])
    content {
      key    = lookup(run_command_targets.value, "key", null)
      values = lookup(run_command_targets.value, "values", null)
    }
  }
  dynamic "ecs_target" {
    for_each = lookup(var.aws_cloudwatch_event_target, "ecs_target", [])
    content {
      group       = lookup(ecs_target.value, "group", null)
      launch_type = lookup(ecs_target.value, "launch_type", null)
      dynamic "network_configuration" {
        for_each = lookup(ecs_target.value, "network_configuration", [])
        content {
          subnets          = lookup(network_configuration.value, "subnets", null)
          security_groups  = lookup(network_configuration.value, "security_groups", null)
          assign_public_ip = lookup(network_configuration.value, "assign_public_ip", null)
        }
      }
      platform_version    = lookup(ecs_target.value, "platform_version", null)
      task_count          = lookup(ecs_target.value, "task_count", null)
      task_definition_arn = lookup(ecs_target.value, "task_definition_arn", null)
    }
  }
  dynamic "batch_target" {
    for_each = lookup(var.aws_cloudwatch_event_target, "batch_target", [])
    content {
      job_definition = lookup(batch_target.value, "job_definition", null)
      job_name       = lookup(batch_target.value, "job_name", null)
      array_size     = lookup(batch_target.value, "array_size", null)
      job_attempts   = lookup(batch_target.value, "job_attempts", null)
    }
  }
  dynamic "kinesis_target" {
    for_each = lookup(var.aws_cloudwatch_event_target, "kinesis_target", [])
    content {
      partition_key_path = lookup(kinesis_target.value, "partition_key_path", null)
    }
  }
  dynamic "sqs_target" {
    for_each = lookup(var.aws_cloudwatch_event_target, "sqs_target", null)
    content {
      message_group_id = lookup(sqs_target.value, "message_group_id", null)
    }
  }
  dynamic "input_transformer" {
    for_each = lookup(var.aws_cloudwatch_event_target, "input_transformer", [])
    content {
      input_paths    = lookup(input_transformer.value, "input_paths", null)
      input_template = lookup(input_transformer.value, "input_template", null)
    }
  }
  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
