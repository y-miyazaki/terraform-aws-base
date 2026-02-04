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
