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
