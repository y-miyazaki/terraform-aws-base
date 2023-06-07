#--------------------------------------------------------------
# For RDS
#--------------------------------------------------------------
#--------------------------------------------------------------
# Local
#--------------------------------------------------------------
locals {
  tags = {
    for k, v in(var.tags == null ? {} : var.tags) : k => v if lookup(data.aws_default_tags.provider.tags, k, null) == null || lookup(data.aws_default_tags.provider.tags, k, null) != v
  }
  url   = var.is_aurora ? "https://docs.aws.amazon.com/AmazonRDS/latest/AuroraUserGuide/Aurora.AuroraMySQL.Monitoring.Metrics.html" : "https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/monitoring-cloudwatch.html"
  count = length(var.dimensions) > 0 ? length(var.dimensions) : 1
  names = length(var.dimensions) > 0 ? flatten([
    for r in var.dimensions : {
      name = format("%s-", lookup(r, "DBInstanceIdentifier", r.DBClusterIdentifier))
    }]) : [{
    name = ""
  }]
  #   is_dimensions = length(var.dimensions) > 0 ? true : false
}
#--------------------------------------------------------------
# Use this data source to get the default tags configured on the provider.
#--------------------------------------------------------------
data "aws_default_tags" "provider" {}

#--------------------------------------------------------------
# For CommitLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "commit_latency" {
  count               = var.is_enabled && var.threshold.enabled_commit_latency && var.is_aurora && (var.is_mysql || var.is_postgres) ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}commit-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "CommitLatency"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.commit_latency
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS commit latency>(>= ${var.threshold.commit_latency}sec)."
  ok_actions          = var.ok_actions
  unit                = "Milliseconds"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}
#--------------------------------------------------------------
# For CPUCreditBalance
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_creadit_balance" {
  count               = var.is_enabled && var.threshold.enabled_cpu_creadit_balance && length(regexall("(t2|t3)", var.db_instance_class)) > 0 ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}cpu-creadit-balance"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "CPUCreditBalance"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.cpu_creadit_balance
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS CPU Credit Balance>(<= ${var.threshold.cpu_creadit_balance})."
  ok_actions          = var.ok_actions
  unit                = "Count"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}

#--------------------------------------------------------------
# For CPUUtilization
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  count               = var.is_enabled && var.threshold.enabled_cpu_utilization ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "CPUUtilization"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.cpu_utilization
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS CPU Utilization>(>= ${var.threshold.cpu_utilization}%)."
  ok_actions          = var.ok_actions
  unit                = "Percent"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}

#--------------------------------------------------------------
# For DatabaseConnections
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "database_connections" {
  count               = var.is_enabled && var.threshold.enabled_database_connections ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}database-connections"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "DatabaseConnections"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.database_connections
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS database connections>(>= ${var.threshold.database_connections})."
  ok_actions          = var.ok_actions
  unit                = "Count"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}

#--------------------------------------------------------------
# For Deadlocks
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "deadlocks" {
  count               = var.is_enabled && var.threshold.enabled_deadlocks && var.is_aurora && (var.is_mysql || var.is_postgres) ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}deadlocks"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "Deadlocks"
  period              = var.period
  statistic           = "Sum"
  threshold           = var.threshold.deadlocks
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS deadlocks>(>= ${var.threshold.deadlocks})."
  ok_actions          = var.ok_actions
  unit                = "Count/Second"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}
#--------------------------------------------------------------
# For DeleteLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "delete_latency" {
  count               = var.is_enabled && var.threshold.enabled_delete_latency && var.is_aurora && var.is_mysql ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}delete-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "DeleteLatency"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.delete_latency
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS delete latency>(>= ${var.threshold.delete_latency}sec)."
  ok_actions          = var.ok_actions
  unit                = "Seconds"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}
#--------------------------------------------------------------
# For DiskQueueDepth
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "disk_queue_depth" {
  count               = var.is_enabled && var.threshold.enabled_disk_queue_depth ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}disk-queue-depth"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "DiskQueueDepth"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.disk_queue_depth
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS disk queue depth>(>= ${var.threshold.disk_queue_depth})."
  ok_actions          = var.ok_actions
  unit                = "Count"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}

#--------------------------------------------------------------
# For FreeableMemory
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "freeable_memory" {
  count               = var.is_enabled && var.threshold.enabled_freeable_memory && var.is_aurora && var.is_mysql ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}freeable-memory"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "FreeableMemory"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.freeable_memory
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS freeable memory>(<= ${var.threshold.freeable_memory}MB)."
  ok_actions          = var.ok_actions
  unit                = "Megabits"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}

#--------------------------------------------------------------
# For ReadLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "read_latency" {
  count               = var.is_enabled && var.threshold.enabled_read_latency ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}read-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "ReadLatency"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.read_latency
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS read latency>(>= ${var.threshold.read_latency}sec)."
  ok_actions          = var.ok_actions
  unit                = "Seconds"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}

#--------------------------------------------------------------
# For WriteLatency
# Provides a CloudWatch Metric Alarm resource.
#--------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "write_latency" {
  count               = var.is_enabled && var.threshold.enabled_write_latency ? local.count : 0
  alarm_name          = "${var.name_prefix}metric-rds-${local.names[count.index].name}write-latency"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  namespace           = "AWS/RDS"
  metric_name         = "WriteLatency"
  period              = var.period
  statistic           = "Average"
  threshold           = var.threshold.write_latency
  actions_enabled     = true
  alarm_actions       = var.alarm_actions
  alarm_description   = "This is an alarm to check for <${local.url}|RDS write latency(>= ${var.threshold.write_latency}sec)."
  ok_actions          = var.ok_actions
  unit                = "Seconds"
  treat_missing_data  = "notBreaching"
  dimensions          = var.dimensions[count.index]
  tags                = local.tags
}
