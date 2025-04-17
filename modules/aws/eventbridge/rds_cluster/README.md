<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.0 |
| <a name="requirement_template"></a> [template](#requirement\_template) | >=2.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.35.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_scheduler_schedule.start](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |
| [aws_scheduler_schedule.stop](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/scheduler_schedule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_db_cluster_identifier"></a> [db\_cluster\_identifier](#input\_db\_cluster\_identifier) | (Required) Specify the ID of the target RDS Cluster. | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Brief description of the schedule. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | (Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name. | `string` | `null` | no |
| <a name="input_name_start_cluster"></a> [name\_start\_cluster](#input\_name\_start\_cluster) | (Optional, Forces new resource) Name of the schedule. If omitted, Terraform will assign a random, unique name. Conflicts with name\_prefix. | `string` | `null` | no |
| <a name="input_name_stop_cluster"></a> [name\_stop\_cluster](#input\_name\_stop\_cluster) | (Optional, Forces new resource) Name of the schedule. If omitted, Terraform will assign a random, unique name. Conflicts with name\_prefix. | `string` | `null` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | (Required) ARN of the IAM role that EventBridge Scheduler will use for this target when the schedule is invoked. Read more in Set up the execution role. | `string` | n/a | yes |
| <a name="input_schedule_expression_start"></a> [schedule\_expression\_start](#input\_schedule\_expression\_start) | (Required) Defines when the schedule runs. Read more in Schedule types on EventBridge Scheduler. | `string` | `null` | no |
| <a name="input_schedule_expression_stop"></a> [schedule\_expression\_stop](#input\_schedule\_expression\_stop) | (Required) Defines when the schedule runs. Read more in Schedule types on EventBridge Scheduler. | `string` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
