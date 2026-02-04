### 2. Code Standards (CODE)

**CODE-01: 配列適切利用**

Check: 空白含むパスや複数値が配列で管理されているか
Why: 文字列分割・引用符漏れでファイル名分割、予期しない引数展開
Fix: 配列で複数値管理、`"${array[@]}"`展開

**CODE-02: グローバル変数最小化**

Check: 関数内でlocal宣言が使用されているか
Why: グローバル変数多用で変数汚染、予期しない動作、デバッグ困難
Fix: 関数内local宣言、readonly定数、グローバル最小化

**CODE-03: Here document 適切利用**

Check: 複数行文字列にhere documentが使用されているか
Why: echo繰り返しでエスケープ複雑化、可読性低下、保守困難
Fix: `cat <<'EOF'`利用、ヒアドキュメント活用

**CODE-04: Process substitution 適切利用**

Check: 一時ファイル不要な箇所でprocess substitutionが使用されているか
Why: 不要な一時ファイル生成でファイルI/O増、クリーンアップ複雑化
Fix: `<(command)`、`>(command)`活用

**CODE-05: 関数単一責任・引数明示**

Check: 関数が単一責任で引数を明示的に受け取るか
Why: 複数責任混在・グローバル変数依存でテスト困難、再利用不可
Fix: 単一責任分割、引数で入力受取、グローバル依存最小化
