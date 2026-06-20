# Auto Discovery Filter Helper Module

## Purpose

Internal helper module providing common auto-discovery filtering logic with null safety and include/exclude patterns.

## Features

- **Null Safety**: Handles null inputs gracefully
- **Include/Exclude Filtering**: Whitelist and blacklist pattern matching
- **is_enabled Control**: Master switch for module enablement
- **Auto/Manual Toggle**: Seamless switching between auto-discovery and manual configuration

## Usage

This module is intended for internal use by AWS metric and CloudWatch modules only.

### Example

```terraform
module "filter" {
  source = "../_internal/auto_discovery_filter"

  is_enabled         = var.is_enabled
  create_auto        = var.create_auto_dimensions
  source_list        = split(",", data.external.list[0].result.list)
  include_list       = var.auto_dimensions_include_list
  exclude_list       = var.auto_dimensions_exclude_list
  manual_dimensions  = var.dimensions
}

locals {
  auto_dimensions = module.filter.filtered_list
  safe_dimensions = module.filter.safe_manual_dimensions
}
```

## Inputs

| Name              | Description                                 | Type         | Default |
| ----------------- | ------------------------------------------- | ------------ | ------- |
| is_enabled        | Master switch to enable/disable             | bool         | true    |
| create_auto       | Use auto-discovery (true) or manual (false) | bool         | false   |
| source_list       | Source list to filter                       | list(string) | []      |
| include_list      | Include filter (empty = all)                | list(string) | []      |
| exclude_list      | Exclude filter                              | list(string) | []      |
| manual_dimensions | Manual dimensions list                      | any          | null    |

## Outputs

| Name                   | Description                        |
| ---------------------- | ---------------------------------- |
| filtered_list          | Filtered list with null safety     |
| safe_manual_dimensions | Manual dimensions with null safety |
| should_use_auto        | Whether to use auto or manual      |

## Notes

- This module does not create any AWS resources
- It only provides filtering logic via locals and outputs
- Not intended for direct use outside of internal modules

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.7 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 6.0 |

## Providers

| Name | Version |
| ---- | ------- |
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
| ---- | ---- |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_create_auto"></a> [create\_auto](#input\_create\_auto) | Whether to create auto-discovered resources (true) or use manual dimensions (false) | `bool` | `false` | no |
| <a name="input_exclude_list"></a> [exclude\_list](#input\_exclude\_list) | Exclude filter list | `list(string)` | `[]` | no |
| <a name="input_include_list"></a> [include\_list](#input\_include\_list) | Include filter list (empty = include all) | `list(string)` | `[]` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Master switch to enable/disable the entire module | `bool` | `true` | no |
| <a name="input_manual_dimensions"></a> [manual\_dimensions](#input\_manual\_dimensions) | Manual dimensions list (when create\_auto = false) | `any` | `null` | no |
| <a name="input_region"></a> [region](#input\_region) | (Optional) AWS region. Defaults to provider region. | `string` | `null` | no |
| <a name="input_source_list"></a> [source\_list](#input\_source\_list) | Source list to filter (from data source or external script) | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_filtered_list"></a> [filtered\_list](#output\_filtered\_list) | Filtered list after applying include/exclude patterns with null safety |
| <a name="output_safe_manual_dimensions"></a> [safe\_manual\_dimensions](#output\_safe\_manual\_dimensions) | Manual dimensions with null safety applied |
| <a name="output_should_use_auto"></a> [should\_use\_auto](#output\_should\_use\_auto) | Whether to use auto-discovered dimensions (true) or manual (false) |
<!-- END_TF_DOCS -->
