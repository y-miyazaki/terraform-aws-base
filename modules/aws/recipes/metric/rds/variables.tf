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
    commit_latency = number
    # CPUCreditBalance threshold (unit=Count)
    cpu_creadit_balance = number
    # CPUUtilization threshold (unit=%)
    cpu_utilization = number
    # DatabaseConnections threshold (unit=Count)
    database_connections = number
    # Deadlocks threshold (unit=Count/Seconds)
    deadlocks = number
    # DeleteLatency threshold (unit=Count)
    delete_latency = number
    # DiskQueueDepth threshold (unit=Count)
    disk_queue_depth = number
    # FreeableMemory threshold (unit=Megabytes)
    freeable_memory = number
    # ReadLatency threshold (unit=Seconds)
    read_latency = number
    # WriteLatency threshold (unit=Seconds)
    write_latency = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in RDS."
  default = {
    commit_latency       = 10000
    cpu_creadit_balance  = 100
    cpu_utilization      = 80
    database_connections = 100
    deadlocks            = 1
    delete_latency       = 10
    disk_queue_depth     = 64
    freeable_memory      = 512
    read_latency         = 10
    write_latency        = 10
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
