---
applyTo: "**/*.go"
description: "AI Assistant Instructions for Go Development"
---

# AI Assistant Instructions for Go Development

**言語ポリシー**: ドキュメントは日本語、コード・コメントは英語。

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

- ファイルレベルの宣言順序（厳守）: const → var → type（interface → struct）→ func（constructor → methods → helpers） — ファイル全体での順序維持・可読性向上
- セクション内の宣言順（推奨）: 各セクション（const/var/type/func）内は原則 A→Z のアルファベット順。ただし、論理的関連のある宣言群はグループ化を許容、最終的な整備は linter/formatter に準拠

例:

- const: アルファベット順（関連グループは一括）
- type: interfaces 先出し（アルファベット順）、次に structs（アルファベット順）
- func: constructors（NewXxx）先出し → methods（アルファベット順） → helper/free functions（アルファベット順）

### Lambda Function

- パッケージコメント: 機能概要記載
- 環境変数: 必須変数バリデーション実装
- エラーハンドリング: context.Context でタイムアウト処理
- ログ出力: 構造化ログ使用

### Testing

#### Test Naming

- ファイル名: `_test.go`付与（例: `user_service_test.go`）
- 関数名: `TestFunctionName_Scenario`（例: `TestUserService_GetUser`）

#### testify Usage

- Assert: `testify/assert`、Mock: `testify/mock`、Suite: `testify/suite`
- AAA Pattern: Arrange-Act-Assert で構造化

#### Mock Implementation

- インターフェースベース依存注入前提
- モックはテストファイル内定義
- モックメソッドはインターフェースと完全一致

#### Table-Driven Tests

- テーブル形式で複数ケース定義
- 正常系・異常系網羅
- 明確なケース名

#### Test Structure

- AAA Pattern 使用
- テスト独立実行可能
- データ準備明確分離
- モック期待値はテスト開始時設定

#### Error Testing

- エラー種別ごと個別ケース
- エラーメッセージ内容検証
- エラー型チェック

#### Test Helpers

- 共通セットアップヘルパー化
- 複雑モック設定ヘルパー化

#### Coverage

- 目標: 80%以上
- 全公開関数/メソッドテスト
- `go test -cover`確認

#### Integration Test

- 別ファイル: `*_integration_test.go`
- ビルドタグ: `// +build integration`
- 実依存関係使用

#### Benchmark

- 関数名: `Benchmark`始まり
- `testing.B`使用

#### Test Organization

- テストファイル同ディレクトリ配置
- テスト専用: `package_test`形式

#### Common Patterns

- Constructor: `TestNewXxx`、Method: `TestXxx_MethodName`
- Validation: `TestXxx_ValidateXxx`、Edge: `TestXxx_EdgeCase`

#### Test Data

- 定数またはヘルパー定義
- 独立性保持

## Testing and Validation

**詳細ガイド**: [go-validation Skill](../skills/go-validation/SKILL.md) を参照（検証手順・カバレッジ要件・トラブルシューティング）

- **serena**: 構造体・関数理解、メソッド編集、インターフェース実装確認
- **AWS 開発**: Go SDK 設定・ベストプラクティス確認
- **依存関係**: gin/gorm ドキュメント取得
