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
    enabled_cpu_credit_balance = bool
    cpu_credit_balance         = number
    # (Required) InstanceEBSIOPSExceededCheck threshold (unit=None)
    enabled_instance_ebs_iops_exceeded_check = bool
    instance_ebs_iops_exceeded_check         = number
    # (Required) InstanceEBSThroughputExceededCheck threshold (unit=None)
    enabled_instance_ebs_throughput_exceeded_check = bool
    instance_ebs_throughput_exceeded_check         = number
    # (Required) CPUCreditUsage threshold (unit=Count)
    enabled_cpu_credit_usage = bool
    cpu_credit_usage         = number
    # (Required) CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = bool
    cpu_utilization         = number
    # (Required) CPUSurplusCreditBalance threshold (unit=Count)
    enabled_cpu_surplus_credit_balance = bool
    cpu_surplus_credit_balance         = number
    # (Required) CPUSurplusCreditsCharged threshold (unit=Count)
    enabled_cpu_surplus_credits_charged = bool
    cpu_surplus_credits_charged         = number
    # (Required) DedicatedHostCPUUtilization threshold (unit=Percent)
    enabled_dedicated_host_cpu_utilization = bool
    dedicated_host_cpu_utilization         = number
    # (Required) DiskReadBytes threshold (unit=Bytes)
    enabled_disk_read_bytes = bool
    disk_read_bytes         = number
    # (Required) DiskReadOps threshold (unit=Count)
    enabled_disk_read_ops = bool
    disk_read_ops         = number
    # (Required) DiskWriteBytes threshold (unit=Bytes)
    enabled_disk_write_bytes = bool
    disk_write_bytes         = number
    # (Required) DiskWriteOps threshold (unit=Count)
    enabled_disk_write_ops = bool
    disk_write_ops         = number
    # (Required) EBSByteBalance% threshold (unit=Percent)
    enabled_ebs_byte_balance_percent = bool
    ebs_byte_balance_percent         = number
    # (Required) EBSIOBalance% threshold (unit=Percent)
    enabled_ebs_io_balance_percent = bool
    ebs_io_balance_percent         = number
    # (Required) EBSReadBytes threshold (unit=Bytes)
    enabled_ebs_read_bytes = bool
    ebs_read_bytes         = number
    # (Required) EBSReadOps threshold (unit=Count)
    enabled_ebs_read_ops = bool
    ebs_read_ops         = number
    # (Required) EBSWriteBytes threshold (unit=Bytes)
    enabled_ebs_write_bytes = bool
    ebs_write_bytes         = number
    # (Required) EBSWriteOps threshold (unit=Count)
    enabled_ebs_write_ops = bool
    ebs_write_ops         = number
    # (Required) MetadataNoToken threshold (unit=Count)
    enabled_metadata_no_token = bool
    metadata_no_token         = number
    # (Required) MetadataNoTokenRejected threshold (unit=Count)
    enabled_metadata_no_token_rejected = bool
    metadata_no_token_rejected         = number
    # (Required) NetworkIn threshold (unit=Bytes)
    enabled_network_in = bool
    network_in         = number
    # (Required) NetworkOut threshold (unit=Bytes)
    enabled_network_out = bool
    network_out         = number
    # (Required) NetworkPacketsIn threshold (unit=Count)
    enabled_network_packets_in = bool
    network_packets_in         = number
    # (Required) NetworkPacketsOut threshold (unit=Count)
    enabled_network_packets_out = bool
    network_packets_out         = number
    # (Required) StatusCheckFailed threshold (unit=Count)
    enabled_status_check_failed = bool
    status_check_failed         = number
    # (Required) StatusCheckFailed_AttachedEBS threshold (unit=Count)
    enabled_status_check_failed_attached_ebs = bool
    status_check_failed_attached_ebs         = number
    # (Required) StatusCheckFailed_Instance threshold (unit=Count)
    enabled_status_check_failed_instance = bool
    status_check_failed_instance         = number
    # (Required) StatusCheckFailed_System threshold (unit=Count)
    enabled_status_check_failed_system = bool
    status_check_failed_system         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in EC2."
  default = {
    enabled_cpu_credit_balance                     = true
    cpu_credit_balance                             = 10
    enabled_instance_ebs_iops_exceeded_check       = true
    instance_ebs_iops_exceeded_check               = 1
    enabled_instance_ebs_throughput_exceeded_check = true
    instance_ebs_throughput_exceeded_check         = 1
    enabled_cpu_credit_usage                       = true
    cpu_credit_usage                               = 5
    enabled_cpu_utilization                        = true
    cpu_utilization                                = 80
    enabled_cpu_surplus_credit_balance             = true
    cpu_surplus_credit_balance                     = 5
    enabled_cpu_surplus_credits_charged            = true
    cpu_surplus_credits_charged                    = 1
    enabled_dedicated_host_cpu_utilization         = true
    dedicated_host_cpu_utilization                 = 80
    enabled_disk_read_bytes                        = true
    disk_read_bytes                                = 1000000000
    enabled_disk_read_ops                          = true
    disk_read_ops                                  = 1000
    enabled_disk_write_bytes                       = true
    disk_write_bytes                               = 1000000000
    enabled_disk_write_ops                         = true
    disk_write_ops                                 = 1000
    enabled_ebs_byte_balance_percent               = true
    ebs_byte_balance_percent                       = 10
    enabled_ebs_io_balance_percent                 = true
    ebs_io_balance_percent                         = 10
    enabled_ebs_read_bytes                         = true
    ebs_read_bytes                                 = 1000000000
    enabled_ebs_read_ops                           = true
    ebs_read_ops                                   = 1000
    enabled_ebs_write_bytes                        = true
    ebs_write_bytes                                = 1000000000
    enabled_ebs_write_ops                          = true
    ebs_write_ops                                  = 1000
    enabled_metadata_no_token                      = true
    metadata_no_token                              = 1
    enabled_metadata_no_token_rejected             = true
    metadata_no_token_rejected                     = 1
    enabled_network_in                             = true
    network_in                                     = 1000000000
    enabled_network_out                            = true
    network_out                                    = 1000000000
    enabled_network_packets_in                     = true
    network_packets_in                             = 100000
    enabled_network_packets_out                    = true
    network_packets_out                            = 100000
    enabled_status_check_failed                    = true
    status_check_failed                            = 1
    enabled_status_check_failed_attached_ebs       = true
    status_check_failed_attached_ebs               = 1
    enabled_status_check_failed_instance           = true
    status_check_failed_instance                   = 1
    enabled_status_check_failed_system             = true
    status_check_failed_system                     = 1
  }
}
variable "threshold_override" {
  type = map(object({
    # (Optional) CPUCreditBalance threshold (unit=Count)
    enabled_cpu_credit_balance = optional(bool)
    cpu_credit_balance         = optional(number)
    # (Optional) InstanceEBSIOPSExceededCheck threshold (unit=None)
    enabled_instance_ebs_iops_exceeded_check = optional(bool)
    instance_ebs_iops_exceeded_check         = optional(number)
    # (Optional) InstanceEBSThroughputExceededCheck threshold (unit=None)
    enabled_instance_ebs_throughput_exceeded_check = optional(bool)
    instance_ebs_throughput_exceeded_check         = optional(number)
    # (Optional) CPUCreditUsage threshold (unit=Count)
    enabled_cpu_credit_usage = optional(bool)
    cpu_credit_usage         = optional(number)
    # (Optional) CPUUtilization threshold (unit=Percent)
    enabled_cpu_utilization = optional(bool)
    cpu_utilization         = optional(number)
    # (Optional) CPUSurplusCreditBalance threshold (unit=Count)
    enabled_cpu_surplus_credit_balance = optional(bool)
    cpu_surplus_credit_balance         = optional(number)
    # (Optional) CPUSurplusCreditsCharged threshold (unit=Count)
    enabled_cpu_surplus_credits_charged = optional(bool)
    cpu_surplus_credits_charged         = optional(number)
    # (Optional) DedicatedHostCPUUtilization threshold (unit=Percent)
    enabled_dedicated_host_cpu_utilization = optional(bool)
    dedicated_host_cpu_utilization         = optional(number)
    # (Optional) DiskReadBytes threshold (unit=Bytes)
    enabled_disk_read_bytes = optional(bool)
    disk_read_bytes         = optional(number)
    # (Optional) DiskReadOps threshold (unit=Count)
    enabled_disk_read_ops = optional(bool)
    disk_read_ops         = optional(number)
    # (Optional) DiskWriteBytes threshold (unit=Bytes)
    enabled_disk_write_bytes = optional(bool)
    disk_write_bytes         = optional(number)
    # (Optional) DiskWriteOps threshold (unit=Count)
    enabled_disk_write_ops = optional(bool)
    disk_write_ops         = optional(number)
    # (Optional) EBSByteBalance% threshold (unit=Percent)
    enabled_ebs_byte_balance_percent = optional(bool)
    ebs_byte_balance_percent         = optional(number)
    # (Optional) EBSIOBalance% threshold (unit=Percent)
    enabled_ebs_io_balance_percent = optional(bool)
    ebs_io_balance_percent         = optional(number)
    # (Optional) EBSReadBytes threshold (unit=Bytes)
    enabled_ebs_read_bytes = optional(bool)
    ebs_read_bytes         = optional(number)
    # (Optional) EBSReadOps threshold (unit=Count)
    enabled_ebs_read_ops = optional(bool)
    ebs_read_ops         = optional(number)
    # (Optional) EBSWriteBytes threshold (unit=Bytes)
    enabled_ebs_write_bytes = optional(bool)
    ebs_write_bytes         = optional(number)
    # (Optional) EBSWriteOps threshold (unit=Count)
    enabled_ebs_write_ops = optional(bool)
    ebs_write_ops         = optional(number)
    # (Optional) MetadataNoToken threshold (unit=Count)
    enabled_metadata_no_token = optional(bool)
    metadata_no_token         = optional(number)
    # (Optional) MetadataNoTokenRejected threshold (unit=Count)
    enabled_metadata_no_token_rejected = optional(bool)
    metadata_no_token_rejected         = optional(number)
    # (Optional) NetworkIn threshold (unit=Bytes)
    enabled_network_in = optional(bool)
    network_in         = optional(number)
    # (Optional) NetworkOut threshold (unit=Bytes)
    enabled_network_out = optional(bool)
    network_out         = optional(number)
    # (Optional) NetworkPacketsIn threshold (unit=Count)
    enabled_network_packets_in = optional(bool)
    network_packets_in         = optional(number)
    # (Optional) NetworkPacketsOut threshold (unit=Count)
    enabled_network_packets_out = optional(bool)
    network_packets_out         = optional(number)
    # (Optional) StatusCheckFailed threshold (unit=Count)
    enabled_status_check_failed = optional(bool)
    status_check_failed         = optional(number)
    # (Optional) StatusCheckFailed_AttachedEBS threshold (unit=Count)
    enabled_status_check_failed_attached_ebs = optional(bool)
    status_check_failed_attached_ebs         = optional(number)
    # (Optional) StatusCheckFailed_Instance threshold (unit=Count)
    enabled_status_check_failed_instance = optional(bool)
    status_check_failed_instance         = optional(number)
    # (Optional) StatusCheckFailed_System threshold (unit=Count)
    enabled_status_check_failed_system = optional(bool)
    status_check_failed_system         = optional(number)
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the InstanceId."
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
