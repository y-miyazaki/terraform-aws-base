#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of ElastiCache. Defaults true."
  default     = true
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
    # KeyAuthorizationFailures threshold (unit=Count)
    enabled_key_authorization_failures = bool
    key_authorization_failures         = number
    # NewConnections threshold (unit=Count)
    enabled_new_connections = bool
    new_connections         = number
    # SwapUsage threshold (unit=Bytes)
    enabled_swap_usage = bool
    swap_usage         = number
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
    enabled_key_authorization_failures       = true
    key_authorization_failures               = 1
    enabled_new_connections                  = true
    new_connections                          = 100
    enabled_swap_usage                       = true
    swap_usage                               = 52428800 # 50MB
  }
}
variable "dimensions" {
  type        = list(map(any))
  description = "(Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
}
variable "name_prefix" {
  type        = string
  description = "(Required) Center for Internet Security CloudWatch Filter/Alarm name prefix."
}
variable "alarm_actions" {
  type        = list(string)
  description = "(Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
}
variable "ok_actions" {
  type        = list(string)
  description = "(Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN)."
  default     = null
}
variable "tags" {
  type        = map(any)
  description = "(Optional) Key-value map of resource tags."
  default     = null
}
