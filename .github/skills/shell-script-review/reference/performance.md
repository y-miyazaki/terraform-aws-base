### 6. Performance (PERF)

**PERF-01: 外部コマンド最小化**

Check: ループ内外部コマンドが最小化されBash組込機能が優先されているか
Why: ループ内外部コマンドで実行時間増、CPU負荷、スクリプト遅延
Fix: Bash組込機能優先、ループ外移動、一括処理

**PERF-02: サブシェル削減**

Check: 不要な`()`が削減され`{}`が使用されているか
Why: 不要サブシェルでメモリ消費、実行時間増、リソース浪費
Fix: `{}`利用、変数直接操作、サブシェル回避

**PERF-03: ファイル I/O 最適化**

Check: ファイルが一括読込されバッファリングが活用されているか
Why: ファイル複数回読込・行毎I/OでI/O待機時間、実行遅延
Fix: 一括読込、while read最適化、buffering活用

**PERF-04: ループ効率化**

Check: `while IFS= read -r`が使用され非効率ループが回避されているか
Why: `for in $(cat)`でメモリ消費、処理遅延、大ファイル処理不可
Fix: `while IFS= read -r`利用、効率的ループ

**PERF-05: 文字列処理最適化**

Check: Bash parameter expansionが活用されsed/awk濫用が回避されているか
Why: sed/awk濫用でプロセス生成コスト、実行時間増
Fix: Bash parameter expansion活用、組込機能優先

**PERF-06: 条件分岐最適化**

Check: early return・短絡評価が使用されネストが浅いか
Why: ネスト深い・重複判定で可読性低下、実行時間増
Fix: early return、`&&`/`||`短絡評価、case文活用

**PERF-07: 並列実行活用**

Check: 並列実行可能な処理で`&`・`xargs -P`が活用されているか
Why: 逐次処理で実行時間長、リソース活用不足、スループット低
Fix: バックグラウンド実行、`xargs -P`、wait管理

**PERF-08: キャッシュ戦略**

Check: 同一処理結果が変数保存されキャッシュされているか
Why: 同一処理繰返しで無駄な処理、実行時間増、リソース浪費
Fix: 結果変数保存、条件キャッシュ、重複削減

**PERF-09: リソース制限 (ulimit)**

Check: ulimitでリソース制限が設定されているか
Why: リソース無制限でメモリリーク、プロセス暴走、システムリソース枯渇
Fix: ulimit設定、リソース制限、防御的プログラミング

**PERF-10: プロファイリング**

Check: パフォーマンスボトルネックがset -x・timeで特定されているか
Why: ボトルネック不明で効果薄い最適化、リソース浪費
Fix: `set -x`trace、time測定、ボトルネック特定
