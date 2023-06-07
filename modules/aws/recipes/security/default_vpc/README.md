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
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_default_network_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_network_acl) | resource |
| [aws_default_route_table.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_route_table) | resource |
| [aws_default_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_security_group) | resource |
| [aws_default_subnet.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_subnet) | resource |
| [aws_default_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/default_vpc) | resource |
| [aws_flow_log.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_availability_zones.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloudwatch_log_group"></a> [aws\_cloudwatch\_log\_group](#input\_aws\_cloudwatch\_log\_group) | (Optional) need to flow log, true. flow log saves cloudwatch logs. | <pre>object(<br>    {<br>      # The name of the log group. If omitted, Terraform will assign a random, unique name.<br>      name = string<br>      # Specifies the number of days you want to retain log events in the specified log group. Possible values are: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653, and 0. If you select 0, the events in the log group are always retained and never expire.<br>      retention_in_days = number<br>    }<br>  )</pre> | <pre>{<br>  "name": "vpc-flow-logs",<br>  "retention_in_days": 30<br>}</pre> | no |
| <a name="input_aws_iam_policy"></a> [aws\_iam\_policy](#input\_aws\_iam\_policy) | (Optional) The resource of aws\_iam\_policy. | <pre>object(<br>    {<br>      # Description of the IAM policy.<br>      description = string<br>      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Policy for VPC Flow log.",<br>  "name": "vpc-flow-logs-policy",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_aws_iam_role"></a> [aws\_iam\_role](#input\_aws\_iam\_role) | (Optional) The resource of aws\_iam\_role. | <pre>object(<br>    {<br>      # Description of the role.<br>      description = string<br>      # Friendly name of the role. If omitted, Terraform will assign a random, unique name. See IAM Identifiers for more information.<br>      name = string<br>      # Path to the role. See IAM Identifiers for more information.<br>      path = string<br>    }<br>  )</pre> | <pre>{<br>  "description": "Role for VPC Flow log.",<br>  "name": "vpc-flow-logs-role",<br>  "path": "/"<br>}</pre> | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | (Optional) A boolean flag to enable/disable settings of Dafault VPC. Defaults true. | `bool` | `true` | no |
| <a name="input_is_enabled_flow_logs"></a> [is\_enabled\_flow\_logs](#input\_is\_enabled\_flow\_logs) | (Optional) A boolean flag to enable/disable Flow Log. Defaults true. | `bool` | `true` | no |
| <a name="input_is_enabled_vpc_end_point"></a> [is\_enabled\_vpc\_end\_point](#input\_is\_enabled\_vpc\_end\_point) | (Optional) A boolean flag to enable/disable VPC Endpoint for [EC2.10]. Defaults false. | `bool` | `false` | no |
| <a name="input_region"></a> [region](#input\_region) | (Required) The region name. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
