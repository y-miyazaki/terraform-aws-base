### 12. Dependencies (DEP)

**DEP-01: 直接依存明示**

Check: 直接依存go.mod明示・バージョン固定・定期更新されているか
Why: 間接依存に依存・バージョン固定なしでビルド不安定、予期しない動作
Fix: 直接依存go.mod明示、バージョン固定、定期更新

**DEP-02: 依存更新戦略**

Check: 定期的go get -u・Renovate/Dependabot導入・更新方針策定があるか
Why: 依存更新なし・脆弱性放置でセキュリティリスク、技術的負債
Fix: 定期的go get -u、Renovate/Dependabot導入、更新方針策定

**DEP-03: vendor管理（必要時のみ）**

Check: 必要時のみvendor・.gitignore設定・モジュールプロキシ活用されているか
Why: vendor不要使用・コミット漏れでリポジトリサイズ増、CI時間増
Fix: 必要時のみvendor、.gitignore設定、モジュールプロキシ活用

**DEP-04: 標準ライブラリ優先**

Check: 標準ライブラリ優先検討・最小依存原則・依存理由明確化されているか
Why: 標準で可能な機能の外部依存で脆弱性リスク増、保守コスト増
Fix: 標準ライブラリ優先検討、最小依存原則、依存理由明確化

**DEP-05: AWS SDKバージョン管理**

Check: AWS SDK v2移行・最新版利用・非推奨API置換されているか
Why: AWS SDK古いバージョン・v1/v2混在で新機能使用不可、非推奨警告
Fix: AWS SDK v2移行、最新版利用、非推奨API置換

**DEP-06: 開発依存分離**

Check: //go:build tools利用・開発依存明確化・本番除外されているか
Why: 開発依存が本番依存・不要依存含有でセキュリティリスク、デプロイサイズ増
Fix: //go:build tools利用、開発依存明確化、本番除外

**DEP-07: ライセンス互換性**

Check: go-licenses活用・ライセンス一覧生成・互換性確認されているか
Why: ライセンス未確認・GPL等制限ライブラリで法的リスク、商用利用不可
Fix: go-licenses活用、ライセンス一覧生成、互換性確認

## Best Practices

- **Context-First**: Always start reviews with context handling and concurrency patterns
- **Security Priority**: Prioritize security checks (G, SEC, ERR) to catch critical issues early
- **Performance Aware**: Check hot paths and common performance anti-patterns
- **Test Quality**: Verify test design and coverage complement automated checks
- **Architecture Focus**: Assess long-term maintainability through architecture patterns
