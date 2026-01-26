---
name: go-review
description: Go code review for correctness, security, performance, and best practices. Use for manual review of Go code checking design decisions and patterns requiring human judgment.
license: MIT
---

# Go Code Review

This skill provides comprehensive guidance for reviewing Go code to ensure correctness, security, performance, and best practices compliance.

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on Go pull requests
- Checking Go code before merging
- Ensuring security and compliance standards
- Validating best practices adherence
- Architecture and design review

## Important Notes

- **Automation First**: Lint and auto-checkable items (syntax errors, import ordering, naming conventions, function length, complexity, DRY violations, magic numbers, error checks, vulnerabilities, coverage, go.sum consistency, unused dependencies) are excluded as they should be caught by pre-commit/CI/CD.
- **Manual Review Focus**: This skill focuses on design decisions, security patterns, and architectural issues that require human judgment.
- **Go Idioms**: Reviews emphasize Go-specific best practices and idiomatic patterns.

## Output Language

**IMPORTANT**: レビュー結果はすべて日本語で出力。ただし以下は英語：

- ファイルパス、コードスニペット、技術識別子（関数名、変数名、型名、パッケージ名など）

## Review Process

### Step 1: Verify Automated Checks

Confirm scripts/go/validate.sh has passed before manual review:

- `go fmt` formatting
- `golangci-lint` static analysis
- `go test` with race detection
- Coverage requirements

### Step 2: Systematic Review by Category

Review code systematically using priority levels:

- **🔴 Critical**: G, CTX, CON, ERR, SEC (security, correctness, concurrency)
- **🟡 Important**: CODE, FUNC, PERF, TEST (quality, performance, testability)
- **🟢 Enhancement**: ARCH, DOC, DEP (architecture, documentation, dependencies)

### Step 3: Report Issues with Recommendations

Document issues using Check+Why+Fix format with actionable recommendations.

## Review Guidelines

### 1. Global / Base (G)

**G-01: 機密情報ハードコーディング禁止**

Check: API Key・パスワード・トークンがソースコードに埋め込まれていないか
Why: 機密情報埋め込みでセキュリティ侵害、認証情報漏洩、監査違反
Fix: 環境変数・AWS Secrets Manager利用、定数削除

**G-02: 関数シグネチャ適切**

Check: 引数数（4個以上）・戻り値型・bool戻り値多用が適切か
Why: 引数過多・戻り値不明瞭でAPI誤用、可読性低下、保守コスト増大
Fix: 引数構造体化、named return回避、error戻り値最後配置

**G-03: 標準ライブラリ活用**

Check: 標準ライブラリで実装可能な機能に外部依存していないか
Why: 不要な外部依存で脆弱性リスク、依存増加、保守負荷増大
Fix: net/http・encoding/json等標準ライブラリ優先検討

**G-04: ログ出力適切レベル**

Check: Debug/Info/Warn/Errorレベルが適切か、構造化ログ使用か
Why: ログレベル混在・非構造化でトラブルシューティング困難、監視不全
Fix: 構造化ログライブラリ（zap/zerolog）利用、レベル統一、機密情報マスク

**G-05: 宣言順序（ファイルレベル）**

Check: const→var→type（interface→struct）→func（constructor→methods→helpers）順か
Why: 宣言順不統一で可読性低下、レビュー時見落としリスク増加
Fix: ファイルレベルでconst→var→type→func順維持

**G-06: 宣言順序（グループ内順序）**

Check: 各グループ内がA→Zアルファベット順か（推奨）
Why: 同カテゴリ内ばらつきで差分追跡困難、不整合、可読性低下
Fix: グループ内A→Z順（推奨）、関連宣言グループ化許容

### 2. Context Handling (CTX)

**CTX-01: public APIでcontext受け取り**

Check: public関数・メソッドがcontext.Contextを第1引数で受け取るか
Why: context未使用でタイムアウト制御不可、キャンセル伝播不可、テスト困難
Fix: 全public API第1引数にcontext.Context追加、ctx変数名統一

**CTX-02: context.Background()/TODO()乱用回避**

Check: context.Background()多用・context.TODO()放置がないか
Why: Background乱用でタイムアウト・キャンセル伝播せず、グレースフルシャットダウン不可
Fix: main/init以外でBackground回避、受け取ったcontext伝播、TODO一時的のみ

**CTX-03: goroutineへcontext伝播**

Check: goroutine起動時にcontextが渡されているか
Why: context未渡しでgoroutineリーク、キャンセル伝播なし、リソース枯渇
Fix: goroutine起動時必ずcontext渡す、context.Done()監視

**CTX-04: cancel適切呼び出し**

Check: WithCancel/WithTimeoutのcancelがdefer呼び出されているか
Why: cancel未呼出でリソースリーク、goroutineリーク、メモリ増加
Fix: defer cancel()必須、WithTimeoutでもdefer推奨

### 3. Concurrency (CON)

**CON-01: goroutine leak回避**

Check: goroutineが適切に終了するか、context.Done()を監視しているか
Why: goroutine未終了でメモリリーク、リソース枯渇、性能劣化
Fix: 終了条件明確化、context.Done()監視、WaitGroup利用、pprofで確認

**CON-02: channel close責務明確化**

Check: channelのclose責務が送信側にあるか
Why: 受信側close・複数close・close忘れでpanic、goroutineリーク、デッドロック
Fix: 送信側がclose責務、受信側close禁止、deferでclose、1回のみ

**CON-03: buffered/unbuffered channel適切選択**

Check: buffered/unbufferedの選択が適切か、サイズに根拠があるか
Why: サイズ不適切でデッドロック、性能低下、goroutineブロック
Fix: ユースケース応じた選択、bufferedサイズ根拠明示、非同期はbuffered推奨

**CON-04: sync primitives適切利用**

Check: sync.Mutex/RWMutex/WaitGroup/atomicが適切に使用されているか
Why: Mutexコピー・誤用・WaitGroup負値で競合状態、デッドロック、data race
Fix: Mutexポインタ渡し、読取多用時RWMutex、WaitGroup対応、atomic活用

**CON-05: for+goroutine変数キャプチャ問題**

Check: ループ変数をgoroutineで直接参照していないか
Why: 変数キャプチャ未実施で全goroutineが同じ値参照、予期しない動作
Fix: ループ変数ローカルコピー、関数引数渡し（Go 1.22+は自動解決確認）

**CON-06: data race検出・防止**

Check: go test -race実行しているか、共有メモリにsync保護があるか
Why: data race検出未実施でデータ破損、予期しない動作、本番限定不具合
Fix: CI/CDでgo test -race必須、共有状態sync保護、可能な限りchannel利用

### 4. Code Standards (CODE)

**CODE-01: インターフェース適切設計**

Check: インターフェースメソッド数（5個以上）・消費側定義されているか
Why: メソッド過多・実装側定義でモック困難、テスト負荷、柔軟性低下
Fix: 小さなインターフェース（1-3メソッド）、consumer-side interface

**CODE-02: API/パッケージ境界設計**

Check: export過多・package名責務不明・internal/未活用がないか
Why: export過多でAPI表面積大、保守困難、破壊的変更リスク
Fix: 公開API最小化、package名に責務表現、internal/で内部実装隠蔽

**CODE-03: 構造体適切設計**

Check: 公開field・mutex公開・フィールド数過多（20個以上）がないか
Why: field公開でカプセル化破壊、競合状態、可読性低下
Fix: field非公開化、getter/setter追加、構造体分割

**CODE-04: 型アサーション安全**

Check: 型アサーションにokチェックがあるか（v, ok := i.(string)形式）
Why: okチェック無しでpanic発生、アプリケーション停止
Fix: v, ok := i.(string); if !ok {...}形式使用

**CODE-05: defer適切利用**

Check: ループ内deferがないか、リソース解放が適切か
Why: ループ内deferでメモリリーク、ファイルディスクリプタ枯渇
Fix: ループ外defer、即時Close()、値コピー

**CODE-06: slice・map適切操作**

Check: nilチェック・範囲外アクセス防止・map競合状態対策があるか
Why: nilチェック無し・範囲外アクセスでpanic、map競合でデータ破損
Fix: lenチェック、nilチェック、sync.Mapまたはsync.RWMutex利用

### 5. Function Design (FUNC)

**FUNC-01: 関数分割適切**

Check: 単一関数内に複数責任混在・ビジネスとインフラ層混在がないか
Why: 複数責任混在でテスト困難、再利用不可、保守コスト増
Fix: 単一責任原則適用、レイヤー分離、ヘルパー関数抽出

**FUNC-02: 引数設計適切**

Check: 位置引数過多・bool引数多用がないか、オプション対応は適切か
Why: 引数過多・bool多用で呼び出し側誤用、拡張困難
Fix: Functional Options Pattern利用、構造体引数化

**FUNC-03: 戻り値設計**

Check: named return最小化・error最後配置・多値返却適切か
Why: named return多用・error位置不統一でエラーハンドリング漏れ、API不整合
Fix: named return最小化、error最後配置、戻り値2-3個以内

**FUNC-04: 純粋関数推奨**

Check: グローバル変数参照・副作用混在・非決定的動作がないか
Why: 副作用混在でテスト困難、並列実行不可、予測不能
Fix: 引数で全入力受取、副作用分離、依存性注入

**FUNC-05: レシーバー設計適切**

Check: ポインタ/値レシーバー混在・大きな値レシーバーがないか
Why: レシーバー混在でコピーコスト、変更反映されない、可読性低下
Fix: ポインタレシーバー原則、レシーバー名1-2文字統一

**FUNC-06: メソッドセット設計**

Check: 関連性低いメソッド混在・God Object化・責任範囲不明確がないか
Why: メソッド混在で保守困難、テスト範囲肥大、理解コスト増
Fix: 凝集度高いメソッドセット、型分割、インターフェース分離

**FUNC-07: 初期化関数適切**

Check: New関数がエラー処理・バリデーション実装しているか
Why: エラー処理無しで不正状態オブジェクト、初期化失敗検知不可
Fix: NewXxx()でエラー返却、バリデーション実装、Must関数分離

**FUNC-08: 高次関数活用**

Check: コールバック・関数ポインタが適切に活用されているか
Why: コールバック未使用で拡張性低下、重複コード、柔軟性欠如
Fix: 戦略パターン適用、Functional Options、コールバック活用

**FUNC-09: ジェネリクス適切利用**

Check: interface{}多用・不要なジェネリクスがないか
Why: interface{}多用で型安全性欠如、過度なジェネリクスで複雑度増加
Fix: 型パラメータ適切使用、constraint定義、過度な抽象化回避

**FUNC-10: 関数ドキュメント充実**

Check: 全公開関数にgodoc・引数戻り値説明があるか
Why: godoc未記載でAPI理解困難、誤用増加、保守負荷
Fix: 全公開関数godoc、引数・戻り値・エラー条件明記

### 6. Error Handling (ERR)

**ERR-01: エラーラップ適切**

Check: fmt.Errorf("%w", err)でエラーラップしているか、コンテキスト情報があるか
Why: エラー文字列のみ返却でデバッグ困難、スタックトレース欠如、根本原因不明
Fix: fmt.Errorf("%w", err)でラップ、コンテキスト情報追加

**ERR-02: カスタムエラー適切定義**

Check: sentinel error定義・errors.Is/As対応カスタムエラーがあるか
Why: 文字列エラーのみでエラー処理分岐困難、リトライ判定不可
Fix: errors.Is/As対応カスタムエラー定義、sentinel error定義、errors.Is判定

**ERR-03: パニック回避・復旧**

Check: panicが致命的エラーのみか、defer+recover実装があるか
Why: panic多用・recover未実装でアプリケーション突然終了、データ不整合
Fix: panic致命的エラーのみ、defer+recover実装、通常エラーはerror返却

**ERR-04: ログエラー情報適切**

Check: エラーログレベル統一・スタックトレース記録・機密情報マスクがあるか
Why: ログレベル不統一・機密情報含有で障害解析困難、セキュリティリスク
Fix: Error/Warnレベル統一、スタックトレース記録、機密情報マスク

**ERR-05: 上位層エラー伝播**

Check: エラー握り潰しがないか、エラーコンテキスト保持されているか
Why: エラー握り潰しで障害検知不可、根本原因追跡不可
Fix: エラー必ず返却、コンテキスト保持してラップ、適切なログ記録

**ERR-06: エラーハンドリング戦略**

Check: エラー分類定義・リトライロジック・Fail Fast実装があるか
Why: エラー処理方針不統一でリトライ欠如、障害拡大、復旧遅延
Fix: エラー分類定義、リトライ可能エラー識別、Circuit Breaker実装

**ERR-07: 外部依存エラー処理**

Check: タイムアウト設定・リトライ実装・エラー分類があるか
Why: タイムアウト未設定・リトライ未実装で無限待機、障害伝播
Fix: context timeout設定、exponential backoff、一時/恒久エラー分類

**ERR-08: バリデーションエラー**

Check: 入力検証・フィールド単位エラー・ユーザーフレンドリーメッセージがあるか
Why: 入力検証不足・エラーメッセージ不明瞭でサポートコスト増、ユーザー困惑
Fix: struct tagバリデーション実装、フィールド単位エラー、明確なメッセージ

**ERR-09: エラーメッセージセキュリティ**

Check: 内部実装露出・スタックトレース外部公開・SQL文露出がないか
Why: 内部情報露出で情報漏洩、攻撃手がかり提供、セキュリティリスク
Fix: ユーザー向けメッセージと内部ログ分離、詳細情報非公開

### 7. Security (SEC)

**SEC-01: 入力値検証**

Check: 入力値バリデーション・prepared statement・サニタイズ実装があるか
Why: 入力値無検証・SQL文字列連結でSQL injection・XSS攻撃、データ改ざん
Fix: prepared statement必須、バリデーション実装、サニタイズ実装

**SEC-02: 出力値サニタイズ**

Check: HTMLエスケープ・JSONインジェクション対策・CRLF injection対策があるか
Why: エスケープ未実装でXSS脆弱性、レスポンス改ざん、セッションハイジャック
Fix: html/template利用、出力コンテキスト応じたエスケープ

**SEC-03: 暗号化適切**

Check: TLS 1.2以上・AES-256-GCM・crypto/rand使用されているか
Why: 平文通信・弱い暗号化で盗聴、中間者攻撃、データ漏洩
Fix: TLS 1.2以上必須、AES-256-GCM利用、crypto/rand使用

**SEC-04: 認証・認可実装**

Check: 全エンドポイント認証・JWT署名検証・RBAC実装があるか
Why: 認証スキップ・検証不足で不正アクセス、権限昇格、データ漏洩
Fix: 全エンドポイント認証必須、JWT署名検証、RBAC実装

**SEC-05: レート制限・DOS対策**

Check: rate limiter・タイムアウト設定・リクエストサイズ制限があるか
Why: リクエスト制限無しでDOS攻撃、サービス停止、リソース枯渇
Fix: rate limiter実装、タイムアウト設定、リクエストサイズ制限

**SEC-06: ログセキュリティ**

Check: 機密情報マスク関数・パスワード/トークンマスクがあるか
Why: パスワード・トークンログ出力で認証情報漏洩、GDPR違反
Fix: 機密情報マスク関数実装、構造化ログ、ログローテーション

**SEC-07: 安全デフォルト値**

Check: 最小権限原則・本番環境debug無効・明示的CORS設定があるか
Why: セキュアでないデフォルトでセキュリティ侵害、攻撃成功率上昇
Fix: 最小権限原則、本番環境debug無効、明示的CORS設定

**SEC-08: OWASP準拠**

Check: OWASP Top 10対応・Security Headers設定・CSP設定があるか
Why: OWASP未対応で既知脆弱性放置、攻撃リスク増大
Fix: OWASP Top 10チェック、Security Headers設定、定期診断

### 8. Performance (PERF)

**PERF-01: メモリ最適化**

Check: slice capacity事前確保・map初期容量指定・sync.Pool活用があるか
Why: 再割当頻発・初期容量未指定でGC負荷増、メモリ使用量増大
Fix: make([]T, 0, cap)事前確保、sync.Pool活用、pprof解析

**PERF-02: CPU最適化**

Check: O(n²)アルゴリズム・不要な計算・ループ内重複処理がないか
Why: 非効率アルゴリズムでレスポンス遅延、CPU使用率高、スループット低下
Fix: アルゴリズム見直し、計算結果キャッシュ、ベンチマーク測定

**PERF-03: I/O最適化**

Check: bufio利用・connection pool実装・適切なバッファサイズか
Why: 非buffered I/O・接続都度生成でI/O待機時間増、レイテンシ増加
Fix: bufio利用、connection pool実装、適切なバッファサイズ

**PERF-04: データ構造選択適切**

Check: map/set活用・適切なインデックス・データ構造最適化されているか
Why: 不適切なデータ構造・線形探索多用で検索時間増、処理速度低下
Fix: map/set活用、適切なインデックス、データ構造最適化

**PERF-05: GC配慮**

Check: allocation削減・値型活用・sync.Pool利用があるか
Why: 大量allocation・ポインタ多用でGC pause増加、レイテンシ悪化
Fix: allocation削減、値型活用、sync.Pool利用、pprof heap解析

**PERF-06: 文字列処理最適化**

Check: strings.Builder利用・bytes.Buffer活用・文字列連結最小化されているか
Why: string連結（+演算子）・bytes変換頻発でメモリ使用量増、処理速度低下
Fix: strings.Builder利用、bytes.Buffer活用、文字列連結最小化

**PERF-07: 並列処理最適化**

Check: worker pool実装・GOMAXPROCS考慮・buffered channel利用があるか
Why: goroutine無制限生成・並列度未調整でコンテキストスイッチ増、メモリ枯渇
Fix: worker pool実装、GOMAXPROCS考慮、buffered channel利用

**PERF-08: キャッシュ戦略**

Check: キャッシュ実装・TTL設定・LRU/LFU戦略があるか
Why: キャッシュ未実装・TTL未設定でDB負荷高、スケーラビリティ低下
Fix: Redis/in-memory cache実装、TTL設定、LRU/LFU戦略

**PERF-09: pprof活用**

Check: 定期的pprof計測・CPU/memory/goroutine profile解析があるか
Why: プロファイリング未実施でボトルネック不明、推測最適化、問題見逃し
Fix: 定期的pprof計測、profile解析、継続監視

**PERF-10: Hot path最適化**

Check: クリティカルパス特定・高頻度処理最適化・before/after測定があるか
Why: hot path未特定・高頻度処理最適化不足で全体パフォーマンス低下
Fix: hot path特定、優先度付け最適化、before/after測定

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

### 10. Architecture (ARCH)

**ARCH-01: レイヤー分離**

Check: handler/usecase/repository分離・ビジネスとインフラ層分離されているか
Why: ビジネスロジックとインフラ層混在でテスト困難、技術スタック変更困難
Fix: Clean Architecture適用、handler/usecase/repository分離

**ARCH-02: 依存性注入**

Check: コンストラクタ注入・wire/dig活用・インターフェース依存があるか
Why: グローバル変数依存・ハードコーディング依存でモック不可、並列テスト不可
Fix: コンストラクタ注入、wire/dig活用、インターフェース依存

**ARCH-03: ドメイン駆動設計**

Check: 集約ルート定義・Value Object活用・Repository抽象化があるか
Why: 貧血ドメインモデル・ビジネスロジック散在で整合性保証困難
Fix: 集約ルート定義、Value Object活用、Repository抽象化

**ARCH-04: SOLID原則**

Check: SRP/OCP/LSP/ISP/DIP適用・インターフェース分離・抽象化されているか
Why: 単一責任違反・依存関係逆転なしで変更影響範囲拡大、拡張困難
Fix: SOLID原則適用、インターフェース分離、抽象化

**ARCH-05: パッケージ構成適切**

Check: 循環依存なし・標準layout準拠・internal/活用されているか
Why: 循環依存・パッケージ肥大化でビルド困難、理解困難
Fix: 依存方向制御、標準layout準拠、internal/活用

**ARCH-06: 設定管理統一**

Check: viper/envconfig利用・config構造体集約・環境変数優先されているか
Why: 設定値散在・環境別設定未分離で設定漏れ、環境間不整合
Fix: viper/envconfig利用、config構造体集約、環境変数優先

**ARCH-07: ログ管理統一**

Check: zap/zerolog統一・structured logging・trace ID伝播があるか
Why: ログライブラリ混在・フォーマット不統一でログ解析困難、監視困難
Fix: zap/zerolog統一、structured logging、trace ID伝播

**ARCH-08: エラー管理統一**

Check: エラーパッケージ集約・エラーコード体系定義・標準化されているか
Why: エラーハンドリング方針不統一・エラーコード未定義で運用困難
Fix: エラーパッケージ集約、エラーコード体系定義、標準化

**ARCH-09: 外部連携抽象化**

Check: アダプタパターン・インターフェース定義・抽象化層実装があるか
Why: 外部API直接呼出・抽象化層なしでベンダーロックイン、テスト困難
Fix: アダプタパターン、インターフェース定義、抽象化層実装

**ARCH-10: モジュール設計**

Check: 境界明確化・疎結合・高凝集・公開API最小化されているか
Why: モジュール境界不明確・過度な凝集/結合で変更影響大、スケール困難
Fix: 境界明確化、疎結合・高凝集、公開API最小化

### 11. Documentation (DOC)

**DOC-01: パッケージドキュメント存在**

Check: package docコメント・パッケージ目的・使用方法記載があるか
Why: package docコメント欠如でAPI理解困難、誤用増加、オンボーディング遅延
Fix: package docコメント追加、目的・責任・使用例記載

**DOC-02: godoc公開関数ドキュメント**

Check: 全公開API godoc記載・引数戻り値エラー条件明記があるか
Why: 公開関数コメントなし・説明不足でAPI使用方法不明、誤用
Fix: 全公開API godoc記載、引数・戻り値・エラー条件明記

**DOC-03: 複雑ロジックコメント**

Check: Why重視コメント・アルゴリズム説明・前提条件明記があるか
Why: アルゴリズム説明なし・前提条件不明で理解困難、バグ混入
Fix: Why重視コメント、アルゴリズム説明、前提条件明記

**DOC-04: 構造体フィールドコメント**

Check: 各フィールドコメント・制約デフォルト値必須性明記があるか
Why: フィールド目的不明・制約条件不明で誤用、バリデーション漏れ
Fix: 各フィールドコメント、制約・デフォルト値・必須性明記

**DOC-05: 定数・変数説明**

Check: 定数/変数コメント・単位制約理由記載があるか
Why: magic number・定数目的不明で意図不明、変更影響不明
Fix: 定数/変数コメント、単位・制約・理由記載

**DOC-06: 英語コメント統一**

Check: 英語統一・文法チェック・簡潔明瞭な記述か
Why: 日英混在・文法誤りで可読性低下、国際化困難
Fix: 英語統一、文法チェック、簡潔明瞭な記述

**DOC-07: README.md整備**

Check: 目的前提セットアップ使用例貢献方法記載があるか
Why: README不足・セットアップ手順不明でオンボーディング遅延、誤った使用
Fix: 目的・前提・セットアップ・使用例・貢献方法記載

**DOC-08: API仕様書（OpenAPI）**

Check: OpenAPI 3.0記述・swag利用・自動生成検証があるか
Why: API仕様書なし・エンドポイント不明でフロントエンド開発困難、API誤用
Fix: OpenAPI 3.0記述、swag利用、自動生成・検証

**DOC-09: 運用ドキュメント**

Check: デプロイ手順・監視項目・障害対応手順・ログ解析方法記載があるか
Why: 運用手順不明・トラブルシュート情報なしで運用困難、障害対応遅延
Fix: 運用ドキュメント整備、デプロイ・監視・障害対応・ログ解析記載

**DOC-10: CHANGELOG**

Check: Keep a Changelog形式・セマンティックバージョニング・破壊的変更明記があるか
Why: 変更履歴なし・破壊的変更不明で影響範囲不明、アップグレード困難
Fix: Keep a Changelog形式、セマンティックバージョニング、破壊的変更明記

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

## Output Format

### Checks

List all review items with Pass/Fail status:

```
- G-01 機密情報ハードコーディング禁止: ✅ Pass
- CTX-01 public APIでcontext受け取り: ❌ Fail
...
```

### Issues

Document only failed items with:

1. **項目ID+項目名**
   - Problem: 問題説明
   - Impact: 影響範囲・重要度
   - Recommendation: 具体的修正案

### Examples

#### ✅ All Pass

```markdown
# Go Review Result

## Checks

- G-01 機密情報ハードコーディング禁止: ✅ Pass
- CTX-01 public APIでcontext受け取り: ✅ Pass
  ...

## Issues

None ✅
```

#### ❌ Issues Found

```markdown
# Go Review Result

## Checks

- G-01 機密情報ハードコーディング禁止: ✅ Pass
- CTX-01 public APIでcontext受け取り: ❌ Fail
- ERR-01 エラーラップ適切: ❌ Fail
  ...

## Issues

1. CTX-01 public APIでcontext受け取り
   - Problem: ProcessData関数がcontext.Contextを受け取っていない
   - Impact: タイムアウト制御不可、キャンセル伝播不可、テスト困難
   - Recommendation: `func ProcessData(ctx context.Context, data []byte) error` に変更

2. ERR-01 エラーラップ適切
   - Problem: エラー文字列のみ返却、スタックトレース欠如
   - Impact: デバッグ困難、エラー発生箇所特定不可
   - Recommendation: `fmt.Errorf("failed to process: %w", err)` でラップ
```
