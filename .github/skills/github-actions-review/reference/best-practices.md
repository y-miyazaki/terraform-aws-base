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
