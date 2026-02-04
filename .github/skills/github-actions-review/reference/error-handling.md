### 2. Error Handling (ERR)

**ERR-01: continue-on-error の慎重利用**

Check: `continue-on-error`使用が根拠明示され限定的か
Why: `continue-on-error`多用で隠れた失敗の見落とし
Fix: 使用は限定的、根拠コメント明示

**ERR-02: 失敗時の後処理の準備**

Check: 失敗時の後処理（ログ収集・クリーンアップ）が整備されているか
Why: 失敗時の後処理未整備で解析困難、リソース残留
Fix: `if: failure()`でログ・アーティファクト収集とクリーンアップ

**ERR-03: 障害通知の統合**

Check: 重要ジョブ失敗時の通知が設定されているか
Why: 障害通知未整備で失敗の見逃し、対応遅延
Fix: Slack/Email通知導入、重要度別集約

**ERR-04: ジョブタイムアウトの設定**

Check: 各ジョブに適切な`timeout-minutes`が設定されているか
Why: タイムアウト未設定でランナー浪費、CI停滞
Fix: 適切な`timeout-minutes`設定
