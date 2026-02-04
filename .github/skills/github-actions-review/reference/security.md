### 4. Security (SEC)

**SEC-01: トップレベル permissions の明示**

Check: トップレベルpermissionsが明示的に設定されているか
Why: permissions未設定で権限過多、被害拡大
Fix: トップレベルで最小権限明示（例: `contents: read`）

**SEC-02: シークレットの安全な参照**

Check: シークレットが`${{ secrets.NAME }}`のみで参照され直接出力されていないか
Why: シークレット不適切扱い（直接出力等）でログ/アーティファクト経由の漏洩
Fix: `${{ secrets.NAME }}`のみ利用、ログ出力禁止、必要時マスク化

**SEC-03: pull_request_target の慎重な利用**

Check: `pull_request_target`使用時にfork PR制限があるか
Why: `pull_request_target`誤用でフォーク経由のシークレット流出リスク
Fix: fork PRでは`pull_request`利用、または条件付きアクセス制限

**SEC-04: 機密情報のログマスク**

Check: 機密値が`::add-mask::`または`core.setSecret()`でマスクされているか
Why: 機密値のログ露出で機密漏洩リスク
Fix: `core.setSecret()`/`::add-mask::`によるログマスク

**SEC-05: サードパーティアクションの固定**

Check: 重要アクションがSHA固定されているか
Why: アクション未固定でサプライチェーンリスク、予期せぬ挙動
Fix: 重要アクションはSHA固定、Dependabot監視

**SEC-06: 環境変数のサニタイズ**

Check: 環境変数の入力が検証・サニタイズされているか
Why: 環境変数の未検証入力でインジェクション、情報漏洩リスク
Fix: 入力の検証・サニタイズ、PR値の直接シェル渡し禁止

**SEC-07: 公開リポジトリ向けのガードレール**

Check: 公開リポジトリで`github.event.repository.private`等の条件分岐があるか
Why: 公開/プライベート判別欠落で公開フォーク経由のシークレット露出リスク
Fix: `github.event.repository.private`等で条件分岐、使用制限
