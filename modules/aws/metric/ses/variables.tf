#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of SES. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # Bounce threshold (unit=Count)
    bounce = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Complaint threshold (unit=Count)
    complaint = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Delivery threshold (unit=Count)
    delivery = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Reject threshold (unit=Count)
    reject = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Reputation.BounceRate threshold (unit=Percent)
    reputation_bouncerate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Reputation.ComplaintRate threshold (unit=Percent)
    reputation_complaintrate = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Send threshold (unit=Count)
    send = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in SES."
  default = {
    # Bounce count threshold
    bounce = { enabled = false, value = 100 }
    # Complaint count threshold
    complaint = { enabled = false, value = 10 }
    # Delivery count threshold (monitoring)
    delivery = { enabled = false, value = 1000 }
    # Reject count threshold
    reject = { enabled = false, value = 100 }
    # https://aws.amazon.com/jp/premiumsupport/knowledge-center/ses-reputation-dashboard-bounce-rate/
    reputation_bouncerate = { enabled = true, value = 5 }
    # https://aws.amazon.com/jp/premiumsupport/knowledge-center/ses-reputation-dashboard-bounce-rate/
    reputation_complaintrate = { enabled = true, value = 0.1 }
    # Send count threshold (monitoring)
    send = { enabled = false, value = 10000 }
  }
}

variable "threshold_override" {
  type = map(object({
    # Bounce threshold (unit=Count)
    bounce = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Complaint threshold (unit=Count)
    complaint = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Delivery threshold (unit=Count)
    delivery = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Reject threshold (unit=Count)
    reject = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Reputation.BounceRate threshold (unit=Percent)
    reputation_bouncerate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Reputation.ComplaintRate threshold (unit=Percent)
    reputation_complaintrate = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Send threshold (unit=Count)
    send = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Per-resource threshold overrides. Key is ConfigurationSetName (exact match), or the reserved key \"default\" when dimensions is empty (account-level alarms). NOTE: do not use \"default\" as an actual ConfigurationSetName in dimensions; it would be indistinguishable from the reserved key. Value contains optional threshold attributes to override. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "dimensions" {
  type        = list(map(any))
  description = "(Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here."
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
