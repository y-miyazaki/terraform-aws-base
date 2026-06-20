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
    enabled_active_connection_count = bool
    active_connection_count         = number
    # BytesOutToDestination threshold (unit=Bytes)
    enabled_bytes_out_to_destination = bool
    bytes_out_to_destination         = number
    # BytesInFromSource threshold (unit=Bytes)
    enabled_bytes_in_from_source = bool
    bytes_in_from_source         = number
    # BytesInFromDestination threshold (unit=Bytes)
    enabled_bytes_in_from_destination = bool
    bytes_in_from_destination         = number
    # BytesOutToSource threshold (unit=Bytes)
    enabled_bytes_out_to_source = bool
    bytes_out_to_source         = number
    # PacketsDropCount threshold (unit=Count)
    enabled_packets_drop_count = bool
    packets_drop_count         = number
    # ErrorPortAllocation threshold (unit=Count)
    enabled_error_port_allocation = bool
    error_port_allocation         = number
    # IdleTimeoutCount threshold (unit=Count)
    enabled_idle_timeout_count = bool
    idle_timeout_count         = number
    # PacketsInFromDestination threshold (unit=Count)
    enabled_packets_in_from_destination = bool
    packets_in_from_destination         = number
    # PacketsInFromSource threshold (unit=Count)
    enabled_packets_in_from_source = bool
    packets_in_from_source         = number
    # PacketsOutToDestination threshold (unit=Count)
    enabled_packets_out_to_destination = bool
    packets_out_to_destination         = number
    # PacketsOutToSource threshold (unit=Count)
    enabled_packets_out_to_source = bool
    packets_out_to_source         = number
    # ConnectionAttemptCount threshold (unit=Count)
    enabled_connection_attempt_count = bool
    connection_attempt_count         = number
    # ConnectionEstablishedCount threshold (unit=Count)
    enabled_connection_established_count = bool
    connection_established_count         = number
    # PeakBytesPerSecond threshold (unit=Bytes/Second)
    enabled_peak_bytes_per_second = bool
    peak_bytes_per_second         = number
    # PeakPacketsPerSecond threshold (unit=Count/Second)
    enabled_peak_packets_per_second = bool
    peak_packets_per_second         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in NAT Gateway."
  default = {
    enabled_active_connection_count      = false
    active_connection_count              = 10000
    enabled_bytes_out_to_destination     = true
    bytes_out_to_destination             = 107374182400 # 100GB in bytes
    enabled_bytes_in_from_source         = true
    bytes_in_from_source                 = 107374182400 # 100GB in bytes
    enabled_bytes_in_from_destination    = false
    bytes_in_from_destination            = 107374182400 # 100GB in bytes
    enabled_bytes_out_to_source          = false
    bytes_out_to_source                  = 107374182400 # 100GB in bytes
    enabled_packets_drop_count           = true
    packets_drop_count                   = 100
    enabled_error_port_allocation        = true
    error_port_allocation                = 10
    enabled_idle_timeout_count           = false
    idle_timeout_count                   = 100
    enabled_packets_in_from_destination  = false
    packets_in_from_destination          = 10000000
    enabled_packets_in_from_source       = false
    packets_in_from_source               = 10000000
    enabled_packets_out_to_destination   = false
    packets_out_to_destination           = 10000000
    enabled_packets_out_to_source        = false
    packets_out_to_source                = 10000000
    enabled_connection_attempt_count     = true
    connection_attempt_count             = 10000
    enabled_connection_established_count = true
    connection_established_count         = 10000
    enabled_peak_bytes_per_second        = false
    peak_bytes_per_second                = 1073741824 # 1GB/sec
    enabled_peak_packets_per_second      = false
    peak_packets_per_second              = 100000
  }
}

variable "threshold_override" {
  type = map(object({
    # ActiveConnectionCount threshold (unit=Count)
    enabled_active_connection_count = optional(bool)
    active_connection_count         = optional(number)
    # BytesOutToDestination threshold (unit=Bytes)
    enabled_bytes_out_to_destination = optional(bool)
    bytes_out_to_destination         = optional(number)
    # BytesInFromSource threshold (unit=Bytes)
    enabled_bytes_in_from_source = optional(bool)
    bytes_in_from_source         = optional(number)
    # BytesInFromDestination threshold (unit=Bytes)
    enabled_bytes_in_from_destination = optional(bool)
    bytes_in_from_destination         = optional(number)
    # BytesOutToSource threshold (unit=Bytes)
    enabled_bytes_out_to_source = optional(bool)
    bytes_out_to_source         = optional(number)
    # PacketsDropCount threshold (unit=Count)
    enabled_packets_drop_count = optional(bool)
    packets_drop_count         = optional(number)
    # ErrorPortAllocation threshold (unit=Count)
    enabled_error_port_allocation = optional(bool)
    error_port_allocation         = optional(number)
    # IdleTimeoutCount threshold (unit=Count)
    enabled_idle_timeout_count = optional(bool)
    idle_timeout_count         = optional(number)
    # PacketsInFromDestination threshold (unit=Count)
    enabled_packets_in_from_destination = optional(bool)
    packets_in_from_destination         = optional(number)
    # PacketsInFromSource threshold (unit=Count)
    enabled_packets_in_from_source = optional(bool)
    packets_in_from_source         = optional(number)
    # PacketsOutToDestination threshold (unit=Count)
    enabled_packets_out_to_destination = optional(bool)
    packets_out_to_destination         = optional(number)
    # PacketsOutToSource threshold (unit=Count)
    enabled_packets_out_to_source = optional(bool)
    packets_out_to_source         = optional(number)
    # ConnectionAttemptCount threshold (unit=Count)
    enabled_connection_attempt_count = optional(bool)
    connection_attempt_count         = optional(number)
    # ConnectionEstablishedCount threshold (unit=Count)
    enabled_connection_established_count = optional(bool)
    connection_established_count         = optional(number)
    # PeakBytesPerSecond threshold (unit=Bytes/Second)
    enabled_peak_bytes_per_second = optional(bool)
    peak_bytes_per_second         = optional(number)
    # PeakPacketsPerSecond threshold (unit=Count/Second)
    enabled_peak_packets_per_second = optional(bool)
    peak_packets_per_second         = optional(number)
  }))
  description = "(Optional) Override thresholds for specific NAT Gateways. Key is the NatGatewayId."
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
