<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>6.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.8.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_filter"></a> [filter](#module\_filter) | ../../_internal/auto_discovery_filter | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.aurora_replica_lag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.buffer_cache_hit_ratio](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.commit_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_credit_balance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.database_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.deadlocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.delete_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_queue_depth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.engine_uptime](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.free_local_storage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.freeable_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_receive_throughput](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_transmit_throughput](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.read_iops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.read_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.read_throughput](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.write_iops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.write_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.write_throughput](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_rds_clusters.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_clusters) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_auto_dimensions_exclude_list"></a> [auto\_dimensions\_exclude\_list](#input\_auto\_dimensions\_exclude\_list) | (Optional) If create\_auto\_dimensions is set to true, a list of RDSs will be automatically registered, but at that time, specify the RDS name you want to exclude using partial match. | `list(string)` | `[]` | no |
| <a name="input_auto_dimensions_include_list"></a> [auto\_dimensions\_include\_list](#input\_auto\_dimensions\_include\_list) | (Optional) If create\_auto\_dimensions is set to true, a list of RDSs will be automatically registered, but at that time, specify the RDS cluster identifier you want to include using partial match. If empty, all RDS clusters will be included (except excluded ones). | `list(string)` | `[]` | no |
| <a name="input_create_auto_dimensions"></a> [create\_auto\_dimensions](#input\_create\_auto\_dimensions) | (Optional) Builds a list of RDSs to automatically set dimensions. If this is true, the dimensions setting will be ignored. | `bool` | `false` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | (Optional) RDS instance class. | `string` | `""` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) If create\_auto\_dimensions is set to false, The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | `[]` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_aurora"></a> [is\_aurora](#input\_is\_aurora) | (Required) True if the DB engine of RDS is MySQL, false otherwise. | `bool` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of RDS. Defaults true. | `bool` | `true` | no |
| <a name="input_is_mysql"></a> [is\_mysql](#input\_is\_mysql) | (Required) True if the DB engine of RDS is MySQL, false otherwise. | `bool` | n/a | yes |
| <a name="input_is_postgresql"></a> [is\_postgresql](#input\_is\_postgresql) | (Required) True if the DB engine of RDS is PostgreSQL, false otherwise. | `bool` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in RDS. | <pre>object({<br/>    # AuroraReplicaLag threshold (unit=Milliseconds)<br/>    enabled_aurora_replica_lag = bool<br/>    aurora_replica_lag         = number<br/>    # BufferCacheHitRatio threshold (unit=Percent)<br/>    enabled_buffer_cache_hit_ratio = bool<br/>    buffer_cache_hit_ratio         = number<br/>    # CommitLatency threshold (unit=Milliseconds)<br/>    enabled_commit_latency = bool<br/>    commit_latency         = number<br/>    # CPUCreditBalance threshold (unit=Count)<br/>    enabled_cpu_credit_balance = bool<br/>    cpu_credit_balance         = number<br/>    # CPUUtilization threshold (unit=%)<br/>    enabled_cpu_utilization = bool<br/>    cpu_utilization         = number<br/>    # DatabaseConnections threshold (unit=Count)<br/>    enabled_database_connections = bool<br/>    database_connections         = number<br/>    # Deadlocks threshold (unit=Count/Seconds)<br/>    enabled_deadlocks = bool<br/>    deadlocks         = number<br/>    # DeleteLatency threshold (unit=Count)<br/>    enabled_delete_latency = bool<br/>    delete_latency         = number<br/>    # DiskQueueDepth threshold (unit=Count)<br/>    enabled_disk_queue_depth = bool<br/>    disk_queue_depth         = number<br/>    # EngineUptime threshold (unit=Seconds)<br/>    enabled_engine_uptime = bool<br/>    engine_uptime         = number<br/>    # FreeLocalStorage threshold (unit=Bytes)<br/>    enabled_free_local_storage = bool<br/>    free_local_storage         = number<br/>    # FreeableMemory threshold (unit=Megabytes)<br/>    enabled_freeable_memory = bool<br/>    freeable_memory         = number<br/>    # NetworkReceiveThroughput threshold (unit=Bytes/Second)<br/>    enabled_network_receive_throughput = bool<br/>    network_receive_throughput         = number<br/>    # NetworkTransmitThroughput threshold (unit=Bytes/Second)<br/>    enabled_network_transmit_throughput = bool<br/>    network_transmit_throughput         = number<br/>    # ReadIOPS threshold (unit=Count/Second)<br/>    enabled_read_iops = bool<br/>    read_iops         = number<br/>    # ReadLatency threshold (unit=Seconds)<br/>    enabled_read_latency = bool<br/>    read_latency         = number<br/>    # ReadThroughput threshold (unit=Bytes/Second)<br/>    enabled_read_throughput = bool<br/>    read_throughput         = number<br/>    # WriteIOPS threshold (unit=Count/Second)<br/>    enabled_write_iops = bool<br/>    write_iops         = number<br/>    # WriteLatency threshold (unit=Seconds)<br/>    enabled_write_latency = bool<br/>    write_latency         = number<br/>    # WriteThroughput threshold (unit=Bytes/Second)<br/>    enabled_write_throughput = bool<br/>    write_throughput         = number<br/>    }<br/>  )</pre> | <pre>{<br/>  "aurora_replica_lag": 1000,<br/>  "buffer_cache_hit_ratio": 95,<br/>  "commit_latency": 10000,<br/>  "cpu_credit_balance": 100,<br/>  "cpu_utilization": 80,<br/>  "database_connections": 100,<br/>  "deadlocks": 1,<br/>  "delete_latency": 10,<br/>  "disk_queue_depth": 64,<br/>  "enabled_aurora_replica_lag": true,<br/>  "enabled_buffer_cache_hit_ratio": true,<br/>  "enabled_commit_latency": true,<br/>  "enabled_cpu_credit_balance": true,<br/>  "enabled_cpu_utilization": true,<br/>  "enabled_database_connections": true,<br/>  "enabled_deadlocks": true,<br/>  "enabled_delete_latency": true,<br/>  "enabled_disk_queue_depth": true,<br/>  "enabled_engine_uptime": true,<br/>  "enabled_free_local_storage": true,<br/>  "enabled_freeable_memory": true,<br/>  "enabled_network_receive_throughput": true,<br/>  "enabled_network_transmit_throughput": true,<br/>  "enabled_read_iops": true,<br/>  "enabled_read_latency": true,<br/>  "enabled_read_throughput": true,<br/>  "enabled_write_iops": true,<br/>  "enabled_write_latency": true,<br/>  "enabled_write_throughput": true,<br/>  "engine_uptime": 86400,<br/>  "free_local_storage": 1073741824,<br/>  "freeable_memory": 512,<br/>  "network_receive_throughput": 104857600,<br/>  "network_transmit_throughput": 104857600,<br/>  "read_iops": 1000,<br/>  "read_latency": 10,<br/>  "read_throughput": 104857600,<br/>  "write_iops": 1000,<br/>  "write_latency": 10,<br/>  "write_throughput": 104857600<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
