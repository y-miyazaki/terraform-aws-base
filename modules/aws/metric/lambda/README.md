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
| [aws_cloudwatch_metric_alarm.async_event_age](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.async_events_dropped](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.async_events_received](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.claimed_account_concurrency](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.concurrent_executions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.dead_letter_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.destination_delivery_failures](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.duration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.invocations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.iterator_age](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.offset_lag](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.post_runtime_extensions_duration](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.provisioned_concurrency_invocations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.provisioned_concurrency_spillover_invocations](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.provisioned_concurrency_utilization](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.recursive_invocations_dropped](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.throttles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.unreserved_concurrent_executions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_lambda_functions.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/lambda_functions) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alarm_actions"></a> [alarm\_actions](#input\_alarm\_actions) | (Required) The list of actions to execute when this alarm transitions into an ALARM state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | n/a | yes |
| <a name="input_auto_dimensions_exclude_list"></a> [auto\_dimensions\_exclude\_list](#input\_auto\_dimensions\_exclude\_list) | (Optional) If create\_auto\_dimensions is set to true, a list of Lambda functions will be automatically registered, but at that time, specify the function name you want to exclude using partial match. | `list(string)` | `[]` | no |
| <a name="input_auto_dimensions_include_list"></a> [auto\_dimensions\_include\_list](#input\_auto\_dimensions\_include\_list) | (Optional) If create\_auto\_dimensions is set to true, a list of Lambda functions will be automatically registered, but at that time, specify the function name you want to include using partial match. If empty, all functions will be included (except excluded ones). | `list(string)` | `[]` | no |
| <a name="input_create_auto_dimensions"></a> [create\_auto\_dimensions](#input\_create\_auto\_dimensions) | (Optional) Builds a list of DLQs to automatically set dimensions. If this is true, the dimensions setting will be ignored. | `bool` | `false` | no |
| <a name="input_dimensions"></a> [dimensions](#input\_dimensions) | (Optional) If create\_auto\_dimensions is set to false, The dimensions for the alarm's associated metric. For the list of available dimensions see the AWS documentation here. | `list(map(any))` | `[]` | no |
| <a name="input_insufficient_data_actions"></a> [insufficient\_data\_actions](#input\_insufficient\_data\_actions) | (Optional) The list of actions to execute when this alarm transitions into an INSUFFICIENT\_DATA state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Lambda. Defaults true. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Required) CloudWatch Filter/Alarm name prefix. | `string` | n/a | yes |
| <a name="input_ok_actions"></a> [ok\_actions](#input\_ok\_actions) | (Optional) The list of actions to execute when this alarm transitions into an OK state from any other state. Each action is specified as an Amazon Resource Name (ARN). | `list(string)` | `[]` | no |
| <a name="input_period"></a> [period](#input\_period) | (Optional) The period in seconds over which the specified statistic is applied. | `number` | `300` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value map of resource tags. | `map(any)` | `null` | no |
| <a name="input_threshold"></a> [threshold](#input\_threshold) | (Optional) Set the threshold for each Metric in Lambda. | <pre>object({<br/>    # AsyncEventAge threshold (unit=Milliseconds)<br/>    enabled_async_event_age = bool<br/>    async_event_age         = number<br/>    # AsyncEventsDropped threshold (unit=Count)<br/>    enabled_async_events_dropped = bool<br/>    async_events_dropped         = number<br/>    # AsyncEventsReceived threshold (unit=Count)<br/>    enabled_async_events_received = bool<br/>    async_events_received         = number<br/>    # ClaimedAccountConcurrency threshold (unit=Count)<br/>    enabled_claimed_account_concurrency = bool<br/>    claimed_account_concurrency         = number<br/>    # ConcurrentExecutions threshold (unit=Count)<br/>    enabled_concurrent_executions = bool<br/>    concurrent_executions         = number<br/>    # DeadLetterErrors threshold (unit=Count)<br/>    enabled_dead_letter_errors = bool<br/>    dead_letter_errors         = number<br/>    # DestinationDeliveryFailures threshold (unit=Count)<br/>    enabled_destination_delivery_failures = bool<br/>    destination_delivery_failures         = number<br/>    # Duration threshold (unit=Milliseconds)<br/>    enabled_duration = bool<br/>    duration         = number<br/>    # Errors threshold (unit=Count)<br/>    enabled_errors = bool<br/>    errors         = number<br/>    # Invocations threshold (unit=Count)<br/>    enabled_invocations = bool<br/>    invocations         = number<br/>    # IteratorAge threshold (unit=Milliseconds)<br/>    enabled_iterator_age = bool<br/>    iterator_age         = number<br/>    # OffsetLag threshold (unit=Milliseconds)<br/>    enabled_offset_lag = bool<br/>    offset_lag         = number<br/>    # PostRuntimeExtensionsDuration threshold (unit=Milliseconds)<br/>    enabled_post_runtime_extensions_duration = bool<br/>    post_runtime_extensions_duration         = number<br/>    # ProvisionedConcurrencyInvocations threshold (unit=Count)<br/>    enabled_provisioned_concurrency_invocations = bool<br/>    provisioned_concurrency_invocations         = number<br/>    # ProvisionedConcurrencySpilloverInvocations threshold (unit=Count)<br/>    enabled_provisioned_concurrency_spillover_invocations = bool<br/>    provisioned_concurrency_spillover_invocations         = number<br/>    # ProvisionedConcurrencyUtilization threshold (unit=Percent)<br/>    enabled_provisioned_concurrency_utilization = bool<br/>    provisioned_concurrency_utilization         = number<br/>    # RecursiveInvocationsDropped threshold (unit=Count)<br/>    enabled_recursive_invocations_dropped = bool<br/>    recursive_invocations_dropped         = number<br/>    # Throttles threshold (unit=Count)<br/>    enabled_throttles = bool<br/>    throttles         = number<br/>    # UnreservedConcurrentExecutions threshold (unit=Count)<br/>    enabled_unreserved_concurrent_executions = bool<br/>    unreserved_concurrent_executions         = number<br/>    }<br/>  )</pre> | <pre>{<br/>  "async_event_age": 30000,<br/>  "async_events_dropped": 1,<br/>  "async_events_received": 100000,<br/>  "claimed_account_concurrency": 900,<br/>  "concurrent_executions": 500,<br/>  "dead_letter_errors": 1,<br/>  "destination_delivery_failures": 1,<br/>  "duration": 10000,<br/>  "enabled_async_event_age": true,<br/>  "enabled_async_events_dropped": true,<br/>  "enabled_async_events_received": false,<br/>  "enabled_claimed_account_concurrency": false,<br/>  "enabled_concurrent_executions": true,<br/>  "enabled_dead_letter_errors": true,<br/>  "enabled_destination_delivery_failures": true,<br/>  "enabled_duration": true,<br/>  "enabled_errors": true,<br/>  "enabled_invocations": true,<br/>  "enabled_iterator_age": true,<br/>  "enabled_offset_lag": false,<br/>  "enabled_post_runtime_extensions_duration": false,<br/>  "enabled_provisioned_concurrency_invocations": false,<br/>  "enabled_provisioned_concurrency_spillover_invocations": false,<br/>  "enabled_provisioned_concurrency_utilization": false,<br/>  "enabled_recursive_invocations_dropped": true,<br/>  "enabled_throttles": true,<br/>  "enabled_unreserved_concurrent_executions": false,<br/>  "errors": 1,<br/>  "invocations": 100000,<br/>  "iterator_age": 60000,<br/>  "offset_lag": 100000,<br/>  "post_runtime_extensions_duration": 5000,<br/>  "provisioned_concurrency_invocations": 10000,<br/>  "provisioned_concurrency_spillover_invocations": 100,<br/>  "provisioned_concurrency_utilization": 80,<br/>  "recursive_invocations_dropped": 1,<br/>  "throttles": 10,<br/>  "unreserved_concurrent_executions": 800<br/>}</pre> | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
