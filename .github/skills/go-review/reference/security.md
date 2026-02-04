### 7. Security (SEC)

**SEC-01: 入力値検証**

Check: 入力値バリデーション・prepared statement・サニタイズ実装があるか
Why: 入力値無検証・SQL文字列連結でSQL injection・XSS攻撃、データ改ざん
Fix: prepared statement必須、バリデーション実装、サニタイズ実装

**SEC-02: 出力値サニタイズ**

Check: HTMLエスケープ・JSONインジェクション対策・CRLF injection対策があるか
Why: エスケープ未実装でXSS脆弱性、レスポンス改ざん、セッションハイジャック
Fix: html/template利用、出力コンテキスト応じたエスケープ

**SEC-03: 暗号化適切**

Check: TLS 1.2以上・AES-256-GCM・crypto/rand使用されているか
Why: 平文通信・弱い暗号化で盗聴、中間者攻撃、データ漏洩
Fix: TLS 1.2以上必須、AES-256-GCM利用、crypto/rand使用

**SEC-04: 認証・認可実装**

Check: 全エンドポイント認証・JWT署名検証・RBAC実装があるか
Why: 認証スキップ・検証不足で不正アクセス、権限昇格、データ漏洩
Fix: 全エンドポイント認証必須、JWT署名検証、RBAC実装

**SEC-05: レート制限・DOS対策**

Check: rate limiter・タイムアウト設定・リクエストサイズ制限があるか
Why: リクエスト制限無しでDOS攻撃、サービス停止、リソース枯渇
Fix: rate limiter実装、タイムアウト設定、リクエストサイズ制限

**SEC-06: ログセキュリティ**

Check: 機密情報マスク関数・パスワード/トークンマスクがあるか
Why: パスワード・トークンログ出力で認証情報漏洩、GDPR違反
Fix: 機密情報マスク関数実装、構造化ログ、ログローテーション

**SEC-07: 安全デフォルト値**

Check: 最小権限原則・本番環境debug無効・明示的CORS設定があるか
Why: セキュアでないデフォルトでセキュリティ侵害、攻撃成功率上昇
Fix: 最小権限原則、本番環境debug無効、明示的CORS設定

**SEC-08: OWASP準拠**

Check: OWASP Top 10対応・Security Headers設定・CSP設定があるか
Why: OWASP未対応で既知脆弱性放置、攻撃リスク増大
Fix: OWASP Top 10チェック、Security Headers設定、定期診断
