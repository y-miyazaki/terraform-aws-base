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
    enabled_commit_queue_length = bool
    commit_queue_length         = number
    # (Required) ConcurrencyScalingActiveClusters threshold (unit=Count)
    enabled_concurrency_scaling_active_clusters = bool
    concurrency_scaling_active_clusters         = number
    # (Required) ConcurrencyScalingSeconds threshold (unit=Sum)
    enabled_concurrency_scaling_seconds = bool
    concurrency_scaling_seconds         = number
    # (Required) CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = bool
    cpu_utilization         = number
    # (Required) DatabaseConnections threshold (unit=Count)
    enabled_database_connections = bool
    database_connections         = number
    # (Required) HealthStatus threshold (HEALTHY(1)/UNHEALTHY(0))
    enabled_health_status = bool
    health_status         = number
    # (Required) MaintenanceMode threshold (unit=Count(ON(1)/OFF(0)))
    enabled_maintenance_mode = bool
    maintenance_mode         = number
    # (Required) MaxConfiguredConcurrencyScalingClusters threshold (unit=Count)
    enabled_max_configured_concurrency_scaling_clusters = bool
    max_configured_concurrency_scaling_clusters         = number
    # (Required) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    enabled_network_receive_throughput = bool
    network_receive_throughput         = number
    # (Required) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    enabled_network_transmit_throughput = bool
    network_transmit_throughput         = number
    # (Required) PercentageDiskSpaceUsed threshold (unit=Percent)
    enabled_percentage_disk_space_used = bool
    percentage_disk_space_used         = number
    # (Required) QueriesCompletedPerSecond threshold (unit=Count/Second)
    enabled_queries_completed_per_second = bool
    queries_completed_per_second         = number
    # (Required) QueryDuration threshold (unit=Microseconds)
    enabled_query_duration = bool
    query_duration         = number
    # (Required) QueryRuntimeBreakdown threshold (unit=Microseconds)
    enabled_query_runtime_breakdown = bool
    query_runtime_breakdown         = number
    # (Required) ReadIOPS threshold (unit=Count/Second)
    enabled_read_iops = bool
    read_iops         = number
    # (Required) ReadLatency threshold (unit=Seconds)
    enabled_read_latency = bool
    read_latency         = number
    # (Required) ReadThroughput threshold (unit=Bytes)
    enabled_read_throughput = bool
    read_throughput         = number
    # (Required) RedshiftManagedStorageTotalCapacity threshold (unit=Megabytes)
    enabled_redshift_managed_storage_total_capacity = bool
    redshift_managed_storage_total_capacity         = number
    # (Required) TotalTableCount threshold (unit=Count)
    enabled_total_table_count = bool
    total_table_count         = number
    # (Required) WLMQueueLength threshold (unit=Count)
    enabled_wlm_queue_length = bool
    wlm_queue_length         = number
    # (Required) WLMQueueWaitTime threshold (unit=Milliseconds)
    enabled_wlm_queue_wait_time = bool
    wlm_queue_wait_time         = number
    # (Required) WLMQueriesCompletedPerSecond threshold (unit=Count/Second)
    enabled_wlm_queries_completed_per_second = bool
    wlm_queries_completed_per_second         = number
    # (Required) WLMQueryDuration threshold (unit=Microseconds)
    enabled_wlm_query_duration = bool
    wlm_query_duration         = number
    # (Required) WLMRunningQueries threshold (unit=Count)
    enabled_wlm_running_queries = bool
    wlm_running_queries         = number
    # (Required) WriteIOPS threshold (unit=Count/Second)
    enabled_write_iops = bool
    write_iops         = number
    # (Required) WriteLatency threshold (unit=Seconds)
    enabled_write_latency = bool
    write_latency         = number
    # (Required) WriteThroughput threshold (unit=Bytes)
    enabled_write_throughput = bool
    write_throughput         = number
    # (Required) SchemaQuota threshold (unit=Megabytes)
    enabled_schema_quota = bool
    schema_quota         = number
    # (Required) NumExceededSchemaQuotas threshold (unit=Count)
    enabled_num_exceeded_schema_quotas = bool
    num_exceeded_schema_quotas         = number
    # (Required) StorageUsed threshold (unit=Megabytes)
    enabled_storage_used = bool
    storage_used         = number
    # (Required) PercentageQuotaUsed threshold (unit=Percent)
    enabled_percentage_quota_used = bool
    percentage_quota_used         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in SES."
  default = {
    # (Required) CommitQueueLength threshold (unit=Count)
    enabled_commit_queue_length = true
    commit_queue_length         = 100
    # (Required) ConcurrencyScalingActiveClusters threshold (unit=Count)
    enabled_concurrency_scaling_active_clusters = true
    concurrency_scaling_active_clusters         = 100
    # (Required) ConcurrencyScalingSeconds threshold (unit=Sum)
    enabled_concurrency_scaling_seconds = true
    concurrency_scaling_seconds         = 10
    # (Required) CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = true
    cpu_utilization         = 80
    # (Required) DatabaseConnections threshold (unit=Count)
    enabled_database_connections = true
    database_connections         = 100
    # (Required) HealthStatus threshold (HEALTHY(1)/UNHEALTHY(0))
    enabled_health_status = true
    health_status         = 0
    # (Required) MaintenanceMode threshold (unit=Count(ON(1)/OFF(0)))
    enabled_maintenance_mode = true
    maintenance_mode         = 1
    # (Required) MaxConfiguredConcurrencyScalingClusters threshold (unit=Count)
    enabled_max_configured_concurrency_scaling_clusters = true
    max_configured_concurrency_scaling_clusters         = 5
    # (Required) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    enabled_network_receive_throughput = false
    network_receive_throughput         = 1024 * 1024
    # (Required) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    enabled_network_transmit_throughput = false
    network_transmit_throughput         = 1024 * 1024
    # (Required) PercentageDiskSpaceUsed threshold (unit=Percent)
    enabled_percentage_disk_space_used = true
    percentage_disk_space_used         = 80
    # (Required) QueriesCompletedPerSecond threshold (unit=Count/Second)
    enabled_queries_completed_per_second = true
    queries_completed_per_second         = 100
    # (Required) QueryDuration threshold (unit=Microseconds)
    enabled_query_duration = true
    query_duration         = 3000000
    # (Required) QueryRuntimeBreakdown threshold (unit=Microseconds)
    enabled_query_runtime_breakdown = true
    query_runtime_breakdown         = 3000000
    # (Required) ReadIOPS threshold (unit=Count/Second)
    enabled_read_iops = false
    read_iops         = 1000
    # (Required) ReadLatency threshold (unit=Seconds)
    enabled_read_latency = true
    read_latency         = 3
    # (Required) ReadThroughput threshold (unit=Bytes)
    enabled_read_throughput = false
    read_throughput         = 1024 * 1024 * 1024
    # (Required) RedshiftManagedStorageTotalCapacity threshold (unit=Megabytes)
    enabled_redshift_managed_storage_total_capacity = true
    redshift_managed_storage_total_capacity         = 10240
    # (Required) TotalTableCount threshold (unit=Count)
    enabled_total_table_count = false
    total_table_count         = 50
    # (Required) WLMQueueLength threshold (unit=Count)
    enabled_wlm_queue_length = true
    wlm_queue_length         = 100
    # (Required) WLMQueueWaitTime threshold (unit=Milliseconds)
    enabled_wlm_queue_wait_time = true
    wlm_queue_wait_time         = 100
    # (Required) WLMQueriesCompletedPerSecond threshold (unit=Count/Second)
    enabled_wlm_queries_completed_per_second = false
    wlm_queries_completed_per_second         = 100
    # (Required) WLMQueryDuration threshold (unit=Microseconds)
    enabled_wlm_query_duration = true
    wlm_query_duration         = 3000000
    # (Required) WLMRunningQueries threshold (unit=Count)
    enabled_wlm_running_queries = false
    wlm_running_queries         = 10
    # (Required) WriteIOPS threshold (unit=Count/Second)
    enabled_write_iops = false
    write_iops         = 1000
    # (Required) WriteLatency threshold (unit=Seconds)
    enabled_write_latency = true
    write_latency         = 3
    # (Required) WriteThroughput threshold (unit=Bytes)
    enabled_write_throughput = false
    write_throughput         = 1024 * 1024 * 1024
    # (Required) WriteThroughput threshold (unit=Bytes)
    enabled_write_throughput = false
    write_throughput         = 1024 * 1024 * 1024
    # (Required) SchemaQuota threshold (unit=Megabytes)
    enabled_schema_quota = false
    schema_quota         = 1024
    # (Required) NumExceededSchemaQuotas threshold (unit=Count)
    enabled_num_exceeded_schema_quotas = false
    num_exceeded_schema_quotas         = 10
    # (Required) StorageUsed threshold (unit=Megabytes)
    enabled_storage_used = false
    storage_used         = 1024
    # (Required) PercentageQuotaUsed threshold (unit=Percent)
    enabled_percentage_quota_used = false
    percentage_quota_used         = 1024
  }
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
