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
| [aws_iam_policy.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_tasks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.events](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input\_aws\_iam\_policy) | (Optional) Provides an IAM policy. | <pre>object(<br>    {<br>      events = object({<br>        # Description of the IAM policy.<br>        description = string<br>        # The name of the policy. If omitted, Terraform will assign a random, unique name.<br>        name = string<br>        # Path in which to create the policy. See IAM Identifiers for more information.<br>        path = string<br>        }<br>      )<br>    }<br>  )</pre> | <pre>{<br>  "events": {<br>    "description": "Policy for ECS.",<br>    "name": "ecs-policy",<br>    "path": "/"<br>  }<br>}</pre> | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) Provides an IAM role. | <pre>object(<br>    {<br>      ecs = object({<br>        # Description of the role.<br>        description = string<br>        # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>        name = string<br>        # Path to the role. See IAM Identifiers for more information.<br>        path = string<br>        }<br>      )<br>      ecs_tasks = object({<br>        # Description of the role.<br>        description = string<br>        # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>        name = string<br>        # Path to the role. See IAM Identifiers for more information.<br>        path = string<br>        }<br>      )<br>      events = object({<br>        # Description of the role.<br>        description = string<br>        # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>        name = string<br>        # Path to the role. See IAM Identifiers for more information.<br>        path = string<br>        }<br>      )<br>    }<br>  )</pre> | <pre>{<br>  "ecs": {<br>    "description": "Role for ECS.",<br>    "name": "ecs-role",<br>    "path": "/"<br>  },<br>  "ecs_tasks": {<br>    "description": "Role for ECS Task.",<br>    "name": "ecs-tasks-role",<br>    "path": "/"<br>  },<br>  "events": {<br>    "description": "Role for Events.",<br>    "name": "events-role",<br>    "path": "/"<br>  }<br>}</pre> | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Key-value mapping of tags for the IAM role | `map(any)` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecs_arn"></a> [ecs\_arn](#output\_ecs\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_ecs_name"></a> [ecs\_name](#output\_ecs\_name) | Name of the role. |
| <a name="output_ecs_tasks_arn"></a> [ecs\_tasks\_arn](#output\_ecs\_tasks\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_ecs_tasks_name"></a> [ecs\_tasks\_name](#output\_ecs\_tasks\_name) | Name of the role. |
| <a name="output_events_arn"></a> [events\_arn](#output\_events\_arn) | Amazon Resource Name (ARN) specifying the role. |
| <a name="output_events_name"></a> [events\_name](#output\_events\_name) | Name of the role. |
<!-- END_TF_DOCS -->
