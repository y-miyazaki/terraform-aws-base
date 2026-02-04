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
