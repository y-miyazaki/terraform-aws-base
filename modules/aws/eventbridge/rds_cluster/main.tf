#--------------------------------------------------------------
# Module: aws/eventbridge/rds_cluster
# Purpose: Schedule start and stop of an RDS/Aurora DB Cluster using EventBridge Scheduler.
# Notes: Creates separate schedules for start/stop if expressions provided; future improvement: add tagging support when service adds it and validation of cron syntax.
#--------------------------------------------------------------
#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource.
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "stop" {
  count = var.schedule_expression_stop == null ? 0 : 1

  name  = var.name_prefix == null ? var.name_stop_cluster : format("%s%s", var.name_prefix, "stop-db-cluster-eventbridge-scheduler")
  state = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_expression_stop

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:stopDBCluster"
    role_arn = var.role_arn

    input = jsonencode({
      DbClusterIdentifier = var.db_cluster_identifier
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
  description = var.description
}

#--------------------------------------------------------------
# Provides an EventBridge Scheduler Schedule resource.
#--------------------------------------------------------------
resource "aws_scheduler_schedule" "start" {
  count = var.schedule_expression_start == null ? 0 : 1

  name  = var.name_prefix == null ? var.name_start_cluster : format("%s%s", var.name_prefix, "start-db-eventbridge-scheduler")
  state = "ENABLED"

  flexible_time_window {
    mode = "OFF"
  }

  schedule_expression = var.schedule_expression_start

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:rds:startDBCluster"
    role_arn = var.role_arn

    input = jsonencode({
      DbClusterIdentifier = var.db_cluster_identifier
    })

    retry_policy {
      maximum_event_age_in_seconds = 3600
      maximum_retry_attempts       = 3
    }
  }
  description = var.description
}
