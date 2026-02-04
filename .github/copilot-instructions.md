# GitHub Copilot Instructions

## Language and Formatting Standards

- instructions,prompt ファイル
  - 日本語。章名のみ英語
- other ファイル
  - 生成されるコードとコメントはすべて英語

## Core Principles

- **Path-Specific Instructions の遵守（最重要）**
  - **Chat/Agent 機能使用時**: 作業前に `.github/instructions/*.instructions.md` を `read_file` で明示的読込・確認
  - **自動補完時**: 現在のコンテキストから最大限推測して適用
  - 対象ファイルの拡張子に応じた instructions ファイルを適用（例: `terraform.instructions.md` for .tf files）
  - 自動適用でも `read_file` で内容確認
  - 検証コマンド・コーディング規約の遵守
- **Serena Memory の活用（最重要）**
  - 新規作業開始時に `mcp_serena_list_memories` で利用可能なプロジェクトメモリを確認
  - 関連するメモリを `mcp_serena_read_memory` で参照し、プロジェクト知識を活用
  - 主要メモリ: project_overview, suggested_commands, style_conventions, post_task_checklist, system_utilities
  - **Fallback**: 指定された MCP ツールが利用できない場合は、このステップをスキップし、ユーザーに手動確認が必要な旨を報告（捏造禁止）
- 作業開始時に instructions の要点を明示
- **統一性の維持**: 修正内容が他にも適用すべき場合は grep で検索し全体修正
- 完了報告は全作業完了後に実施（残作業はリスト化）
- 「残タスクリスト」を維持し進捗更新

## General Standards

### Git Command Guidelines

- コミットメッセージフォーマット: 英語、Markdown、先頭行は #(h1)+概要、2 行目以降はリスト形式

### Code Modification Guidelines

- 修正後の動作検証必須
- **統一性確保手順**:
  1. grep でパターン検索
  2. 他ファイルの同様パターン確認
  3. 該当箇所を一括修正
  4. grep コマンドと結果を報告
- 共通ライブラリは内容把握後に修正
- エラーは自律的に修正
- コマンド検証: dry-run 不使用、`||`/`&&` でワンライナー化、`set -e` 不使用
- 出力ファイル名はデフォルト維持
- 長時間対話（10 ターン以上）時はガイドライン再確認
- CLI は help または公式ドキュメント確認後に実行

### Temporary Files Management

- **一時ファイルの配置**: `/workspace/tmp/` ディレクトリ以下に作成
  - カバレッジレポート（`*.out`, `*.html`）
  - テスト出力ファイル
  - ビルド成果物の一時コピー
  - その他の検証用一時ファイル
- **理由**: `.gitignore` で `tmp` ディレクトリ全体を除外しており、誤コミット防止
- **例外**: プロジェクトルートに生成される特定のファイル（`go.sum` など）は対象外

#### Final Checklist

- [ ] 対応 `.github/instructions/*.instructions.md` を `read_file` で読込・確認
- [ ] grep による統一性確認実施・報告
- [ ] 追加確認が必要なファイル・関数の読込
- [ ] 対応言語の instructions.md（例: script.instructions.md）の `Code Modification Guidelines` 遵守
- [ ] 残作業リスト更新・未完了項目確認
- [ ] 逸脱・懸念点の振り返りコメント記載

## Path-Specific Instructions

**重要**: `.github/instructions/*.instructions.md` でパス固有の指示を定義。

### 使用方法

**必須手順**:

1. **作業前に `read_file` で対応 instructions ファイルを読込**
   - 例: `read_file` with filePath="/workspace/.github/instructions/script.instructions.md"
2. **要点の明示**
3. **検証コマンド・コーディング規約の遵守**

### Available Instructions Files

| File                                                           | Applies To                                                   | 主要内容                                                                       |
| -------------------------------------------------------------- | ------------------------------------------------------------ | ------------------------------------------------------------------------------ |
| `.github/instructions/go.instructions.md`                      | \*\*/\*.go                                                   | 検証: go fmt, golangci-lint / 命名: camelCase, PascalCase / エラーハンドリング |
| `.github/instructions/terraform.instructions.md`               | \*\*/\*.tf,\*\*/\*.tfvars,\*\*/\*.hcl                        | 検証: terraform fmt, tflint / 命名: snake_case / セキュリティ規約              |
| `.github/instructions/script.instructions.md`                  | \*\*/\*.sh,scripts/\*\*                                      | 検証: bash -n, shellcheck / 関数ドキュメント / エラーハンドリング              |
| `.github/instructions/markdown.instructions.md`                | \*\*/\*.md                                                   | GitHub Markdown 記法 / 表・リスト・コードブロックの規約                        |
| `.github/instructions/github-actions-workflow.instructions.md` | \*\*/.github/workflows/\*.yaml,\*\*/.github/workflows/\*.yml | ワークフロー構文 / セキュリティ / 再利用可能なワークフロー                     |

### Documentation and Comments

- ファイル/スクリプト/モジュールは目的記載ヘッダーを含む
- 関数は目的・引数説明を含む
- 複雑なロジックにインラインコメント付与
- コメント・ドキュメントは英語記載（全言語共通）

### Error Handling

- エラー検知と適切な処理
- 具体的かつ行動可能なエラーメッセージ
- デバッグ用の十分なログ出力
- 機密情報はエラーメッセージに含めない

## Validation Script Enforcement

**CRITICAL**: When validating code, ALWAYS use the comprehensive validation scripts. Never run individual commands directly.

### Required Validation Scripts

- **Go**: `bash go-validation/scripts/validate.sh`
- **Terraform**: `bash terraform-validation/scripts/validate.sh`
- **Shell Script**: `bash shell-script-validation/scripts/validate.sh`

### Prohibited Individual Commands

**NEVER run these commands directly:**

- ❌ `go fmt`, `go vet`, `golangci-lint`, `go test` alone
- ❌ `terraform fmt`, `terraform validate`, `tflint`, `trivy` alone
- ❌ `bash -n`, `shellcheck` alone

### Exception

Only use individual commands when explicitly debugging a specific validation failure reported by the validation script. In such cases, refer to the skill's `reference/` directory for detailed command usage.

## MCP Tools

Model Context Protocol (MCP) 対応ツールを活用。

### Serena 初期化（必須）

作業開始時：

1. `mcp_serena_list_memories` でプロジェクトメモリを確認
2. 関連メモリを `mcp_serena_read_memory` で参照

**利用可能なメモリ**:

- `project_overview.md`: プロジェクト目的・技術スタック・構造
- `suggested_commands.md`: 開発・検証・デプロイコマンド
- `style_conventions.md`: 言語別コーディング規約
- `post_task_checklist.md`: 変更後の検証手順
- `system_utilities.md`: 利用可能なツール・コマンド

### 使用方針

- MCP ツールは補助的に使用
- エラー時はツール制限として受入、代替手段を検討
