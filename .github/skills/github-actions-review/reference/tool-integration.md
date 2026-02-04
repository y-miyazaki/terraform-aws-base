### 3. Tool Integration (TOOL)

**TOOL-01: PR diff lint (Reviewdog 等) 設定**

Check: PRコメント型lintツールが設定されているか
Why: PR diff lint未設定で問題のレビュー遅延、修正コスト増
Fix: Reviewdog等でPR上に自動コメント

**TOOL-02: Reviewdog の reporter 設定**

Check: Reviewdogの`reporter`が適切に設定されているか
Why: reporter未指定で可視化不足、対応漏れリスク
Fix: `reporter: github-pr-review`などで見える化

**TOOL-03: カバレッジ報告のトークン管理**

Check: カバレッジトークンがシークレット化され最小権限か
Why: トークン不適切管理でトークン漏洩、報告失敗
Fix: トークンのシークレット化、最小権限化、成功確認

**TOOL-04: Artifact の命名と保護**

Check: アーティファクト命名規約があり機密情報が除外されているか
Why: 命名・保持未整備でストレージ肥大化、機密露出リスク
Fix: 命名規約と`retention-days`設定、機密除外

**TOOL-05: Artifact 保持期間とローテーション**

Check: アーティファクトに適切な`retention-days`が設定されているか
Why: 保持期間未設定・過長でストレージ浪費、古い情報露出
Fix: `retention-days`設定と定期クリーンアップ

**TOOL-06: actions/cache のキー設計**

Check: キャッシュキーが安定ハッシュで設計され`restore-keys`があるか
Why: キャッシュキー設計不備でキャッシュミス、再構築、時間増加
Fix: `runner.os`プレフィックス＋安定ハッシュ、`restore-keys`設定
