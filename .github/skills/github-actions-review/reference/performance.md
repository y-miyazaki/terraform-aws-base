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
