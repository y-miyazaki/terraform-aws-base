---
applyTo: "**/*.yaml,**/aws_architecture_diagram*.{yaml,yml,png}"
description: "AI Assistant Instructions for Diagram as Code (DAC)"
---

# AI Assistant Instructions for Diagram as Code

**言語ポリシー**: ドキュメント日本語、コード・コメント英語

| File/Pattern                  | Purpose                  |
| ----------------------------- | ------------------------ |
| aws_architecture_diagram*.yaml | DACソース（環境別）      |
| aws_architecture_diagram*.png  | 生成図（環境別）         |
| scripts/terraform/aws*arch*    | DAC自動生成スクリプト    |

## Standards

### Naming Conventions

| Component   | Rule                 | Example                   |
| ----------- | -------------------- | ------------------------- |
| YAML/PNG    | snake_case + env     | aws_architecture_diagram_prd.yaml |
| Resource ID | PascalCase           | VPC, ECSBackend           |
| Stack ID    | PascalCase + "Stack" | EdgeServicesStack         |
| Title       | Human-readable       | "ECS Backend"             |
| Link Label  | Short text           | "HTTPS", "SQL"            |

### Resource Type Mapping（主要のみ）

| Terraform Resource           | DAC Type                                  | Title Note           |
| ---------------------------- | ----------------------------------------- | -------------------- |
| aws_lb (application)         | AWS::ElasticLoadBalancingV2::LoadBalancer | "(ALB)"追加          |
| aws_lb (network)             | AWS::ElasticLoadBalancingV2::LoadBalancer | "(NLB)"追加          |
| aws_ecs_service              | AWS::ECS::Service                         | クラスタ名含める     |
| aws_rds_cluster              | AWS::RDS::DBCluster                       | エンジン名明記       |
| aws_lambda_function          | AWS::Lambda::Function                     | VPC配置記載（任意）  |
| aws_s3_bucket                | AWS::S3::Bucket                           | バケット目的含む     |
| aws_subnet (public/private)  | AWS::EC2::Subnet                          | "Public"/"Private"   |

### DAC Best Practices

階層構造:
- Canvas → Cloud → Region → VPC → Subnet → Resources

リンク描画:
- ユーザートラフィック: North → South
- 水平通信: East ↔ West
- DBクエリ: orthogonalタイプ
- 弱関連: dashed

Route53/WAF可視化:
- Route53: Globalセクション（Region配下でない）
- User→Route53線引かない（User→実配信先へ直接）
- ドメイン名: 実リソース（CloudFront等）Titleに記載
- WAF: 適用リソース右横配置、リソース→WAF破線

## Guidelines

### Documentation and Comments

- YAMLコメントで構成意図記載
- 複雑リンク構造に説明コメント
- 環境固有設定はTODOコメント

### Code Modification Guidelines

検証手順:
1. `yamllint`構文チェック
2. `awsdac -d <yaml> -o <png>`生成
3. 画像確認

### MCP Tool Usage (awsdac-mcp-server)

```bash
# 1. フォーマット情報取得
mcp_awsdac-mcp-se_getDiagramAsCodeFormat

# 2. PNG生成（ファイル保存）
mcp_awsdac-mcp-se_generateDiagramToFile

# 3. Base64取得（表示可能クライアント用）
mcp_awsdac-mcp-se_generateDiagram
```

### Terraform→DAC変換手順

1. リソース収集: `grep_search`でTerraform抽出
2. 構造設計: Public/Private App/Private Data 3層
3. リンク設計: 主要フロー定義
4. 検証: PNG視覚確認

## Testing and Validation

### Validation Checklist

- YAML構文エラー無
- 全ResourcesがCanvasから到達可能
- Links Source/Target存在確認
- Title理解容易性
- 環境名Region Title含む
- VPC/Subnet階層正確性

### Generation Test

```bash
awsdac -d <yaml> -o test.png && file test.png && rm -f test.png
```

## Security Guidelines

- 機密情報含めない（IP/アカウントID等）
- 公開前確認
- Title一般名称使用
