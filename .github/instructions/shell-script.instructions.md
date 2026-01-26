---
applyTo: "**/*.sh,scripts/**"
description: "AI Assistant Instructions for Shell Script"
---

# AI Assistant Instructions for Shell Script

**言語ポリシー**: ドキュメント日本語、コード・コメント英語

| Directory/File      | Purpose                     |
| ------------------- | --------------------------- |
| scripts/db/         | DB スキーマ・ドキュメント   |
| scripts/go/         | Go ビルド・テスト・デプロイ |
| scripts/lib/        | 共通ライブラリ              |
| scripts/nodejs/     | Node.js テスト・検証        |
| scripts/terraform/  | Terraform・AWS 自動化       |
| scripts/validate.sh | 品質チェックツール          |

## Standards

### Naming Conventions

| Component | Rule             | Example                  |
| --------- | ---------------- | ------------------------ |
| File      | snake_case       | deploy_terraform.sh      |
| Function  | snake_case       | show_usage, log_message  |
| Variable  | snake_case       | script_name, error_count |
| Constant  | UPPER_SNAKE_CASE | DEFAULT_TIMEOUT          |

### Shell Script Standards

テンプレート必須要素:

- `set -euo pipefail`
- `SCRIPT_DIR`設定、`lib/all.sh` source
- 関数順序: `show_usage/parse_arguments`→ 他 a-z 順 →`main`最後
- 依存関係検証
- `error_exit`でエラー処理
- エントリポイント: `if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then main "$@"; fi`

## Guidelines

### Documentation and Comments

ファイルヘッダー:

```bash
#!/bin/bash
#######################################
# Description: Script purpose and functionality
#
# Usage: ./script_name.sh [options]
#   options:
#     -h, --help     Show help message
#     -v, --verbose  Enable verbose output
#
# Output:
# - Output description
# - Side effects description
#
# Design Rules:
# - Rule 1: Specific design constraint
# - Rule 2: Architecture decision
#######################################

# Error handling: exit on error, unset variable, or failed pipeline
set -euo pipefail

# Secure defaults
umask 027
export LC_ALL=C.UTF-8

# Get script directory for library loading
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCRIPT_DIR

# Load all-in-one library
# shellcheck source=../lib/all.sh
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/../lib/all.sh"

#######################################
# Global variables and default values
#######################################
VERBOSE=false
export VERBOSE
VAR_NAME="default_value"
```

関数コメント必須形式:

```bash
#######################################
# function_name: 簡潔な説明（1行）
#
# Description:
#   詳細説明（複数行可）
#
# Arguments:
#   $1 - 引数1の説明
#   $2 - 引数2の説明（optional記載）
#
# Global Variables:
#   VAR_NAME - グローバル変数説明（使用時のみ）
#
# Returns:
#   戻り値説明/Exit code説明
#
# Usage:
#   function_name "arg1" "arg2"
#
#######################################
```

その他:

- 複雑ロジック: インラインコメント
- 全コメント英語

### Help Function

`show_usage`関数必須内容:

- Usage/Description/Options/Examples
- `exit 0`で終了

### Error Handling

- `set -euo pipefail`必須
- 共通ライブラリ`error_exit`利用
- クリーンアップ: `trap`設定
- エラーメッセージ明確化

### Code Modification Guidelines

**詳細ガイド**: [shell-script-validation Skill](../skills/shell-script-validation/SKILL.md) を参照（検証手順・Batsテスト標準・トラブルシューティング）

### MCP Tool Usage

共通ライブラリ関数（`lib/all.sh`）:

- `error_exit`: エラー終了
- `log_message`: 構造化ログ
- `echo_section`: セクション区切り
- `validate_dependencies`: コマンド存在確認

## Testing and Validation

**詳細ガイド**: [shell-script-validation Skill](../skills/shell-script-validation/SKILL.md) を参照（検証手順・Batsテスト標準・トラブルシューティング）
