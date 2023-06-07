<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>4.67.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 4.67.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.commit_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_creadit_balance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.database_connections](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.deadlocks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.delete_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_queue_depth](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.freeable_memory](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.read_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.write_latency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | (Optional) RDS instance class. | `string` | `""` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Required) The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | n/a | yes |
| <a name="input_is_aurora"></a> [is\_aurora](#input\_is\_aurora) | (Required) True if the DB engine of RDS is MySQL, false otherwise. | `bool` | n/a | yes |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of RDS. Defaults true. | `bool` | `true` | no |
| <a name="input_is_mysql"></a> [is\_mysql](#input\_is\_mysql) | (Required) True if the DB engine of RDS is MySQL, false otherwise. | `bool` | n/a | yes |
| <a name="input_is_postgres"></a> [is\_postgres](#input\_is\_postgres) | (Required) True if the DB engine of RDS is Postgres, false otherwise. | `bool` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) Center for Internet Security CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `null` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in RDS. | <pre>object({<br>    # CommitRatency threshold (unit=Milliseconds)<br>    enabled_commit_latency = bool<br>    commit_latency         = number<br>    # CPUCreditBalance threshold (unit=Count)<br>    enabled_cpu_creadit_balance = bool<br>    cpu_creadit_balance         = number<br>    # CPUUtilization threshold (unit=%)<br>    enabled_cpu_utilization = bool<br>    cpu_utilization         = number<br>    # DatabaseConnections threshold (unit=Count)<br>    enabled_database_connections = bool<br>    database_connections         = number<br>    # Deadlocks threshold (unit=Count/Seconds)<br>    enabled_deadlocks = bool<br>    deadlocks         = number<br>    # DeleteLatency threshold (unit=Count)<br>    enabled_delete_latency = bool<br>    delete_latency         = number<br>    # DiskQueueDepth threshold (unit=Count)<br>    enabled_disk_queue_depth = bool<br>    disk_queue_depth         = number<br>    # FreeableMemory threshold (unit=Megabytes)<br>    enabled_freeable_memory = bool<br>    freeable_memory         = number<br>    # ReadLatency threshold (unit=Seconds)<br>    enabled_read_latency = bool<br>    read_latency         = number<br>    # WriteLatency threshold (unit=Seconds)<br>    enabled_write_latency = bool<br>    write_latency         = number<br>    }<br>  )</pre> | <pre>{<br>  "commit_latency": 10000,<br>  "cpu_creadit_balance": 100,<br>  "cpu_utilization": 80,<br>  "database_connections": 100,<br>  "deadlocks": 1,<br>  "delete_latency": 10,<br>  "disk_queue_depth": 64,<br>  "enabled_commit_latency": true,<br>  "enabled_cpu_creadit_balance": true,<br>  "enabled_cpu_utilization": true,<br>  "enabled_database_connections": true,<br>  "enabled_deadlocks": true,<br>  "enabled_delete_latency": true,<br>  "enabled_disk_queue_depth": true,<br>  "enabled_freeable_memory": true,<br>  "enabled_read_latency": true,<br>  "enabled_write_latency": true,<br>  "freeable_memory": 512,<br>  "read_latency": 10,<br>  "write_latency": 10<br>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
