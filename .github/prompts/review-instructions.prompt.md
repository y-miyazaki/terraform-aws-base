# Review Instructions for \*.instructions.md Files

## Objective

`.github/instructions/*.instructions.md`ファイルの品質・統一性・実用性確保。

## Review Checklist

### 1. File Structure (G: General)

- G-01: Front Matter
  - Problem: Front Matter 欠如
  - Impact: 自動処理不全
  - Recommendation: `applyTo` と `description` の明記
- G-02: Language Policy
  - Problem: 言語ポリシー未記載
  - Impact: 表記不整合
  - Recommendation: "言語ポリシー: ドキュメント日本語、コード・コメント英語" の追記
- G-03: Title
  - Problem: タイトル不明瞭
  - Impact: ファイル用途判別困難
  - Recommendation: 目的が明確なタイトル付与

### 2. Chapter Structure (STRUCT: Structure)

必須章構成（順序厳守）:

```markdown
## Standards

## Guidelines

## Testing and Validation

## Security Guidelines
```

チェック項目:

- STRUCT-01: 4 つの必須章が全て存在
  - Problem: 必須章欠落
  - Impact: 情報欠損
  - Recommendation: Standards/Guidelines/Testing and Validation/Security Guidelines の整備
- STRUCT-02: 章順序の統一
  - Problem: 章順序不統一
  - Impact: 検索性低下
  - Recommendation: 指定順序へ統一
- STRUCT-03: 見出しレベル適切
  - Problem: 見出し階層不適切
  - Impact: 可読性低下
  - Recommendation: H2/H3 階層規則の適用

### 3. Standards Chapter (STD: Standards)

- STD-01: Naming Conventions
  - Problem: 命名規則未整備
  - Impact: コード一貫性欠如
  - Recommendation: コンポーネント別命名表の追加
- STD-02: Tool Standards
  - Problem: ツール規約不足
  - Impact: 自動検証不能
  - Recommendation: 対象ツールの標準規約追記
- STD-03: Consistency
  - Problem: ファイル間不整合
  - Impact: 学習コスト増大
  - Recommendation: 記載レベルの統一

### 4. Guidelines Chapter (GUIDE: Guidelines)

必須サブセクション:

- GUIDE-01: Documentation and Comments
  - Problem: ドキュメント規約不足
  - Impact: 保守困難
  - Recommendation: コメント・ドキュメント規約明記
- GUIDE-02: Code Modification Guidelines
  - Problem: 修正手順不明瞭
  - Impact: ミスおよび統一性欠如
  - Recommendation: 明確な修正手順と検証方法の追加
- GUIDE-03: Tool Usage
  - Problem: Tool 使用例不足
  - Impact: 運用差異発生
  - Recommendation: MCP Tool 使用例の追加
- GUIDE-04: Error Handling
  - Problem: エラーハンドリング指針不足
  - Impact: 想定外障害時の対処不備
  - Recommendation: エラーハンドリング方針の明記

### 5. Security Guidelines Chapter (SEC: Security)

- SEC-01: Security Items
  - Problem: セキュリティ項目不足
  - Impact: 脆弱性見落とし
  - Recommendation: 必須セキュリティ項目の追加
- SEC-02: Secrets Management
  - Problem: 機密管理指針不足
  - Impact: 機密漏洩リスク
  - Recommendation: シークレット管理ポリシーの明記
- SEC-03: Best Practices
  - Problem: 具体対策不足
  - Impact: 誤った実装助長
  - Recommendation: 具体的ベストプラクティス追加
- SEC-04: Examples
  - Problem: 例示不足
  - Impact: 実装ミス誘発
  - Recommendation: YAML/コード例の追加（該当時）

### 6. Testing and Validation Chapter (TEST: Testing)

必須サブセクション:

- TEST-01: Validation Commands
  - Problem: 検証コマンド未記載
  - Impact: 自動検証不能
  - Recommendation: 実行可能な検証コマンド記載（例付き）
- TEST-02: Command Count
  - Problem: コマンド数不足
  - Impact: 検証網羅性低下
  - Recommendation: 最低 3 項目以上の検証コマンド追加
- TEST-03: Code Block
  - Problem: 実行例非コードブロック
  - Impact: 実行困難
  - Recommendation: ```bash 形式で実行例記載
- TEST-04: Validation Items
  - Problem: 検証項目リスト不足
  - Impact: 期待チェック漏れ
  - Recommendation: 検証項目リストの充実

検証コマンド例:

- **script**: `bash -n`, `shellcheck`, `validate_all_scripts.sh`
- **go**: `go fmt`, `go vet`, `golangci-lint`, `go test`, `govulncheck`（8 項目）
- **terraform**: `terraform fmt`, `terraform validate`, `tflint`, `trivy config`
- **github-actions**: `actionlint`, `ghalint run`, `disable-checkout-persist-credentials`, `ghatm`
- **markdown**: `markdownlint`, `markdown-link-check`
- **dac**: YAML 構文チェック、図生成テスト

### 7. Content Quality (QUAL: Quality)

- QUAL-01: Conciseness
  - Problem: 冗長表現多発
  - Impact: トークン効率低下
  - Recommendation: 体言止め・短文化
- QUAL-02: Practical Examples
  - Problem: 実用例不足
  - Impact: 活用性低下
  - Recommendation: 実用的なコード例追加
- QUAL-03: No Redundancy
  - Problem: 重複記載
  - Impact: 保守性低下
  - Recommendation: 重複排除
- QUAL-04: Token Efficiency
  - Problem: 大規模コード例残存
  - Impact: トークン浪費
  - Recommendation: 不要例の削除・短縮

### 8. Consistency Across Files (CONS: Consistency)

- CONS-01: Chapter Order
  - Problem: 章順序不整合
  - Impact: 横断比較困難
  - Recommendation: 章順序統一
- CONS-02: Section Names
  - Problem: セクション名不統一
  - Impact: 見つけにくさ増大
  - Recommendation: セクション名統一
- CONS-03: Detail Level
  - Problem: 詳細度差異
  - Impact: 標準化困難
  - Recommendation: 記載レベル合わせ込み
- CONS-04: Format
  - Problem: 表記形式バラツキ
  - Impact: 読み取りエラー
  - Recommendation: 表・リスト形式の統一

### 9. Completeness (COMP: Completeness)

- COMP-01: All Required Sections
  - Problem: 必須セクション欠落
  - Impact: 不完全レビュー
  - Recommendation: 全必須セクションの整備
- COMP-02: No Missing Commands
  - Problem: 検証コマンド不足
  - Impact: 実行不能な検証
  - Recommendation: 実行可能な検証コマンドの網羅
- COMP-03: Tool Coverage
  - Problem: ツール記載漏れ
  - Impact: 検証欠落
  - Recommendation: aqua.yaml と照合して全ツール追記
- COMP-04: Real Commands
  - Problem: 実行例不足
  - Impact: 検証困難
  - Recommendation: 実行例の具体的に記載
## Validation Process

### 1. 章構成確認

```bash
# 全ファイルの章構成抽出
for f in /workspace/.github/instructions/*.instructions.md; do
  echo "=== $(basename $f) ==="
  grep -E '^## ' "$f"
  echo
done
```

期待結果: 全ファイルで 4 章統一（Standards/Guidelines/Testing and Validation/Security Guidelines）

### 2. 行数バランス確認

```bash
wc -l /workspace/.github/instructions/*.instructions.md
```

期待範囲:

- 最小: 70 行程度（terraform: 73 行）
- 最大: 230 行程度（go: 222 行、特殊ケース）
- 標準: 100-180 行

### 3. 検証コマンド網羅性確認

各ファイルの"Testing and Validation"章で検証コマンド数確認:

- 最低 3 項目以上
- 実行例付き
- コードブロック形式

### 4. セキュリティガイドライン確認

全ファイルで"Security Guidelines"章存在確認:

```bash
grep -l "## Security Guidelines" /workspace/.github/instructions/*.instructions.md | wc -l
```

期待: 6 ファイル全て

## Common Issues and Fixes

### Issue 1: 章順序不統一

**Problem**: Testing and Validation が Guidelines 内にある
**Fix**: 独立章として抽出、Security Guidelines の前に配置

### Issue 2: 検証コマンド不足

**Problem**: 検証コマンドが 1-2 項目のみ
**Fix**: aqua.yaml 確認、関連ツール全て追加（最低 3 項目）

### Issue 3: Security Guidelines 章なし

**Problem**: セキュリティ章が存在しない
**Fix**: 機密情報管理・ベストプラクティス記載の章追加

### Issue 4: 記載レベル不統一

**Problem**: 他ファイルより詳細度が低い
**Fix**: 他ファイル参照、同等の詳細度に拡充

## Final Verification

全チェック完了後:

1. **統一性**: 全 6 ファイルで章構成・順序統一確認
2. **実用性**: 各検証コマンドが実行可能確認
3. **完全性**: 必須セクション全て存在確認
4. **バランス**: 行数・詳細度が他ファイルと同等確認

## Reference Files

最良の参考例:

- **go.instructions.md** (222 行): 最も詳細、Testing 章 8 項目
- **github-actions-workflow.instructions.md** (180 行): 拡充後の良例
- **script.instructions.md** (106 行): 標準的なバランス
