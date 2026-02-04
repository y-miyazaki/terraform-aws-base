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
