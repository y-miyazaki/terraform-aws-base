---
applyTo: "**/aws_architecture_diagram*.yaml,**/aws_architecture_diagram*.yml,**/aws_architecture_diagram*.png"
description: "AI Assistant Instructions for Diagram as Code (DAC)"
---

# AI Assistant Instructions for Diagram as Code

## Scope

- 対象は `aws_architecture_diagram*.yaml|yml|png` と、その生成・検証運用に限定する

| File/Pattern                    | Purpose                |
| ------------------------------- | ---------------------- |
| aws_architecture_diagram\*.yaml | DAC ソース（環境別）   |
| aws_architecture_diagram\*.png  | 生成図（環境別）       |
| scripts/terraform/aws*arch*     | DAC 自動生成スクリプト |

## Standards

### Naming Conventions

| Component   | Rule                 | Example                           |
| ----------- | -------------------- | --------------------------------- |
| YAML/PNG    | snake_case + env     | aws_architecture_diagram_prd.yaml |
| Resource ID | PascalCase           | VPC, ECSBackend                   |
| Stack ID    | PascalCase + "Stack" | EdgeServicesStack                 |
| Title       | Human-readable       | "ECS Backend"                     |
| Link Label  | Short text           | "HTTPS", "SQL"                    |

### Resource Type Mapping（主要のみ）

| Terraform Resource          | DAC Type                                  | Title Note           |
| --------------------------- | ----------------------------------------- | -------------------- |
| aws_lb (application)        | AWS::ElasticLoadBalancingV2::LoadBalancer | "(ALB)"追加          |
| aws_lb (network)            | AWS::ElasticLoadBalancingV2::LoadBalancer | "(NLB)"追加          |
| aws_ecs_service             | AWS::ECS::Service                         | クラスタ名含める     |
| aws_rds_cluster             | AWS::RDS::DBCluster                       | エンジン名明記       |
| aws_lambda_function         | AWS::Lambda::Function                     | VPC 配置記載（任意） |
| aws_s3_bucket               | AWS::S3::Bucket                           | バケット目的含む     |
| aws_subnet (public/private) | AWS::EC2::Subnet                          | "Public"/"Private"   |

### DAC Best Practices

階層構造:

- Canvas → Cloud → Region → VPC → Subnet → Resources

リンク描画:

- ユーザートラフィック: North → South
- 水平通信: East ↔ West
- DB クエリ: orthogonal タイプ
- 弱関連: dashed

Route53/WAF 可視化:

- Route53: Global セクション（Region 配下でない）
- User→Route53 線引かない（User→ 実配信先へ直接）
- ドメイン名: 実リソース（CloudFront 等）Title に記載
- WAF: 適用リソース右横配置、リソース →WAF 破線

## Guidelines

### Documentation and Comments

- YAML コメントで構成意図記載
- 複雑リンク構造に説明コメント
- 環境固有設定は TODO コメント

### Code Modification Guidelines

- 検証は [diagram-as-code-validation Skill](../skills/diagram-as-code-validation/SKILL.md) の Required Validation Steps を優先
- 詳細コマンドオプションはデバッグ時のみ使用

### MCP Tool Usage (awsdac-mcp-server)

```bash
# 1. 新規作成・形式確認時に使用
mcp_awsdac-mcp-se_getDiagramAsCodeFormat

# 2. 出力物検証・保存時に使用
mcp_awsdac-mcp-se_generateDiagramToFile

# 3. プレビュー表示時に使用
mcp_awsdac-mcp-se_generateDiagram
```

### Terraform→DAC 変換手順

1. リソース収集: `grep_search`で Terraform 抽出
2. 構造設計: Public/Private App/Private Data 3 層
3. リンク設計: 主要フロー定義
4. 検証: PNG 視覚確認

## Testing and Validation

**詳細ガイド**: [diagram-as-code-validation Skill](../skills/diagram-as-code-validation/SKILL.md) を参照（検証手順・図生成トラブルシューティング・セキュリティチェック）

## Security Guidelines

- 機密情報（ARN/Account ID/内部ドメイン等）をコメント・Title・Label に直接記載しない
- 外部入力由来のテキストをそのまま図要素に反映しない（整形・検証を先に実施）
- 生成物（PNG/YAML）公開時は公開可能な環境情報のみ含むことを確認する
