#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of EC2. Defaults true."
  default     = true
}

variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}

variable "threshold" {
  type = object({
    # (Required) CPUCreditBalance threshold (unit=Count)
    cpu_credit_balance = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) CPUCreditUsage threshold (unit=Count)
    cpu_credit_usage = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) CPUUtilization threshold (unit=Percent)
    cpu_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) CPUSurplusCreditBalance threshold (unit=Count)
    cpu_surplus_credit_balance = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) CPUSurplusCreditsCharged threshold (unit=Count)
    cpu_surplus_credits_charged = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) DedicatedHostCPUUtilization threshold (unit=Percent)
    dedicated_host_cpu_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) DiskReadBytes threshold (unit=Bytes)
    disk_read_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) DiskReadOps threshold (unit=Count)
    disk_read_ops = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) DiskWriteBytes threshold (unit=Bytes)
    disk_write_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) DiskWriteOps threshold (unit=Count)
    disk_write_ops = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) EBSByteBalance% threshold (unit=Percent)
    ebs_byte_balance_percent = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) EBSIOBalance% threshold (unit=Percent)
    ebs_io_balance_percent = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) EBSReadBytes threshold (unit=Bytes)
    ebs_read_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) EBSReadOps threshold (unit=Count)
    ebs_read_ops = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) EBSWriteBytes threshold (unit=Bytes)
    ebs_write_bytes = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) EBSWriteOps threshold (unit=Count)
    ebs_write_ops = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) InstanceEBSIOPSExceededCheck threshold (unit=None)
    instance_ebs_iops_exceeded_check = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) InstanceEBSThroughputExceededCheck threshold (unit=None)
    instance_ebs_throughput_exceeded_check = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) MetadataNoToken threshold (unit=Count)
    metadata_no_token = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) MetadataNoTokenRejected threshold (unit=Count)
    metadata_no_token_rejected = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NetworkIn threshold (unit=Bytes)
    network_in = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NetworkOut threshold (unit=Bytes)
    network_out = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NetworkPacketsIn threshold (unit=Count)
    network_packets_in = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) NetworkPacketsOut threshold (unit=Count)
    network_packets_out = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) StatusCheckFailed threshold (unit=Count)
    status_check_failed = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) StatusCheckFailed_AttachedEBS threshold (unit=Count)
    status_check_failed_attached_ebs = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) StatusCheckFailed_Instance threshold (unit=Count)
    status_check_failed_instance = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # (Required) StatusCheckFailed_System threshold (unit=Count)
    status_check_failed_system = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in EC2."
  default = {
    cpu_credit_balance                     = { enabled = true, value = 10 }
    instance_ebs_iops_exceeded_check       = { enabled = true, value = 1 }
    instance_ebs_throughput_exceeded_check = { enabled = true, value = 1 }
    cpu_credit_usage                       = { enabled = true, value = 5 }
    cpu_utilization                        = { enabled = true, value = 80 }
    cpu_surplus_credit_balance             = { enabled = true, value = 5 }
    cpu_surplus_credits_charged            = { enabled = true, value = 1 }
    dedicated_host_cpu_utilization         = { enabled = true, value = 80 }
    disk_read_bytes                        = { enabled = true, value = 1000000000 }
    disk_read_ops                          = { enabled = true, value = 1000 }
    disk_write_bytes                       = { enabled = true, value = 1000000000 }
    disk_write_ops                         = { enabled = true, value = 1000 }
    ebs_byte_balance_percent               = { enabled = true, value = 10 }
    ebs_io_balance_percent                 = { enabled = true, value = 10 }
    ebs_read_bytes                         = { enabled = true, value = 1000000000 }
    ebs_read_ops                           = { enabled = true, value = 1000 }
    ebs_write_bytes                        = { enabled = true, value = 1000000000 }
    ebs_write_ops                          = { enabled = true, value = 1000 }
    metadata_no_token                      = { enabled = true, value = 1 }
    metadata_no_token_rejected             = { enabled = true, value = 1 }
    network_in                             = { enabled = true, value = 1000000000 }
    network_out                            = { enabled = true, value = 1000000000 }
    network_packets_in                     = { enabled = true, value = 100000 }
    network_packets_out                    = { enabled = true, value = 100000 }
    status_check_failed                    = { enabled = true, value = 1 }
    status_check_failed_attached_ebs       = { enabled = true, value = 1 }
    status_check_failed_instance           = { enabled = true, value = 1 }
    status_check_failed_system             = { enabled = true, value = 1 }
  }
}

variable "threshold_override" {
  type = map(object({
    # CPUCreditBalance threshold (unit=Count)
    cpu_credit_balance = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CPUCreditUsage threshold (unit=Count)
    cpu_credit_usage = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CPUUtilization threshold (unit=Percent)
    cpu_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CPUSurplusCreditBalance threshold (unit=Count)
    cpu_surplus_credit_balance = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CPUSurplusCreditsCharged threshold (unit=Count)
    cpu_surplus_credits_charged = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DedicatedHostCPUUtilization threshold (unit=Percent)
    dedicated_host_cpu_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DiskReadBytes threshold (unit=Bytes)
    disk_read_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DiskReadOps threshold (unit=Count)
    disk_read_ops = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DiskWriteBytes threshold (unit=Bytes)
    disk_write_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DiskWriteOps threshold (unit=Count)
    disk_write_ops = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # EBSByteBalance% threshold (unit=Percent)
    ebs_byte_balance_percent = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # EBSIOBalance% threshold (unit=Percent)
    ebs_io_balance_percent = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # EBSReadBytes threshold (unit=Bytes)
    ebs_read_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # EBSReadOps threshold (unit=Count)
    ebs_read_ops = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # EBSWriteBytes threshold (unit=Bytes)
    ebs_write_bytes = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # EBSWriteOps threshold (unit=Count)
    ebs_write_ops = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # InstanceEBSIOPSExceededCheck threshold (unit=None)
    instance_ebs_iops_exceeded_check = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # InstanceEBSThroughputExceededCheck threshold (unit=None)
    instance_ebs_throughput_exceeded_check = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # MetadataNoToken threshold (unit=Count)
    metadata_no_token = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # MetadataNoTokenRejected threshold (unit=Count)
    metadata_no_token_rejected = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkIn threshold (unit=Bytes)
    network_in = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkOut threshold (unit=Bytes)
    network_out = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkPacketsIn threshold (unit=Count)
    network_packets_in = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkPacketsOut threshold (unit=Count)
    network_packets_out = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # StatusCheckFailed threshold (unit=Count)
    status_check_failed = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # StatusCheckFailed_AttachedEBS threshold (unit=Count)
    status_check_failed_attached_ebs = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # StatusCheckFailed_Instance threshold (unit=Count)
    status_check_failed_instance = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # StatusCheckFailed_System threshold (unit=Count)
    status_check_failed_system = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the InstanceId. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
  default     = {}
}

variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of EC2s to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}

variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of EC2s will be automatically registered, but at that time, specify the EC2 name you want to exclude using partial match."
  default     = []
}

variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of EC2s will be automatically registered, but at that time, specify the EC2 instance ID you want to include using partial match. If empty, all EC2s will be included (except excluded ones)."
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
