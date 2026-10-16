#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of SES. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # (Required) CommitQueueLength threshold (unit=Count)
    commit_queue_length = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ConcurrencyScalingActiveClusters threshold (unit=Count)
    concurrency_scaling_active_clusters = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ConcurrencyScalingSeconds threshold (unit=Seconds)
    concurrency_scaling_seconds = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) CPUUtilization threshold (unit=Percent)
    cpu_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) DatabaseConnections threshold (unit=Count)
    database_connections = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) HealthStatus threshold (HEALTHY(1)/UNHEALTHY(0))
    health_status = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) MaintenanceMode threshold (unit=Count(ON(1)/OFF(0)))
    maintenance_mode = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) MaxConfiguredConcurrencyScalingClusters threshold (unit=Count)
    max_configured_concurrency_scaling_clusters = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    network_receive_throughput = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    network_transmit_throughput = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NumExceededSchemaQuotas threshold (unit=Count)
    num_exceeded_schema_quotas = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) SchemaQuota threshold (unit=Megabytes)
    schema_quota = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) StorageUsed threshold (unit=Megabytes)
    storage_used = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) PercentageDiskSpaceUsed threshold (unit=Percent)
    percentage_disk_space_used = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) PercentageQuotaUsed threshold (unit=Percent)
    percentage_quota_used = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) QueriesCompletedPerSecond threshold (unit=Count/Second)
    queries_completed_per_second = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) QueryDuration threshold (unit=Microseconds)
    query_duration = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) QueryRuntimeBreakdown threshold (unit=Microseconds)
    query_runtime_breakdown = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ReadIOPS threshold (unit=Count/Second)
    read_iops = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ReadLatency threshold (unit=Seconds)
    read_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) ReadThroughput threshold (unit=Bytes)
    read_throughput = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) RedshiftManagedStorageTotalCapacity threshold (unit=Megabytes)
    redshift_managed_storage_total_capacity = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) TotalTableCount threshold (unit=Count)
    total_table_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) WLMQueueLength threshold (unit=Count)
    wlm_queue_length = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) WLMQueueWaitTime threshold (unit=Milliseconds)
    wlm_queue_wait_time = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) WLMQueriesCompletedPerSecond threshold (unit=Count/Second)
    wlm_queries_completed_per_second = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) WLMQueryDuration threshold (unit=Microseconds)
    wlm_query_duration = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) WLMRunningQueries threshold (unit=Count)
    wlm_running_queries = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) WriteIOPS threshold (unit=Count/Second)
    write_iops = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) WriteLatency threshold (unit=Seconds)
    write_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) WriteThroughput threshold (unit=Bytes)
    write_throughput = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in SES."
  default = {
    # (Required) CommitQueueLength threshold (unit=Count)
    commit_queue_length = { enabled = true, value = 100 }
    # (Required) ConcurrencyScalingActiveClusters threshold (unit=Count)
    concurrency_scaling_active_clusters = { enabled = true, value = 100 }
    # (Required) ConcurrencyScalingSeconds threshold (unit=Seconds)
    concurrency_scaling_seconds = { enabled = true, value = 10 }
    # (Required) CPUUtilization threshold (unit=Percent)
    cpu_utilization = { enabled = true, value = 80 }
    # (Required) DatabaseConnections threshold (unit=Count)
    database_connections = { enabled = true, value = 100 }
    # (Required) HealthStatus threshold (HEALTHY(1)/UNHEALTHY(0))
    health_status = { enabled = true, value = 0 }
    # (Required) MaintenanceMode threshold (unit=Count(ON(1)/OFF(0)))
    maintenance_mode = { enabled = true, value = 1 }
    # (Required) MaxConfiguredConcurrencyScalingClusters threshold (unit=Count)
    max_configured_concurrency_scaling_clusters = { enabled = true, value = 5 }
    # (Required) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    network_receive_throughput = { enabled = false, value = 1024 * 1024 }
    # (Required) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    network_transmit_throughput = { enabled = false, value = 1024 * 1024 }
    # (Required) NumExceededSchemaQuotas threshold (unit=Count)
    num_exceeded_schema_quotas = { enabled = false, value = 10 }
    # (Required) PercentageDiskSpaceUsed threshold (unit=Percent)
    percentage_disk_space_used = { enabled = true, value = 80 }
    # (Required) PercentageQuotaUsed threshold (unit=Percent)
    percentage_quota_used = { enabled = false, value = 1024 }
    # (Required) QueriesCompletedPerSecond threshold (unit=Count/Second)
    queries_completed_per_second = { enabled = true, value = 100 }
    # (Required) QueryDuration threshold (unit=Microseconds)
    query_duration = { enabled = true, value = 3000000 }
    # (Required) QueryRuntimeBreakdown threshold (unit=Microseconds)
    query_runtime_breakdown = { enabled = true, value = 3000000 }
    # (Required) ReadIOPS threshold (unit=Count/Second)
    read_iops = { enabled = false, value = 1000 }
    # (Required) ReadLatency threshold (unit=Seconds)
    read_latency = { enabled = true, value = 3 }
    # (Required) ReadThroughput threshold (unit=Bytes)
    read_throughput = { enabled = false, value = 1024 * 1024 * 1024 }
    # (Required) RedshiftManagedStorageTotalCapacity threshold (unit=Megabytes)
    redshift_managed_storage_total_capacity = { enabled = false, value = 1024 * 1024 * 500 }
    # (Required) SchemaQuota threshold (unit=Megabytes)
    schema_quota = { enabled = false, value = 1024 }
    # (Required) StorageUsed threshold (unit=Megabytes)
    storage_used = { enabled = false, value = 1024 }
    # (Required) TotalTableCount threshold (unit=Count)
    total_table_count = { enabled = false, value = 50 }
    # (Required) WLMQueueLength threshold (unit=Count)
    wlm_queue_length = { enabled = true, value = 100 }
    # (Required) WLMQueueWaitTime threshold (unit=Milliseconds)
    wlm_queue_wait_time = { enabled = true, value = 100 }
    # (Required) WLMQueriesCompletedPerSecond threshold (unit=Count/Second)
    wlm_queries_completed_per_second = { enabled = false, value = 100 }
    # (Required) WLMQueryDuration threshold (unit=Microseconds)
    wlm_query_duration = { enabled = true, value = 3000000 }
    # (Required) WLMRunningQueries threshold (unit=Count)
    wlm_running_queries = { enabled = false, value = 10 }
    # (Required) WriteIOPS threshold (unit=Count/Second)
    write_iops = { enabled = false, value = 1000 }
    # (Required) WriteLatency threshold (unit=Seconds)
    write_latency = { enabled = true, value = 3 }
    # (Required) WriteThroughput threshold (unit=Bytes)
    write_throughput = { enabled = false, value = 1024 * 1024 * 1024 }
  }
}

variable "threshold_override" {
  type = map(object({
    # CommitQueueLength threshold (unit=Count)
    commit_queue_length = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ConcurrencyScalingActiveClusters threshold (unit=Count)
    concurrency_scaling_active_clusters = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ConcurrencyScalingSeconds threshold (unit=Seconds)
    concurrency_scaling_seconds = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CPUUtilization threshold (unit=Percent)
    cpu_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DatabaseConnections threshold (unit=Count)
    database_connections = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # HealthStatus threshold (HEALTHY(1)/UNHEALTHY(0))
    health_status = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # MaintenanceMode threshold (unit=Count(ON(1)/OFF(0)))
    maintenance_mode = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # MaxConfiguredConcurrencyScalingClusters threshold (unit=Count)
    max_configured_concurrency_scaling_clusters = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkReceiveThroughput threshold (unit=Bytes/Second)
    network_receive_throughput = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkTransmitThroughput threshold (unit=Bytes/Second)
    network_transmit_throughput = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NumExceededSchemaQuotas threshold (unit=Count)
    num_exceeded_schema_quotas = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SchemaQuota threshold (unit=Megabytes)
    schema_quota = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # StorageUsed threshold (unit=Megabytes)
    storage_used = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PercentageDiskSpaceUsed threshold (unit=Percent)
    percentage_disk_space_used = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PercentageQuotaUsed threshold (unit=Percent)
    percentage_quota_used = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # QueriesCompletedPerSecond threshold (unit=Count/Second)
    queries_completed_per_second = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # QueryDuration threshold (unit=Microseconds)
    query_duration = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # QueryRuntimeBreakdown threshold (unit=Microseconds)
    query_runtime_breakdown = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReadIOPS threshold (unit=Count/Second)
    read_iops = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReadLatency threshold (unit=Seconds)
    read_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReadThroughput threshold (unit=Bytes)
    read_throughput = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # RedshiftManagedStorageTotalCapacity threshold (unit=Megabytes)
    redshift_managed_storage_total_capacity = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TotalTableCount threshold (unit=Count)
    total_table_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WLMQueueLength threshold (unit=Count)
    wlm_queue_length = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WLMQueueWaitTime threshold (unit=Milliseconds)
    wlm_queue_wait_time = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WLMQueriesCompletedPerSecond threshold (unit=Count/Second)
    wlm_queries_completed_per_second = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WLMQueryDuration threshold (unit=Microseconds)
    wlm_query_duration = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WLMRunningQueries threshold (unit=Count)
    wlm_running_queries = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WriteIOPS threshold (unit=Count/Second)
    write_iops = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WriteLatency threshold (unit=Seconds)
    write_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WriteThroughput threshold (unit=Bytes)
    write_throughput = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the ClusterIdentifier. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of Redshifts to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of Redshifts will be automatically registered, but at that time, specify the Redshift name you want to exclude using partial match."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of Redshifts will be automatically registered, but at that time, specify the Redshift cluster identifier you want to include using partial match. If empty, all Redshifts will be included (except excluded ones)."
  default     = []
}

variable "dimensions" {
  type        = list(map(any))
  description = "(Optional) If create_auto_dimensions is set to false, The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
  default     = []
}

variable "name_prefix" {
  type        = string
  description = "(Required) CloudWatch Filter/Alarm name prefix."
}

variable "alarm_actions" {
  type        = list(string)
  description = "(Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}

variable "ok_actions" {
  type        = list(string)
  description = "(Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}

variable "insufficient_data_actions" {
  type        = list(string)
  description = "(Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = []
}

variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
