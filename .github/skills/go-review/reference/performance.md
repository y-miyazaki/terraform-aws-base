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
