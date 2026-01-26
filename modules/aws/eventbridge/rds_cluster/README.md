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
| <a name="module_scheduler_helper"></a> [scheduler\_helper](#module\_scheduler\_helper) | ../../_internal/eventbridge_scheduler_helper | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_scheduler_schedule.start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_rds_clusters.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/rds_clusters) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_auto_schedules_exclude_list"></a> [auto\_schedules\_exclude\_list](#input\_auto\_schedules\_exclude\_list) | (Optional) List of patterns to exclude from auto-discovery (partial match on cluster identifier). | `list(string)` | `[]` | no |
| <a name="input_auto_schedules_include_list"></a> [auto\_schedules\_include\_list](#input\_auto\_schedules\_include\_list) | (Optional) List of patterns to include in auto-discovery (partial match). If empty, all are included. | `list(string)` | `[]` | no |
| <a name="input_create_auto_schedules"></a> [create\_auto\_schedules](#input\_create\_auto\_schedules) | (Optional) Automatically discover RDS clusters to create schedules. If true, schedules variable is ignored. | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Default description for schedules. | `string` | `null` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable RDS cluster schedules. | `bool` | `true` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional) Creates a unique name beginning with the specified prefix. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | (Required) ARN of the IAM role that EventBridge Scheduler will use for this target. | `string` | n/a | yes |
| <a name="input_schedule_expression_start"></a> [schedule\_expression\_start](#input\_schedule\_expression\_start) | (Optional) Default start schedule expression. Can be overridden per schedule. | `string` | `null` | no |
| <a name="input_schedule_expression_stop"></a> [schedule\_expression\_stop](#input\_schedule\_expression\_stop) | (Optional) Default stop schedule expression. Can be overridden per schedule. | `string` | `null` | no |
| <a name="input_schedules"></a> [schedules](#input\_schedules) | (Optional) Map of RDS cluster schedules. Key is a unique identifier. Ignored if create\_auto\_schedules is true. | <pre>map(object({<br/>    db_cluster_identifier     = string<br/>    schedule_expression_start = optional(string)<br/>    schedule_expression_stop  = optional(string)<br/>    description               = optional(string)<br/>  }))</pre> | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
