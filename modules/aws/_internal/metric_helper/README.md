<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_base_threshold"></a> [base\_threshold](#input\_base\_threshold) | Base threshold object containing default values for all metrics | `any` | n/a | yes |
| <a name="input_create_auto"></a> [create\_auto](#input\_create\_auto) | Whether to create auto-discovered resources (true) or use manual dimensions (false) | `bool` | `false` | no |
| <a name="input_dimension_key"></a> [dimension\_key](#input\_dimension\_key) | The primary dimension key name (e.g., 'QueueName' for SQS, 'DBClusterIdentifier' for RDS) | `string` | n/a | yes |
| <a name="input_exclude_list"></a> [exclude\_list](#input\_exclude\_list) | Exclude filter list | `list(string)` | `[]` | no |
| <a name="input_include_list"></a> [include\_list](#input\_include\_list) | Include filter list (empty = include all) | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Master switch to enable/disable the entire module | `bool` | `true` | no |
| <a name="input_manual_dimensions"></a> [manual\_dimensions](#input\_manual\_dimensions) | Manual dimensions list (when create\_auto = false) | `any` | `null` | no |
| <a name="input_source_list"></a> [source\_list](#input\_source\_list) | Source list to filter (from data source or external script) | `list(string)` | `[]` | no |
| <a name="input_threshold_override"></a> [threshold\_override](#input\_threshold\_override) | Map of resource name to threshold overrides. Key is the dimension value (exact match), value is an object with optional threshold attributes to override. | `any` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_effective_thresholds"></a> [effective\_thresholds](#output\_effective\_thresholds) | Map of resource name to effective threshold (base merged with overrides). Key matches list keys. |
| <a name="output_filtered_list"></a> [filtered\_list](#output\_filtered\_list) | Filtered list after applying include/exclude patterns with null safety (for backward compatibility) |
| <a name="output_list"></a> [list](#output\_list) | Map of resources for for\_each usage. Key is dimension value, value contains 'name' and 'dimensions'. |
| <a name="output_safe_manual_dimensions"></a> [safe\_manual\_dimensions](#output\_safe\_manual\_dimensions) | Manual dimensions with null safety applied (for backward compatibility) |
| <a name="output_should_use_auto"></a> [should\_use\_auto](#output\_should\_use\_auto) | Whether to use auto-discovered dimensions (true) or manual (false) |
<!-- END_TF_DOCS -->
