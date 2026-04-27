---
applyTo: "README.md,CONTRIBUTING.md,docs/**/*.md"
description: "AI Assistant Instructions for Markdown Documentation"
---

# AI Assistant Instructions for Markdown

## Scope

- 対象は `README.md`、`CONTRIBUTING.md`、`docs/**/*.md` のドキュメント整備に限定する

## Standards

### Repository Documentation Scope

- この instructions は Markdown 記法の一般論ではなく、リポジトリ内ドキュメント運用ルールに限定する
- 構文/リンク/フォーマットの一般チェックは [markdown-validation Skill](../skills/markdown-validation/SKILL.md) に委譲する

## Guidelines

### Documentation Structure

README.md 構成:

1. Project Title + Badge
2. Description
3. Features（簡潔リスト）
4. Installation/Setup
5. Usage/Examples
6. Configuration（必要時）
7. License/Contributing（必要時）

技術ドキュメント構成:

1. Overview
2. Prerequisites
3. Architecture/Design
4. Implementation Details
5. Testing/Validation
6. Troubleshooting

### Documentation Revision Process

修正手順:

1. 対象セクション特定
2. 既存内容確認（`read_file`）
3. 統一性確保（`grep_search`で他ファイル確認）
4. 修正実施
5. フォーマット確認

### Code Modification Guidelines

- 変更後は [markdown-validation Skill](../skills/markdown-validation/SKILL.md) の検証手順を優先
- リンク切れ・表整形・コードブロック言語指定の個別確認はデバッグ時または失敗分析時に実施

### MCP Tool Usage

- `semantic_search`: プロジェクト全体ドキュメント検索
- `grep_search`: キーワード完全一致検索
- `read_file`: ファイル内容確認
- `fetch_webpage`: 外部ドキュメント取得

## Testing and Validation

**詳細ガイド**: [markdown-validation Skill](../skills/markdown-validation/SKILL.md) を参照（検証手順・一般的なエラー修正・セキュリティガイドライン）

## Security Guidelines

- ドキュメントに機密情報（トークン・鍵・内部URL・個人情報）を記載しない
- コマンド例は破壊的操作を既定にしない（必要時は注意書きを付与）
- 外部リンクは信頼できる一次情報を優先し、不明な短縮URLを避ける
