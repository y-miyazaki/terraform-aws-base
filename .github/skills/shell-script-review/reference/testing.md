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
