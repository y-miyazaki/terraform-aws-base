---
applyTo: "**/*.tf,**/*.tfvars,**/*.hcl"
description: "AI Assistant Instructions for Terraform"
---

# AI Assistant Instructions for Terraform

**言語ポリシー**: ドキュメント日本語、コード・コメント英語

## Standards

### Naming Conventions

| Component       | Rule       | Example                   |
| --------------- | ---------- | ------------------------- |
| Resource        | snake_case | aws_s3_bucket.data_lake   |
| Variable        | snake_case | vpc_cidr_block            |
| Output          | snake_case | alb_dns_name              |
| Local           | snake_case | common_tags               |
| Module instance | snake_case | vpc_main                  |
| File            | snake_case | main_vpc.tf, variables.tf |

### Terraform Standards

- 構文: `terraform fmt`準拠
- Validation: `terraform validate`成功
- Security: `tflint`, `trivy`合格

## Guidelines

### Documentation and Comments

- ファイルヘッダー: 目的記載
- 複雑リソース: コメント付与
- 全コメント英語

### Code Modification Guidelines

- 検証は [terraform-validation Skill](../skills/terraform-validation/SKILL.md) を優先し、`validate.sh` を使用する
- 個別コマンド（`terraform fmt`/`terraform validate`/`tflint`/`trivy`）はデバッグ時のみ使用

#### Variables/Outputs

- 変数名: snake_case
- 型: 具体化（`map(any)`/`any`過度回避）
- デフォルト値: 不要 default 削除、sentinel 値回避
- 説明: description + (Required)/(Optional)
- validation: 禁止パターン（`length > 0`等）不使用
- outputs: description 必須、機密情報出力禁止

#### Resources

- `for_each`優先（`count`はトグル用途のみ）
- apply 後決定値を for_each/count キー不使用
- `depends_on`最小限（implicit dependency 優先）
- 循環参照回避
- `moved`ブロックでリソース再作成回避
- deprecated 機能置換
- コメントアウトリソース削除
- terraform resource を使う場合、terraform repository を Fetch して調査

#### Modules

- 外部モジュール: Version 固定（SHA/pseudo version 回避）
- Module 出力活用（不要 output 無/必要 output 欠落無）
- locals/variables/outputs 責務明確
- 重複タグ・命名プリフィックス統一

#### Versioning

- `required_version`範囲プロジェクト標準準拠
- provider version 範囲（`>= lower, < upper`）
- 外部 module 固定バージョン

#### セキュリティ必須項目

- KMS 暗号化（S3/SNS/Logs/StateMachines 等）
- IAM 最小権限（`*`最小限+理由）
- resource_policy に`Condition`（SourceArn 等）
- 平文シークレット禁止
- Logging 設定適切（CloudTrail/CloudWatch Logs 等）
- デフォルト VPC/オープン SG/パブリック S3 禁止
- IAM ポリシー: `jsonencode`または aws_iam_policy_document 使用

#### Tagging

- Name 追加: `merge(local.tags, { Name = "..." })`
- 不要手動重複キー削除

#### State & Backend

- remote backend 暗号化(SSE)+DynamoDB ロック
- backend 設定に資格情報直接記載禁止
- workspace 不使用（方針明文化）
- `terraform state`手動操作ドキュメント化

#### tfvars

- 変数名: snake_case
- シークレット未記載（Secret Manager/SSM Parameter 誘導）
- 環境別ファイル分離（dev/stg/qa/prd）
- 他環境識別子混在禁止（アカウント ID/VPC ID 等）
- 環境名 prefix 誤混在禁止

### MCP Tool Usage (terraform-mcp-server)

AWS provider 優先:

1. `SearchAwsProviderDocs`
2. `SearchAwsccProviderDocs`（Cloud Control API）（fallback）
3. AWS-IA モジュール: `SearchSpecificAwsIaModules`

## Testing and Validation

**詳細ガイド**: [terraform-validation Skill](../skills/terraform-validation/SKILL.md) を参照（検証手順・トラブルシューティング・セキュリティチェック）
