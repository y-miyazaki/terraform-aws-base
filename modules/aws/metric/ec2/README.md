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
| [aws_cloudwatch_metric_alarm.cpu_credit_balance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_credit_usage](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_surplus_credit_balance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_surplus_credits_charged](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.dedicated_host_cpu_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_read_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_read_ops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_write_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.disk_write_ops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ebs_byte_balance_percent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ebs_io_balance_percent](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ebs_read_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ebs_read_ops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ebs_write_bytes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.ebs_write_ops](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.metadata_no_token](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.metadata_no_token_rejected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_packets_in](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.network_packets_out](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.status_check_failed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.status_check_failed_attached_ebs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.status_check_failed_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.status_check_failed_system](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_instances.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instances) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_auto_dimensions_exclude_list"></a> [auto\_dimensions\_exclude\_list](#input\_auto\_dimensions\_exclude\_list) | (Optional) If create\_auto\_dimensions is set to true, a list of EC2s will be automatically registered, but at that time, specify the EC2 name you want to exclude using partial match. | `list(string)` | `[]` | no |
| <a name="input_auto_dimensions_include_list"></a> [auto\_dimensions\_include\_list](#input\_auto\_dimensions\_include\_list) | (Optional) If create\_auto\_dimensions is set to true, a list of EC2s will be automatically registered, but at that time, specify the EC2 instance ID you want to include using partial match. If empty, all EC2s will be included (except excluded ones). | `list(string)` | `[]` | no |
| <a name="input_create_auto_dimensions"></a> [create\_auto\_dimensions](#input\_create\_auto\_dimensions) | (Optional) Builds a list of EC2s to automatically set dimensions. If this is true, the dimensions setting will be ignored. | `bool` | `false` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) If create\_auto\_dimensions is set to false, The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | `[]` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of EC2. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in EC2. | <pre>object({<br/>    # (Required) CPUCreditBalance threshold (unit=Count)<br/>    enabled_cpu_credit_balance = bool<br/>    cpu_credit_balance         = number<br/>    # (Required) CPUCreditUsage threshold (unit=Count)<br/>    enabled_cpu_credit_usage = bool<br/>    cpu_credit_usage         = number<br/>    # (Required) CPUUtilization threshold (unit=Percent)<br/>    enabled_cpu_utilization = bool<br/>    cpu_utilization         = number<br/>    # (Required) CPUSurplusCreditBalance threshold (unit=Count)<br/>    enabled_cpu_surplus_credit_balance = bool<br/>    cpu_surplus_credit_balance         = number<br/>    # (Required) CPUSurplusCreditsCharged threshold (unit=Count)<br/>    enabled_cpu_surplus_credits_charged = bool<br/>    cpu_surplus_credits_charged         = number<br/>    # (Required) DedicatedHostCPUUtilization threshold (unit=Percent)<br/>    enabled_dedicated_host_cpu_utilization = bool<br/>    dedicated_host_cpu_utilization         = number<br/>    # (Required) DiskReadBytes threshold (unit=Bytes)<br/>    enabled_disk_read_bytes = bool<br/>    disk_read_bytes         = number<br/>    # (Required) DiskReadOps threshold (unit=Count)<br/>    enabled_disk_read_ops = bool<br/>    disk_read_ops         = number<br/>    # (Required) DiskWriteBytes threshold (unit=Bytes)<br/>    enabled_disk_write_bytes = bool<br/>    disk_write_bytes         = number<br/>    # (Required) DiskWriteOps threshold (unit=Count)<br/>    enabled_disk_write_ops = bool<br/>    disk_write_ops         = number<br/>    # (Required) EBSByteBalance% threshold (unit=Percent)<br/>    enabled_ebs_byte_balance_percent = bool<br/>    ebs_byte_balance_percent         = number<br/>    # (Required) EBSIOBalance% threshold (unit=Percent)<br/>    enabled_ebs_io_balance_percent = bool<br/>    ebs_io_balance_percent         = number<br/>    # (Required) EBSReadBytes threshold (unit=Bytes)<br/>    enabled_ebs_read_bytes = bool<br/>    ebs_read_bytes         = number<br/>    # (Required) EBSReadOps threshold (unit=Count)<br/>    enabled_ebs_read_ops = bool<br/>    ebs_read_ops         = number<br/>    # (Required) EBSWriteBytes threshold (unit=Bytes)<br/>    enabled_ebs_write_bytes = bool<br/>    ebs_write_bytes         = number<br/>    # (Required) EBSWriteOps threshold (unit=Count)<br/>    enabled_ebs_write_ops = bool<br/>    ebs_write_ops         = number<br/>    # (Required) MetadataNoToken threshold (unit=Count)<br/>    enabled_metadata_no_token = bool<br/>    metadata_no_token         = number<br/>    # (Required) MetadataNoTokenRejected threshold (unit=Count)<br/>    enabled_metadata_no_token_rejected = bool<br/>    metadata_no_token_rejected         = number<br/>    # (Required) NetworkIn threshold (unit=Bytes)<br/>    enabled_network_in = bool<br/>    network_in         = number<br/>    # (Required) NetworkOut threshold (unit=Bytes)<br/>    enabled_network_out = bool<br/>    network_out         = number<br/>    # (Required) NetworkPacketsIn threshold (unit=Count)<br/>    enabled_network_packets_in = bool<br/>    network_packets_in         = number<br/>    # (Required) NetworkPacketsOut threshold (unit=Count)<br/>    enabled_network_packets_out = bool<br/>    network_packets_out         = number<br/>    # (Required) StatusCheckFailed threshold (unit=Count)<br/>    enabled_status_check_failed = bool<br/>    status_check_failed         = number<br/>    # (Required) StatusCheckFailed_AttachedEBS threshold (unit=Count)<br/>    enabled_status_check_failed_attached_ebs = bool<br/>    status_check_failed_attached_ebs         = number<br/>    # (Required) StatusCheckFailed_Instance threshold (unit=Count)<br/>    enabled_status_check_failed_instance = bool<br/>    status_check_failed_instance         = number<br/>    # (Required) StatusCheckFailed_System threshold (unit=Count)<br/>    enabled_status_check_failed_system = bool<br/>    status_check_failed_system         = number<br/>    }<br/>  )</pre> | <pre>{<br/>  "cpu_credit_balance": 10,<br/>  "cpu_credit_usage": 5,<br/>  "cpu_surplus_credit_balance": 5,<br/>  "cpu_surplus_credits_charged": 1,<br/>  "cpu_utilization": 80,<br/>  "dedicated_host_cpu_utilization": 80,<br/>  "disk_read_bytes": 1000000000,<br/>  "disk_read_ops": 1000,<br/>  "disk_write_bytes": 1000000000,<br/>  "disk_write_ops": 1000,<br/>  "ebs_byte_balance_percent": 10,<br/>  "ebs_io_balance_percent": 10,<br/>  "ebs_read_bytes": 1000000000,<br/>  "ebs_read_ops": 1000,<br/>  "ebs_write_bytes": 1000000000,<br/>  "ebs_write_ops": 1000,<br/>  "enabled_cpu_credit_balance": true,<br/>  "enabled_cpu_credit_usage": true,<br/>  "enabled_cpu_surplus_credit_balance": true,<br/>  "enabled_cpu_surplus_credits_charged": true,<br/>  "enabled_cpu_utilization": true,<br/>  "enabled_dedicated_host_cpu_utilization": true,<br/>  "enabled_disk_read_bytes": true,<br/>  "enabled_disk_read_ops": true,<br/>  "enabled_disk_write_bytes": true,<br/>  "enabled_disk_write_ops": true,<br/>  "enabled_ebs_byte_balance_percent": true,<br/>  "enabled_ebs_io_balance_percent": true,<br/>  "enabled_ebs_read_bytes": true,<br/>  "enabled_ebs_read_ops": true,<br/>  "enabled_ebs_write_bytes": true,<br/>  "enabled_ebs_write_ops": true,<br/>  "enabled_metadata_no_token": true,<br/>  "enabled_metadata_no_token_rejected": true,<br/>  "enabled_network_in": true,<br/>  "enabled_network_out": true,<br/>  "enabled_network_packets_in": true,<br/>  "enabled_network_packets_out": true,<br/>  "enabled_status_check_failed": true,<br/>  "enabled_status_check_failed_attached_ebs": true,<br/>  "enabled_status_check_failed_instance": true,<br/>  "enabled_status_check_failed_system": true,<br/>  "metadata_no_token": 1,<br/>  "metadata_no_token_rejected": 1,<br/>  "network_in": 1000000000,<br/>  "network_out": 1000000000,<br/>  "network_packets_in": 100000,<br/>  "network_packets_out": 100000,<br/>  "status_check_failed": 1,<br/>  "status_check_failed_attached_ebs": 1,<br/>  "status_check_failed_instance": 1,<br/>  "status_check_failed_system": 1<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
