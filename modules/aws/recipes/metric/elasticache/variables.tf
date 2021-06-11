#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of Lambda. Defaults true."
  default     = true
}
variable "db_instance_class" {
  type        = string
  description = "(Optional) ElasicCache instance class."
  default     = ""
}
variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}
variable "threshold" {
  type = object({
    # (Required) AuthenticationFailures threshold (unit=Count)
    authentication_failures = number
    # (Required) CacheHitRate threshold (unit=Percent)
    cache_hit_rate = number
    # (Required) CommandAuthorizationFailures threshold (unit=Count)
    command_authorization_failures = number
    # (Required) CurrConnections threshold (unit=Count)
    curr_connections = number
    # (Required) DatabaseMemoryUsagePercentage threshold (unit=Percent)
    database_memory_usage_percentage = number
    # (Required) EngineCPUUtilization threshold (unit=Percent)
    engine_cpu_utilization = number
    # (Required) KeyAuthorizationFailures threshold (unit=Count)
    key_authorization_failures = number
    # (Required) NewConnections threshold (unit=Count)
    new_connections = number
    # (Required) SwapUsage threshold (unit=Bytes)
    swap_usage = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in ElastiCache."
  default = {
    authentication_failures          = 1
    cache_hit_rate                   = 10
    command_authorization_failures   = 1
    curr_connections                 = 50
    database_memory_usage_percentage = 80
    engine_cpu_utilization           = 90
    key_authorization_failures       = 1
    new_connections                  = 100
    swap_usage                       = 52428800 # 50MB
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
