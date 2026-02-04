### 3. Function Design (FUNC)

**FUNC-01: 関数 50 行以下推奨**

Check: 関数が50行以下か
Why: 100行以上の関数で可読性低下、テスト困難、保守困難
Fix: ヘルパー関数抽出、単一責任原則、50行以内推奨

**FUNC-02: parse_arguments 標準化**

Check: parse_argumentsがgetopts・case文で標準化されているか
Why: 引数解析ロジック重複・不統一でオプション追加困難、バグ混入
Fix: getopts利用、case文標準パターン、-h|--help対応

**FUNC-03: show_usage 実装**

Check: show_usage関数がUsage/Options/Examplesを含みexit 0か
Why: ヘルプ未実装でユーザビリティ低下、問い合わせ増、誤用
Fix: show_usage関数実装、Usage/Options/Examples記載、exit 0

**FUNC-04: 戻り値設計**

Check: 関数がreturn code・echo出力で戻り値を適切に設定しているか
Why: 戻り値未設定でエラーハンドリング不可、条件分岐不可、障害検知不可
Fix: return 0/1設定、echo出力、`|| error_exit`利用

**FUNC-05: 共通ライブラリ活用**

Check: lib/all.shの共通関数が活用されているか
Why: コード重複・エラー処理不統一で保守コスト増、不整合、品質低下
Fix: lib/all.sh関数利用、プロジェクト標準遵守

**FUNC-06: validate_dependencies 関数**

Check: 必須コマンド存在確認がvalidate_dependencies関数で実装されているか
Why: 必須コマンド未確認でスクリプト途中失敗、ユーザー困惑
Fix: validate_dependencies実装、command -v確認、明確エラー

**FUNC-07: main 関数実装**

Check: main関数が実装されグローバルスコープ処理が最小化されているか
Why: グローバルスコープ処理で構造不明確、デバッグ困難、ユニットテスト不可
Fix: main関数実装、`main "$@"`呼出、構造化
