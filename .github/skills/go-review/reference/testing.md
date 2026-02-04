### 9. Testing (TEST)

**TEST-01: テーブル駆動テスト**

Check: []struct形式テーブル駆動・subtests利用・エッジケース網羅されているか
Why: テストケース重複・Go イディオム違反でテスト漏れ、保守コスト増
Fix: []struct形式テーブル駆動、subtests利用、エッジケース網羅

**TEST-02: testify利用・テスト設計**

Check: assert/require適切利用・testable API設計・time/rand注入されているか
Why: testify過度依存・testable でないAPI・time/randomness直接使用で外部依存増、テスト不安定
Fix: testify依存プロジェクト方針決定、テスト可能性考慮、time.Now/randインターフェース注入

**TEST-03: モック適切利用**

Check: gomock/testify mock利用・インターフェース分離・依存性注入があるか
Why: 外部依存実呼出でテスト不安定、実行時間長、本番影響
Fix: gomock/testify mock利用、インターフェース分離、依存性注入

**TEST-04: テストヘルパー分離**

Check: testing_test.go分離・共通ヘルパー関数・fixture管理があるか
Why: テストコード重複・setup/teardown散在で保守困難、テスト追加コスト増
Fix: testing_test.go分離、共通ヘルパー関数、fixture管理

**TEST-05: ベンチマークテスト**

Check: Benchmark関数・benchstat比較・CI組込があるか
Why: パフォーマンス回帰検知不可・最適化効果不明でパフォーマンス劣化
Fix: \*\_test.go内Benchmark関数、benchstat比較、CI組込

**TEST-06: 統合テスト分離**

Check: build tag分離・// +build integration・並列実行設定があるか
Why: ユニット/統合テスト混在・実行時間長でCI/CD遅延、フィードバック遅延
Fix: build tag分離、// +build integration、並列実行設定

**TEST-07: テストデータ管理**

Check: testdata/ディレクトリ活用・factory パターン・Golden File Testingがあるか
Why: テストデータハードコード・fixture未管理でテスト脆弱性、データ不整合
Fix: testdata/ディレクトリ活用、factory パターン、Golden File Testing

**TEST-08: テスト並列実行効率**

Check: t.Parallel()使用・-race -parallel指定・並列安全実装があるか
Why: t.Parallel()未使用・テスト実行時間長でCI時間増、開発速度低下
Fix: t.Parallel()追加、-race -parallel指定、並列安全実装
