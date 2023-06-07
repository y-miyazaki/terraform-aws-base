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
| [aws_cloudwatch_log_metric_filter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_metric_filter) | resource |
| [aws_cloudwatch_metric_alarm.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_default_tags.provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/default_tags) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_cloudwatch_log_metric_filter"></a> [aws\_cloudwatch\_log\_metric\_filter](#input\_aws\_cloudwatch\_log\_metric\_filter) | (Required) aws\_cloudwatch\_log\_metric\_filter. | `list(any)` | n/a | yes |
| <a name="input_aws_cloudwatch_metric_alarm"></a> [aws\_cloudwatch\_metric\_alarm](#input\_aws\_cloudwatch\_metric\_alarm) | (Required) aws\_cloudwatch\_metric\_alarm. | `list(any)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map(any)` | `null` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
