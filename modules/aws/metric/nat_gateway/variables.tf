#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of NAT Gateway. Defaults true."
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
    active_connection_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # BytesOutToDestination threshold (unit=Bytes)
    bytes_out_to_destination = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # BytesInFromSource threshold (unit=Bytes)
    bytes_in_from_source = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # BytesInFromDestination threshold (unit=Bytes)
    bytes_in_from_destination = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # BytesOutToSource threshold (unit=Bytes)
    bytes_out_to_source = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # PacketsDropCount threshold (unit=Count)
    packets_drop_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ErrorPortAllocation threshold (unit=Count)
    error_port_allocation = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # IdleTimeoutCount threshold (unit=Count)
    idle_timeout_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # PacketsInFromDestination threshold (unit=Count)
    packets_in_from_destination = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # PacketsInFromSource threshold (unit=Count)
    packets_in_from_source = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # PacketsOutToDestination threshold (unit=Count)
    packets_out_to_destination = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # PacketsOutToSource threshold (unit=Count)
    packets_out_to_source = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ConnectionAttemptCount threshold (unit=Count)
    connection_attempt_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ConnectionEstablishedCount threshold (unit=Count)
    connection_established_count = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # PeakBytesPerSecond threshold (unit=Bytes/Second)
    peak_bytes_per_second = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # PeakPacketsPerSecond threshold (unit=Count/Second)
    peak_packets_per_second = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in NAT Gateway."
  default = {
    active_connection_count      = { enabled = false, value = 10000 }
    bytes_out_to_destination     = { enabled = true, value = 107374182400 }  # 100GB in bytes
    bytes_in_from_source         = { enabled = true, value = 107374182400 }  # 100GB in bytes
    bytes_in_from_destination    = { enabled = false, value = 107374182400 } # 100GB in bytes
    bytes_out_to_source          = { enabled = false, value = 107374182400 } # 100GB in bytes
    packets_drop_count           = { enabled = true, value = 100 }
    error_port_allocation        = { enabled = true, value = 10 }
    idle_timeout_count           = { enabled = false, value = 100 }
    packets_in_from_destination  = { enabled = false, value = 10000000 }
    packets_in_from_source       = { enabled = false, value = 10000000 }
    packets_out_to_destination   = { enabled = false, value = 10000000 }
    packets_out_to_source        = { enabled = false, value = 10000000 }
    connection_attempt_count     = { enabled = true, value = 10000 }
    connection_established_count = { enabled = true, value = 10000 }
    peak_bytes_per_second        = { enabled = false, value = 1073741824 } # 1GB/sec
    peak_packets_per_second      = { enabled = false, value = 100000 }
  }
}

variable "threshold_override" {
  type = map(object({
    # ActiveConnectionCount threshold (unit=Count)
    active_connection_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # BytesOutToDestination threshold (unit=Bytes)
    bytes_out_to_destination = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # BytesInFromSource threshold (unit=Bytes)
    bytes_in_from_source = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # BytesInFromDestination threshold (unit=Bytes)
    bytes_in_from_destination = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # BytesOutToSource threshold (unit=Bytes)
    bytes_out_to_source = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PacketsDropCount threshold (unit=Count)
    packets_drop_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ErrorPortAllocation threshold (unit=Count)
    error_port_allocation = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # IdleTimeoutCount threshold (unit=Count)
    idle_timeout_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PacketsInFromDestination threshold (unit=Count)
    packets_in_from_destination = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PacketsInFromSource threshold (unit=Count)
    packets_in_from_source = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PacketsOutToDestination threshold (unit=Count)
    packets_out_to_destination = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PacketsOutToSource threshold (unit=Count)
    packets_out_to_source = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ConnectionAttemptCount threshold (unit=Count)
    connection_attempt_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ConnectionEstablishedCount threshold (unit=Count)
    connection_established_count = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PeakBytesPerSecond threshold (unit=Bytes/Second)
    peak_bytes_per_second = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # PeakPacketsPerSecond threshold (unit=Count/Second)
    peak_packets_per_second = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific NAT Gateways. Key is the NatGatewayId. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of NAT Gateways to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of NAT Gateways will be automatically registered, but at that time, specify the NAT Gateway ID you want to exclude using partial match."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of NAT Gateways will be automatically registered, but at that time, specify the NAT Gateway ID you want to include using partial match. If empty, all NAT Gateways will be included (except excluded ones)."
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
