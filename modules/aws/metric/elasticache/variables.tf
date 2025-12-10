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
    # CacheHitRate threshold (unit=Percent)
    enabled_cache_hit_rate = bool
    cache_hit_rate         = number
    # CommandAuthorizationFailures threshold (unit=Count)
    enabled_command_authorization_failures = bool
    command_authorization_failures         = number
    # CurrConnections threshold (unit=Count)
    enabled_curr_connections = bool
    curr_connections         = number
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
    enabled_authentication_failures          = true
    authentication_failures                  = 1
    enabled_cache_hit_rate                   = true
    cache_hit_rate                           = 10
    enabled_command_authorization_failures   = true
    command_authorization_failures           = 1
    enabled_curr_connections                 = true
    curr_connections                         = 50
    enabled_database_memory_usage_percentage = true
    database_memory_usage_percentage         = 80
    enabled_engine_cpu_utilization           = true
    engine_cpu_utilization                   = 90
    enabled_error_count                      = true
    error_count                              = 1
    enabled_evictions                        = true
    evictions                                = 100
    enabled_iam_authentication_expirations   = true
    iam_authentication_expirations           = 1
    enabled_iam_authentication_throttling    = true
    iam_authentication_throttling            = 1
    enabled_key_authorization_failures       = true
    key_authorization_failures               = 1
    enabled_memory_fragmentation_ratio       = true
    memory_fragmentation_ratio               = 5
    enabled_new_connections                  = true
    new_connections                          = 100
    enabled_replication_bytes                = true
    replication_bytes                        = 104857600 # 100MB
    enabled_replication_lag                  = true
    replication_lag                          = 30
    enabled_save_in_progress                 = true
    save_in_progress                         = 1
    enabled_successful_read_request_latency  = true
    successful_read_request_latency          = 10000
    enabled_successful_write_request_latency = true
    successful_write_request_latency         = 10000
    enabled_swap_usage                       = true
    swap_usage                               = 52428800 # 50MB
    enabled_traffic_management_active        = true
    traffic_management_active                = 1
  }
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
