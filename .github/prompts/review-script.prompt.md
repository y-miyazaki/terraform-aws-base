---
name: "review-script"
description: "Shell Script正確性・セキュリティ・保守性・ベストプラクティス準拠レビュー"
---

# Shell Script Review Prompt

Shell Script ベストプラクティス精通エキスパート。正確性・セキュリティ・保守性・業界標準準拠レビュー。
validate_all_scripts.sh 自動化検証前提。

**Note**: Lint/自動チェック可能項目（shebang、set -euo pipefail、引用符、コマンド置換、test [[]]、パイプライン等）は shellcheck/validate_all_scripts.sh で検出するため、本レビューでは除外。

## Review Guidelines (ID Based)

### 1. Global / Base (G)

- G-01: SCRIPT_DIR 設定+lib/all.sh source
  - Problem: SCRIPT_DIR 未設定・共通ライブラリ未読込・相対パス問題
  - Impact: error_exit/validate_dependencies 等共通関数利用不可・実行ディレクトリ依存
  - Recommendation: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "${SCRIPT_DIR}/../lib/all.sh"`
- G-02: 機密情報ハードコーディング禁止
  - Problem: API Key・パスワード・トークンのスクリプト埋め込み
  - Impact: セキュリティ侵害・認証情報漏洩・Git 履歴汚染
  - Recommendation: 環境変数・AWS Secrets Manager 利用、定数削除
- G-03: 関数順序遵守（show_usage/parse_arguments→a-z 順 →main 最後）
  - Problem: 関数順序不統一・main 関数位置不適切
  - Impact: 可読性低下・プロジェクト標準違反・レビュー効率低下
  - Recommendation: show_usage→parse_arguments→ 関数 a-z 順 →main 最後配置
- G-04: デッドコード削除
  - Problem: コメントアウトコード・未使用関数・到達不能コード
  - Impact: 保守困難・混乱・不要行数増加
  - Recommendation: git 履歴利用、デッドコード削除、TODO コメント適切管理
- G-05: error_exit 利用エラーハンドリング
  - Problem: エラー時 exit 1 直接実行・エラーハンドリング不統一
  - Impact: クリーンアップ未実行・エラーメッセージ不統一・デバッグ困難
  - Recommendation: error_exit 関数利用、統一的エラー処理
- G-06: スクリプト冪等性
  - Problem: 再実行時エラー・副作用残留・状態依存実行
  - Impact: 運用困難・デプロイ失敗・リトライ不可
  - Recommendation: 存在チェック、冪等操作、状態確認後実行

### 2. Code Standards (CODE)

- CODE-01: 配列適切利用
  - Problem: 空白含むパス文字列分割・引用符漏れ・配列未使用
  - Impact: ファイル名分割・予期しない引数展開・スクリプト失敗
  - Recommendation: 配列で複数値管理、"${array[@]}"展開
- CODE-02: グローバル変数最小化（local 宣言）
  - Problem: 関数内グローバル変数多用・変数スコープ不明確・副作用
  - Impact: 変数汚染・予期しない動作・デバッグ困難
  - Recommendation: 関数内 local 宣言、readonly 定数、グローバル最小化
- CODE-03: Here document 適切利用
  - Problem: echo 繰り返し・複数行文字列の引用符エスケープ複雑化
  - Impact: 可読性低下・保守困難・エスケープミス
  - Recommendation: cat <<'EOF'利用、ヒアドキュメント活用
- CODE-04: Process substitution 適切利用
  - Problem: 一時ファイル不要生成・パイプライン変数スコープ問題
  - Impact: ファイル I/O 増・クリーンアップ複雑化・変数更新されない
  - Recommendation: <(command)、>(command)活用
- CODE-05: 関数単一責任・引数明示
  - Problem: 関数内複数責任混在・引数なしグローバル変数依存
  - Impact: テスト困難・再利用不可・依存関係不明
  - Recommendation: 単一責任分割、引数で入力受取、グローバル依存最小化

### 3. Function Design (FUNC)

- FUNC-01: 関数 50 行以下推奨
  - Problem: 100 行以上の関数・複雑度高・ネスト深い
  - Impact: 可読性低下・テスト困難・保守困難
  - Recommendation: ヘルパー関数抽出、単一責任原則、50 行以内推奨
- FUNC-02: parse_arguments 標準化（case 文・getopts）
  - Problem: 引数解析ロジック重複・オプション処理不統一・getopts 未使用
  - Impact: オプション追加困難・バグ混入・ヘルプ不整合
  - Recommendation: getopts 利用、case 文標準パターン、-h|--help 対応
- FUNC-03: show_usage 実装（Usage/Description/Options/Examples・exit 0）
  - Problem: ヘルプ未実装・使用方法不明・exit 1 終了
  - Impact: ユーザビリティ低下・問い合わせ増・誤用
  - Recommendation: show_usage 関数実装、Usage/Options/Examples 記載、exit 0
- FUNC-04: 戻り値設計（return code・echo・エラー伝播）
  - Problem: 戻り値未設定・成功/失敗判定不可・エラー伝播なし
  - Impact: エラーハンドリング不可・条件分岐不可・障害検知不可
  - Recommendation: return 0/1 設定、echo 出力、|| error_exit 利用
- FUNC-05: 共通ライブラリ活用（error_exit/log_message 等）
  - Problem: コード重複・エラー処理不統一・ログ出力ばらつき
  - Impact: 保守コスト増・不整合・品質低下
  - Recommendation: lib/all.sh 関数利用、プロジェクト標準遵守
- FUNC-06: validate_dependencies 関数（コマンド存在確認）
  - Problem: 必須コマンド未確認・実行時エラー・エラーメッセージ不明瞭
  - Impact: スクリプト途中失敗・ユーザー困惑・トラブルシュート困難
  - Recommendation: validate_dependencies 実装、command -v 確認、明確エラー
- FUNC-07: main 関数実装
  - Problem: グローバルスコープ処理・構造不明確・テスト不可
  - Impact: 可読性低下・デバッグ困難・ユニットテスト不可
  - Recommendation: main 関数実装、main "$@"呼出、構造化

### 4. Error Handling (ERR)

- ERR-01: trap 設定（EXIT・ERR・INT・TERM）
  - Problem: trap 未設定・クリーンアップなし・一時ファイル残留
  - Impact: リソースリーク・ゾンビプロセス・ディスク浪費
  - Recommendation: trap 'cleanup' EXIT ERR 設定、cleanup 関数実装
- ERR-02: 終了コード確認
  - Problem: コマンド終了コード未確認・|| true 多用・エラー無視
  - Impact: 障害検知不可・データ不整合・サイレント失敗
  - Recommendation: $?確認、|| error_exit、適切エラーハンドリング
- ERR-03: エラーメッセージ明確
  - Problem: エラーメッセージ不明瞭・コンテキスト情報不足・行番号なし
  - Impact: デバッグ困難・問題特定遅延・ユーザー困惑
  - Recommendation: 明確メッセージ、変数値出力、"${BASH_SOURCE}:${LINENO}"追加
- ERR-04: クリーンアップ処理
  - Problem: 一時ファイル削除なし・プロセス終了なし・ロック解放なし
  - Impact: ディスクリーク・プロセスリーク・デッドロック
  - Recommendation: cleanup 関数、trap 設定、確実リソース解放
- ERR-05: リトライ戦略
  - Problem: 一時的エラーでスクリプト停止・ネットワーク障害未対応
  - Impact: 運用負荷・自動復旧不可・可用性低下
  - Recommendation: リトライループ、exponential backoff、最大試行回数
- ERR-06: 部分的失敗許容（set +e 一時解除）
  - Problem: set -e 環境で許容エラー処理困難・|| true 乱用
  - Impact: 可読性低下・意図不明・エラー処理複雑化
  - Recommendation: set +e; command; set -e、明示的エラー許容
- ERR-07: エラーログ記録
  - Problem: エラー出力のみ・永続ログなし・監視困難
  - Impact: 障害履歴不明・トレンド分析不可・事後調査困難
  - Recommendation: エラーログファイル記録、timestamp 付与、ログローテーション

### 5. Security (SEC)

- SEC-01: 入力値検証
  - Problem: ユーザー入力無検証・パス検証なし・注入攻撃脆弱性
  - Impact: コマンドインジェクション・パストラバーサル・データ破壊
  - Recommendation: 入力値正規表現検証、ホワイトリスト、範囲チェック
- SEC-02: コマンドインジェクション対策（引用符）
  - Problem: 変数引用符なし・eval 使用・ユーザー入力直接実行
  - Impact: 任意コマンド実行・権限昇格・システム侵害
  - Recommendation: 全変数"$var"引用符、eval 回避、配列利用
- SEC-03: パス traversal 対策
  - Problem: ../許容・絶対パス未検証・シンボリックリンク未チェック
  - Impact: 意図しないファイルアクセス・データ漏洩・改ざん
  - Recommendation: realpath 利用、パス正規化、許可ディレクトリ制限
- SEC-04: 一時ファイル mktemp+trap 削除
  - Problem: /tmp 固定ファイル名・予測可能パス・削除漏れ
  - Impact: シンボリックリンク攻撃・情報漏洩・ディスク浪費
  - Recommendation: mktemp -d 利用、trap 削除、セキュアパス
- SEC-05: 権限チェック
  - Problem: root 権限未確認・必要権限不足・権限昇格未対応
  - Impact: 実行失敗・部分的成功・セキュリティリスク
  - Recommendation: [[$EUID -eq 0]]確認、適切エラーメッセージ
- SEC-06: ログ機密情報マスク
  - Problem: パスワード・トークンログ出力・機密情報露出
  - Impact: 認証情報漏洩・監査ログ汚染・セキュリティ侵害
  - Recommendation: 機密変数マスク、\*\*\*表示、ログ出力前フィルタ
- SEC-07: 外部コマンド検証
  - Problem: PATH 環境変数依存・コマンド絶対パス未使用・検証なし
  - Impact: コマンド偽装・マルウェア実行・予期しない動作
  - Recommendation: /usr/bin/等絶対パス使用、command -v 検証
- SEC-08: 環境変数汚染回避
  - Problem: 継承環境変数信頼・未初期化変数使用・汚染伝播
  - Impact: 予期しない動作・セキュリティバイパス・データ破損
  - Recommendation: 環境変数明示的初期化、デフォルト値設定、検証
- SEC-09: セキュアデフォルト（umask 027）
  - Problem: デフォルト umask・ファイル権限緩い・グループ読取可能
  - Impact: 情報漏洩・不正アクセス・機密ファイル露出
  - Recommendation: umask 027 設定、明示的権限設定、最小権限原則

### 6. Performance (PERF)

- PERF-01: 外部コマンド最小化
  - Problem: ループ内外部コマンド・cat 濫用・プロセス生成過多
  - Impact: 実行時間増・CPU 負荷・スクリプト遅延
  - Recommendation: Bash 組込機能優先、ループ外移動、一括処理
- PERF-02: サブシェル削減
  - Problem: 不要な()・パイプライン多用・フォーク過多
  - Impact: メモリ消費・実行時間増・リソース浪費
  - Recommendation: {}利用、変数直接操作、サブシェル回避
- PERF-03: ファイル I/O 最適化
  - Problem: ファイル複数回読込・行毎 I/O・バッファリングなし
  - Impact: I/O 待機時間・実行遅延・ディスク負荷
  - Recommendation: 一括読込、while read 最適化、buffering 活用
- PERF-04: ループ効率化（while read）
  - Problem: for in $(cat)・word splitting・非効率ループ
  - Impact: メモリ消費・処理遅延・大ファイル処理不可
  - Recommendation: while IFS= read -r 利用、効率的ループ
- PERF-05: 文字列処理最適化
  - Problem: sed/awk 濫用・外部コマンド依存・文字列連結非効率
  - Impact: プロセス生成コスト・実行時間増
  - Recommendation: Bash parameter expansion 活用、組込機能優先
- PERF-06: 条件分岐最適化
  - Problem: ネスト深い・重複判定・短絡評価未使用
  - Impact: 可読性低下・実行時間増・保守困難
  - Recommendation: early return、&&/||短絡評価、case 文活用
- PERF-07: 並列実行活用（&・xargs -P）
  - Problem: 逐次処理・並列化未実装・待機時間長
  - Impact: 実行時間長・リソース活用不足・スループット低
  - Recommendation: バックグラウンド実行、xargs -P、wait 管理
- PERF-08: キャッシュ戦略
  - Problem: 同一処理繰返し・結果キャッシュなし・再計算
  - Impact: 無駄な処理・実行時間増・リソース浪費
  - Recommendation: 結果変数保存、条件キャッシュ、重複削減
- PERF-09: リソース制限（ulimit）
  - Problem: リソース無制限・メモリリーク・プロセス暴走
  - Impact: システムリソース枯渇・他プロセス影響・システムダウン
  - Recommendation: ulimit 設定、リソース制限、防御的プログラミング
- PERF-10: プロファイリング（set -x・time）
  - Problem: パフォーマンスボトルネック不明・推測最適化
  - Impact: 効果薄い最適化・リソース浪費・問題見逃し
  - Recommendation: set -x trace、time 測定、ボトルネック特定

### 7. Testing (TEST)

- TEST-01: 単体テスト実装
  - Problem: テスト未実装・手動テストのみ・品質保証不足
  - Impact: リグレッション・バグ混入・CI/CD 困難
  - Recommendation: Bats 導入、test/bats/配下テスト作成、自動化
- TEST-02: Bats テスト関数 a-z 順（setup 除く）
  - Problem: テスト関数順序不統一・可読性低下
  - Impact: テスト保守困難・レビュー効率低下
  - Recommendation: setup/teardown 後、テスト関数 a-z 順配置
- TEST-03: CI/CD 統合
  - Problem: テスト自動実行なし・デプロイ前検証不足
  - Impact: 本番障害・品質低下・デプロイリスク
  - Recommendation: GitHub Actions 統合、PR 時自動テスト、品質ゲート

### 8. Documentation (DOC)

- DOC-01: ヘッダー標準形式（Description/Usage/Design Rules）
  - Problem: ヘッダーなし・スクリプト目的不明・使用方法不明
  - Impact: 理解困難・誤用・オンボーディング遅延
  - Recommendation: 標準ヘッダー追加、Description/Usage/Design Rules 記載
- DOC-02: show_usage 必須
  - Problem: -h/--help オプションなし・使用方法不明・例示なし
  - Impact: ユーザビリティ低下・問い合わせ増・誤用
  - Recommendation: show_usage 関数、Usage/Options/Examples、exit 0
- DOC-03: 関数#######区切り+コメント
  - Problem: 関数境界不明確・コメントなし・視認性低下
  - Impact: 可読性低下・保守困難・レビュー効率低下
  - Recommendation: 関数前#######区切り、目的・引数・戻り値コメント
- DOC-04: 複雑ロジックコメント
  - Problem: アルゴリズム説明なし・Why 不明・前提条件不明
  - Impact: 理解困難・保守困難・バグ混入
  - Recommendation: Why 重視コメント、複雑処理説明、前提明記
- DOC-05: 変数説明
  - Problem: 変数目的不明・単位不明・制約不明
  - Impact: 誤用・バグ混入・保守困難
  - Recommendation: グローバル変数コメント、単位・デフォルト値・制約記載
- DOC-06: 英語コメント統一
  - Problem: 日英混在・可読性低下・一貫性欠如
  - Impact: 理解困難・国際化困難・プロフェッショナル性欠如
  - Recommendation: 英語コメント統一、簡潔明瞭記述
- DOC-07: README.md 整備
  - Problem: README 不足・セットアップ手順不明・依存関係不明
  - Impact: オンボーディング遅延・誤った実行・質問増加
  - Recommendation: 目的・前提・セットアップ・使用例・トラブルシュート記載
- DOC-08: エラーメッセージ文書化
  - Problem: エラーコード未定義・解決方法不明・ドキュメント不整合
  - Impact: トラブルシュート困難・ユーザー困惑・サポートコスト増
  - Recommendation: エラーコード一覧、原因・対処法記載
- DOC-09: 変更履歴 CHANGELOG
  - Problem: 変更履歴なし・リリースノート不足・影響範囲不明
  - Impact: 変更追跡困難・影響範囲不明・ユーザー混乱
  - Recommendation: CHANGELOG.md 作成、Keep a Changelog 形式、破壊的変更明記

### 9. Dependencies (DEP)

- DEP-01: lib/all.sh 活用
  - Problem: 共通ライブラリ未使用・コード重複・不統一
  - Impact: 保守コスト増・品質ばらつき・バグ混入
  - Recommendation: lib/all.sh source、error_exit/log_message 等共通関数利用
- DEP-02: validate_dependencies 利用
  - Problem: 必須コマンド未確認・実行時エラー・依存不明
  - Impact: スクリプト途中失敗・ユーザー困惑・運用困難
  - Recommendation: validate_dependencies 呼出、必須コマンド明示
- DEP-03: 必須コマンド明示
  - Problem: 依存コマンド不明・ドキュメント不足・実行環境不明
  - Impact: 実行失敗・環境構築困難・オンボーディング遅延
  - Recommendation: README 依存記載、validate_dependencies 実装
- DEP-04: コマンド存在確認
  - Problem: command -v 未実行・which 使用・存在確認なし
  - Impact: コマンド未発見・実行時エラー・エラーメッセージ不明瞭
  - Recommendation: command -v 確認、明確エラーメッセージ、インストール手順提示

### 10. Logging (LOG)

- LOG-01: log_message/echo_section 活用
  - Problem: echo 直接出力・ログ関数未使用・不統一
  - Impact: ログフォーマット不統一・timestamp 欠如・監視困難
  - Recommendation: log_message 利用、echo_section 区切り、プロジェクト標準遵守
- LOG-02: stdout/stderr 分離
  - Problem: エラーメッセージ stdout 出力・分離なし・リダイレクト問題
  - Impact: エラー検知困難・ログ解析困難・パイプライン問題
  - Recommendation: エラーは>&2、情報は stdout、明確分離
- LOG-03: ログレベル実装（INFO・WARN・ERROR）
  - Problem: ログレベルなし・重要度不明・フィルタ困難
  - Impact: ログノイズ・重要ログ埋没・監視困難
  - Recommendation: INFO/WARN/ERROR レベル、log_message 引数レベル指定
- LOG-04: 構造化ログ（timestamp・レベル・メッセージ）
  - Problem: 非構造化ログ・timestamp 欠如・解析困難
  - Impact: ログ解析困難・時系列追跡不可・監視困難
  - Recommendation: [timestamp] [LEVEL] message 形式、構造化ログ
- LOG-05: 機密情報マスク
  - Problem: パスワード・トークンログ出力・機密情報露出
  - Impact: 認証情報漏洩・セキュリティリスク・監査違反
  - Recommendation: 機密変数\*\*\*マスク、ログ出力前フィルタ
- LOG-06: echo_section セクション区切り
  - Problem: セクション区切りなし・ログ可読性低下・構造不明
  - Impact: ログ追跡困難・デバッグ困難・運用効率低下
  - Recommendation: echo_section 利用、処理単位区切り、視認性向上
- LOG-07: verbose 実装
  - Problem: デバッグログ本番出力・ログ制御不可・ノイズ
  - Impact: ログ肥大化・重要ログ埋没・ストレージ浪費
  - Recommendation: -v/--verbose オプション、条件的詳細ログ、レベル制御

## Output Format

レビュー結果リスト形式、簡潔説明+推奨修正案。

**Checks**: 全項目表示、✅=Pass / ❌=Fail
**Issues**: 問題ありのみ表示

## Example Output

### ✅ All Pass

```markdown
# Shell Script Review Result

## Issues

None ✅
```

### ❌ Issues Found

```markdown
# Shell Script Review Result

## Issues

1. G-01 共通ライブラリ未読込

   - Problem: lib/all.sh 未 source、SCRIPT_DIR 未設定
   - Impact: error_exit/validate_dependencies 等共通関数利用不可・相対パス問題
   - Recommendation: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "${SCRIPT_DIR}/../lib/all.sh"`

2. SEC-01 入力値検証不足
   - Problem: ユーザー入力無検証・パストラバーサル脆弱性
   - Impact: コマンドインジェクション・データ破壊・セキュリティ侵害
   - Recommendation: 入力値正規表現検証、ホワイトリスト、範囲チェック実装
```
