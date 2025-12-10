#--------------------------------------------------------------
# Module: aws/cloudwatch/events/schedule
# Purpose: Create a scheduled EventBridge rule and flexible target supporting ECS, Batch, Kinesis, SQS, and RunCommand.
# Notes: Many optional nested target configurations; unified tagging applied; future improvement: add validation to ensure at least one target block is defined.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an EventBridge Rule resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_rule" "this" {
  description         = try(var.aws_cloudwatch_event_rule.description, null)
  name                = var.aws_cloudwatch_event_rule.name
  schedule_expression = try(var.aws_cloudwatch_event_rule.schedule_expression, null)
  state               = try(var.aws_cloudwatch_event_rule.state, "ENABLED")

  tags = var.tags
}

#--------------------------------------------------------------
# Provides an EventBridge Target resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_event_target" "this" {
  rule       = aws_cloudwatch_event_rule.this.name
  target_id  = try(var.aws_cloudwatch_event_target.target_id, null)
  arn        = try(var.aws_cloudwatch_event_target.arn, null)
  input      = try(var.aws_cloudwatch_event_target.input, null)
  input_path = try(var.aws_cloudwatch_event_target.input_path, null)
  # role_arn is used for ecs_target
  role_arn = try(var.aws_cloudwatch_event_target.target_role_arn, null)
  dynamic "run_command_targets" {
    for_each = var.aws_cloudwatch_event_target.run_command_targets == null ? [] : var.aws_cloudwatch_event_target.run_command_targets

    content {
      key    = try(run_command_targets.value.key, null)
      values = try(run_command_targets.value.values, null)
    }
  }
  dynamic "ecs_target" {
    for_each = var.aws_cloudwatch_event_target.ecs_target == null ? [] : var.aws_cloudwatch_event_target.ecs_target

    content {
      group       = try(ecs_target.value.group, null)
      launch_type = try(ecs_target.value.launch_type, null)
      dynamic "network_configuration" {
        for_each = try(ecs_target.value.network_configuration, [])

        content {
          subnets          = try(network_configuration.value.subnets, null)
          security_groups  = try(network_configuration.value.security_groups, null)
          assign_public_ip = try(network_configuration.value.assign_public_ip, null)
        }
      }
      platform_version    = try(ecs_target.value.platform_version, null)
      task_count          = try(ecs_target.value.task_count, null)
      task_definition_arn = try(ecs_target.value.task_definition_arn, null)
    }
  }
  dynamic "batch_target" {
    for_each = var.aws_cloudwatch_event_target.batch_target == null ? [] : var.aws_cloudwatch_event_target.batch_target

    content {
      job_definition = try(batch_target.value.job_definition, null)
      job_name       = try(batch_target.value.job_name, null)
      array_size     = try(batch_target.value.array_size, null)
      job_attempts   = try(batch_target.value.job_attempts, null)
    }
  }
  dynamic "kinesis_target" {
    for_each = var.aws_cloudwatch_event_target.kinesis_target == null ? [] : var.aws_cloudwatch_event_target.kinesis_target

    content {
      partition_key_path = try(kinesis_target.value.partition_key_path, null)
    }
  }
  dynamic "sqs_target" {
    for_each = var.aws_cloudwatch_event_target.sqs_target == null ? [] : var.aws_cloudwatch_event_target.sqs_target

    content {
      message_group_id = try(sqs_target.value.message_group_id, null)
    }
  }
  dynamic "input_transformer" {
    for_each = var.aws_cloudwatch_event_target.input_transformer == null ? [] : var.aws_cloudwatch_event_target.input_transformer

    content {
      input_paths    = try(input_transformer.value.input_paths, null)
      input_template = try(input_transformer.value.input_template, null)
    }
  }

  depends_on = [
    aws_cloudwatch_event_rule.this
  ]
}
