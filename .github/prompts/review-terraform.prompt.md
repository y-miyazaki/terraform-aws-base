---
name: "review-terraform"
description: "Terraformコード正確性・セキュリティ・保守性・ベストプラクティス準拠レビュー"
---

# Terraform Review Prompt

Terraform ベストプラクティス精通エキスパート。正確性・セキュリティ・保守性・業界標準準拠レビュー。

**Note**: Lint/自動チェック可能項目（構文エラー、命名規則 snake_case、terraform fmt/validate、tflint、trivy 等）は pre-commit/CI/CD で検出するため、本レビューでは除外。

## Review Guidelines (ID Based)

### 1. Global / Base (G)

- G-01: 変数/outputs/Module 適切利用（外部モジュール: GitHub/Registry 最新ドキュメント確認**必須**、context7/fetch_webpage 使用）
  - Problem: 誤った変数や出力の利用・ドキュメント未確認
  - Impact: 意図しない構成・エラー・破壊的変更見落とし
  - Recommendation: context7/fetch_webpage で最新ドキュメント確認、正しいインターフェース利用
- G-02: シークレットハードコーディング禁止
  - Problem: コード内の機密情報・パスワード・トークン埋込
  - Impact: 情報漏洩リスク・Git 履歴汚染・セキュリティ侵害
  - Recommendation: 変数化・AWS Secrets Manager/SSM Parameter Store 利用
- G-03: 外部 Module Version 最新併記（GitHub releases 実確認**必須**）
  - Problem: バージョン不明確・古いバージョン・脆弱性含有
  - Impact: 予期せぬ破壊的変更・セキュリティリスク・再現性欠如
  - Recommendation: GitHub リリースページ確認、セマンティックバージョン固定
- G-04: Provider Version constraint 記載（実行環境 version 確認）
  - Problem: プロバイダバージョン未固定・バージョン範囲広すぎ
  - Impact: 破壊的変更による動作停止・再現性欠如
  - Recommendation: `required_providers`ブロック、適切バージョン制約（>= lower, < upper）
- G-05: apply 後決定値 for_each/count キー不使用
  - Problem: apply 後決定値の for_each/count キー利用（例: resource.id）
  - Impact: 計画時不確定エラー（`value depends on resource attributes...`）・並列適用困難
  - Recommendation: 事前決定可能値使用（var、local、data source 既知属性）
- G-06: count より for_each 推奨（トグル用途 count 許容）
  - Problem: リスト順序依存 count 利用・インデックス変動リスク
  - Impact: 予期せぬリソース再作成・順序変更時の破壊的変更
  - Recommendation: 一意キーによる for_each 使用、トグル（0/1）のみ count 許容
- G-07: Module 引数設定妥当性
  - Problem: 必須引数欠落・型不一致・デフォルト値誤用
  - Impact: モジュール動作不良・実行時エラー・意図しない動作
  - Recommendation: モジュール README/variables.tf 確認、正しい型・値設定
- G-08: Module 出力活用（不要 output 無/必要 output 欠落無）
  - Problem: 未使用 output 定義・必要な output 欠落・出力過多
  - Impact: 連携ミス・コード肥大化・可読性低下
  - Recommendation: 必要な値のみ出力、参照されない output 削除
- G-09: tfsec→trivy 移行指摘
  - Problem: 旧ツール（tfsec）使用・最新脆弱性検知ツール未導入
  - Impact: 最新セキュリティ脆弱性検知漏れ・CI/CD 品質低下
  - Recommendation: Trivy へ移行、CI/CD パイプライン統合

### 2. Modules (M)

- M-01: モジュールディレクトリ内全 tf 対象
  - Problem: レビュー範囲漏れ・一部ファイルのみレビュー
  - Impact: 隠れたバグ・不整合・品質低下
  - Recommendation: ディレクトリ内全`.tf`ファイル確認、漏れなくレビュー
- M-02: Provider Version 妥当性（aws provider 最新必須でない）
  - Problem: 不適切プロバイダバージョン・最新版強制・互換性問題
  - Impact: 非互換性・バグ・既存コード動作不良
  - Recommendation: プロジェクト要件に合ったバージョン指定、破壊的変更確認
- M-03: locals/variables/outputs 責務明確
  - Problem: 変数・ローカル・出力混同・責務不明確
  - Impact: 可読性低下・保守性低下・理解困難
  - Recommendation: 用途に応じた適切ファイル/ブロック配置、責務分離
- M-04: 重複タグ・命名プリフィックス統一
  - Problem: タグ・命名不統一・プリフィックスばらつき
  - Impact: リソース管理困難・コスト配分不能・検索困難
  - Recommendation: 共通変数・locals 統一管理、merge 関数活用

### 3. variables.tf (V)

- V-01: 型具体化（map(any)/any 過度回避）
  - Problem: `any`型多用・型安全性欠如・デバッグ困難
  - Impact: 実行時型エラー・予期しない動作・トラブルシュート困難
  - Recommendation: 具体的型定義（`string`, `number`, `object({...})`）、型制約強化
- V-02: デフォルト値妥当性（不要 default 削除/sentinel 値回避）
  - Problem: 不適切デフォルト値・空文字列/0 デフォルト・sentinel 値
  - Impact: 誤設定見落とし・意図しない動作・セキュリティリスク
  - Recommendation: 必須変数は default 削除、適切デフォルト値、null デフォルト検討
- V-03: 説明コメント+(Required)/(Optional)規則
  - Problem: 変数説明不足・必須/任意不明・利用方法不明
  - Impact: 利用者混乱・誤用・ドキュメント不足
  - Recommendation: `description`記述、(Required)/(Optional)明示、例示追加
- V-04: validation 禁止パターン（length > 0 等）不使用
  - Problem: 不適切バリデーション・過度制約・柔軟性欠如
  - Impact: 正当な値拒否・エラー・運用困難
  - Recommendation: 適切条件式、ビジネスロジック妥当性検証
- V-05: 不要/未使用変数無
  - Problem: 未使用変数残留・デッドコード・ノイズ
  - Impact: 混乱・メンテナンスコスト増・可読性低下
  - Recommendation: 未使用変数削除、定期的クリーンアップ

### 4. outputs.tf (O)

- O-01: 各 output description 必須
  - Problem: 出力説明不足・用途不明・利用方法不明
  - Impact: 利用用途不明確化・連携困難・ドキュメント不足
  - Recommendation: 全 output`description`付与、用途・形式明記
- O-02: 機密情報出力禁止（ARN/ID 可、秘密値不可）
  - Problem: 機密情報平文出力・パスワード・トークン出力
  - Impact: ログ漏洩・セキュリティ侵害・コンプライアンス違反
  - Recommendation: `sensitive = true`設定、機密値出力回避、ARN/ID 出力許容
- O-03: 未参照 output 削除提案
  - Problem: 不要 output 定義・未使用出力・ノイズ
  - Impact: コード肥大化・可読性低下・保守負荷
  - Recommendation: 利用されない output 削除、必要時追加方針

### 5. tfvars (T)

- T-01: シークレット未記載（Secret Manager/SSM Parameter 誘導）
  - Problem: tfvars 内機密情報・パスワード・トークン記載
  - Impact: リポジトリ漏洩リスク・Git 履歴汚染・セキュリティ侵害
  - Recommendation: 外部シークレットストア参照（data source）、環境変数利用
- T-02: 環境別ファイル分離（dev/stg/qa/prd）
  - Problem: 環境設定混在・単一 tfvars ファイル・環境識別困難
  - Impact: 誤デプロイリスク・環境間汚染・運用ミス
  - Recommendation: 環境ごとファイル分割（dev.tfvars, prd.tfvars）、明確分離
- T-03: 他環境識別子混在禁止（アカウント ID/VPC ID 等）
  - Problem: 環境間設定混入・他環境 ID 誤記載
  - Impact: クロス環境汚染・意図しないリソース参照・セキュリティリスク
  - Recommendation: 環境固有値のみ記述、変数/locals 検証
- T-04: 環境名 prefix 誤混在禁止
  - Problem: 誤環境プレフィックス・命名不整合
  - Impact: リソース命名ミス・識別困難・運用混乱
  - Recommendation: 正しい環境プレフィックス確認、命名規則遵守

### 6. Security (SEC)

- SEC-01: KMS 暗号化（SNS/S3/Logs/StateMachines 等）
  - Problem: 暗号化欠如・平文データ保存・デフォルト暗号化未設定
  - Impact: データ漏洩リスク・コンプライアンス違反・監査失敗
  - Recommendation: CMK/AWS 管理キー暗号化有効化、kms_key_id 設定
- SEC-02: IAM 最小権限（"\*"最小限+理由提示）
  - Problem: 過剰権限付与・ワイルドカード（`*`）多用・最小権限違反
  - Impact: セキュリティ侵害時被害拡大・権限昇格・情報漏洩
  - Recommendation: 必要アクション/リソース限定、`*`使用時理由明記
- SEC-03: EventBridge→SNS 等 resource_policy に Condition（SourceArn 等）
  - Problem: リソースポリシー制限不足・Condition 欠如・オープンアクセス
  - Impact: 意図しないソースアクセス・不正利用・セキュリティリスク
  - Recommendation: `Condition`ブロック`SourceArn`/`SourceAccount`制限
- SEC-04: 平文シークレット禁止
  - Problem: コード内平文シークレット・ハードコード認証情報
  - Impact: 漏洩リスク・Git 履歴残存・セキュリティ侵害
  - Recommendation: Secrets Manager/SSM Parameter Store 利用、data source 参照
- SEC-05: Logging 設定適切（CloudTrail/CloudWatch Logs 等）
  - Problem: ログ設定不備・ログ出力無効・保持期間不適切
  - Impact: 監査不可・トラブルシューティング困難・コンプライアンス違反
  - Recommendation: 適切ログ出力/保持設定、CloudWatch Logs 統合

### 7. Tagging (TAG)

- TAG-01: Name 追加`merge(local.tags,{ Name = "..." })`形式
  - Problem: Name タグ個別設定・merge 関数未使用・タグ重複
  - Impact: 一貫性欠如・タグ管理困難・コスト配分不正確
  - Recommendation: `merge`関数共通タグ+個別 Name、統一形式
- TAG-02: 不要手動重複キー削除
  - Problem: 重複タグ定義・手動タグ記述・locals 未活用
  - Impact: コード冗長化・保守コスト増・不整合リスク
  - Recommendation: 共通タグ locals 利用、重複排除、DRY 原則

### 8. Events & Observability (E)

- E-01: EventBridge event_pattern 過剰キャッチ回避
  - Problem: 広すぎるイベントパターン・フィルタ不足
  - Impact: 不要起動・コスト増・ノイズ増加
  - Recommendation: 必要イベントのみフィルタリング、detail-type/source 絞込
- E-02: CloudWatch Log Group retention 設定
  - Problem: ログ保持期間未設定・無期限保存・デフォルト放置
  - Impact: ストレージコスト増大・ログ肥大化・管理困難
  - Recommendation: 適切`retention_in_days`設定（7/30/90/365 日）、要件整合
- E-03: アラーム/メトリクス/Dashboard 整合
  - Problem: 監視設定不整合・アラーム欠落・メトリクス未定義
  - Impact: 障害検知漏れ・運用困難・SLA 違反
  - Recommendation: リソース/監視設定同期、重要メトリクスアラーム設定
- E-04: Step Functions ログ出力レベル適切
  - Problem: 不適切ログレベル・ALL 設定・ログ過多または不足
  - Impact: デバッグ困難・ログコスト増・トラブルシュート遅延
  - Recommendation: 用途に合ったログレベル（OFF/ALL/ERROR/FATAL）、本番 ERROR 推奨

### 9. Versioning (VERS)

- VERS-01: `required_version`範囲プロジェクト標準準拠
  - Problem: Terraform バージョン不一致・範囲広すぎ・標準逸脱
  - Impact: 動作保証なし・チーム環境不整合・CI/CD 失敗
  - Recommendation: プロジェクト標準バージョン範囲指定、ドキュメント準拠
- VERS-02: provider version 範囲（>= lower,< upper）
  - Problem: プロバイダバージョン固定不足・上限未設定・破壊的変更リスク
  - Impact: 予期せぬ破壊的変更・動作停止・再現性欠如
  - Recommendation: 適切バージョン制約（`>= 4.0, < 5.0`）、上限設定
- VERS-03: 外部 module 固定（SHA/pseudo version 回避）
  - Problem: モジュールバージョン変動・SHA 直接指定・再現性欠如
  - Impact: 予期せぬ変更・ビルド不安定・デバッグ困難
  - Recommendation: タグバージョン固定（`?ref=v1.2.3`）、セマンティックバージョン

### 10. Naming & Docs (N)

- N-01: コメント英語（違反時指摘）
  - Problem: 日本語コメント混在・言語ポリシー違反
  - Impact: グローバルチーム協業困難・一貫性欠如
  - Recommendation: コメント英語記述、プロジェクトポリシー遵守
- N-02: Module 冒頭ヘッダー（目的/概要）
  - Problem: モジュール説明欠如・ファイル冒頭コメント無
  - Impact: 利用方法不明確・オンボーディング遅延・保守困難
  - Recommendation: ファイル冒頭概要ヘッダー追加（目的・概要・使用例）
- N-03: 重要リソース説明コメント
  - Problem: 複雑設定説明不足・意図不明・Why 欠如
  - Impact: 保守性低下・理解困難・変更リスク
  - Recommendation: 意図・理由コメント補足、複雑ロジック説明

### 11. CI & Lint (CI)

- CI-01: `plan`差分意図通り（無駄差分無）
  - Problem: 意図しない差分発生・ドリフト・設定不整合
  - Impact: 予期せぬ変更適用・リソース再作成・ダウンタイム
  - Recommendation: `plan`結果精査・差分解消・state 整合性確認
- CI-02: 新規リソース明確要件裏付け
  - Problem: 不要リソース作成・要件不明確・過剰プロビジョニング
  - Impact: コスト増・セキュリティリスク・管理負荷
  - Recommendation: 要件に基づき必要リソースのみ作成、正当化文書

### 12. Patterns (P)

- P-01: dynamic blocks 過剰回避
  - Problem: `dynamic`ブロック乱用・過度抽象化・ネスト深い
  - Impact: 可読性低下・複雑化・デバッグ困難
  - Recommendation: 必要最小限利用、静的記述優先、明確性重視
- P-02: for_each キー安定（map/object keys 明示）
  - Problem: 不安定キー使用・変更されやすい値・キー衝突
  - Impact: リソース再作成・予期せぬ削除・state 不整合
  - Recommendation: 変更されにくい一意値キー固定、ID または名前利用
- P-03: count = 0/1 トグル多段連鎖回避
  - Problem: 複雑条件分岐・count 連鎖・可読性低下
  - Impact: 理解困難・バグ温床・保守困難
  - Recommendation: ロジック簡素化・モジュール分割・条件整理

### 13. State & Backend (STATE)

- STATE-01: remote backend 暗号化(SSE)+DynamoDB ロック
  - Problem: State 保護不足・暗号化無効・ロック機構欠如
  - Impact: 競合・破損・情報漏洩リスク
  - Recommendation: S3 暗号化+DynamoDB ロック有効化、バージョニング設定
- STATE-02: backend 設定資格情報直接記載禁止
  - Problem: Backend 設定認証情報記述・アクセスキーハードコード
  - Impact: 漏洩リスク・セキュリティ侵害・Git 履歴汚染
  - Recommendation: 環境変数・IAM ロール・プロファイル利用
- STATE-03: workspace 不使用（方針明文化）
  - Problem: Workspace 不適切利用・環境分離曖昧
  - Impact: 環境混同・誤デプロイ・管理困難
  - Recommendation: ディレクトリ環境分離推奨、workspace 使用時方針明文化
- STATE-04: `terraform state`手動操作ドキュメント化
  - Problem: 手動操作ブラックボックス化・記録欠如
  - Impact: 運用リスク・再現不可・トラブルシュート困難
  - Recommendation: 操作手順/理由記録、変更履歴管理

### 14. Compliance & Policy (COMP)

- COMP-01: Organization/Security Hub 等ガバナンス意図整合
  - Problem: 組織ポリシー違反・ガバナンス不整合
  - Impact: コンプライアンス違反・監査失敗・セキュリティリスク
  - Recommendation: 組織ガバナンスルール準拠、ポリシー確認
- COMP-02: trivy 結果パイプライン統合
  - Problem: セキュリティチェック自動化不足・手動スキャン
  - Impact: 脆弱性混入・品質低下・本番リスク
  - Recommendation: パイプライン Trivy スキャン組込、ゲート設定
- COMP-03: デフォルト VPC/オープン SG/パブリック S3 禁止
  - Problem: 安全でないデフォルト設定・過度公開・セキュリティリスク
  - Impact: 攻撃対象拡大・情報漏洩・コンプライアンス違反
  - Recommendation: 明示的セキュア設定、最小公開原則、private 推奨
- COMP-04: IAM ポリシー jsonencode または aws_iam_policy_document 使用
  - Problem: 文字列連結ポリシー生成・JSON 手書き・構文エラーリスク
  - Impact: 構文エラー・可読性低下・保守困難
  - Recommendation: `jsonencode`または data source`aws_iam_policy_document`使用

### 15. Cost Optimization (COST)

- COST-01: 高コストメトリクス/retention 長期化回避
  - Problem: 不要コスト発生・過度保持期間・メトリクス過剰
  - Impact: 予算超過・無駄コスト・リソース浪費
  - Recommendation: 必要期間/メトリクスのみ保持、コスト最適化
- COST-02: 大量リソース生成 cost justification
  - Problem: 過剰リソースプロビジョニング・コスト見積不足
  - Impact: コスト増大・予算超過・ROI 低下
  - Recommendation: コスト対効果正当化、必要性検証、代替案検討
- COST-03: オプション（monitoring/xray/retention）デフォルト最小化
  - Problem: 不要オプション有効化・デフォルト全有効・コスト増
  - Impact: 無駄コスト・複雑化・管理負荷
  - Recommendation: 必要時のみオプション有効化、デフォルト最小構成

### 16. Performance & Limits (PERF)

- PERF-01: 大量 for_each/count plan 時間過多回避（分割検討）
  - Problem: Plan 実行時間増大・大量リソース一括処理・タイムアウト
  - Impact: 開発効率低下・CI/CD 遅延・運用困難
  - Recommendation: ステート分割・`-target`利用検討、リソースグルーピング
- PERF-02: Provider 呼出削減（data source locals/outputs 共有）
  - Problem: API コール過多・data source 重複・レート制限
  - Impact: レート制限抵触・実行遅延・API エラー
  - Recommendation: データキャッシュ/共有、locals 活用、data source 最小化
- PERF-03: CloudWatch イベント/アラーム過剰生成監視
  - Problem: アラーム乱立・イベント過多・管理不能
  - Impact: ノイズ増加・重要アラーム埋没・コスト増
  - Recommendation: 重要イベントのみ監視、アラーム統合・集約

### 17. Migration & Refactor (MIG)

- MIG-01: `moved`ブロックでリソース再作成回避
  - Problem: リファクタリング時リソース再作成・ダウンタイム発生
  - Impact: サービス停止・データ損失・ユーザー影響
  - Recommendation: `moved`ブロック state 移行、破壊的変更回避
- MIG-02: deprecated 置換
  - Problem: 非推奨機能使用・廃止予定 API・サポート終了
  - Impact: 将来的動作停止・セキュリティリスク・保守不可
  - Recommendation: 推奨代替機能置換、最新ドキュメント確認
- MIG-03: コメントアウトリソース不残存
  - Problem: コメントアウトコード・デッドコード・ノイズ
  - Impact: 可読性低下・混乱・メンテナンスコスト増
  - Recommendation: 不要コード削除、Git 履歴利用、クリーンアップ

### 18. Dependency & Ordering (DEP)

- DEP-01: `depends_on`最小限
  - Problem: `depends_on`多用・明示的依存過剰・並列処理阻害
  - Impact: 実行時間増・依存関係複雑化・保守困難
  - Recommendation: 暗黙的依存関係優先、必要最小限 depends_on
- DEP-02: 循環参照回避
  - Problem: リソース間循環依存・相互参照・デッドロック
  - Impact: 適用エラー・実行不可・設計問題
  - Recommendation: 設計見直し・依存解消・モジュール分割
- DEP-03: implicit dependency 明示化（bucket policy before replication 等）
  - Problem: 依存関係欠落・暗黙的依存未考慮・競合状態
  - Impact: 適用エラー・順序問題・リソース作成失敗
  - Recommendation: 必要に応じて明示的依存設定、順序制御

### 19. Data Sources & Imports (DATA)

- DATA-01: data source 再評価（静的値置換可能性）
  - Problem: 不要 data source 参照・静的値で代替可能
  - Impact: 外部依存・実行時間増・API コール無駄
  - Recommendation: 静的値代替可能性検討、必要時のみ data source
- DATA-02: import 手順 README/コメント記録
  - Problem: インポート経緯不明確・手順未記録
  - Impact: 管理困難・再現不可・ナレッジ損失
  - Recommendation: 手順ドキュメント化、コメント記録、変更履歴管理
- DATA-03: 外部 ID/ARN 変数化（アカウント間再利用性）
  - Problem: ID/ARN ハードコード・環境依存・移植性低下
  - Impact: 環境移植困難・マルチアカウント対応不可
  - Recommendation: 変数定義・tfvars 分離・環境非依存設計
- DATA-04: 不要 data source 削除
  - Problem: 未使用 data source・デッドコード・ノイズ
  - Impact: API コール無駄・実行時間増・可読性低下
  - Recommendation: 未使用 data source 削除、定期クリーンアップ

## Output Format

レビュー結果リスト形式、簡潔説明+推奨修正案。

**Checks**: 全項目表示、✅=Pass / ❌=Fail
**Issues**: 問題ありのみ表示

## Example Output

### ✅ All Pass

```markdown
# Terraform Review Result

## Issues

None ✅
```

### ❌ Issues Found

```markdown
# Terraform Review Result

## Issues

1. G-05 apply 後決定値 for_each 利用

   - Problem: for_each = aws_s3_bucket.example.tags
   - Impact: 計画差分不安定・並列適用リスク・`value depends on resource attributes...`エラー
   - Recommendation: 事前決定可能 map(var.enabled_buckets)等へ置換

2. SEC-03 EventBridge→SNS Policy Condition 欠落
   - Problem: sns:Publish Policy に SourceArn Condition 不在
   - Impact: 他アカウント/予期せぬイベントから Publish 可能・セキュリティリスク
   - Recommendation: Condition.StringEquals { aws:SourceArn = aws_cloudwatch_event_rule.example.arn } 追加
```
