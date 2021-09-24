#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of ALB. Defaults true."
  default     = true
}
variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}
variable "threshold" {
  type = object({
    # ActiveConnectionCount threshold (unit=Count)
    enabled_active_connection_count = bool
    active_connection_count         = number
    # ClientTLSNegotiationErrorCount threshold (unit=Count)
    enabled_client_tls_negotiation_error_count = bool
    client_tls_negotiation_error_count         = number
    # ConsumedLCUs threshold (unit=Count)
    enabled_consumed_lcus = bool
    consumed_lcus         = number
    # HTTPCode_4XX_Count	threshold (unit=Count)
    enabled_httpcode_4xx_count = bool
    httpcode_4xx_count         = number
    # HTTPCode_5XX_Count	threshold (unit=Count)
    enabled_httpcode_5xx_count = bool
    httpcode_5xx_count         = number
    # HTTPCode_ELB_4XX_Count	threshold (unit=Count)
    enabled_httpcode_elb_4xx_count = bool
    httpcode_elb_4xx_count         = number
    # HTTPCode_ELB_5XX_Count	threshold (unit=Count)
    enabled_httpcode_elb_5xx_count = bool
    httpcode_elb_5xx_count         = number
    # TargetResponseTime	threshold (unit=)
    enabled_target_response_time = bool
    target_response_time         = number
    # TargetTLSNegotiationErrorCount	threshold (unit=Count)
    enabled_target_tls_negotiation_error_count = bool
    target_tls_negotiation_error_count         = number
    # UnHealthyHostCount	threshold (unit=Count)
    enabled_unhealthy_host_count = bool
    unhealthy_host_count         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in ALB."
  default = {
    enabled_active_connection_count            = true
    active_connection_count                    = 10000
    enabled_client_tls_negotiation_error_count = true
    client_tls_negotiation_error_count         = 10
    enabled_consumed_lcus                      = true
    consumed_lcus                              = 5
    enabled_httpcode_4xx_count                 = true
    httpcode_4xx_count                         = 1
    enabled_httpcode_5xx_count                 = true
    httpcode_5xx_count                         = 1
    enabled_httpcode_elb_4xx_count             = true
    httpcode_elb_4xx_count                     = 1
    enabled_httpcode_elb_5xx_count             = true
    httpcode_elb_5xx_count                     = 1
    enabled_target_response_time               = true
    target_response_time                       = 10
    enabled_target_tls_negotiation_error_count = true
    target_tls_negotiation_error_count         = 10
    enabled_unhealthy_host_count               = true
    unhealthy_host_count                       = 1
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
