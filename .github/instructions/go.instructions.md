---
applyTo: "**/*.go"
description: "AI Assistant Instructions for Go Development"
---

# AI Assistant Instructions for Go Development

## Scope

- 対象は Go ソースコード（`*.go`）の実装・テスト・検証に限定する

Go 共通ライブラリとサンプルアプリケーションを含むプロジェクト。

| Directory/File | Purpose / Description          |
| -------------- | ------------------------------ |
| example/       | サンプルアプリ（Gin、S3 等）   |
| pkg/           | 共通ライブラリ・ユーティリティ |
| cmd/           | 実行可能コマンドツール         |
| internal/      | 内部パッケージ                 |

## Standards

- GoDoc スタイルコメント: 全パッケージ、公開関数/メソッド/構造体
- コメント・ドキュメントは英語記載
- パッケージ名: 小文字、単一単語
- ファイル名: snake_case
- 変数/関数: camelCase、公開: PascalCase
- エラーは明示的処理（`_`無視禁止）
- エラーラッピング: `fmt.Errorf` + `%w`

## Guidelines

### Code Organization

- パッケージ機能別分離
- interface は使用側で定義（Dependency Inversion）
- 循環参照回避

### Error Handling

- error 無視禁止
- context.Context でキャンセル・タイムアウト処理
- 構造化ログ使用

### Performance

- goroutine リーク防止
- channel close 責任明確化
- 高頻度操作でメモリプール検討

### MCP Tool Usage

**詳細は `.github/copilot-instructions.md` 参照。**

#### Go 開発特有パターン

- Struct/Interface 理解: `mcp_serena_find_symbol`
- 依存関係確認: `mcp_serena_find_referencing_symbols`
- テスト整合性: relative_path 指定で検索

### Code Modification Guidelines

- 変更後は [go-validation Skill](../skills/go-validation/SKILL.md) の validate.sh 実行を優先
- 個別コマンド（`go fmt`/`go vet`/`go test`/`golangci-lint` 等）はデバッグ時または失敗分析時に実施

### Coding Standards

#### Code Simplicity

- 不要な一時変数作成禁止
- 関数戻り値は直接使用（可読性損なわない範囲）
- 例: `x := fn(); return x` → `return fn()`
- 例: `tmp := fn(); doSomething(tmp)` → `doSomething(fn())`
- 一時変数が必要な場合: 複数回参照、長い式の分割、エラーチェック

#### Production and Test Separation

- テスト専用コードは本番コードに追加禁止
- テスト性はインターフェース設計で確保
- テストヘルパー・モックは`*_test.go`に分離

### Naming Conventions

| コンポーネント | 規則            | 例                 |
| -------------- | --------------- | ------------------ |
| パッケージ名   | 小文字          | infrastructure     |
| 関数(公開)     | PascalCase      | NewConfig, GetUser |
| 関数(内部)     | camelCase       | validateInput      |
| 定数           | PascalCase      | DefaultTimeout     |
| Interface      | PascalCase + er | UserRepository     |
| ファイル名     | snake_case      | event_handler.go   |

### Go Standards

- ファイルレベルの宣言順序（厳守）: const → var → type（interface → struct）→ func（constructor → public methods → private methods → helpers）— ファイル全体での順序維持・可読性向上
- セクション内の宣言順（厳守）: 各セクション（const/var/type/func）は原則 A→Z のアルファベット順。最終的な整備は linter/formatter に準拠。funcのmainはfuncの先頭に配置。
- unexported helper 配置ルール:
  - 単一の struct だけで使う helper は、その struct の unexported method を優先
  - receiver を今は参照しなくても、その helper がその struct 固有の責務なら method
  - package local の free function は、複数の型やファイルで共有される純粋 helper に限定
  - 単一 struct 専用 helper と package-wide helper を同じ粒度で混在させない

例:

- const: アルファベット順（関連グループは一括）
  ```
  find . -name '*.go' -print0 | xargs -0 -n1 awk '/^[[:space:]]*const[[:space:]]*\(/ {inside=1; print FILENAME ":"; print; next} inside && /^[[:space:]]*\)/ {print; inside=0; next} inside {print}'
  ```
- type: interfaces 先出し（アルファベット順）、次に structs（アルファベット順）
  ```
  grep -Rn --include='*.go' -e '^type.*interface' .
  grep -Rn --include='*.go' -e '^type.*struct' .
  ```
- func: constructors（NewXxx）先出し → methods（アルファベット順） → helper/free functions（アルファベット順）
  ```
  grep -Rn --include='*.go' -e '^func' .
  ```

Helper placement examples:

- type-specific retry or filtering logic → unexported method on that type
- type-specific normalization used only inside one struct → unexported method on that struct
- action/status mapping reused by multiple types → shared helper in a support file

### Lambda Function

- パッケージコメント: 機能概要記載
- 環境変数: 必須変数バリデーション実装
- エラーハンドリング: context.Context でタイムアウト処理
- ログ出力: 構造化ログ使用

### Testing

#### Default Style

- デフォルトは table-driven test + `t.Run` を使用（純粋関数、バリデーション、分岐ロジック）
- テスト名は `TestXxx_Scenario` 形式で統一（例: `TestClient_GetByID_NotFound`）
- Arrange-Act-Assert を維持し、準備・実行・検証を明確に分離
- アサーションは `testify/assert` と `testify/require` を用途で使い分ける（前提条件は `require`）

#### Exceptions

- 状態遷移・副作用・複数ステップが主責務の処理に限り、シナリオテスト形式を許可
- 単一 struct 専用の複雑モックは `*_test.go` 内のヘルパーに閉じる
- Integration テストは `*_integration_test.go` に分離し、`//go:build integration` を付与

#### Minimum Test Rules

- 公開関数/メソッドは正常系と異常系の両方を最低 1 ケース以上持つ
- エラーは種類または sentinel 判定を検証し、文字列完全一致への依存を避ける
- カバレッジ目標は 80%以上（`go test -cover` で確認）

## Testing and Validation

**詳細ガイド**: [go-validation Skill](../skills/go-validation/SKILL.md) を参照（検証手順・カバレッジ要件・トラブルシューティング）

- **serena**: 構造体・関数理解、メソッド編集、インターフェース実装確認
- **AWS 開発**: Go SDK 設定・ベストプラクティス確認
- **依存関係**: gin/gorm ドキュメント取得

## Security Guidelines

- シークレット/資格情報をコード・ログ・テストデータに直接埋め込まない
- 外部入力は検証し、権限境界（IAM/Role/Account）をまたぐ処理では明示的エラー処理を行う
- エラー出力は機密情報を含まない形式でラップし、必要最小限の情報のみ記録する
