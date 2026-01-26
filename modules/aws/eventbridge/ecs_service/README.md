<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>6.0 |
| <a name="requirement_external"></a> [external](#requirement\_external) | ~>2.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.28.0 |
| <a name="provider_external"></a> [external](#provider\_external) | 2.3.5 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_scheduler_helper"></a> [scheduler\_helper](#module\_scheduler\_helper) | ../../_internal/eventbridge_scheduler_helper | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_scheduler_schedule.start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.start_autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.stop_autoscaling](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [external_external.list](https://registry.terraform.io/providers/hashicorp/external/latest/docs/data-sources/external) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_schedules_exclude_list"></a> [auto\_schedules\_exclude\_list](#input\_auto\_schedules\_exclude\_list) | (Optional) List of patterns to exclude from auto-discovery (partial match on cluster or service name). | `list(string)` | `[]` | no |
| <a name="input_auto_schedules_include_list"></a> [auto\_schedules\_include\_list](#input\_auto\_schedules\_include\_list) | (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included. | `list(string)` | `[]` | no |
| <a name="input_autoscaling_max_capacity"></a> [autoscaling\_max\_capacity](#input\_autoscaling\_max\_capacity) | (Optional) Default maximum capacity for Application Auto Scaling when starting ECS services. Set to 0 to skip autoscaling adjustment. | `number` | `0` | no |
| <a name="input_autoscaling_min_capacity"></a> [autoscaling\_min\_capacity](#input\_autoscaling\_min\_capacity) | (Optional) Default minimum capacity for Application Auto Scaling when starting ECS services. Set to 0 to skip autoscaling adjustment. | `number` | `1` | no |
| <a name="input_create_auto_schedules"></a> [create\_auto\_schedules](#input\_create\_auto\_schedules) | (Optional) Automatically discover ECS services to create schedules. If true, schedules variable is ignored. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Default description for schedules. | `string` | `null` | no |
| <a name="input_desired_count"></a> [desired\_count](#input\_desired\_count) | (Optional) Default desired count for starting ECS services when not specified in schedules. | `number` | `1` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable ECS service schedules. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Creates a unique name beginning with the specified prefix. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | (Required) ARN of the IAM role that EventBridge Scheduler will use for this target. | `string` | n/a | yes |
| <a name="input_schedule_expression_start"></a> [schedule\_expression\_start](#input\_schedule\_expression\_start) | (Optional) Default start schedule expression. Can be overridden per schedule. | `string` | `null` | no |
| <a name="input_schedule_expression_stop"></a> [schedule\_expression\_stop](#input\_schedule\_expression\_stop) | (Optional) Default stop schedule expression. Can be overridden per schedule. | `string` | `null` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | (Optional) Map of ECS service schedules. Key is a unique identifier. Ignored if create\_auto\_schedules is true. | <pre>map(object({<br/>    ecs_cluster               = string<br/>    ecs_service               = string<br/>    desired_count             = optional(number)<br/>    has_autoscaling           = optional(number)<br/>    autoscaling_min_capacity  = optional(number)<br/>    autoscaling_max_capacity  = optional(number)<br/>    schedule_expression_start = optional(string)<br/>    schedule_expression_stop  = optional(string)<br/>    description               = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_debug_scheduler_helper_manual_schedules_with_defaults"></a> [debug\_scheduler\_helper\_manual\_schedules\_with\_defaults](#output\_debug\_scheduler\_helper\_manual\_schedules\_with\_defaults) | Debug: scheduler\_helper's manual\_schedules\_with\_defaults |
| <a name="output_debug_scheduler_helper_schedule_expression_start"></a> [debug\_scheduler\_helper\_schedule\_expression\_start](#output\_debug\_scheduler\_helper\_schedule\_expression\_start) | Debug: scheduler\_helper's var.schedule\_expression\_start |
| <a name="output_debug_scheduler_helper_schedule_expression_stop"></a> [debug\_scheduler\_helper\_schedule\_expression\_stop](#output\_debug\_scheduler\_helper\_schedule\_expression\_stop) | Debug: scheduler\_helper's var.schedule\_expression\_stop |
| <a name="output_schedules"></a> [schedules](#output\_schedules) | Map of schedules being managed |
| <a name="output_start_schedule_arns"></a> [start\_schedule\_arns](#output\_start\_schedule\_arns) | ARNs of start schedules |
| <a name="output_stop_schedule_arns"></a> [stop\_schedule\_arns](#output\_stop\_schedule\_arns) | ARNs of stop schedules |
<!-- END_TF_DOCS -->
