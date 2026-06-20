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
    enabled_cache_hit_rate = bool
    cache_hit_rate         = number
    # (Required) Error401Rate threshold (unit=%)
    enabled_error_401_rate = bool
    error_401_rate         = number
    # (Required) Error403Rate threshold (unit=%)
    enabled_error_403_rate = bool
    error_403_rate         = number
    # (Required) Error404Rate threshold (unit=%)
    enabled_error_404_rate = bool
    error_404_rate         = number
    # (Required) Error502Rate threshold (unit=%)
    enabled_error_502_rate = bool
    error_502_rate         = number
    # (Required) Error503Rate threshold (unit=%)
    enabled_error_503_rate = bool
    error_503_rate         = number
    # (Required) Error504Rate threshold (unit=%)
    enabled_error_504_rate = bool
    error_504_rate         = number
    # (Required) OriginLatency threshold (unit=Milliseconds)
    enabled_origin_latency = bool
    origin_latency         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in CloudFront."
  default = {
    enabled_cache_hit_rate = true
    cache_hit_rate         = 70
    enabled_error_401_rate = true
    error_401_rate         = 1
    enabled_error_403_rate = false
    error_403_rate         = 1
    enabled_error_404_rate = true
    error_404_rate         = 1
    enabled_error_502_rate = true
    error_502_rate         = 1
    enabled_error_503_rate = true
    error_503_rate         = 1
    enabled_error_504_rate = true
    error_504_rate         = 1
    enabled_origin_latency = true
    origin_latency         = 10000
  }
}

variable "threshold_override" {
  type = map(object({
    # (Optional) CacheHitRate threshold (unit=%)
    enabled_cache_hit_rate = optional(bool)
    cache_hit_rate         = optional(number)
    # (Optional) Error401Rate threshold (unit=%)
    enabled_error_401_rate = optional(bool)
    error_401_rate         = optional(number)
    # (Optional) Error403Rate threshold (unit=%)
    enabled_error_403_rate = optional(bool)
    error_403_rate         = optional(number)
    # (Optional) Error404Rate threshold (unit=%)
    enabled_error_404_rate = optional(bool)
    error_404_rate         = optional(number)
    # (Optional) Error502Rate threshold (unit=%)
    enabled_error_502_rate = optional(bool)
    error_502_rate         = optional(number)
    # (Optional) Error503Rate threshold (unit=%)
    enabled_error_503_rate = optional(bool)
    error_503_rate         = optional(number)
    # (Optional) Error504Rate threshold (unit=%)
    enabled_error_504_rate = optional(bool)
    error_504_rate         = optional(number)
    # (Optional) OriginLatency threshold (unit=Milliseconds)
    enabled_origin_latency = optional(bool)
    origin_latency         = optional(number)
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the DistributionId."
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
