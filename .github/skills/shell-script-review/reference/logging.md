### 10. Logging (LOG)

**LOG-01: log_message/echo_section 活用**

Check: log_message・echo_section関数が活用されているか
Why: echo直接出力でログフォーマット不統一、timestamp欠如、監視困難
Fix: log_message利用、echo_section区切り、プロジェクト標準遵守

**LOG-02: stdout/stderr 分離**

Check: エラーが>&2、情報がstdoutに明確分離されているか
Why: エラーメッセージstdout出力でエラー検知困難、ログ解析困難
Fix: エラーは`>&2`、情報はstdout、明確分離

**LOG-03: ログレベル実装**

Check: INFO・WARN・ERRORのログレベルが実装されているか
Why: ログレベルなしでログノイズ、重要ログ埋没、監視困難
Fix: INFO/WARN/ERRORレベル、log_message引数レベル指定

**LOG-04: 構造化ログ**

Check: timestamp・レベル・メッセージの構造化ログ形式か
Why: 非構造化ログでログ解析困難、時系列追跡不可
Fix: `[timestamp] [LEVEL] message`形式、構造化ログ

**LOG-05: 機密情報マスク**

Check: パスワード・トークンがログ出力前にマスクされているか
Why: 機密情報ログ出力で認証情報漏洩、セキュリティリスク
Fix: 機密変数`***`マスク、ログ出力前フィルタ

**LOG-06: echo_section セクション区切り**

Check: echo_sectionで処理単位の区切りがあるか
Why: セクション区切りなしでログ追跡困難、デバッグ困難
Fix: echo_section利用、処理単位区切り、視認性向上

**LOG-07: verbose 実装**

Check: -v/--verboseオプションで詳細ログ制御があるか
Why: デバッグログ本番出力でログ肥大化、重要ログ埋没
Fix: -v/--verboseオプション、条件的詳細ログ、レベル制御
