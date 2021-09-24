#--------------------------------------------------------------
# module variables
#--------------------------------------------------------------
variable "is_enabled" {
  type        = bool
  description = "(Optional) A boolean flag to enable/disable settings of RDS. Defaults true."
  default     = true
}
variable "is_aurora" {
  type        = bool
  description = "(Required) True if the DB engine of RDS is MySQL, false otherwise."
}
variable "is_mysql" {
  type        = bool
  description = "(Required) True if the DB engine of RDS is MySQL, false otherwise."
}
variable "is_postgres" {
  type        = bool
  description = "(Required) True if the DB engine of RDS is Postgres, false otherwise."
}
variable "db_instance_class" {
  type        = string
  description = "(Optional) RDS instance class."
  default     = ""
}
variable "period" {
  type        = number
  description = "(Optional) The period in seconds over which the specified statistic is applied."
  default     = 300
}
variable "threshold" {
  type = object({
    # CommitRatency threshold (unit=Milliseconds)
    enabled_commit_latency = bool
    commit_latency         = number
    # CPUCreditBalance threshold (unit=Count)
    enabled_cpu_creadit_balance = bool
    cpu_creadit_balance         = number
    # CPUUtilization threshold (unit=%)
    enabled_cpu_utilization = bool
    cpu_utilization         = number
    # DatabaseConnections threshold (unit=Count)
    enabled_database_connections = bool
    database_connections         = number
    # Deadlocks threshold (unit=Count/Seconds)
    enabled_deadlocks = bool
    deadlocks         = number
    # DeleteLatency threshold (unit=Count)
    enabled_delete_latency = bool
    delete_latency         = number
    # DiskQueueDepth threshold (unit=Count)
    enabled_disk_queue_depth = bool
    disk_queue_depth         = number
    # FreeableMemory threshold (unit=Megabytes)
    enabled_freeable_memory = bool
    freeable_memory         = number
    # ReadLatency threshold (unit=Seconds)
    enabled_read_latency = bool
    read_latency         = number
    # WriteLatency threshold (unit=Seconds)
    enabled_write_latency = bool
    write_latency         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in RDS."
  default = {
    enabled_commit_latency       = true
    commit_latency               = 10000
    enabled_cpu_creadit_balance  = true
    cpu_creadit_balance          = 100
    enabled_cpu_utilization      = true
    cpu_utilization              = 80
    enabled_database_connections = true
    database_connections         = 100
    enabled_deadlocks            = true
    deadlocks                    = 1
    enabled_delete_latency       = true
    delete_latency               = 10
    enabled_disk_queue_depth     = true
    disk_queue_depth             = 64
    enabled_freeable_memory      = true
    freeable_memory              = 512
    enabled_read_latency         = true
    read_latency                 = 10
    enabled_write_latency        = true
    write_latency                = 10
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
