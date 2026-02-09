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
    enabled_authentication_failures = bool
    authentication_failures         = number
    # BytesUsedForCache threshold (unit=Bytes)
    enabled_bytes_used_for_cache = bool
    bytes_used_for_cache         = number
    # CacheHitRate threshold (unit=Percent)
    enabled_cache_hit_rate = bool
    cache_hit_rate         = number
    # CacheHits threshold (unit=Count)
    enabled_cache_hits = bool
    cache_hits         = number
    # CacheMisses threshold (unit=Count)
    enabled_cache_misses = bool
    cache_misses         = number
    # CommandAuthorizationFailures threshold (unit=Count)
    enabled_command_authorization_failures = bool
    command_authorization_failures         = number
    # CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = bool
    cpu_utilization         = number
    # CurrConnections threshold (unit=Count)
    enabled_curr_connections = bool
    curr_connections         = number
    # CurrItems threshold (unit=Count)
    enabled_curr_items = bool
    curr_items         = number
    # DatabaseCapacityUsagePercentage threshold (unit=Percent)
    enabled_database_capacity_usage_percentage = bool
    database_capacity_usage_percentage         = number
    # DatabaseMemoryUsagePercentage threshold (unit=Percent)
    enabled_database_memory_usage_percentage = bool
    database_memory_usage_percentage         = number
    # EngineCPUUtilization threshold (unit=Percent)
    enabled_engine_cpu_utilization = bool
    engine_cpu_utilization         = number
    # ErrorCount threshold (unit=Count)
    enabled_error_count = bool
    error_count         = number
    # Evictions threshold (unit=Count)
    enabled_evictions = bool
    evictions         = number
    # FreeableMemory threshold (unit=Bytes)
    enabled_freeable_memory = bool
    freeable_memory         = number
    # IamAuthenticationExpirations threshold (unit=Count)
    enabled_iam_authentication_expirations = bool
    iam_authentication_expirations         = number
    # IamAuthenticationThrottling threshold (unit=Count)
    enabled_iam_authentication_throttling = bool
    iam_authentication_throttling         = number
    # KeyAuthorizationFailures threshold (unit=Count)
    enabled_key_authorization_failures = bool
    key_authorization_failures         = number
    # MemoryFragmentationRatio threshold (unit=None)
    enabled_memory_fragmentation_ratio = bool
    memory_fragmentation_ratio         = number
    # NetworkBytesIn threshold (unit=Bytes)
    enabled_network_bytes_in = bool
    network_bytes_in         = number
    # NetworkBytesOut threshold (unit=Bytes)
    enabled_network_bytes_out = bool
    network_bytes_out         = number
    # NewConnections threshold (unit=Count)
    enabled_new_connections = bool
    new_connections         = number
    # ReplicationBytes threshold (unit=Bytes)
    enabled_replication_bytes = bool
    replication_bytes         = number
    # ReplicationLag threshold (unit=Seconds)
    enabled_replication_lag = bool
    replication_lag         = number
    # SaveInProgress threshold (unit=None)
    enabled_save_in_progress = bool
    save_in_progress         = number
    # SuccessfulReadRequestLatency threshold (unit=Microseconds)
    enabled_successful_read_request_latency = bool
    successful_read_request_latency         = number
    # SuccessfulWriteRequestLatency threshold (unit=Microseconds)
    enabled_successful_write_request_latency = bool
    successful_write_request_latency         = number
    # SwapUsage threshold (unit=Bytes)
    enabled_swap_usage = bool
    swap_usage         = number
    # TrafficManagementActive threshold (unit=None)
    enabled_traffic_management_active = bool
    traffic_management_active         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in ElastiCache."
  default = {
    enabled_authentication_failures            = true
    authentication_failures                    = 1
    enabled_bytes_used_for_cache               = true
    bytes_used_for_cache                       = 3221225472 # 3GB
    enabled_cache_hit_rate                     = true
    cache_hit_rate                             = 10
    enabled_cache_hits                         = false
    cache_hits                                 = 0
    enabled_cache_misses                       = true
    cache_misses                               = 1000
    enabled_command_authorization_failures     = true
    command_authorization_failures             = 1
    enabled_cpu_utilization                    = true
    cpu_utilization                            = 90
    enabled_curr_connections                   = true
    curr_connections                           = 50
    enabled_curr_items                         = true
    curr_items                                 = 100000
    enabled_database_capacity_usage_percentage = true
    database_capacity_usage_percentage         = 80
    enabled_database_memory_usage_percentage   = true
    database_memory_usage_percentage           = 80
    enabled_engine_cpu_utilization             = true
    engine_cpu_utilization                     = 90
    enabled_error_count                        = true
    error_count                                = 1
    enabled_evictions                          = true
    evictions                                  = 100
    enabled_freeable_memory                    = true
    freeable_memory                            = 1073741824 # 1GB
    enabled_iam_authentication_expirations     = true
    iam_authentication_expirations             = 1
    enabled_iam_authentication_throttling      = true
    iam_authentication_throttling              = 1
    enabled_key_authorization_failures         = true
    key_authorization_failures                 = 1
    enabled_memory_fragmentation_ratio         = true
    memory_fragmentation_ratio                 = 5
    enabled_network_bytes_in                   = true
    network_bytes_in                           = 524288000 # 500MB
    enabled_network_bytes_out                  = true
    network_bytes_out                          = 524288000 # 500MB
    enabled_new_connections                    = true
    new_connections                            = 100
    enabled_replication_bytes                  = true
    replication_bytes                          = 104857600 # 100MB
    enabled_replication_lag                    = true
    replication_lag                            = 30
    enabled_save_in_progress                   = true
    save_in_progress                           = 1
    enabled_successful_read_request_latency    = true
    successful_read_request_latency            = 10000
    enabled_successful_write_request_latency   = true
    successful_write_request_latency           = 10000
    enabled_swap_usage                         = true
    swap_usage                                 = 52428800 # 50MB
    enabled_traffic_management_active          = true
    traffic_management_active                  = 1
  }
}
variable "threshold_override" {
  type = map(object({
    # (Optional) AuthenticationFailures threshold (unit=Count)
    enabled_authentication_failures = optional(bool)
    authentication_failures         = optional(number)
    # (Optional) BytesUsedForCache threshold (unit=Bytes)
    enabled_bytes_used_for_cache = optional(bool)
    bytes_used_for_cache         = optional(number)
    # (Optional) CacheHitRate threshold (unit=Percent)
    enabled_cache_hit_rate = optional(bool)
    cache_hit_rate         = optional(number)
    # (Optional) CacheHits threshold (unit=Count)
    enabled_cache_hits = optional(bool)
    cache_hits         = optional(number)
    # (Optional) CacheMisses threshold (unit=Count)
    enabled_cache_misses = optional(bool)
    cache_misses         = optional(number)
    # (Optional) CommandAuthorizationFailures threshold (unit=Count)
    enabled_command_authorization_failures = optional(bool)
    command_authorization_failures         = optional(number)
    # (Optional) CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = optional(bool)
    cpu_utilization         = optional(number)
    # (Optional) CurrConnections threshold (unit=Count)
    enabled_curr_connections = optional(bool)
    curr_connections         = optional(number)
    # (Optional) CurrItems threshold (unit=Count)
    enabled_curr_items = optional(bool)
    curr_items         = optional(number)
    # (Optional) DatabaseCapacityUsagePercentage threshold (unit=Percent)
    enabled_database_capacity_usage_percentage = optional(bool)
    database_capacity_usage_percentage         = optional(number)
    # (Optional) DatabaseMemoryUsagePercentage threshold (unit=Percent)
    enabled_database_memory_usage_percentage = optional(bool)
    database_memory_usage_percentage         = optional(number)
    # (Optional) EngineCPUUtilization threshold (unit=Percent)
    enabled_engine_cpu_utilization = optional(bool)
    engine_cpu_utilization         = optional(number)
    # (Optional) ErrorCount threshold (unit=Count)
    enabled_error_count = optional(bool)
    error_count         = optional(number)
    # (Optional) Evictions threshold (unit=Count)
    enabled_evictions = optional(bool)
    evictions         = optional(number)
    # (Optional) FreeableMemory threshold (unit=Bytes)
    enabled_freeable_memory = optional(bool)
    freeable_memory         = optional(number)
    # (Optional) IamAuthenticationExpirations threshold (unit=Count)
    enabled_iam_authentication_expirations = optional(bool)
    iam_authentication_expirations         = optional(number)
    # (Optional) IamAuthenticationThrottling threshold (unit=Count)
    enabled_iam_authentication_throttling = optional(bool)
    iam_authentication_throttling         = optional(number)
    # (Optional) KeyAuthorizationFailures threshold (unit=Count)
    enabled_key_authorization_failures = optional(bool)
    key_authorization_failures         = optional(number)
    # (Optional) MemoryFragmentationRatio threshold (unit=None)
    enabled_memory_fragmentation_ratio = optional(bool)
    memory_fragmentation_ratio         = optional(number)
    # (Optional) NetworkBytesIn threshold (unit=Bytes)
    enabled_network_bytes_in = optional(bool)
    network_bytes_in         = optional(number)
    # (Optional) NetworkBytesOut threshold (unit=Bytes)
    enabled_network_bytes_out = optional(bool)
    network_bytes_out         = optional(number)
    # (Optional) NewConnections threshold (unit=Count)
    enabled_new_connections = optional(bool)
    new_connections         = optional(number)
    # (Optional) ReplicationBytes threshold (unit=Bytes)
    enabled_replication_bytes = optional(bool)
    replication_bytes         = optional(number)
    # (Optional) ReplicationLag threshold (unit=Seconds)
    enabled_replication_lag = optional(bool)
    replication_lag         = optional(number)
    # (Optional) SaveInProgress threshold (unit=None)
    enabled_save_in_progress = optional(bool)
    save_in_progress         = optional(number)
    # (Optional) SuccessfulReadRequestLatency threshold (unit=Microseconds)
    enabled_successful_read_request_latency = optional(bool)
    successful_read_request_latency         = optional(number)
    # (Optional) SuccessfulWriteRequestLatency threshold (unit=Microseconds)
    enabled_successful_write_request_latency = optional(bool)
    successful_write_request_latency         = optional(number)
    # (Optional) SwapUsage threshold (unit=Bytes)
    enabled_swap_usage = optional(bool)
    swap_usage         = optional(number)
    # (Optional) TrafficManagementActive threshold (unit=None)
    enabled_traffic_management_active = optional(bool)
    traffic_management_active         = optional(number)
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the CacheClusterId."
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
