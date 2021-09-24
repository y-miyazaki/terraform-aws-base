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
    # Reputation.BounceRate threshold (unit=Percent)
    enabled_reputation_bouncerate = bool
    reputation_bouncerate         = number
    # Reputation.ComplaintRate threshold (unit=Percent)
    enabled_reputation_complaintrate = bool
    reputation_complaintrate         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in SES."
  default = {
    # https://aws.amazon.com/jp/premiumsupport/knowledge-center/ses-reputation-dashboard-bounce-rate/
    enabled_reputation_bouncerate = true
    reputation_bouncerate         = 5
    # https://aws.amazon.com/jp/premiumsupport/knowledge-center/ses-reputation-dashboard-bounce-rate/
    enabled_reputation_complaintrate = true
    reputation_complaintrate         = 0.1
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
