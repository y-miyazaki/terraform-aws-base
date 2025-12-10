---
name: "review-github-actions-workflow"
description: "GitHub Actions Workflow正確性・セキュリティ・ベストプラクティス準拠レビュー"
---

# GitHub Actions Workflow Review Prompt

GitHub Actions ベストプラクティス精通エキスパート。Workflow 正確性・セキュリティ・ベストプラクティス準拠レビュー。

**Note**: Lint/自動チェック可能項目（YAML 構文エラー、runs-on 未指定、ステップ名欠落、working-directory 不正、キー順序等）は actionlint/yamllint で検出するため、本レビューでは除外。

## Review Guidelines (ID Based)

### 1. Global / Base (G)

- G-01: ワークフロー名の明確化
  - Problem: ワークフロー名の欠如・不明瞭
  - Impact: 実行判別困難によるトリアージ遅延
  - Recommendation: 簡潔な `name` 設定（例: `terraform/init (audit)`）
- G-02: トリガー (`on`) の限定
  - Problem: トリガーの過度な広さ
  - Impact: 不要実行によるコスト増・ノイズ発生
  - Recommendation: `paths` / `types` によるトリガー絞り込み
- G-03: トップレベル `permissions` の最小化
  - Problem: トップレベル permissions 未設定または過剰
  - Impact: 侵害時の被害拡大（シークレット露出等）
  - Recommendation: トップレベルで最小権限の明示（例: `contents: read`）
- G-04: ステップの明確化・順序保証
  - Problem: ステップの不明瞭さ・順序混在
  - Impact: ビルド脆弱化・保守性低下
  - Recommendation: `name` 付与と論理的順序、`uses`/`run` の役割分離
- G-05: サードパーティアクションのバージョン管理
  - Problem: サードパーティアクションのバージョン未固定
  - Impact: 挙動変化・サプライチェーンリスク
  - Recommendation: 重要アクションは SHA 固定・定期レビュー
- G-06: 環境(environment) と承認フローの明示
  - Problem: 環境 (environment) 未設定または承認欠落
  - Impact: 本番誤実行・シークレット漏洩リスク
  - Recommendation: 重要ジョブに `environment` 設定・承認者指定

### 2. Error Handling (ERR)

- ERR-01: `continue-on-error` の慎重利用
  - Problem: `continue-on-error` の多用
  - Impact: 隠れた失敗の見落とし
  - Recommendation: 使用は限定的・根拠明示
- ERR-02: 失敗時の後処理の準備
  - Problem: 失敗時の後処理未整備
  - Impact: 解析困難・リソース残留
  - Recommendation: `if: failure()` によるログ・アーティファクト収集とクリーンアップ
- ERR-03: 障害通知の統合
  - Problem: 障害通知の未整備
  - Impact: 失敗の見逃し・対応遅延
  - Recommendation: Slack/Email 通知導入・重要度別集約
- ERR-04: ジョブタイムアウトの設定
  - Problem: ジョブタイムアウト未設定
  - Impact: ランナー浪費・CI 停滞
  - Recommendation: 適切な `timeout-minutes` 設定

### 3. Tool Integration (TOOL)

- TOOL-01: PR diff lint (Reviewdog 等) 設定
  - Problem: PR diff lint 未設定
  - Impact: 問題のレビュー遅延・修正コスト増
  - Recommendation: Reviewdog 等で PR 上に自動コメント
- TOOL-02: Reviewdog の reporter 設定
  - Problem: reporter 未指定で可視化不足
  - Impact: 対応漏れリスク
  - Recommendation: `reporter: github-pr-review` などで見える化
- TOOL-03: カバレッジ報告のトークン管理
  - Problem: カバレッジトークンの不適切管理
  - Impact: トークン漏洩・報告失敗
  - Recommendation: トークンのシークレット化・最小権限化し、成功確認
- TOOL-04: Artifact の命名と保護
  - Problem: アーティファクト命名・保持の未整備
  - Impact: ストレージ肥大化・機密露出リスク
  - Recommendation: 命名規約と `retention-days` 設定、機密除外
- TOOL-05: Artifact 保持期間とローテーション
  - Problem: 保持期間未設定または過長
  - Impact: ストレージ浪費・古い情報露出
  - Recommendation: `retention-days` 設定と定期クリーンアップ
- TOOL-06: actions/cache のキー設計
  - Problem: キャッシュキー設計の不備
  - Impact: キャッシュミスによる再構築・時間増加
  - Recommendation: `runner.os` プレフィックス＋安定ハッシュ、`restore-keys` 設定
  - Example:
    ```yaml
    - name: Cache terraform
      uses: actions/cache@v3
      with:
        key: terraform-init-${{ runner.os }}-${{ hashFiles('**/lockfile') }}
        restore-keys: |
          terraform-init-${{ runner.os }}-
          terraform-init-
    ```

### 4. Security (SEC)

- SEC-01: トップレベル `permissions` の明示
  - Problem: トップレベル permissions 未設定
  - Impact: 権限過多による被害拡大
  - Recommendation: トップレベルで最小権限の明示
- SEC-02: シークレットの安全な参照
  - Problem: シークレットの不適切な扱い（直接出力等）
  - Impact: ログ/アーティファクト経由のシークレット漏洩
  - Recommendation: `${{ secrets.NAME }}` のみ利用、ログ出力禁止、必要時マスク化
- SEC-03: `pull_request_target` の慎重な利用
  - Problem: `pull_request_target` の誤用
  - Impact: フォーク経由でのシークレット流出リスク
  - Recommendation: フォーク PR では `pull_request` の利用、もしくは条件付きアクセス制限
- SEC-04: 機密情報のログマスク
  - Problem: 機密値のログ露出
  - Impact: 機密漏洩リスク
  - Recommendation: `core.setSecret()` / `::add-mask::` によるログマスク
- SEC-05: サードパーティアクションの固定
  - Problem: アクション未固定
  - Impact: サプライチェーンリスク・予期せぬ挙動
  - Recommendation: 重要アクションは SHA 固定・Dependabot 監視
- SEC-06: 環境変数のサニタイズ
  - Problem: 環境変数の未検証入力
  - Impact: インジェクション・情報漏洩リスク
  - Recommendation: 入力の検証・サニタイズ、PR 値の直接シェル渡し禁止
- SEC-07: 公開リポジトリ向けのガードレール
  - Problem: 公開/プライベート判別の欠落
  - Impact: 公開フォーク経由のシークレット露出リスク
  - Recommendation: `github.event.repository.private` 等で条件分岐・使用制限

### 5. Performance (PERF)

- PERF-01: matrix 活用による並列化
  - Problem: matrix 未活用で冗長
  - Impact: 実行時間増加・冗長化
  - Recommendation: `matrix` 導入による並列化
- PERF-02: キャッシュによる作業短縮
  - Problem: 依存キャッシュ未利用
  - Impact: 毎回の再取得による時間増
  - Recommendation: 適切パスのキャッシュと `restore-keys` 設計
- PERF-03: 冗長ステップの削除
  - Problem: ステップ重複
  - Impact: 不要実行による時間/コスト増
  - Recommendation: ステップ集約・共有化
- PERF-04: concurrency 設定による古い実行キャンセル
  - Problem: 重複実行による無駄
  - Impact: リソース浪費・遅延
  - Recommendation: `concurrency` 設定で古い実行のキャンセル

### 6. Best Practices (BP)

- BP-01: 再利用可能なワークフロー設計
  - Problem: ワークフローの手作業コピー
  - Impact: メンテナンスコスト増・機能乖離
  - Recommendation: reusable workflows / composite actions へ抽出
- BP-02: DRY 原則による重複削減
  - Problem: コード重複
  - Impact: 更新負荷増・ヒューマンエラー
  - Recommendation: テンプレート化・入力パラメータ化
- BP-03: job 依存関係の明示
  - Problem: job 依存関係の曖昧さ
  - Impact: 直列化・失敗伝播
  - Recommendation: `needs` による明示化
- BP-04: 条件分岐の簡素化
  - Problem: 複雑な `if` 式
  - Impact: 判定ミスによるジョブ不整合
  - Recommendation: `if` の簡潔化・意図コメント
- BP-05: 環境変数スコープの限定
  - Problem: env の過剰スコープ
  - Impact: 予期せぬ挙動・秘密露出
  - Recommendation: 最小スコープの `env`、outputs/inputs 利用

## Output Format

レビュー結果リスト形式、簡潔説明+推奨修正案。

**Checks**: 全項目表示、✅=Pass / ❌=Fail
**Issues**: 問題ありのみ表示

## Example Output

### ✅ All Pass

```markdown
# GitHub Actions Workflow Review Result

## Issues

None ✅
```

### ❌ Issues Found

```markdown
# GitHub Actions Workflow Review Result

## Issues

1. permissions 未設定

   - Problem: トップレベル permissions 欠落
   - Impact: デフォルト全権限付与、過剰権限リスク
   - Recommendation: `permissions: contents: read`追加

2. Public repo fork PR 制限未実装
   - Problem: pull_request_target または fork PR 制限無
   - Impact: fork PR から機密情報アクセス可能
   - Recommendation: `if: github.event.repository.private == false && github.event.pull_request.head.repo.fork == false`追加
```
