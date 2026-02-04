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
