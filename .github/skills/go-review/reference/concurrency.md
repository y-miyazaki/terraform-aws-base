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
