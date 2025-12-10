---
applyTo: "**/*.md"
description: "AI Assistant Instructions for Markdown Documentation"
---

# AI Assistant Instructions for Markdown

**言語ポリシー**: ドキュメント日本語、コード・コメント英語

## Standards

### Markdown Standards

GitHub Markdown 準拠:

- 見出し: `#`階層（H1→H2→H3 順）
- コードブロック: 言語指定（\`\`\`bash）
- リンク: `[text](url)`、相対パス可
- 画像: `![alt](url)`
- 表: header + separator + rows

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

Markdown 検証:

- リンク切れチェック
- 表整形確認
- コードブロック言語指定確認

### MCP Tool Usage

- `semantic_search`: プロジェクト全体ドキュメント検索
- `grep_search`: キーワード完全一致検索
- `read_file`: ファイル内容確認
- `fetch_webpage`: 外部ドキュメント取得

## Testing and Validation

### Validation Commands

必須検証コマンド:

```bash
# Markdownlint実行
markdownlint **/*.md

# リンク切れチェック（推奨）
markdown-link-check **/*.md
```

検証項目:

- Markdown 構文エラー検出
- 見出し階層検証（H1→H2→H3 順）
- リスト・表フォーマット確認
- コードブロック言語指定確認
- リンク切れ検出

### Manual Review Checklist

- [ ] 文書構成が統一されている
- [ ] 誤字脱字がない
- [ ] コードブロックが正しく表示される
- [ ] リンクが有効である
- [ ] 画像が正しく表示される
- [ ] 表が整形されている

## Security Guidelines

機密情報管理:

- API キー・パスワード記載禁止
- 実データ記載回避（サンプル・ダミーデータ使用）
- 個人情報・内部情報記載禁止

ドキュメント公開時:

- Public repository では機密情報確認必須
- `.gitignore`で除外すべきドキュメント確認
- 環境変数・設定ファイル参照で機密情報回避
