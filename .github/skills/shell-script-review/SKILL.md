---
name: shell-script-review
description: Shell Script code review for correctness, security, maintainability, and best practices. Use for manual review of shell scripts checking design decisions and security patterns requiring human judgment.
license: MIT
---

# Shell Script Code Review

This skill provides comprehensive guidance for reviewing Shell Script code to ensure correctness, security, maintainability, and best practices compliance.

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on shell script pull requests
- Checking shell scripts before merging
- Ensuring security and compliance standards
- Validating best practices adherence
- Architecture and design review

## Important Notes

- **Automation First**: Lint and auto-checkable items (shebang, set -euo pipefail, quoting, command substitution, test [[]], pipelines) are excluded as they should be caught by shellcheck/validate.sh in CI/CD.
- **Manual Review Focus**: This skill focuses on design decisions, security patterns, and maintainability issues that require human judgment.
- **Project Standards**: Assumes lib/all.sh common library usage and project-specific conventions.

## Output Language

**IMPORTANT**: レビュー結果はすべて日本語で出力。ただし以下は英語：

- ファイルパス、コードスニペット、技術識別子（関数名、変数名、コマンド名など）

## Review Guidelines

### 1. Global / Base (G)

**G-01: SCRIPT_DIR 設定+lib/all.sh source**

Check: SCRIPT_DIRが設定されlib/all.shがsourceされているか
Why: SCRIPT_DIR未設定・共通ライブラリ未読込で共通関数利用不可、実行ディレクトリ依存
Fix: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "${SCRIPT_DIR}/../lib/all.sh"`

**G-02: 機密情報ハードコーディング禁止**

Check: API Key・パスワード・トークンがスクリプトに埋め込まれていないか
Why: 機密情報埋め込みでセキュリティ侵害、認証情報漏洩、Git履歴汚染
Fix: 環境変数・AWS Secrets Manager利用、定数削除

**G-03: 関数順序遵守**

Check: show_usage→parse_arguments→関数a-z順→main最後の順序か
Why: 関数順序不統一でプロジェクト標準違反、可読性低下、レビュー効率低下
Fix: show_usage→parse_arguments→関数a-z順→main最後配置

**G-04: デッドコード削除**

Check: コメントアウトコード・未使用関数・到達不能コードがないか
Why: デッドコードで保守困難、混乱、不要行数増加
Fix: git履歴利用、デッドコード削除、TODOコメント適切管理

**G-05: error_exit 利用エラーハンドリング**

Check: エラー時にerror_exit関数を使用しているか
Why: exit 1直接実行でクリーンアップ未実行、エラーメッセージ不統一、デバッグ困難
Fix: error_exit関数利用、統一的エラー処理

**G-06: スクリプト冪等性**

Check: 再実行時にエラーなく動作するか
Why: 再実行時エラー・副作用残留で運用困難、デプロイ失敗、リトライ不可
Fix: 存在チェック、冪等操作、状態確認後実行

### 2. Code Standards (CODE)

**CODE-01: 配列適切利用**

Check: 空白含むパスや複数値が配列で管理されているか
Why: 文字列分割・引用符漏れでファイル名分割、予期しない引数展開
Fix: 配列で複数値管理、`"${array[@]}"`展開

**CODE-02: グローバル変数最小化**

Check: 関数内でlocal宣言が使用されているか
Why: グローバル変数多用で変数汚染、予期しない動作、デバッグ困難
Fix: 関数内local宣言、readonly定数、グローバル最小化

**CODE-03: Here document 適切利用**

Check: 複数行文字列にhere documentが使用されているか
Why: echo繰り返しでエスケープ複雑化、可読性低下、保守困難
Fix: `cat <<'EOF'`利用、ヒアドキュメント活用

**CODE-04: Process substitution 適切利用**

Check: 一時ファイル不要な箇所でprocess substitutionが使用されているか
Why: 不要な一時ファイル生成でファイルI/O増、クリーンアップ複雑化
Fix: `<(command)`、`>(command)`活用

**CODE-05: 関数単一責任・引数明示**

Check: 関数が単一責任で引数を明示的に受け取るか
Why: 複数責任混在・グローバル変数依存でテスト困難、再利用不可
Fix: 単一責任分割、引数で入力受取、グローバル依存最小化

### 3. Function Design (FUNC)

**FUNC-01: 関数 50 行以下推奨**

Check: 関数が50行以下か
Why: 100行以上の関数で可読性低下、テスト困難、保守困難
Fix: ヘルパー関数抽出、単一責任原則、50行以内推奨

**FUNC-02: parse_arguments 標準化**

Check: parse_argumentsがgetopts・case文で標準化されているか
Why: 引数解析ロジック重複・不統一でオプション追加困難、バグ混入
Fix: getopts利用、case文標準パターン、-h|--help対応

**FUNC-03: show_usage 実装**

Check: show_usage関数がUsage/Options/Examplesを含みexit 0か
Why: ヘルプ未実装でユーザビリティ低下、問い合わせ増、誤用
Fix: show_usage関数実装、Usage/Options/Examples記載、exit 0

**FUNC-04: 戻り値設計**

Check: 関数がreturn code・echo出力で戻り値を適切に設定しているか
Why: 戻り値未設定でエラーハンドリング不可、条件分岐不可、障害検知不可
Fix: return 0/1設定、echo出力、`|| error_exit`利用

**FUNC-05: 共通ライブラリ活用**

Check: lib/all.shの共通関数が活用されているか
Why: コード重複・エラー処理不統一で保守コスト増、不整合、品質低下
Fix: lib/all.sh関数利用、プロジェクト標準遵守

**FUNC-06: validate_dependencies 関数**

Check: 必須コマンド存在確認がvalidate_dependencies関数で実装されているか
Why: 必須コマンド未確認でスクリプト途中失敗、ユーザー困惑
Fix: validate_dependencies実装、command -v確認、明確エラー

**FUNC-07: main 関数実装**

Check: main関数が実装されグローバルスコープ処理が最小化されているか
Why: グローバルスコープ処理で構造不明確、デバッグ困難、ユニットテスト不可
Fix: main関数実装、`main "$@"`呼出、構造化

### 4. Error Handling (ERR)

**ERR-01: trap 設定**

Check: trapでEXIT・ERR・INT・TERMが設定されているか
Why: trap未設定でクリーンアップなし、リソースリーク、一時ファイル残留
Fix: `trap 'cleanup' EXIT ERR`設定、cleanup関数実装

**ERR-02: 終了コード確認**

Check: コマンド終了コードが適切に確認されているか
Why: 終了コード未確認・`|| true`多用で障害検知不可、サイレント失敗
Fix: `$?`確認、`|| error_exit`、適切エラーハンドリング

**ERR-03: エラーメッセージ明確**

Check: エラーメッセージがコンテキスト情報と行番号を含むか
Why: 不明瞭メッセージでデバッグ困難、問題特定遅延、ユーザー困惑
Fix: 明確メッセージ、変数値出力、`"${BASH_SOURCE}:${LINENO}"`追加

**ERR-04: クリーンアップ処理**

Check: cleanup関数で一時ファイル・プロセス・ロックが解放されるか
Why: クリーンアップなしでディスクリーク、プロセスリーク、デッドロック
Fix: cleanup関数、trap設定、確実リソース解放

**ERR-05: リトライ戦略**

Check: 一時的エラーに対するリトライ戦略があるか
Why: リトライなしで運用負荷、自動復旧不可、可用性低下
Fix: リトライループ、exponential backoff、最大試行回数

**ERR-06: 部分的失敗許容**

Check: 許容エラーでset +e一時解除が明示的か
Why: `set -e`環境で`|| true`乱用、可読性低下、意図不明
Fix: `set +e; command; set -e`、明示的エラー許容

**ERR-07: エラーログ記録**

Check: エラーがログファイルに永続記録されるか
Why: エラー出力のみで障害履歴不明、トレンド分析不可、事後調査困難
Fix: エラーログファイル記録、timestamp付与、ログローテーション

### 5. Security (SEC)

**SEC-01: 入力値検証**

Check: ユーザー入力が正規表現・ホワイトリストで検証されているか
Why: 入力無検証でコマンドインジェクション、パストラバーサル、データ破壊
Fix: 入力値正規表現検証、ホワイトリスト、範囲チェック

**SEC-02: コマンドインジェクション対策**

Check: 全変数が`"$var"`で引用符されevalが回避されているか
Why: 変数引用符なし・eval使用で任意コマンド実行、権限昇格、システム侵害
Fix: 全変数`"$var"`引用符、eval回避、配列利用

**SEC-03: パス traversal 対策**

Check: パスがrealpath・正規化され許可ディレクトリ制限があるか
Why: `../`許容でファイルアクセス、データ漏洩、改ざん
Fix: realpath利用、パス正規化、許可ディレクトリ制限

**SEC-04: 一時ファイル mktemp+trap 削除**

Check: 一時ファイルがmktempで作成されtrapで削除されるか
Why: 固定ファイル名・予測可能パスでシンボリックリンク攻撃、情報漏洩
Fix: `mktemp -d`利用、trap削除、セキュアパス

**SEC-05: 権限チェック**

Check: 必要な権限（root等）がチェックされているか
Why: 権限未確認で実行失敗、部分的成功、セキュリティリスク
Fix: `[[ $EUID -eq 0 ]]`確認、適切エラーメッセージ

**SEC-06: ログ機密情報マスク**

Check: パスワード・トークンがログ出力前にマスクされているか
Why: 機密情報ログ出力で認証情報漏洩、監査ログ汚染、セキュリティ侵害
Fix: 機密変数`***`マスク、ログ出力前フィルタ

**SEC-07: 外部コマンド検証**

Check: 外部コマンドが絶対パスまたはcommand -vで検証されているか
Why: PATH環境変数依存でコマンド偽装、マルウェア実行、予期しない動作
Fix: `/usr/bin/`等絶対パス使用、command -v検証

**SEC-08: 環境変数汚染回避**

Check: 環境変数が明示的に初期化されデフォルト値があるか
Why: 継承環境変数信頼で予期しない動作、セキュリティバイパス、データ破損
Fix: 環境変数明示的初期化、デフォルト値設定、検証

**SEC-09: セキュアデフォルト (umask 027)**

Check: umask 027が設定され最小権限原則が適用されているか
Why: デフォルトumaskで情報漏洩、不正アクセス、機密ファイル露出
Fix: umask 027設定、明示的権限設定、最小権限原則

### 6. Performance (PERF)

**PERF-01: 外部コマンド最小化**

Check: ループ内外部コマンドが最小化されBash組込機能が優先されているか
Why: ループ内外部コマンドで実行時間増、CPU負荷、スクリプト遅延
Fix: Bash組込機能優先、ループ外移動、一括処理

**PERF-02: サブシェル削減**

Check: 不要な`()`が削減され`{}`が使用されているか
Why: 不要サブシェルでメモリ消費、実行時間増、リソース浪費
Fix: `{}`利用、変数直接操作、サブシェル回避

**PERF-03: ファイル I/O 最適化**

Check: ファイルが一括読込されバッファリングが活用されているか
Why: ファイル複数回読込・行毎I/OでI/O待機時間、実行遅延
Fix: 一括読込、while read最適化、buffering活用

**PERF-04: ループ効率化**

Check: `while IFS= read -r`が使用され非効率ループが回避されているか
Why: `for in $(cat)`でメモリ消費、処理遅延、大ファイル処理不可
Fix: `while IFS= read -r`利用、効率的ループ

**PERF-05: 文字列処理最適化**

Check: Bash parameter expansionが活用されsed/awk濫用が回避されているか
Why: sed/awk濫用でプロセス生成コスト、実行時間増
Fix: Bash parameter expansion活用、組込機能優先

**PERF-06: 条件分岐最適化**

Check: early return・短絡評価が使用されネストが浅いか
Why: ネスト深い・重複判定で可読性低下、実行時間増
Fix: early return、`&&`/`||`短絡評価、case文活用

**PERF-07: 並列実行活用**

Check: 並列実行可能な処理で`&`・`xargs -P`が活用されているか
Why: 逐次処理で実行時間長、リソース活用不足、スループット低
Fix: バックグラウンド実行、`xargs -P`、wait管理

**PERF-08: キャッシュ戦略**

Check: 同一処理結果が変数保存されキャッシュされているか
Why: 同一処理繰返しで無駄な処理、実行時間増、リソース浪費
Fix: 結果変数保存、条件キャッシュ、重複削減

**PERF-09: リソース制限 (ulimit)**

Check: ulimitでリソース制限が設定されているか
Why: リソース無制限でメモリリーク、プロセス暴走、システムリソース枯渇
Fix: ulimit設定、リソース制限、防御的プログラミング

**PERF-10: プロファイリング**

Check: パフォーマンスボトルネックがset -x・timeで特定されているか
Why: ボトルネック不明で効果薄い最適化、リソース浪費
Fix: `set -x`trace、time測定、ボトルネック特定

### 7. Testing (TEST)

**TEST-01: 単体テスト実装**

Check: Batsによる単体テストが実装されているか
Why: テスト未実装でリグレッション、バグ混入、CI/CD困難
Fix: Bats導入、test/bats/配下テスト作成、自動化

**TEST-02: Bats テスト関数 a-z 順**

Check: テスト関数がsetup/teardown後にa-z順で配置されているか
Why: テスト関数順序不統一でテスト保守困難、レビュー効率低下
Fix: setup/teardown後、テスト関数a-z順配置

**TEST-03: CI/CD 統合**

Check: テストがGitHub Actions等CI/CDに統合されているか
Why: テスト自動実行なしで本番障害、品質低下、デプロイリスク
Fix: GitHub Actions統合、PR時自動テスト、品質ゲート

### 8. Documentation (DOC)

**DOC-01: ヘッダー標準形式**

Check: ファイルヘッダーにDescription/Usage/Design Rulesがあるか
Why: ヘッダーなしでスクリプト目的不明、使用方法不明、オンボーディング遅延
Fix: 標準ヘッダー追加、Description/Usage/Design Rules記載

**DOC-02: show_usage 必須**

Check: show_usage関数が実装されているか
Why: -h/--helpオプションなしでユーザビリティ低下、問い合わせ増
Fix: show_usage関数、Usage/Options/Examples、exit 0

**DOC-03: 関数区切り+コメント**

Check: 関数前に`#######`区切りと目的・引数・戻り値コメントがあるか
Why: 関数境界不明確でレビュー効率低下、保守困難
Fix: 関数前`#######`区切り、目的・引数・戻り値コメント

**DOC-04: 複雑ロジックコメント**

Check: 複雑なアルゴリズムにWhyコメントがあるか
Why: アルゴリズム説明なしで理解困難、保守困難、バグ混入
Fix: Why重視コメント、複雑処理説明、前提明記

**DOC-05: 変数説明**

Check: グローバル変数に目的・単位・制約コメントがあるか
Why: 変数目的不明で誤用、バグ混入、保守困難
Fix: グローバル変数コメント、単位・デフォルト値・制約記載

**DOC-06: 英語コメント統一**

Check: すべてのコメントが英語で統一されているか
Why: 日英混在で可読性低下、一貫性欠如、プロフェッショナル性欠如
Fix: 英語コメント統一、簡潔明瞭記述

**DOC-07: README.md 整備**

Check: README.mdに目的・前提・セットアップ・使用例が記載されているか
Why: README不足でオンボーディング遅延、誤った実行、質問増加
Fix: 目的・前提・セットアップ・使用例・トラブルシュート記載

**DOC-08: エラーメッセージ文書化**

Check: エラーコードと解決方法が文書化されているか
Why: エラーコード未定義でトラブルシュート困難、ユーザー困惑
Fix: エラーコード一覧、原因・対処法記載

**DOC-09: 変更履歴 CHANGELOG**

Check: CHANGELOG.mdが整備され破壊的変更が明記されているか
Why: 変更履歴なしで変更追跡困難、影響範囲不明、ユーザー混乱
Fix: CHANGELOG.md作成、Keep a Changelog形式、破壊的変更明記

### 9. Dependencies (DEP)

**DEP-01: lib/all.sh 活用**

Check: lib/all.shがsourceされ共通関数が利用されているか
Why: 共通ライブラリ未使用でコード重複、保守コスト増、品質ばらつき
Fix: lib/all.sh source、error_exit/log_message等共通関数利用

**DEP-02: validate_dependencies 利用**

Check: validate_dependencies関数が呼び出されているか
Why: 必須コマンド未確認でスクリプト途中失敗、ユーザー困惑
Fix: validate_dependencies呼出、必須コマンド明示

**DEP-03: 必須コマンド明示**

Check: READMEに依存コマンドが明示されているか
Why: 依存コマンド不明で実行失敗、環境構築困難、オンボーディング遅延
Fix: README依存記載、validate_dependencies実装

**DEP-04: コマンド存在確認**

Check: command -vで存在確認され明確なエラーメッセージがあるか
Why: コマンド存在確認なしで実行時エラー、エラーメッセージ不明瞭
Fix: command -v確認、明確エラーメッセージ、インストール手順提示

### 10. Logging (LOG)

**LOG-01: log_message/echo_section 活用**

Check: log_message・echo_section関数が活用されているか
Why: echo直接出力でログフォーマット不統一、timestamp欠如、監視困難
Fix: log_message利用、echo_section区切り、プロジェクト標準遵守

**LOG-02: stdout/stderr 分離**

Check: エラーが>&2、情報がstdoutに明確分離されているか
Why: エラーメッセージstdout出力でエラー検知困難、ログ解析困難
Fix: エラーは`>&2`、情報はstdout、明確分離

**LOG-03: ログレベル実装**

Check: INFO・WARN・ERRORのログレベルが実装されているか
Why: ログレベルなしでログノイズ、重要ログ埋没、監視困難
Fix: INFO/WARN/ERRORレベル、log_message引数レベル指定

**LOG-04: 構造化ログ**

Check: timestamp・レベル・メッセージの構造化ログ形式か
Why: 非構造化ログでログ解析困難、時系列追跡不可
Fix: `[timestamp] [LEVEL] message`形式、構造化ログ

**LOG-05: 機密情報マスク**

Check: パスワード・トークンがログ出力前にマスクされているか
Why: 機密情報ログ出力で認証情報漏洩、セキュリティリスク
Fix: 機密変数`***`マスク、ログ出力前フィルタ

**LOG-06: echo_section セクション区切り**

Check: echo_sectionで処理単位の区切りがあるか
Why: セクション区切りなしでログ追跡困難、デバッグ困難
Fix: echo_section利用、処理単位区切り、視認性向上

**LOG-07: verbose 実装**

Check: -v/--verboseオプションで詳細ログ制御があるか
Why: デバッグログ本番出力でログ肥大化、重要ログ埋没
Fix: -v/--verboseオプション、条件的詳細ログ、レベル制御

## Output Format

Review results must be output in the following format:

### Output Structure

Report **only detected issues** in numbered list format. Each issue includes:

- Item ID + Item Name
- File: file path and line number
- Problem: Description of the issue
- Impact: Scope and severity
- Recommendation: Specific fix suggestion

### Output Format Example

問題なし時：

```markdown
# Shell Script Code Review Result

No issues found ✅

All checks passed. Code is ready for merge.
```

問題検出時：

````markdown
# Shell Script Code Review Result

Found 2 issues that need to be addressed:

### 1. G-01: SCRIPT_DIR 設定+lib/all.sh source

**File**: `scripts/deploy.sh:1`

**Problem**: lib/all.sh未source、SCRIPT_DIR未設定

**Impact**: error_exit等共通関数利用不可、実行ディレクトリ依存

**Recommendation**: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "${SCRIPT_DIR}/../lib/all.sh"`追加

---

### 2. SEC-01: 入力値検証

**File**: `scripts/setup.sh:42`

**Problem**: ユーザー入力無検証、パストラバーサル脆弱性

**Impact**: コマンドインジェクション、データ破壊リスク

**Recommendation**: 入力値正規表現検証、ホワイトリスト、範囲チェック実装

```

```
````

## Review Process

### Step 1: Verify Automated Checks

自動チェックが合格していることを確認：

- `bash -n` (構文チェック)
- `shellcheck`
- Bats tests (実装時)

自動チェック失敗時は手動レビュー前に修正依頼。

### Step 2: Systematic Review by Category

10カテゴリで体系的にレビュー：
Global (G) → Code Standards (CODE) → Function Design (FUNC) → Error Handling (ERR) → Security (SEC) → Performance (PERF) → Testing (TEST) → Documentation (DOC) → Dependencies (DEP) → Logging (LOG)

**優先度**：

- **Critical**: セキュリティ問題 (SEC-\*)、機密情報露出 (G-02, SEC-06)
- **High**: エラーハンドリング不備 (ERR-\*)、入力検証不足 (SEC-01)
- **Medium**: ベストプラクティス違反、保守性問題
- **Low**: パフォーマンス改善、ドキュメント改善

### Step 3: Report Issues with Recommendations

Output Formatに従ってレビュー結果出力：

- 検出された問題のみ報告
- ファイルパスと行番号含む
- 具体的で実行可能な推奨事項
- コード例示含む

## Best Practices

### Review Guidelines

- **建設的・具体的に**: コード例を含む推奨事項、共通ライブラリ参照
- **コンテキスト考慮**: PR目的と要件理解、トレードオフ検討
- **優先度明確化**: "must fix"と"nice to have"の区別
- **MCPツール活用**: serenaでプロジェクト構造確認、grep_searchでパターン検索
- **自動チェック優先**: 構文エラーやクォーティングへの過度な焦点回避
- **セキュリティ見落とし防止**: SEC-\*項目は特に注意深く
- **プロジェクト標準遵守**: lib/all.sh共通ライブラリ活用を重視
