<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.12 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | ~> 6.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_cloudwatch_log_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |
| [aws_wafv2_web_acl_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_custom_response_bodies"></a> [custom\_response\_bodies](#input\_custom\_response\_bodies) | (Optional) Custom response bodies for the Web ACL. | <pre>list(object({<br/>    content      = string<br/>    content_type = string<br/>    key          = string<br/>  }))</pre> | `[]` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | (Optional) Default action for the Web ACL. Valid values: allow, block. | `string` | `"allow"` | no |
| <a name="input_description"></a> [description](#input\_description) | (Optional) Description of the Web ACL. | `string` | `null` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | (Optional) Logging configuration. Set enabled=true to create CloudWatch Log Group and logging configuration. | <pre>object({<br/>    enabled             = optional(bool, false)<br/>    log_group_name      = optional(string)<br/>    retention_in_days   = optional(number, 14)<br/>    kms_key_id          = optional(string)<br/>    redacted_fields     = optional(list(any), [])<br/>    logging_filter      = optional(any, {})<br/>    log_destination_arn = optional(string)<br/>  })</pre> | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) Name of the WAFv2 Web ACL. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_resource_arns"></a> [resource\_arns](#input\_resource\_arns) | (Optional) Map of resource ARNs to associate the Web ACL with. Key is a stable identifier, value is the ARN. | `map(string)` | `{}` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | (Optional) List of WAF rule definitions. Supports managed\_rule\_group\_statement, rate\_based\_statement, and custom statements. | `any` | `[]` | no |
| <a name="input_scope"></a> [scope](#input\_scope) | (Required) Scope of the Web ACL. Valid values: CLOUDFRONT, REGIONAL. | `string` | `"REGIONAL"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) Tags to assign to resources. | `map(string)` | `{}` | no |
| <a name="input_visibility_config"></a> [visibility\_config](#input\_visibility\_config) | (Required) Visibility config for the Web ACL. | <pre>object({<br/>    cloudwatch_metrics_enabled = optional(bool, true)<br/>    metric_name                = string<br/>    sampled_requests_enabled   = optional(bool, true)<br/>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | The ARN of the CloudWatch Log Group for WAF logging. |
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | The ARN of the WAFv2 Web ACL. |
| <a name="output_web_acl_capacity"></a> [web\_acl\_capacity](#output\_web\_acl\_capacity) | The capacity units used by the Web ACL. |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | The ID of the WAFv2 Web ACL. |
| <a name="output_web_acl_name"></a> [web\_acl\_name](#output\_web\_acl\_name) | The name of the WAFv2 Web ACL. |
<!-- END_TF_DOCS -->
