# EventBridge Scheduler Helper Module

内部ヘルパーモジュール。EventBridge Schedulerモジュール（ECS, RDS, EC2）で使用し、auto-discoveryとフィルタリングのロジックを統一。

## 目的

- **Auto-discovery解析**: 外部スクリプトからの結果を解析
- **フィルタリング**: include/excludeリストによる柔軟なフィルタリング
- **スケジュール生成**: for_each用のスケジュールマップを生成
- **拡張性**: EC2などの新しいサービスタイプを簡単に追加可能

## サポートするスケジュールタイプ

- `ecs_service`: ECSサービスのstart/stop
- `rds_cluster`: RDSクラスターのstart/stop
- `ec2_instance`: EC2インスタンスのstart/stop

## 使用例

```hcl
module "scheduler_helper" {
  source = "../../_internal/eventbridge_scheduler_helper"

  is_enabled                  = var.is_enabled
  create_auto_schedules       = var.create_auto_schedules
  auto_discovered_data        = try(data.external.list[0].result, null)
  auto_schedules_include_list = var.auto_schedules_include_list
  auto_schedules_exclude_list = var.auto_schedules_exclude_list
  manual_schedules            = var.schedules
  schedule_type               = "ecs_service"  # or "rds_cluster" or "ec2_instance"
}

locals {
  schedules = module.scheduler_helper.schedules
}
```

## 入力変数

| 変数名                        | 型           | 説明                            |
| ----------------------------- | ------------ | ------------------------------- |
| `is_enabled`                  | bool         | モジュール全体の有効/無効フラグ |
| `create_auto_schedules`       | bool         | auto-discoveryを使用するか      |
| `auto_discovered_data`        | any          | 外部スクリプトからの生データ    |
| `auto_schedules_include_list` | list(string) | 含めるパターンリスト            |
| `auto_schedules_exclude_list` | list(string) | 除外するパターンリスト          |
| `manual_schedules`            | any          | 手動定義のスケジュール          |
| `schedule_type`               | string       | スケジュールタイプ（必須）      |

## 出力

| 出力名            | 説明                             |
| ----------------- | -------------------------------- |
| `schedules`       | for_each用のスケジュールマップ   |
| `should_use_auto` | auto-discoveryを使用しているか   |
| `schedule_count`  | フィルタリング後のスケジュール数 |

## アーキテクチャ

```
┌─────────────────────────────────────┐
│  eventbridge/{service}/main.tf      │
│  - data.external.list (script実行)  │
└──────────────┬──────────────────────┘
               │ auto_discovered_data
               ▼
┌─────────────────────────────────────┐
│  _internal/eventbridge_scheduler_   │
│  helper                              │
│  - schedule_type判定                 │
│  - 解析ロジック選択                  │
│  - フィルタリング実行                │
└──────────────┬──────────────────────┘
               │ schedules
               ▼
┌─────────────────────────────────────┐
│  eventbridge/{service}/main.tf      │
│  - aws_scheduler_schedule resources │
└─────────────────────────────────────┘
```

## 設計の利点

1. **DRY原則**: フィルタリングロジックを一元化
2. **拡張性**: 新しいサービスタイプを追加しやすい
3. **保守性**: ロジック変更が1箇所で済む
4. **テスタビリティ**: ヘルパーモジュール単体でテスト可能

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_auto_schedules_exclude_list"></a> [auto\_schedules\_exclude\_list](#input\_auto\_schedules\_exclude\_list) | Exclude filter list | `list(string)` | `[]` | no |
| <a name="input_auto_schedules_include_list"></a> [auto\_schedules\_include\_list](#input\_auto\_schedules\_include\_list) | Include filter list (empty = include all) | `list(string)` | `[]` | no |
| <a name="input_create_auto_schedules"></a> [create\_auto\_schedules](#input\_create\_auto\_schedules) | Whether to create auto-discovered schedules (true) or use manual schedules (false) | `bool` | `false` | no |
| <a name="input_is_enabled"></a> [is\_enabled](#input\_is\_enabled) | Master switch to enable/disable the entire module | `bool` | `true` | no |
| <a name="input_manual_schedules"></a> [manual\_schedules](#input\_manual\_schedules) | Manual schedules map (when create\_auto\_schedules = false) | `map(any)` | `{}` | no |
| <a name="input_primary_key"></a> [primary\_key](#input\_primary\_key) | The primary key name to use for filtering (e.g., 'instance\_id' for EC2, 'db\_cluster\_identifier' for RDS, 'ecs\_service' for ECS) | `string` | n/a | yes |
| <a name="input_schedule_expression_start"></a> [schedule\_expression\_start](#input\_schedule\_expression\_start) | Default start schedule expression to apply when a schedule omits it | `string` | `null` | no |
| <a name="input_schedule_expression_stop"></a> [schedule\_expression\_stop](#input\_schedule\_expression\_stop) | Default stop schedule expression to apply when a schedule omits it | `string` | `null` | no |
| <a name="input_source_schedules"></a> [source\_schedules](#input\_source\_schedules) | Source schedules map to filter (from caller's data processing logic) | `map(any)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_debug_manual_schedules_with_defaults"></a> [debug\_manual\_schedules\_with\_defaults](#output\_debug\_manual\_schedules\_with\_defaults) | Debug: manual\_schedules\_with\_defaults |
| <a name="output_debug_schedule_expression_start"></a> [debug\_schedule\_expression\_start](#output\_debug\_schedule\_expression\_start) | Debug: var.schedule\_expression\_start value |
| <a name="output_debug_schedule_expression_stop"></a> [debug\_schedule\_expression\_stop](#output\_debug\_schedule\_expression\_stop) | Debug: var.schedule\_expression\_stop value |
| <a name="output_schedule_count"></a> [schedule\_count](#output\_schedule\_count) | Number of schedules after filtering |
| <a name="output_schedules"></a> [schedules](#output\_schedules) | Map of schedules for for\_each usage. Key is unique identifier, value contains schedule configuration. |
| <a name="output_should_use_auto"></a> [should\_use\_auto](#output\_should\_use\_auto) | Whether to use auto-discovered schedules (true) or manual (false) |
<!-- END_TF_DOCS -->
