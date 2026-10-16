#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of ElastiCache. Defaults true."
  default     = true
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable automatic discovery of ElastiCache clusters. When true, automatically fetches all cluster IDs. Defaults false."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) List of patterns to exclude from auto-discovered ElastiCache clusters. Supports substring matching."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) List of patterns to include from auto-discovered ElastiCache clusters. If empty, includes all. Supports substring matching."
  default     = []
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # AuthenticationFailures threshold (unit=Count)
    authentication_failures = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # BytesUsedForCache threshold (unit=Bytes)
    bytes_used_for_cache = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CacheHitRate threshold (unit=Percent)
    cache_hit_rate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CacheHits threshold (unit=Count)
    cache_hits = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CacheMisses threshold (unit=Count)
    cache_misses = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CommandAuthorizationFailures threshold (unit=Count)
    command_authorization_failures = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CPUUtilization threshold (unit=Percent)
    cpu_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CurrConnections threshold (unit=Count)
    curr_connections = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CurrItems threshold (unit=Count)
    curr_items = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # DatabaseCapacityUsagePercentage threshold (unit=Percent)
    database_capacity_usage_percentage = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # DatabaseMemoryUsagePercentage threshold (unit=Percent)
    database_memory_usage_percentage = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # EngineCPUUtilization threshold (unit=Percent)
    engine_cpu_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ErrorCount threshold (unit=Count)
    error_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Evictions threshold (unit=Count)
    evictions = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # FreeableMemory threshold (unit=Bytes)
    freeable_memory = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # IamAuthenticationExpirations threshold (unit=Count)
    iam_authentication_expirations = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # IamAuthenticationThrottling threshold (unit=Count)
    iam_authentication_throttling = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # KeyAuthorizationFailures threshold (unit=Count)
    key_authorization_failures = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # MemoryFragmentationRatio threshold (unit=None)
    memory_fragmentation_ratio = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # NetworkBytesIn threshold (unit=Bytes)
    network_bytes_in = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # NetworkBytesOut threshold (unit=Bytes)
    network_bytes_out = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # NewConnections threshold (unit=Count)
    new_connections = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ReplicationBytes threshold (unit=Bytes)
    replication_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ReplicationLag threshold (unit=Seconds)
    replication_lag = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # SaveInProgress threshold (unit=None)
    save_in_progress = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # SuccessfulReadRequestLatency threshold (unit=Microseconds)
    successful_read_request_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # SuccessfulWriteRequestLatency threshold (unit=Microseconds)
    successful_write_request_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # SwapUsage threshold (unit=Bytes)
    swap_usage = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # TrafficManagementActive threshold (unit=None)
    traffic_management_active = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in ElastiCache."
  default = {
    authentication_failures            = { enabled = true, value = 1 }
    bytes_used_for_cache               = { enabled = true, value = 3221225472 } # 3GB
    cache_hit_rate                     = { enabled = true, value = 10 }
    cache_hits                         = { enabled = false, value = 0 }
    cache_misses                       = { enabled = true, value = 1000 }
    command_authorization_failures     = { enabled = true, value = 1 }
    cpu_utilization                    = { enabled = true, value = 90 }
    curr_connections                   = { enabled = true, value = 50 }
    curr_items                         = { enabled = true, value = 100000 }
    database_capacity_usage_percentage = { enabled = true, value = 80 }
    database_memory_usage_percentage   = { enabled = true, value = 80 }
    engine_cpu_utilization             = { enabled = true, value = 90 }
    error_count                        = { enabled = true, value = 1 }
    evictions                          = { enabled = true, value = 100 }
    freeable_memory                    = { enabled = true, value = 1073741824 } # 1GB
    iam_authentication_expirations     = { enabled = true, value = 1 }
    iam_authentication_throttling      = { enabled = true, value = 1 }
    key_authorization_failures         = { enabled = true, value = 1 }
    memory_fragmentation_ratio         = { enabled = true, value = 5 }
    network_bytes_in                   = { enabled = true, value = 524288000 } # 500MB
    network_bytes_out                  = { enabled = true, value = 524288000 } # 500MB
    new_connections                    = { enabled = true, value = 100 }
    replication_bytes                  = { enabled = true, value = 104857600 } # 100MB
    replication_lag                    = { enabled = true, value = 30 }
    save_in_progress                   = { enabled = true, value = 1 }
    successful_read_request_latency    = { enabled = true, value = 10000 }
    successful_write_request_latency   = { enabled = true, value = 10000 }
    swap_usage                         = { enabled = true, value = 52428800 } # 50MB
    traffic_management_active          = { enabled = true, value = 1 }
  }
}

variable "threshold_override" {
  type = map(object({
    # AuthenticationFailures threshold (unit=Count)
    authentication_failures = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # BytesUsedForCache threshold (unit=Bytes)
    bytes_used_for_cache = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CacheHitRate threshold (unit=Percent)
    cache_hit_rate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CacheHits threshold (unit=Count)
    cache_hits = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CacheMisses threshold (unit=Count)
    cache_misses = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CommandAuthorizationFailures threshold (unit=Count)
    command_authorization_failures = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CPUUtilization threshold (unit=Percent)
    cpu_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CurrConnections threshold (unit=Count)
    curr_connections = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CurrItems threshold (unit=Count)
    curr_items = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DatabaseCapacityUsagePercentage threshold (unit=Percent)
    database_capacity_usage_percentage = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DatabaseMemoryUsagePercentage threshold (unit=Percent)
    database_memory_usage_percentage = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # EngineCPUUtilization threshold (unit=Percent)
    engine_cpu_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ErrorCount threshold (unit=Count)
    error_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Evictions threshold (unit=Count)
    evictions = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # FreeableMemory threshold (unit=Bytes)
    freeable_memory = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # IamAuthenticationExpirations threshold (unit=Count)
    iam_authentication_expirations = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # IamAuthenticationThrottling threshold (unit=Count)
    iam_authentication_throttling = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # KeyAuthorizationFailures threshold (unit=Count)
    key_authorization_failures = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # MemoryFragmentationRatio threshold (unit=None)
    memory_fragmentation_ratio = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkBytesIn threshold (unit=Bytes)
    network_bytes_in = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkBytesOut threshold (unit=Bytes)
    network_bytes_out = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NewConnections threshold (unit=Count)
    new_connections = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReplicationBytes threshold (unit=Bytes)
    replication_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReplicationLag threshold (unit=Seconds)
    replication_lag = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SaveInProgress threshold (unit=None)
    save_in_progress = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SuccessfulReadRequestLatency threshold (unit=Microseconds)
    successful_read_request_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SuccessfulWriteRequestLatency threshold (unit=Microseconds)
    successful_write_request_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # SwapUsage threshold (unit=Bytes)
    swap_usage = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # TrafficManagementActive threshold (unit=None)
    traffic_management_active = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the CacheClusterId. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "dimensions" {
  type        = list(map(any))
  description = "(Optional) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. Required when create_auto_dimensions is false."
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
