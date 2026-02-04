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
