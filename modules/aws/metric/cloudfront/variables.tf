#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of CloudFront. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # (Required) CacheHitRate threshold (unit=%)
    cache_hit_rate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) Error401Rate threshold (unit=%)
    error_401_rate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) Error403Rate threshold (unit=%)
    error_403_rate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) Error404Rate threshold (unit=%)
    error_404_rate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) Error502Rate threshold (unit=%)
    error_502_rate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) Error503Rate threshold (unit=%)
    error_503_rate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) Error504Rate threshold (unit=%)
    error_504_rate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) OriginLatency threshold (unit=Milliseconds)
    origin_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in CloudFront."
  default = {
    cache_hit_rate = { enabled = true, value = 70 }
    error_401_rate = { enabled = true, value = 1 }
    error_403_rate = { enabled = false, value = 1 }
    error_404_rate = { enabled = true, value = 1 }
    error_502_rate = { enabled = true, value = 1 }
    error_503_rate = { enabled = true, value = 1 }
    error_504_rate = { enabled = true, value = 1 }
    origin_latency = { enabled = true, value = 10000 }
  }
}

variable "threshold_override" {
  type = map(object({
    # CacheHitRate threshold (unit=%)
    cache_hit_rate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Error401Rate threshold (unit=%)
    error_401_rate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Error403Rate threshold (unit=%)
    error_403_rate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Error404Rate threshold (unit=%)
    error_404_rate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Error502Rate threshold (unit=%)
    error_502_rate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Error503Rate threshold (unit=%)
    error_503_rate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Error504Rate threshold (unit=%)
    error_504_rate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # OriginLatency threshold (unit=Milliseconds)
    origin_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the DistributionId. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of CloudFronts to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of CloudFronts will be automatically registered, but at that time, specify the CloudFront name you want to exclude using partial match."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of CloudFronts will be automatically registered, but at that time, specify the CloudFront distribution ID you want to include using partial match. If empty, all CloudFronts will be included (except excluded ones)."
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
