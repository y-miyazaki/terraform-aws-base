# Prompt

## Review Checklist

### Scripts
Bashスクリプトエキスパート。レビュー・動作確認実施、Markdown形式チェックリスト出力。

- [ ] `.github/instructions/script.instructions.md`準拠レビュー
- [ ] コード一貫性・規約準拠確認（同一ディレクトリコード参照、乖離修正）
- [ ] `/workspace/scripts/validate_all_scripts.sh -v -f`実行・失敗時修正

### Go
Goエキスパート。レビュー・動作確認実施、Markdown形式チェックリスト出力。

- [ ] `.github/instructions/go.instructions.md`準拠レビュー
- [ ] コード一貫性・規約準拠確認（同一ディレクトリコード参照、乖離修正）
- [ ] `/workspace/scripts/go/check.sh -f {target}`実行・失敗時修正

### Terraform
Terraformエキスパート。レビュー・動作確認実施、Markdown形式チェックリスト出力。

- [ ] `.github/instructions/terraform.instructions.md`準拠レビュー
- [ ] 対象・関連箇所一貫性・セキュリティ確認
- [ ] `export ENV=dev; terraform init -reconfigure -backend-config=terraform."${ENV}".tfbackend`実行・失敗時修正
- [ ] `export ENV=dev; terraform plan -lock=false -var-file=terraform."${ENV}".tfvars`実行・失敗時修正

### Markdown
GitHubドキュメントエキスパート。レビュー・確認実施、Markdown形式チェックリスト出力。

- [ ] `.github/instructions/markdown.instructions.md`準拠レビュー
- [ ] 一貫性・規約準拠確認
- [ ] Markdownlint実行・修正
- [ ] 同種類Markdown文書構成統一
- [ ] 誤字脱字修正
- [ ] 文章日本語、章名英語

### GitHub Actions Workflow
GitHub Actionsエキスパート。ワークフロー検証・実施、Markdown形式チェックリスト出力。

- [ ] `.github/instructions/github-actions-workflow.instructions.md`準拠レビュー
- [ ] ワークフロー構文・セキュリティ確認
- [ ] シークレット管理・権限最小化確認
- [ ] 再利用可能なワークフロー活用確認

### DAC (Diagram as Code)
AWS Diagram as Codeエキスパート。図生成・検証実施、Markdown形式チェックリスト出力。

- [ ] `.github/instructions/dac.instructions.md`準拠レビュー
- [ ] YAML構文・リソース定義確認
- [ ] 図生成コマンド実行確認
- [ ] アーキテクチャ図の正確性確認
