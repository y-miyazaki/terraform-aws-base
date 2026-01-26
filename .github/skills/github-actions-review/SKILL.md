---
name: github-actions-review
description: GitHub Actions Workflow code review for correctness, security, and best practices. Use for manual review of workflow files checking design decisions and security patterns requiring human judgment.
license: MIT
---

# GitHub Actions Workflow Code Review

This skill provides comprehensive guidance for reviewing GitHub Actions Workflow configurations to ensure correctness, security, and best practices compliance.

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on GitHub Actions Workflow pull requests
- Checking workflow configurations before merging
- Ensuring security and compliance standards
- Validating best practices adherence
- Architecture and design review

## Important Notes

- **Automation First**: Lint and auto-checkable items (YAML syntax, runs-on missing, step names, working-directory, key ordering) are excluded as they should be caught by actionlint/yamllint in CI/CD.
- **Manual Review Focus**: This skill focuses on design decisions, security patterns, and workflow architecture that require human judgment.

## Output Language

**IMPORTANT**: レビュー結果はすべて日本語で出力。ただし以下は英語：

- ファイルパス、コードスニペット、技術識別子（アクション名、変数名、シークレット名など）

## Review Guidelines

### 1. Global / Base (G)

**G-01: ワークフロー名の明確化**

Check: ワークフロー名が明確で目的を表現しているか
Why: 名前欠如・不明瞭で実行判別困難、トリアージ遅延
Fix: 簡潔な`name`設定（例: `terraform/init (audit)`）

**G-02: トリガー (on) の限定**

Check: トリガーが適切に絞り込まれているか
Why: トリガー過度に広く不要実行でコスト増、ノイズ発生
Fix: `paths`/`types`でトリガー絞り込み

**G-03: トップレベル permissions の最小化**

Check: トップレベルpermissionsが最小権限で明示されているか
Why: permissions未設定・過剰で侵害時の被害拡大（シークレット露出等）
Fix: トップレベルで最小権限明示（例: `contents: read`）

**G-04: ステップの明確化・順序保証**

Check: 各ステップに`name`があり論理的順序か
Why: ステップ不明瞭・順序混在でビルド脆弱化、保守性低下
Fix: `name`付与と論理的順序、`uses`/`run`の役割分離

**G-05: サードパーティアクションのバージョン管理**

Check: 重要アクションがSHA固定されているか
Why: バージョン未固定で挙動変化、サプライチェーンリスク
Fix: 重要アクションはSHA固定、定期レビュー、Dependabot監視

**G-06: 環境 (environment) と承認フローの明示**

Check: 本番環境ジョブに`environment`設定と承認があるか
Why: environment未設定・承認欠落で本番誤実行、シークレット漏洩リスク
Fix: 重要ジョブに`environment`設定、承認者指定

### 2. Error Handling (ERR)

**ERR-01: continue-on-error の慎重利用**

Check: `continue-on-error`使用が根拠明示され限定的か
Why: `continue-on-error`多用で隠れた失敗の見落とし
Fix: 使用は限定的、根拠コメント明示

**ERR-02: 失敗時の後処理の準備**

Check: 失敗時の後処理（ログ収集・クリーンアップ）が整備されているか
Why: 失敗時の後処理未整備で解析困難、リソース残留
Fix: `if: failure()`でログ・アーティファクト収集とクリーンアップ

**ERR-03: 障害通知の統合**

Check: 重要ジョブ失敗時の通知が設定されているか
Why: 障害通知未整備で失敗の見逃し、対応遅延
Fix: Slack/Email通知導入、重要度別集約

**ERR-04: ジョブタイムアウトの設定**

Check: 各ジョブに適切な`timeout-minutes`が設定されているか
Why: タイムアウト未設定でランナー浪費、CI停滞
Fix: 適切な`timeout-minutes`設定

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

### 5. Performance (PERF)

**PERF-01: matrix 活用による並列化**

Check: 複数環境テストで`matrix`が活用されているか
Why: matrix未活用で冗長、実行時間増加
Fix: `matrix`導入による並列化

**PERF-02: キャッシュによる作業短縮**

Check: 依存関係に適切なキャッシュが設定されているか
Why: 依存キャッシュ未利用で毎回の再取得、時間増
Fix: 適切パスのキャッシュと`restore-keys`設計

**PERF-03: 冗長ステップの削除**

Check: ステップの重複がないか
Why: ステップ重複で不要実行、時間/コスト増
Fix: ステップ集約、共有化

**PERF-04: concurrency 設定による古い実行キャンセル**

Check: `concurrency`設定で古い実行がキャンセルされるか
Why: 重複実行によるリソース浪費、遅延
Fix: `concurrency`設定で古い実行のキャンセル

### 6. Best Practices (BP)

**BP-01: 再利用可能なワークフロー設計**

Check: 共通処理が再利用可能ワークフローまたはcomposite actionに抽出されているか
Why: ワークフローの手作業コピーでメンテナンスコスト増、機能乖離
Fix: reusable workflows/composite actionsへ抽出

**BP-02: DRY 原則による重複削減**

Check: コード重複がないか
Why: コード重複で更新負荷増、ヒューマンエラー
Fix: テンプレート化、入力パラメータ化

**BP-03: job 依存関係の明示**

Check: job依存関係が`needs`で明示されているか
Why: job依存関係曖昧で直列化、失敗伝播
Fix: `needs`による明示化

**BP-04: 条件分岐の簡素化**

Check: `if`式が簡潔で理解しやすいか
Why: 複雑な`if`式で判定ミス、ジョブ不整合
Fix: `if`の簡潔化、意図コメント

**BP-05: 環境変数スコープの限定**

Check: `env`が最小スコープで定義されているか
Why: envの過剰スコープで予期せぬ挙動、秘密露出
Fix: 最小スコープの`env`、outputs/inputs利用

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
# GitHub Actions Workflow Code Review Result

No issues found ✅

All checks passed. Code is ready for merge.
```

問題検出時：

````markdown
# GitHub Actions Workflow Code Review Result

Found 2 issues that need to be addressed:

### 1. G-03: トップレベル permissions の最小化

**File**: `.github/workflows/deploy.yml:1`

**Problem**: トップレベルpermissions未設定

**Impact**: デフォルト全権限付与、侵害時の被害拡大

**Recommendation**: ワークフロー先頭に`permissions: contents: read`追加

---

### 2. SEC-03: pull_request_target の慎重な利用

**File**: `.github/workflows/pr.yml:5`

**Problem**: `pull_request_target`使用時のfork PR制限なし

**Impact**: フォーク経由のシークレット流出リスク

**Recommendation**: `if: github.event.pull_request.head.repo.fork == false`条件追加

```

```
````

## Review Process

### Step 1: Verify Automated Checks

自動チェックが合格していることを確認：

- `actionlint`
- `yamllint`
- `ghalint`（利用時）
- `zizmor`（利用時）

自動チェック失敗時は手動レビュー前に修正依頼。

### Step 2: Systematic Review by Category

6カテゴリで体系的にレビュー：
Global (G) → Error Handling (ERR) → Tool Integration (TOOL) → Security (SEC) → Performance (PERF) → Best Practices (BP)

**優先度**：

- **Critical**: セキュリティ問題 (SEC-\*)、権限設定 (G-03, SEC-01)
- **High**: シークレット露出リスク (SEC-02, SEC-03, SEC-04)、本番誤実行 (G-06)
- **Medium**: ベストプラクティス違反、保守性問題
- **Low**: パフォーマンス改善、軽微な最適化

### Step 3: Report Issues with Recommendations

Output Formatに従ってレビュー結果出力：

- 検出された問題のみ報告
- ファイルパスと行番号含む
- 具体的で実行可能な推奨事項
- コード例示含む

## Best Practices

### Review Guidelines

- **建設的・具体的に**: コード例を含む推奨事項、公式ドキュメントリンク
- **コンテキスト考慮**: PR目的と要件理解、トレードオフ検討
- **優先度明確化**: "must fix"と"nice to have"の区別
- **MCPツール活用**: context7でアクションドキュメント確認、github_repoで最新バージョン確認
- **自動チェック優先**: YAML構文やキー順序への過度な焦点回避
- **セキュリティ見落とし防止**: SEC-\*項目は特に注意深く
- **個人的好み回避**: プロジェクト標準とベストプラクティスに基づく
