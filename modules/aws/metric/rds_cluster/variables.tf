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
variable "is_postgresql" {
  type        = bool
  description = "(Required) True if the DB engine of RDS is PostgreSQL, false otherwise."
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
    # AuroraReplicaLag threshold (unit=Milliseconds)
    enabled_aurora_replica_lag = bool
    aurora_replica_lag         = number
    # BufferCacheHitRatio threshold (unit=Percent)
    enabled_buffer_cache_hit_ratio = bool
    buffer_cache_hit_ratio         = number
    # CommitLatency threshold (unit=Milliseconds)
    enabled_commit_latency = bool
    commit_latency         = number
    # CPUCreditBalance threshold (unit=Count)
    enabled_cpu_credit_balance = bool
    cpu_credit_balance         = number
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
    # EngineUptime threshold (unit=Seconds)
    enabled_engine_uptime = bool
    engine_uptime         = number
    # FreeLocalStorage threshold (unit=Bytes)
    enabled_free_local_storage = bool
    free_local_storage         = number
    # FreeableMemory threshold (unit=Megabytes)
    enabled_freeable_memory = bool
    freeable_memory         = number
    # NetworkReceiveThroughput threshold (unit=Bytes/Second)
    enabled_network_receive_throughput = bool
    network_receive_throughput         = number
    # NetworkTransmitThroughput threshold (unit=Bytes/Second)
    enabled_network_transmit_throughput = bool
    network_transmit_throughput         = number
    # ReadIOPS threshold (unit=Count/Second)
    enabled_read_iops = bool
    read_iops         = number
    # ReadLatency threshold (unit=Seconds)
    enabled_read_latency = bool
    read_latency         = number
    # ReadThroughput threshold (unit=Bytes/Second)
    enabled_read_throughput = bool
    read_throughput         = number
    # WriteIOPS threshold (unit=Count/Second)
    enabled_write_iops = bool
    write_iops         = number
    # WriteLatency threshold (unit=Seconds)
    enabled_write_latency = bool
    write_latency         = number
    # WriteThroughput threshold (unit=Bytes/Second)
    enabled_write_throughput = bool
    write_throughput         = number
    }
  )
  description = "(Optional) Set the threshold for each Metric in RDS."
  default = {
    enabled_aurora_replica_lag          = true
    aurora_replica_lag                  = 1000
    enabled_buffer_cache_hit_ratio      = true
    buffer_cache_hit_ratio              = 95
    enabled_commit_latency              = true
    commit_latency                      = 10000
    enabled_cpu_credit_balance          = true
    cpu_credit_balance                  = 100
    enabled_cpu_utilization             = true
    cpu_utilization                     = 80
    enabled_database_connections        = true
    database_connections                = 100
    enabled_deadlocks                   = true
    deadlocks                           = 1
    enabled_delete_latency              = true
    delete_latency                      = 10
    enabled_disk_queue_depth            = true
    disk_queue_depth                    = 64
    enabled_engine_uptime               = true
    engine_uptime                       = 86400
    enabled_free_local_storage          = true
    free_local_storage                  = 1073741824 # 1GB
    enabled_freeable_memory             = true
    freeable_memory                     = 512
    enabled_network_receive_throughput  = true
    network_receive_throughput          = 104857600 # 100MB/s
    enabled_network_transmit_throughput = true
    network_transmit_throughput         = 104857600 # 100MB/s
    enabled_read_iops                   = true
    read_iops                           = 1000
    enabled_read_latency                = true
    read_latency                        = 10
    enabled_read_throughput             = true
    read_throughput                     = 104857600 # 100MB/s
    enabled_write_iops                  = true
    write_iops                          = 1000
    enabled_write_latency               = true
    write_latency                       = 10
    enabled_write_throughput            = true
    write_throughput                    = 104857600 # 100MB/s
  }
}
variable "threshold_override" {
  type = map(object({
    # (Optional) AuroraReplicaLag threshold (unit=Milliseconds)
    enabled_aurora_replica_lag = optional(bool)
    aurora_replica_lag         = optional(number)
    # (Optional) BufferCacheHitRatio threshold (unit=Percent)
    enabled_buffer_cache_hit_ratio = optional(bool)
    buffer_cache_hit_ratio         = optional(number)
    # (Optional) CommitLatency threshold (unit=Milliseconds)
    enabled_commit_latency = optional(bool)
    commit_latency         = optional(number)
    # (Optional) CPUCreditBalance threshold (unit=Count)
    enabled_cpu_credit_balance = optional(bool)
    cpu_credit_balance         = optional(number)
    # (Optional) CPUUtilization threshold (unit=%)
    enabled_cpu_utilization = optional(bool)
    cpu_utilization         = optional(number)
    # (Optional) DatabaseConnections threshold (unit=Count)
    enabled_database_connections = optional(bool)
    database_connections         = optional(number)
    # (Optional) Deadlocks threshold (unit=Count/Seconds)
    enabled_deadlocks = optional(bool)
    deadlocks         = optional(number)
    # (Optional) DeleteLatency threshold (unit=Count)
    enabled_delete_latency = optional(bool)
    delete_latency         = optional(number)
    # (Optional) DiskQueueDepth threshold (unit=Count)
    enabled_disk_queue_depth = optional(bool)
    disk_queue_depth         = optional(number)
    # (Optional) EngineUptime threshold (unit=Seconds)
    enabled_engine_uptime = optional(bool)
    engine_uptime         = optional(number)
    # (Optional) FreeLocalStorage threshold (unit=Bytes)
    enabled_free_local_storage = optional(bool)
    free_local_storage         = optional(number)
    # (Optional) FreeableMemory threshold (unit=Megabytes)
    enabled_freeable_memory = optional(bool)
    freeable_memory         = optional(number)
    # (Optional) NetworkReceiveThroughput threshold (unit=Bytes/Second)
    enabled_network_receive_throughput = optional(bool)
    network_receive_throughput         = optional(number)
    # (Optional) NetworkTransmitThroughput threshold (unit=Bytes/Second)
    enabled_network_transmit_throughput = optional(bool)
    network_transmit_throughput         = optional(number)
    # (Optional) ReadIOPS threshold (unit=Count/Second)
    enabled_read_iops = optional(bool)
    read_iops         = optional(number)
    # (Optional) ReadLatency threshold (unit=Seconds)
    enabled_read_latency = optional(bool)
    read_latency         = optional(number)
    # (Optional) ReadThroughput threshold (unit=Bytes/Second)
    enabled_read_throughput = optional(bool)
    read_throughput         = optional(number)
    # (Optional) WriteIOPS threshold (unit=Count/Second)
    enabled_write_iops = optional(bool)
    write_iops         = optional(number)
    # (Optional) WriteLatency threshold (unit=Seconds)
    enabled_write_latency = optional(bool)
    write_latency         = optional(number)
    # (Optional) WriteThroughput threshold (unit=Bytes/Second)
    enabled_write_throughput = optional(bool)
    write_throughput         = optional(number)
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the DBClusterIdentifier."
  default     = {}
}
variable "create_auto_dimensions" {
  type        = bool
  description = "(Optional) Builds a list of RDSs to automatically set dimensions. If this is true, the dimensions setting will be ignored."
  default     = false
}
variable "auto_dimensions_exclude_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of RDSs will be automatically registered, but at that time, specify the RDS name you want to exclude using partial match."
  default     = []
}
variable "auto_dimensions_include_list" {
  type        = list(string)
  description = "(Optional) If create_auto_dimensions is set to true, a list of RDSs will be automatically registered, but at that time, specify the RDS cluster identifier you want to include using partial match. If empty, all RDS clusters will be included (except excluded ones)."
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
