# GitHub Copilot Instructions

Common guidelines for AI-assisted development. Project-specific overrides defined in `.github/instructions/*.instructions.md`.

## Language and Formatting Standards

- **Documentation files** (instructions, prompt, SKILL.md): 日本語（章名のみ英語）
- **Generated code and comments**: English only
- **Chat/Agent interaction**: 日本語で質問・回答、コード例は英語で記載

## Core Principles

- **優先順位**: 共通ルールより `.github/instructions/*.instructions.md` の path-specific 指示を優先
- **Memory 活用**: 新規作業時は repo/session memory を確認
- **Tool Fallback**: 指定ツール利用不可時は代替手段検討（捏造禁止）
- **曖昧性対応**: 要件不明確時は確認してから進行
- **完了報告**: 全作業後に総括、残工事はリスト化

## General Development Standards

### Code Modifications

- **Pre-flight Check**: grep で他箇所への波及確認
- **Implementation**: 修正後の検証必須、エラー自律修正、複数ファイル編集時は `apply_patch` 利用
- **QA**: 統一性が必須なら全該当箇所一括修正、変更前後で動作確認

### Output Formatting

- **Markdown**: Headings、lists、code blocks は Markdown 記法に従う。File references は workspace-relative paths で記載
- **Code Examples**: 言語固有の慣例に従う。長いスニペットは段階的に説明
- **Response Length**: Simple queries は 1-3 sentences（コード外）。Complex tasks は必要な detail のみ。ツール呼び出し後は簡潔に

### Error Handling & Edge Cases

- **Unexpected Situations**: 手作業確認必須時は明示（捏造禁止）。ツール制限下でも代替手段検討。Timeout/部分的結果は明示後に次ステップ提案
- **User Interaction**: 要件曖昧時は確認してから進行。エラーメッセージは具体的で行動可能に

### Temporary Files Management

- **配置**: `/workspace/tmp/` ディレクトリ以下に作成
  - カバレッジレポート（`*.out`, `*.html`）
  - テスト出力ファイル
  - ビルド成果物の一時コピー
  - その他の検証用一時ファイル
- **目的**: `.gitignore` で除外対象のディレクトリを活用し、誤コミット防止
