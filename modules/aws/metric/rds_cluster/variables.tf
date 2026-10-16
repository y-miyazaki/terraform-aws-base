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
    aurora_replica_lag = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # BufferCacheHitRatio threshold (unit=Percent)
    buffer_cache_hit_ratio = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CommitLatency threshold (unit=Milliseconds)
    commit_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CPUCreditBalance threshold (unit=Count)
    cpu_credit_balance = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # CPUUtilization threshold (unit=%)
    cpu_utilization = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # DatabaseConnections threshold (unit=Count)
    database_connections = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # Deadlocks threshold (unit=Count/Seconds)
    deadlocks = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # DeleteLatency threshold (unit=Count)
    delete_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # DiskQueueDepth threshold (unit=Count)
    disk_queue_depth = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # EngineUptime threshold (unit=Seconds)
    engine_uptime = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # FreeLocalStorage threshold (unit=Bytes)
    free_local_storage = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # FreeableMemory threshold (unit=Megabytes)
    freeable_memory = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # NetworkReceiveThroughput threshold (unit=Bytes/Second)
    network_receive_throughput = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # NetworkTransmitThroughput threshold (unit=Bytes/Second)
    network_transmit_throughput = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ReadIOPS threshold (unit=Count/Second)
    read_iops = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ReadLatency threshold (unit=Seconds)
    read_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # ReadThroughput threshold (unit=Bytes/Second)
    read_throughput = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # WriteIOPS threshold (unit=Count/Second)
    write_iops = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # WriteLatency threshold (unit=Seconds)
    write_latency = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
    # WriteThroughput threshold (unit=Bytes/Second)
    write_throughput = object({ enabled = bool, value = number, datapoints_to_alarm = optional(number, 1), evaluation_periods = optional(number, 1) })
  })
  description = "(Optional) Set the threshold for each Metric in RDS."
  default = {
    aurora_replica_lag          = { enabled = true, value = 1000 }
    buffer_cache_hit_ratio      = { enabled = true, value = 95 }
    commit_latency              = { enabled = true, value = 10000 }
    cpu_credit_balance          = { enabled = true, value = 100 }
    cpu_utilization             = { enabled = true, value = 80 }
    database_connections        = { enabled = true, value = 100 }
    deadlocks                   = { enabled = true, value = 1 }
    delete_latency              = { enabled = true, value = 10 }
    disk_queue_depth            = { enabled = true, value = 64 }
    engine_uptime               = { enabled = true, value = 86400 }
    free_local_storage          = { enabled = true, value = 1073741824 } # 1GB
    freeable_memory             = { enabled = true, value = 512 }
    network_receive_throughput  = { enabled = true, value = 104857600 } # 100MB/s
    network_transmit_throughput = { enabled = true, value = 104857600 } # 100MB/s
    read_iops                   = { enabled = true, value = 1000 }
    read_latency                = { enabled = true, value = 10 }
    read_throughput             = { enabled = true, value = 104857600 } # 100MB/s
    write_iops                  = { enabled = true, value = 1000 }
    write_latency               = { enabled = true, value = 10 }
    write_throughput            = { enabled = true, value = 104857600 } # 100MB/s
  }
}

variable "threshold_override" {
  type = map(object({
    # AuroraReplicaLag threshold (unit=Milliseconds)
    aurora_replica_lag = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # BufferCacheHitRatio threshold (unit=Percent)
    buffer_cache_hit_ratio = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CommitLatency threshold (unit=Milliseconds)
    commit_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CPUCreditBalance threshold (unit=Count)
    cpu_credit_balance = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # CPUUtilization threshold (unit=%)
    cpu_utilization = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DatabaseConnections threshold (unit=Count)
    database_connections = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # Deadlocks threshold (unit=Count/Seconds)
    deadlocks = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DeleteLatency threshold (unit=Count)
    delete_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # DiskQueueDepth threshold (unit=Count)
    disk_queue_depth = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # EngineUptime threshold (unit=Seconds)
    engine_uptime = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # FreeLocalStorage threshold (unit=Bytes)
    free_local_storage = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # FreeableMemory threshold (unit=Megabytes)
    freeable_memory = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkReceiveThroughput threshold (unit=Bytes/Second)
    network_receive_throughput = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # NetworkTransmitThroughput threshold (unit=Bytes/Second)
    network_transmit_throughput = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReadIOPS threshold (unit=Count/Second)
    read_iops = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReadLatency threshold (unit=Seconds)
    read_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # ReadThroughput threshold (unit=Bytes/Second)
    read_throughput = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WriteIOPS threshold (unit=Count/Second)
    write_iops = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WriteLatency threshold (unit=Seconds)
    write_latency = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
    # WriteThroughput threshold (unit=Bytes/Second)
    write_throughput = optional(object({ enabled = optional(bool), value = optional(number), datapoints_to_alarm = optional(number), evaluation_periods = optional(number) }))
  }))
  description = "(Optional) Override thresholds for specific resources. Key is the DBClusterIdentifier. Each metric accepts enabled, value, datapoints_to_alarm and evaluation_periods."
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

variable "region" {
  type        = string
  description = "(Optional) AWS region. Defaults to provider region."
  default     = null
}
