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
