<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~> 2.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_scheduler_helper"></a> [scheduler\_helper](#module\_scheduler\_helper) | ../../_internal/eventbridge_scheduler_helper | n/a |

## Resources

| Name | Type |
| ---- | ---- |
| [aws_scheduler_schedule.pause](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.resume](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [external_external.list](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_auto_schedules_exclude_list"></a> [auto\_schedules\_exclude\_list](#input\_auto\_schedules\_exclude\_list) | (Optional) List of patterns to exclude from auto-discovery (partial match on cluster identifier). | `list(string)` | `[]` | no |
| <a name="input_auto_schedules_include_list"></a> [auto\_schedules\_include\_list](#input\_auto\_schedules\_include\_list) | (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included. | `list(string)` | `[]` | no |
| <a name="input_create_auto_schedules"></a> [create\_auto\_schedules](#input\_create\_auto\_schedules) | (Optional) Automatically discover Redshift clusters to create schedules. If true, schedules variable is ignored. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Default description for schedules. | `string` | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable Redshift cluster schedules. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Creates a unique name beginning with the specified prefix. | `string` | `null` | no |
| <a name="input_retry_max_age_seconds"></a> [retry\_max\_age\_seconds](#input\_retry\_max\_age\_seconds) | (Optional) Maximum age of a request that EventBridge Scheduler sends to a target for processing. | `number` | `3600` | no |
| <a name="input_retry_max_attempts"></a> [retry\_max\_attempts](#input\_retry\_max\_attempts) | (Optional) Maximum number of retry attempts to make before the request fails. | `number` | `3` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | (Required) ARN of the IAM role that EventBridge Scheduler will use for this target. | `string` | n/a | yes |
| <a name="input_schedule_expression_start"></a> [schedule\_expression\_start](#input\_schedule\_expression\_start) | (Optional) Default start schedule expression. Can be overridden per schedule. | `string` | `null` | no |
| <a name="input_schedule_expression_stop"></a> [schedule\_expression\_stop](#input\_schedule\_expression\_stop) | (Optional) Default stop schedule expression. Can be overridden per schedule. | `string` | `null` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | (Optional) Map of Redshift cluster schedules. Key is a unique identifier. Ignored if create\_auto\_schedules is true. | <pre>map(object({<br/>    cluster_identifier        = string<br/>    schedule_expression_start = optional(string)<br/>    schedule_expression_stop  = optional(string)<br/>    description               = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_schedule_arns_pause"></a> [schedule\_arns\_pause](#output\_schedule\_arns\_pause) | Map of schedule ARNs for stop/pause operations. Key is the cluster identifier. |
| <a name="output_schedule_arns_resume"></a> [schedule\_arns\_resume](#output\_schedule\_arns\_resume) | Map of schedule ARNs for start/resume operations. Key is the cluster identifier. |
| <a name="output_schedules"></a> [schedules](#output\_schedules) | Map of all configured schedules after filtering and merging. |
<!-- END_TF_DOCS -->
