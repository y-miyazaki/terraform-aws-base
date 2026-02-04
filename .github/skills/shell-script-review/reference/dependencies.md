### 9. Dependencies (DEP)

**DEP-01: lib/all.sh 活用**

Check: lib/all.shがsourceされ共通関数が利用されているか
Why: 共通ライブラリ未使用でコード重複、保守コスト増、品質ばらつき
Fix: lib/all.sh source、error_exit/log_message等共通関数利用

**DEP-02: validate_dependencies 利用**

Check: validate_dependencies関数が呼び出されているか
Why: 必須コマンド未確認でスクリプト途中失敗、ユーザー困惑
Fix: validate_dependencies呼出、必須コマンド明示

**DEP-03: 必須コマンド明示**

Check: READMEに依存コマンドが明示されているか
Why: 依存コマンド不明で実行失敗、環境構築困難、オンボーディング遅延
Fix: README依存記載、validate_dependencies実装

**DEP-04: コマンド存在確認**

Check: command -vで存在確認され明確なエラーメッセージがあるか
Why: コマンド存在確認なしで実行時エラー、エラーメッセージ不明瞭
Fix: command -v確認、明確エラーメッセージ、インストール手順提示
