# Review Instructions for \*.prompt.md Files

## Objective

`.github/prompts/review-*.prompt.md` のレビュー基準と自動検証ルールの整備。

## Must-follow rules (必須ルール)

以下はすべての `review-*.prompt.md` が満たすべき最小ルール（簡潔な要約）:

- ID 形式: CAT-NN（大文字、カテゴリ+2 桁）
- 各項目に Problem / Impact / Recommendation を 1 つずつ記載（短い名詞句、体言止め）
- カテゴリ順序: Core canonical order を保持（言語固有カテゴリは相対順を厳守）
- カテゴリ内項目: 主要カテゴリは最低 3 項目を目安
- 重複禁止: 同一 ID の重複禁止
- バランス: 1 ファイルあたり 150–200 行を目安（言語により調整可）

## Review Checklist

### 1. File Structure (G: General)

- G-01: Title
  - Problem: タイトル不明瞭
  - Impact: 対象判別困難
  - Recommendation: 明確なタイトル付与
- G-02: Purpose
  - Problem: 目的・スコープ未記載
  - Impact: レビュー基準不一致
  - Recommendation: 目的とスコープの明記
- G-03: ID-Based Format
  - Problem: ID 付与欠如
  - Impact: 管理・検索困難
  - Recommendation: CAT-NN 形式で ID の付与

### 2. Category Structure (CAT: Category)

必須カテゴリ（順序統一）:

```markdown
1. General (G)
2. Code Quality (CODE) / Module (M) / Variables (V) など言語固有
3. Functionality (FUNC) / Error Handling (ERR)
4. Security (SEC)
5. Performance (PERF)
6. Testing (TEST)
7. Documentation (DOC)
8. Dependencies (DEP)
```

チェック項目:

- CAT-01: カテゴリ順序が統一
  - Problem: カテゴリ順序不統一
  - Impact: 比較困難
  - Recommendation: 規定順序に統一
- CAT-02: カテゴリ ID が統一
  - Problem: ID 表記揺れ
  - Impact: 自動解析困難
  - Recommendation: カテゴリ ID の標準化
- CAT-03: 番号が連番
  - Problem: 番号飛び/重複
  - Impact: 管理困難
  - Recommendation: 番号の連番化

### Canonical Category Order (explicit)

このリポジトリで採用する「正規カテゴリ順序」を明文化する。すべての `review-*.prompt.md` は下記のコア順序を満たすこと。

- Core canonical order (保持必須):
  1. G (General)
  2. CODE (Code Quality) / language primary category（例: Terraform の M）
  3. FUNC (Functionality)
  4. ERR (Error Handling)
  5. SEC (Security)
  6. PERF (Performance)
  7. TEST (Testing)
  8. DOC (Documentation)
  9. DEP (Dependencies)

言語/ドメイン固有のカテゴリ（例: Terraform の M, V, TAG, STATE, DATA など）は上記 Core の相対順序を崩さないように挿入可能。ただし、ファイルが Core に含まれないケース（例: GitHub Actions は TOOL/BP 優先）については、該当ファイルの先頭で許容順序を明示すること。

### 3. Category Coverage (COV: Coverage)

言語別必須カテゴリ:

**Terraform** (20 カテゴリ):

- G, M, V, O, T, S, TAG, E, VERS, N, CI, P, STATE, COMP, COST, TEST, MIG, PERF, DEP, DATA

**Script** (10 カテゴリ):

- G, CODE, FUNC, ERR, SEC, PERF, TEST, DOC, DEP, LOG

**Go** (10 カテゴリ):

- G, CODE, FUNC, ERR, SEC, PERF, TEST, ARCH, DOC, DEP

**GitHub Actions** (6 カテゴリ):

- G, SEC, TOOL, ERR, PERF, BP

- COV-01: 対象言語の全カテゴリ存在
  - Problem: カテゴリ欠落
  - Impact: 覆い漏れリスク
  - Recommendation: 言語別必須カテゴリの追加
- COV-02: カテゴリ番号重複なし
  - Problem: 番号重複
  - Impact: 参照混乱
  - Recommendation: 番号重複の解消
- COV-03: 各カテゴリに最低 3 項目以上
  - Problem: 項目数不足
  - Impact: 網羅性不足
  - Recommendation: 各カテゴリに 3 以上の項目追加

### 4. Item Structure (ITEM: Item)

各チェック項目の必須要素:

```markdown
- CAT-NN: Item Title
  - Problem: 問題・リスク説明
  - Impact: 影響範囲・重要度
  - Recommendation: 具体的推奨事項
```

チェック項目:

- ITEM-01: 全項目に ID 付与（CAT-NN 形式）
  - Problem: ID 無し
  - Impact: 追跡困難
  - Recommendation: 全項目へ CAT-NN の ID 付与
- ITEM-02: Problem/Impact/Recommendation 3 要素記載
  - Problem: P/I/R 欠如
  - Impact: 対応不明瞭
  - Recommendation: 各項目に P/I/R の短い名詞句で記載
- ITEM-03: 具体的・実用的な推奨事項
  - Problem: 抽象的指摘
  - Impact: 実行困難
  - Recommendation: 実用的な推奨へ変更
- ITEM-04: コード例記載（該当する場合）
  - Problem: 例示不足
  - Impact: 理解低下
  - Recommendation: 該当時に短いコード例の追加

### 5. Content Quality (QUAL: Quality)

- QUAL-01: Conciseness
  - Problem: 冗長表現
  - Impact: トークン効率低下
  - Recommendation: 体言止め・簡潔化
- QUAL-02: Actionable
  - Problem: 実行指針不足
  - Impact: レビュー実施困難
  - Recommendation: 実行可能な指示へ改善
- QUAL-03: Specific
  - Problem: 抽象記述
  - Impact: 評価基準不明瞭
  - Recommendation: 具体的なチェック基準記載
- QUAL-04: No Duplication
  - Problem: 重複項目
  - Impact: 冗長・誤検出
  - Recommendation: 重複排除
- QUAL-05: Token efficiency
  - Problem: 長文化
  - Impact: トークン浪費
  - Recommendation: 各 P/I/R の短い名詞句へ

### 6. Balance (BAL: Balance)

適切なバランス:

- BAL-01: Not Too Short
  - Problem: 過度圧縮
  - Impact: レビュー不可能
  - Recommendation: 最低限の詳細の保持
- BAL-02: Not Too Long
  - Problem: 冗長化
  - Impact: メンテ負担増
  - Recommendation: 冗長削減
- BAL-03: Detail Level
  - Problem: 詳細度不足
  - Impact: 情報欠落
  - Recommendation: 主要カテゴリは詳細保持
- BAL-04: Optimal Range

  - Problem: 長さ偏差
  - Impact: 読み手負荷
  - Recommendation: 150-200 行の目安
    現在の行数:

- review-terraform.prompt.md: 162 行 ✅
- review-script.prompt.md: 150 行 ✅
- review-go.prompt.md: 164 行 ✅
- review-github-actions-workflow.prompt.md: 88 行 ✅（カテゴリ少ないため適切）

### 7. Automation Awareness (AUTO: Automation)

- AUTO-01: Lint-detectable Items Exclusion
  - Problem: Lint/自動チェック可能項目がレビューに含まれる
  - Impact: レビュー工数重複・誤検出・非効率
  - Recommendation: 自動検出可能項目は pre-commit/CI/CD で検出するため、`review-*.prompt.md`では除外。各ファイル冒頭に除外 Note の記載を必須とする
- AUTO-02: Exclusion Note Presence
  - Problem: 除外ポリシー未記載
  - Impact: レビュー範囲混乱・判断ぶれ
  - Recommendation: 各`review-*.prompt.md`冒頭に除外 Note を追加（例: "Note: Lint/自動検出可能項目は pre-commit/CI/CD で検出するため除外"）
- AUTO-03: Tool-Specific Exclusions
  - Problem: 言語別の自動検出ツールが未明記
  - Impact: 除外基準不明瞭・運用差異
  - Recommendation: 言語/ドメイン別のツール一覧を明記し除外対象を定義（例: Go: golangci-lint/go vet/goimports/errcheck/govulncheck、Script: shellcheck、Terraform: terraform fmt/validate/tflint/trivy、GitHub Actions: actionlint/yamllint）
- AUTO-04: Human-Judgment Focus
  - Problem: 自動検出項目と人間判断項目の混在
  - Impact: レビュー焦点散漫・人手の浪費
  - Recommendation: 人間レビューはアーキテクチャ、セキュリティ設計、コスト最適化、複雑な設計判断に焦点を当てる

### 8. Consistency Across Files (CONS: Consistency)

- CONS-01: ID Format
  - Problem: ID 形式不統一
  - Impact: 自動解析困難
  - Recommendation: CAT-NN 形式へ統一
- CONS-02: Category Order
- Problem: カテゴリ順序の曖昧さ
- Impact: 自動検証ブレ・レビュー者混乱
- Recommendation: Core canonical order に従い順序の固定。言語固有カテゴリは Core の相対順序の崩さない範囲で挿入可。例外はファイル先頭で明示すること
- CONS-03: Structure
  - Problem: P/I/R 構造不統一
  - Impact: 可読性低下
  - Recommendation: P/I/R 構造の統一
- CONS-04: Naming
  - Problem: カテゴリ名の揺れ
  - Impact: 混乱
  - Recommendation: カテゴリ名統一

### 9. Usability (USE: Usability)

- USE-01: Reviewable
  - Problem: 実践不能な記載
  - Impact: レビュー不能
  - Recommendation: レビュー実行可能な情報へ修正
- USE-02: Clear Criteria
  - Problem: 判定基準不明瞭
  - Impact: 判断ぶれ
  - Recommendation: 明確な基準の記載
- USE-03: Examples
  - Problem: 例示不足
  - Impact: 理解困難
  - Recommendation: 具体例・パターンの追加
- USE-04: Tools
  - Problem: 使用ツール未明記
  - Impact: 実行困難
  - Recommendation: 使用ツール・コマンドの明記

### 10. Completeness (COMP: Completeness)

- COMP-01: All Categories
  - Problem: カテゴリの未網羅
  - Impact: 覆い漏れ
  - Recommendation: 全カテゴリのカバー
- COMP-02: No Missing Items
  - Problem: 重要項目欠落
  - Impact: 品質低下
  - Recommendation: 必須項目の補完
- COMP-03: Cross-reference
  - Problem: instructions.md 参照不整合
  - Impact: 一貫性欠如
  - Recommendation: 参照整合の確保
- COMP-04: Tool Coverage
  - Problem: ツール記載不足
  - Impact: 検証不足
  - Recommendation: 検証ツールの全記載

## Validation Process

### 1. カテゴリ構成確認

```bash
# 全promptファイルのカテゴリ抽出
for f in /workspace/.github/prompts/review-*.prompt.md; do
  echo "=== $(basename $f) ==="
  # Accepts either bold header (**G-01) or list-style (
  # Accepts either bold header (**G-01) or list-style (
  - G-01 formats
  grep -E '^\s*-?\s*\*{0,2}[A-Z]+-[0-9]+:' "$f" | sed 's/:.*$//' | cut -d'-' -f1 | sort -u
  echo
done
```

期待結果: 各ファイルで定義されたカテゴリセット表示

### 1.b Core canonical order check

期待: 各ファイルで Core canonical order に沿って Core カテゴリ（G,CODE,FUNC,ERR,SEC,PERF,TEST,DOC,DEP）が出現する。

```bash
# Fail if a file's core categories appear out-of-order relative to the canonical order
CANONICAL=(G CODE FUNC ERR SEC PERF TEST DOC DEP)
for f in /workspace/.github/prompts/review-*.prompt.md; do
  # extract category tokens in file order
  seq=$(grep -E '^\s*-?\s*[A-Z]+-[0-9]+:' "$f" | sed -E 's/^\s*-?\s*([A-Z]+)-[0-9]+:.*/\1/' | tr '\n' ' ')
  # filter only canonical categories
  filtered=$(echo "$seq" | tr ' ' '\n' | grep -E '^(G|CODE|FUNC|ERR|SEC|PERF|TEST|DOC|DEP)$' | tr '\n' ' ')
  if [ -z "$filtered" ]; then
    continue
  fi
  # verify order using python quick-check
  python3 - <<PY - "$filtered" || true
import sys
canonical = ['G','CODE','FUNC','ERR','SEC','PERF','TEST','DOC','DEP']
seq = sys.argv[1].strip().split()
idxs = [canonical.index(c) for c in seq if c in canonical]
if idxs != sorted(idxs):
    print(f"ORDER MISMATCH in {sys.argv[1]} -> seq={' '.join(seq)}")
    sys.exit(1)
PY
done
```

### 2. ID 重複確認

```bash
# 各ファイルのID重複チェック
for f in /workspace/.github/prompts/review-*.prompt.md; do
  echo "=== $(basename $f) ==="
  grep -oE '[A-Z]+-[0-9]+:' "$f" | sort | uniq -d
  echo "---"
done
```

期待結果: 重複 ID 表示なし（空出力）

### 3. 行数バランス確認

```bash
wc -l /workspace/.github/prompts/review-*.prompt.md
```

期待範囲:

- Terraform: 150-200 行（20 カテゴリ）
- Script/Go: 150-170 行（10 カテゴリ）
- GitHub Actions: 80-100 行（6 カテゴリ）

### 4. 構造統一確認

各 ID に対して Problem/Impact/Recommendation が各 1 つずつ存在するかの検証する。検証は次のルールを適用：

- 各 ID のブロックは次の ID、またはトップレベル章見出し (## )、もしくはファイル末尾までとする
- ブロック内で Problem/Impact/Recommendation の数が 1,1,1 でない場合は失敗とする

````bash
# Per-file P/I/R presence check
python3 - <<'PY'
import re,sys
from pathlib import Path
files = list(Path('/workspace/.github/prompts').glob('review-*.prompt.md'))
ok=True
for p in files:
  s=p.read_text()
  lines=s.splitlines()
  # locate all ID headers and top-level headers
  id_positions = []
  in_code = False
  for i,l in enumerate(lines):
    if l.strip().startswith('```'):
      in_code = not in_code
      continue
    if in_code:
      continue
    m = re.match(r'^\s*-\s+([A-Z]+-[0-9]+):', l)
    if m:
      id_positions.append((i, m.group(1)))
  # stop at **any** markdown header (H1/H2/H3...), not only H2
  top_positions = [i for i,l in enumerate(lines) if re.match(r"^#+\s+", l)]
  for idx,(i,name) in enumerate(id_positions):
    # block ends at next id or at next top-level header (## ) or EOF
    candidates = [pos for pos,_ in id_positions[idx+1:]] + top_positions + [len(lines)]
    end = min([c for c in candidates if c>i])
    block='\n'.join(lines[i+1:end])
    # Count Problem/Impact/Recommendation occurrences, ignoring code fences
    def count_non_code(pattern, text):
      in_code = False
      cnt = 0
      for l in text.splitlines():
        if l.strip().startswith('```'):
          in_code = not in_code
          continue
        if in_code:
          continue
        if re.match(pattern, l):
          cnt += 1
      return cnt

    pc = count_non_code(r'^[ \t]*-?[ \t]*Problem:', block)
    ic = count_non_code(r'^[ \t]*-?[ \t]*Impact:', block)
    rc = count_non_code(r'^[ \t]*-?[ \t]*Recommendation:', block)
    if (pc,ic,rc)!=(1,1,1):
      print(f"{p.name}: {name} -> Problem={pc},Impact={ic},Recommendation={rc}")
      ok=False
if not ok:
  sys.exit(1)
PY
````

期待結果: 各 ID のブロックで Problem/Impact/Recommendation がそれぞれ 1 つずつ存在すること

## Common Issues and Fixes

### Issue 1: 過度圧縮版（75 行）

**Problem**: "2-20. その他カテゴリ（簡略版）"1 行要約のみ
**Fix**: バランス版へ修正、全 20 カテゴリ詳細保持（150-200 行）

### Issue 2: リスト形式（ID なし）

**Problem**: 単純リスト形式、ID 付与なし
**Example**:

```markdown
- Check workflow syntax
- Verify permissions
```

**Fix**: ID 付き形式へ変更
**Example**:

```markdown
- EX-01: Workflow Syntax
  - Problem: ...
  - Impact: ...
  - Recommendation: ...
```

### Issue 3: カテゴリ番号重複

**Problem**: 同じ番号が複数カテゴリで使用
**Example**: 4 番が 2 つ（ERR-04 と SEC-04 が両方 4 番）

**Fix**: 連番修正（1,2,3,4,5,6...）

### Issue 4: カテゴリ順序不統一

**Problem**: ファイル毎にカテゴリ順序が異なる
**Fix**: 統一順序適用（G→CODE→FUNC→ERR→SEC→PERF→TEST→DOC→DEP）

## Common Category Definitions

全 prompt ファイルで共通のカテゴリ:

| Category ID | Full Name      | Description        |
| ----------- | -------------- | ------------------ |
| G           | General        | 一般的品質・構成   |
| CODE        | Code Quality   | コード品質・可読性 |
| FUNC        | Functionality  | 機能性・設計       |
| ERR         | Error Handling | エラーハンドリング |
| SEC         | Security       | セキュリティ       |
| PERF        | Performance    | パフォーマンス     |
| TEST        | Testing        | テスト             |
| DOC         | Documentation  | ドキュメント       |
| DEP         | Dependencies   | 依存関係           |

## Final Verification

全チェック完了後:

1. **統一性**: 全 prompt ファイルで ID 形式・構造統一確認
2. **実用性**: 記載内容でレビュー実施可能確認
3. **完全性**: 対象言語の全カテゴリカバー確認
4. **バランス**: 過度圧縮・冗長でない適切な詳細度確認

## Reference Files

最良の参考例:

- **review-terraform.prompt.md** (162 行): 全 20 カテゴリ詳細、バランス版
- **review-go.prompt.md** (164 行): 10 カテゴリ、Problem/Impact/Recommendation 構造
- **review-script.prompt.md** (150 行): カテゴリ番号修正済み、統一構造

## Version History

- **v1 (過度圧縮版)**: 75 行、"その他カテゴリ（簡略版）"1 行のみ → レビュー不可能
- **v2 (バランス版)**: 150-164 行、全カテゴリ詳細保持 → 現行推奨バージョン
