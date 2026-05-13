<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~>1.4 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.43.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_macie2_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_account) | resource |
| [aws_macie2_classification_job.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_classification_job) | resource |
| [aws_macie2_findings_filter.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_findings_filter) | resource |
| [aws_macie2_organization_admin_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_organization_admin_account) | resource |
| [aws_macie2_organization_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/macie2_organization_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_admin_account_id"></a> [admin\_account\_id](#input\_admin\_account\_id) | AWS account ID to designate as the Macie organization admin account | `string` | n/a | yes |
| <a name="input_auto_enable"></a> [auto\_enable](#input\_auto\_enable) | Whether to enable Macie automatically for new organization members | `bool` | `true` | no |
| <a name="input_classification_jobs"></a> [classification\_jobs](#input\_classification\_jobs) | (Optional) List of classification job configurations. Each item requires name, job\_type, and s3\_job\_definition. | `any` | `[]` | no |
| <a name="input_finding_publishing_frequency"></a> [finding\_publishing\_frequency](#input\_finding\_publishing\_frequency) | Frequency for publishing Macie findings. Valid values are FIFTEEN\_MINUTES, ONE\_HOUR, SIX\_HOURS. | `string` | `"FIFTEEN_MINUTES"` | no |
| <a name="input_findings_filters"></a> [findings\_filters](#input\_findings\_filters) | (Optional) List of findings filter configurations. Each item requires name, action, and finding\_criteria. | `any` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Whether to enable Macie organization configuration | `bool` | `false` | no |
| <a name="input_is_enabled_admin"></a> [is\_enabled\_admin](#input\_is\_enabled\_admin) | Whether to enable Macie organization admin account designation | `bool` | `false` | no |
| <a name="input_status"></a> [status](#input\_status) | Status for the Macie account. Valid values are ENABLED or PAUSED. | `string` | `"ENABLED"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to classification jobs and findings filters | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | The ID of the Macie account |
| <a name="output_classification_job_ids"></a> [classification\_job\_ids](#output\_classification\_job\_ids) | Map of classification job names to their IDs |
| <a name="output_findings_filter_arns"></a> [findings\_filter\_arns](#output\_findings\_filter\_arns) | Map of findings filter names to their ARNs |
| <a name="output_findings_filter_ids"></a> [findings\_filter\_ids](#output\_findings\_filter\_ids) | Map of findings filter names to their IDs |
| <a name="output_organization_admin_account_id"></a> [organization\_admin\_account\_id](#output\_organization\_admin\_account\_id) | The ID of the Macie organization admin account configuration |
| <a name="output_service_role"></a> [service\_role](#output\_service\_role) | The ARN of the service-linked role for Macie |
<!-- END_TF_DOCS -->
