---
name: instructions-review
description: Instructions file review for structure, completeness, and consistency. Use for manual review of .instructions.md files checking content quality and standards compliance.
license: MIT
---

# Instructions File Review

This skill provides comprehensive guidance for reviewing `.github/instructions/*.instructions.md` files to ensure quality, consistency, and practical usability.

## When to Use This Skill

This skill is applicable for:

- Reviewing instructions file pull requests
- Checking instructions files before merging
- Ensuring consistency across all instructions files
- Validating completeness and structure
- Quality and standards compliance

## Important Notes

- **Structure First**: All files must follow the 4-chapter structure (Standards → Guidelines → Testing and Validation → Security Guidelines)
- **Consistency Focus**: This skill emphasizes consistency across all instructions files
- **Practical Validation**: All validation commands must be executable with examples
- **Manual Review Required**: Structure, completeness, and cross-file consistency require human judgment

## Output Language

**IMPORTANT**: レビュー結果はすべて日本語で出力。ただし以下は英語：

- ファイルパス、コードスニペット、技術識別子（章名、コマンド名など）

## Review Process

### Step 1: Verify Required Structure

Confirm all 4 required chapters exist in correct order:

1. Standards
2. Guidelines
3. Testing and Validation
4. Security Guidelines

### Step 2: Systematic Review by Category

Review systematically using priority levels:

- **🔴 Critical**: STRUCT, COMP (structure, completeness)
- **🟡 Important**: STD, GUIDE, TEST, SEC (content quality)
- **🟢 Enhancement**: QUAL, CONS (quality improvements, consistency)

### Step 3: Report Issues with Recommendations

Document issues using Check+Why+Fix format with actionable recommendations.

## Review Guidelines

### 1. General (G)

**G-01: Front Matter**

Check: Front MatterにapplyToとdescription記載があるか
Why: Front Matter欠如で自動処理不全、ファイル適用対象不明
Fix: `applyTo`と`description`を明記

**G-02: Language Policy**

Check: 言語ポリシーが記載されているか
Why: 言語ポリシー未記載で表記不整合、日英混在
Fix: "言語ポリシー: ドキュメント日本語、コード・コメント英語"を追記

**G-03: Title**

Check: タイトルが目的を明確に示しているか
Why: タイトル不明瞭でファイル用途判別困難、検索性低下
Fix: 目的が明確なタイトル付与

### 2. Structure (STRUCT)

**STRUCT-01: 4つの必須章存在**

Check: Standards/Guidelines/Testing and Validation/Security Guidelinesの4章が存在するか
Why: 必須章欠落で情報欠損、不完全なガイド、標準化不能
Fix: 全4章を整備（Standards → Guidelines → Testing and Validation → Security Guidelines）

**STRUCT-02: 章順序統一**

Check: 章の順序がStandards→Guidelines→Testing→Securityか
Why: 章順序不統一で検索性低下、ファイル間比較困難
Fix: 指定順序へ統一（Standards最初、Security最後）

**STRUCT-03: 見出しレベル適切**

Check: 見出し階層がH2（章）→H3（サブセクション）で適切か
Why: 見出し階層不適切で可読性低下、構造不明瞭
Fix: H2/H3階層規則の適用、H4以降は最小化

### 3. Standards Chapter (STD)

**STD-01: Naming Conventions**

Check: 命名規則がコンポーネント別に整備されているか
Why: 命名規則未整備でコード一貫性欠如、レビュー基準不明
Fix: コンポーネント別命名表の追加（関数、変数、ファイル等）

**STD-02: Tool Standards**

Check: ツール規約が記載されているか
Why: ツール規約不足で自動検証不能、実装差異発生
Fix: 対象ツールの標準規約追記（フォーマッター、リンター等）

**STD-03: Consistency**

Check: 他のinstructionsファイルと記載レベルが同等か
Why: ファイル間不整合で学習コスト増大、標準化困難
Fix: 記載レベルの統一、参照ファイル確認

### 4. Guidelines Chapter (GUIDE)

**GUIDE-01: Documentation and Comments**

Check: コメント・ドキュメント規約が明記されているか
Why: ドキュメント規約不足で保守困難、コメント品質低下
Fix: コメント・ドキュメント規約明記（言語、形式、必須項目）

**GUIDE-02: Code Modification Guidelines**

Check: 修正手順と検証方法が明確に記載されているか
Why: 修正手順不明瞭でミスおよび統一性欠如、レビュー品質低下
Fix: 明確な修正手順と検証方法の追加

**GUIDE-03: Tool Usage**

Check: MCP Tool使用例が記載されているか
Why: Tool使用例不足で運用差異発生、非効率な作業
Fix: MCP Tool使用例の追加（該当する場合）

**GUIDE-04: Error Handling**

Check: エラーハンドリング方針が明記されているか
Why: エラーハンドリング指針不足で想定外障害時の対処不備
Fix: エラーハンドリング方針の明記

### 5. Testing and Validation Chapter (TEST)

**TEST-01: Validation Commands**

Check: 実行可能な検証コマンドが記載されているか
Why: 検証コマンド未記載で自動検証不能、品質担保不可
Fix: 実行可能な検証コマンド記載（例付き）

**TEST-02: Command Count**

Check: 検証コマンドが最低3項目以上あるか
Why: コマンド数不足で検証網羅性低下、品質保証不十分
Fix: 最低3項目以上の検証コマンド追加

**TEST-03: Code Block**

Check: 実行例が\`\`\`bash形式のコードブロックで記載されているか
Why: 実行例非コードブロックで実行困難、コピー&ペースト不可
Fix: \`\`\`bash形式で実行例記載

**TEST-04: Validation Items**

Check: 検証項目リストが充実しているか
Why: 検証項目リスト不足で期待チェック漏れ、不完全な検証
Fix: 検証項目リストの充実、aqua.yamlと照合

**TEST-05: Tool Coverage**

Check: aqua.yamlに記載のツールが全て検証コマンドに含まれているか
Why: ツール記載漏れで検証欠落、利用可能ツール活用不足
Fix: aqua.yamlと照合して全ツール追記

**TEST-06: Real Commands**

Check: 実行例が具体的で実際に実行可能か
Why: 実行例不足で検証困難、コマンド実行エラー
Fix: 実行例の具体的記載、実際に動作確認

### 6. Security Guidelines Chapter (SEC)

**SEC-01: Security Items**

Check: セキュリティ項目が記載されているか
Why: セキュリティ項目不足で脆弱性見落とし、セキュリティリスク増大
Fix: 必須セキュリティ項目の追加

**SEC-02: Secrets Management**

Check: シークレット管理ポリシーが明記されているか
Why: 機密管理指針不足で機密漏洩リスク、認証情報流出
Fix: シークレット管理ポリシーの明記（環境変数、Secrets Manager等）

**SEC-03: Best Practices**

Check: 具体的なセキュリティベストプラクティスが記載されているか
Why: 具体対策不足で誤った実装助長、セキュリティ基準不明
Fix: 具体的ベストプラクティス追加（例示付き）

**SEC-04: Examples**

Check: YAML/コード例が含まれているか（該当する場合）
Why: 例示不足で実装ミス誘発、ベストプラクティス理解困難
Fix: YAML/コード例の追加（該当技術で必要な場合）

### 7. Content Quality (QUAL)

**QUAL-01: Conciseness**

Check: 冗長表現がなく簡潔か
Why: 冗長表現多発でトークン効率低下、可読性低下
Fix: 体言止め・短文化、不要な説明削除

**QUAL-02: Practical Examples**

Check: 実用的なコード例が含まれているか
Why: 実用例不足で活用性低下、理解困難
Fix: 実用的なコード例追加

**QUAL-03: No Redundancy**

Check: 重複記載がないか
Why: 重複記載で保守性低下、不整合リスク
Fix: 重複排除、参照形式への変更

**QUAL-04: Token Efficiency**

Check: 大規模コード例を避け、トークン効率が高いか
Why: 大規模コード例残存でトークン浪費、コスト増大
Fix: 不要例の削除・短縮、必要最小限の例示

### 8. Consistency (CONS)

**CONS-01: Chapter Order**

Check: 全instructionsファイルで章順序が統一されているか
Why: 章順序不整合で横断比較困難、学習コスト増大
Fix: 章順序統一（Standards → Guidelines → Testing → Security）

**CONS-02: Section Names**

Check: セクション名が他のinstructionsファイルと統一されているか
Why: セクション名不統一で見つけにくさ増大、標準化困難
Fix: セクション名統一、参照ファイル確認

**CONS-03: Detail Level**

Check: 記載の詳細度が他のinstructionsファイルと同等か
Why: 詳細度差異で標準化困難、ファイル間バランス不良
Fix: 記載レベル合わせ込み、参照ファイル基準

**CONS-04: Format**

Check: 表・リスト形式が他のinstructionsファイルと統一されているか
Why: 表記形式バラツキで読み取りエラー、可読性低下
Fix: 表・リスト形式の統一

### 9. Completeness (COMP)

**COMP-01: All Required Sections**

Check: 全必須セクションが存在するか
Why: 必須セクション欠落で不完全レビュー、情報欠損
Fix: 全必須セクションの整備

**COMP-02: No Missing Commands**

Check: 実行可能な検証コマンドが網羅されているか
Why: 検証コマンド不足で実行不能な検証、品質担保不可
Fix: 実行可能な検証コマンドの網羅

**COMP-03: Tool Coverage**

Check: aqua.yamlのツールが全て網羅されているか
Why: ツール記載漏れで検証欠落、利用可能ツール活用不足
Fix: aqua.yamlと照合して全ツール追記

**COMP-04: Real Commands**

Check: 実行例が具体的で網羅的か
Why: 実行例不足で検証困難、実践性欠如
Fix: 実行例の具体的記載

## Validation Process

### Line Count Balance

期待範囲:

- 最小: 70行程度
- 最大: 230行程度（特殊ケース）
- 標準: 100-180行

```bash
wc -l /workspace/.github/instructions/*.instructions.md
```

### Chapter Structure Verification

全ファイルで4章統一確認:

```bash
for f in /workspace/.github/instructions/*.instructions.md; do
  echo "=== $(basename $f) ==="
  grep -E '^## ' "$f"
  echo
done
```

### Validation Command Coverage

各ファイルのTesting and Validation章で検証コマンド数確認（最低3項目以上）

### Security Guidelines Existence

全ファイルでSecurity Guidelines章存在確認:

```bash
grep -l "## Security Guidelines" /workspace/.github/instructions/*.instructions.md | wc -l
```

期待: 全ファイル（6ファイル）

## Best Practices

- **Reference Files**: go.instructions.md (222行)、github-actions-workflow.instructions.md (180行) を参照
- **Minimum Standards**: 最低70行、3項目以上の検証コマンド、4章必須
- **Consistency Priority**: 新規追加より既存ファイルとの整合性優先
- **Practical Focus**: 実行可能・実用的な内容を重視

## Common Issues and Fixes

### Issue 1: 章順序不統一

Problem: Testing and ValidationがGuidelines内にある
Fix: 独立章として抽出、Security Guidelinesの前に配置

### Issue 2: 検証コマンド不足

Problem: 検証コマンドが1-2項目のみ
Fix: aqua.yaml確認、関連ツール全て追加（最低3項目）

### Issue 3: Security Guidelines章なし

Problem: セキュリティ章が存在しない
Fix: 機密情報管理・ベストプラクティス記載の章追加

### Issue 4: 記載レベル不統一

Problem: 他ファイルより詳細度が低い
Fix: 他ファイル参照、同等の詳細度に拡充

## Output Format

### Checks

List all review items with Pass/Fail status:

```
- G-01 Front Matter: ✅ Pass
- STRUCT-01 4つの必須章存在: ❌ Fail
...
```

### Issues

Document only failed items with:

1. **項目ID+項目名**
   - Problem: 問題説明
   - Impact: 影響範囲・重要度
   - Recommendation: 具体的修正案

### Examples

#### ✅ All Pass

```markdown
# Instructions Review Result

## Checks

- G-01 Front Matter: ✅ Pass
- STRUCT-01 4つの必須章存在: ✅ Pass
- TEST-01 Validation Commands: ✅ Pass
  ...

## Issues

None ✅
```

#### ❌ Issues Found

```markdown
# Instructions Review Result

## Checks

- G-01 Front Matter: ✅ Pass
- STRUCT-01 4つの必須章存在: ❌ Fail
- TEST-02 Command Count: ❌ Fail
  ...

## Issues

1. STRUCT-01 4つの必須章存在
   - Problem: Security Guidelines章が存在しない
   - Impact: セキュリティガイドライン欠如、不完全な標準化
   - Recommendation: Security Guidelines章を追加、機密管理・ベストプラクティス記載

2. TEST-02 Command Count
   - Problem: 検証コマンドが2項目のみ
   - Impact: 検証網羅性低下、品質保証不十分
   - Recommendation: aqua.yaml確認、最低3項目以上に拡充
```
