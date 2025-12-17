---
applyTo: "**/.github/workflows/*.yaml,**/.github/workflows/*.yml"
description: "AI Assistant Instructions for GitHub Actions Workflows"
---

# AI Assistant Instructions for GitHub Actions

**言語ポリシー**: ドキュメント日本語、コード・コメント英語

## Standards

### Workflow Standards

必須要素:

- `name`: ワークフロー名
- `on`: トリガー条件
- `permissions`: 最小権限（`contents: read`）
- `jobs.<job_id>.runs-on`: ランナー指定
- `jobs.<job_id>.steps`: ステップリスト

キー記載順序:

- `inputs`, `env`, `permissions`, `with` の中のキーはアルファベット順（A-Z）で記載すること
- 例:
  ```yaml
  inputs:
    component: # a
    environment: # e
    go_version: # g
  env:
    ENVIRONMENT: ${{ inputs.environment }}
    GO_VERSION: ${{ inputs.go_version }}
  permissions:
    contents: write
    id-token: write
  with:
    component: arc
    go_path: "."
    version: ${{ inputs.version }}
  ```

## Guidelines

### Workflow Design Patterns

基本パターン:

- CI: コミット時 lint・test・build
- CD: main マージ時デプロイ
- Schedule: cron 定期実行
- Manual: workflow_dispatch 手動実行

### Tool Integration

Reviewdog 統合:

- PR 差分 lint 結果表示
- `github_token`必須
- `reporter: github-pr-review`推奨

Codecov:

- カバレッジアップロード
- token 管理（Public repo: 不要、Private: 必須）

Artifact:

- アップロード/ダウンロード適切
- retention 設定（デフォルト 90 日、調整推奨）

キャッシュ:

- `actions/cache`で依存関係キャッシュ
- key 設計: ロックファイルハッシュ使用
- restore-keys fallback 設定

### Security Best Practices

セキュリティ必須:

- `permissions`明示的設定
- シークレット: `${{ secrets.NAME }}`
- Public repo: fork PR 制限

### Code Modification Guidelines

検証手順:

1. YAML 構文チェック
2. アクション最新バージョン確認
3. `permissions`設定確認
4. Secret 変数存在確認

### Error Handling

基本パターン:

- `continue-on-error: true`慎重利用（重要ステップで使用禁止）
- `if: failure()`で失敗時処理（cleanup、通知等）
- `if: always()`で必須処理（artifact 保存、通知等）
- `timeout-minutes`必須（job/step 両方）

エラー通知:

```yaml
- name: Notify failure
  if: failure()
  uses: slackapi/slack-github-action@v2
  with:
    webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
```

リトライパターン:

```yaml
- name: Deploy with retry
  uses: nick-invision/retry@v3
  with:
    command: make deploy
    max_attempts: 3
    timeout_minutes: 10
```

### Performance

並列実行:

- `matrix`戦略活用（複数バージョン/OS 並列テスト）
- `concurrency`設定で重複実行キャンセル

キャッシュ活用:

- 依存関係キャッシュでビルド時間短縮
- 不要 step 削減

Concurrency 設定例:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

### Best Practices

DRY 原則:

- reusable workflow 活用（共通処理）
- composite action 作成（複雑 step）
- 重複排除

Job 依存関係:

- `needs`で依存関係明確化
- 並列実行可能な job は依存関係設定しない

条件分岐:

- `if`条件適切
- 環境変数スコープ適切（job/step/global）

Reusable workflow 例:

```yaml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
```

## Testing and Validation

必須検証コマンド（4 項目）:

1. **actionlint**: ワークフロー構文・ベストプラクティスチェック
2. **ghalint run**: セキュリティ・設定検証
3. **disable-checkout-persist-credentials**: `actions/checkout` persist-credentials 設定検証
4. **ghatm**: timeout-minutes 設定検証

実行例:

```bash
# 1. actionlint実行
actionlint .github/workflows/*.{yml,yaml}

# 2. ghalint実行
ghalint run .github/workflows/

# 3. persist-credentials検証
disable-checkout-persist-credentials .github/workflows/

# 4. timeout-minutes検証
ghatm .github/workflows/
```

検証項目:

- ワークフロー構文エラー検出
- 非推奨アクション検出
- セキュリティ問題検出
- `permissions`設定検証
- シェルコマンド安全性確認
- `persist-credentials: false`設定確認
- `timeout-minutes`設定確認

## Security Guidelines

必須セキュリティ設定:

### Permissions

最小権限原則:

```yaml
permissions:
  contents: read # 読取のみ
  pull-requests: write # PR必要時のみ
```

### Secrets Management

- シークレット参照: `${{ secrets.NAME }}`
- 環境変数経由推奨（ログ漏洩防止）
- シークレット echo 禁止

### Actions Checkout

persist-credentials 無効化:

```yaml
- uses: actions/checkout@v4
  with:
    persist-credentials: false # 必須
```

### Timeout 設定

全 job・step 必須:

```yaml
jobs:
  build:
    timeout-minutes: 30 # job timeout
    steps:
      - name: Build
        timeout-minutes: 10 # step timeout
```

### Third-party Actions

- バージョン固定（commit SHA 推奨）
- 信頼できる公式アクションのみ使用
- 定期更新（Renovate/Dependabot）

### Fork PR 制限

Public repository で fork PR 実行制限:

```yaml
on:
  pull_request:
    types: [opened, synchronize, reopened]
  workflow_dispatch: # manual only for fork
```
