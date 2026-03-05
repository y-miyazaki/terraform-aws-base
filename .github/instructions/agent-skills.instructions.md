---
applyTo: "**/.github/skills/**/SKILL.md"
description: "AI Assistant Instructions for Agent Skills Development"
---

# AI Assistant Instructions for Agent Skills

**言語ポリシー**: 全て英語

## Skill Structural Requirements (Mandatory)

各SKILL.mdは実行決定性を保証するため、以下のセクションを定義すること:

### Required Sections

以下のセクションは記載された順序でSKILL.md内に配置すること（H2レベル `##`）:

1. **Purpose** (descriptionフィールドに単一文で記載)
   - スキルが何をするか
   - いつ使用するか

2. **When to Use This Skill**
   - スキルを使用すべき状況
   - 推奨タイミング
   - 例: "Editing Terraform files", "Before committing changes", "During code review"

3. **Input Specification**
   - スキルが期待する情報/ファイル
   - 形式要件
   - 例: "カレントディレクトリのTerraformファイルを期待" または "PR説明とリンクされたissueが必要"

4. **Output Specification**
   - スキルが生成するもの
   - 形式要件（可能な限り構造化フォーマット必須）
   - 構造化フォーマットで出力を定義: markdownセクション、JSONスキーマ、テーブル
   - 自由形式の記述的出力を避ける
   - 例: "ChecksとIssuesセクションを持つmarkdownレビューレポートを出力" または "JSON形式で返却: {status, errors[], warnings[]}"

5. **Execution Scope**
   - スキルが行うこと
   - スキルが行わないこと（Out of Scope）
   - Out of Scope には外部ツール委譲を明記: yamllint/markdownlint等での構文チェック、word count計測、ディレクトリ存在確認等の deterministic check
   - 例: "スコープ外: YAML/Markdown構文エラーはyamllint/markdownlint委譲。対象ディレクトリ外のファイル変更不可。依存関係バージョン変更不可。"

6. **Constraints**
   - 制限と境界
   - 前提条件
   - 例: "AWS基盤のTerraformを想定。自動チェックが先に通過している必要がある。"

7. **Failure Behavior**
   - エラーの処理方法
   - 検証失敗時に報告する内容
   - 例: "検証失敗時、エラーを報告してパッケージ作成せずに終了"

8. **Reference Files Guide**
   - Agent利用時に @-mention で参照可能な reference ファイルのリスト
   - Standard Components (common-_) と Category Details (category-_) に分類
   - 各ファイルに簡潔な説明を付記
   - 例: "When using this skill with an agent, reference the following files as needed via @-mention:"

9. **Workflow**
   - スキル実行の具体的な手順・フロー
   - Validation型: ステップ番号付きの手順（1. Make changes → 2. Run validation → ... → 5. Commit）
   - Review型: Step 1〜Step 4 のサブセクション構造（Step 1: Understand Context, Step 2: Automated Checks First, Step 3: Systematic Review, Step 4: Report Issues）
   - 実行順序と各ステップの明確な説明
   - 例: "1. **Make changes** - Edit files\n2. **Run validation**: `bash script/validate.sh`\n3. **Fix issues** - Address failures\n4. **Commit** - Only when validation passes"

### Execution Determinism Rules

- **Single canonical path**: 明示的に必要でない限り、単一の実装経路を提供
- **Explicit branching**: 選択肢が存在する場合、すべてのオプションと選択基準を列挙
- **No implicit inference**: すべての仮定を明示的に記述
- **Bounded scope**: 行うことだけでなく、行わないことも定義
- **Structured output**: markdownセクション、JSONスキーマ、テーブルを使用; 自由形式の記述を避ける

## Standards

### Absolute Rules

- **Writing Style**: 命令形/不定詞形式（"You should"禁止）
- **Specificity**: 具体的・測定可能な指示（"appropriately"等禁止）
  - 手続き的指示には以下のいずれかを含む:
    - 数値閾値（回数、時間、サイズ、ステータスコード）
    - 明示的条件（Xの場合Yを返す）
    - 具体的API/関数参照
  - 設計原則と概念定義は例外
- **SKILL.md Size Limit**: 5,000単語以下
  - 理由: コンテキストウィンドウ最適化、プロンプト遅延制御、レビュー可能性維持
  - 強制: SKILL.mdが5,000単語を超える場合、マージ前に非本質的な詳細をreferences/へ移動
- **Resource Separation**: scripts/references/assets 明確分離
  - scripts/: 実行可能コード（決定的・反復タスク）
  - references/: 必要時ロードされるドキュメント
  - assets/: 出力に使用するファイル（context外）
  - SKILL.md内に短い説明用コードスニペット（<30行）は許可
  - 実行可能または再利用可能なコードはscripts/に配置

#### Reference Directory Structure

`references/` ディレクトリは以下のファイル構成標準に従う:

**標準構成ファイル (Standard Components)** - `common-` prefix:
Agent Skills全体で推奨される標準的なreference構成。内容はスキル固有だが、すべてのスキルで同じ名前を使用する:

- `common-checklist.md` ★必須: スキル固有のチェック項目リスト（ItemID形式: ERR-01, SEC-01等）
- `common-output-format.md` ★必須: 標準化された出力フォーマット仕様（`## Checks` / `## Issues` 構造）
- `common-troubleshooting.md`: トラブルシューティングガイド（Validation型スキル推奨）
- `common-individual-commands.md`: 個別ツールコマンド実行方法（Validation型スキル推奨、デバッグ用）

**カテゴリ別・スキル固有ファイル (Category-Specific & Skill-Specific)** - `category-` prefix:
すべての詳細情報ファイルは `category-` prefix を使用（内容はスキル固有）:

- `category-security.md`: セキュリティ関連チェック詳細
- `category-testing.md`: テスト関連チェック詳細
- `category-performance.md`: パフォーマンス関連チェック詳細
- `category-error-handling.md`: エラーハンドリング詳細
- `category-global.md`: 全カテゴリ横断チェック項目（Review型スキル）
- `category-patterns.md`: デザインパターン詳細（agent-skills-reviewスキル固有）
- `category-concurrency.md`: 並行性パターン詳細（Go関連スキル固有）
- `category-logging.md`: ロギング詳細（shell-script関連スキル固有）
- その他: `category-*` 形式で統一

**命名規則**:

- すべてのファイル名は小文字ハイフン区切り（kebab-case）
- `common-*`: Agent Skills全体で標準化される構成ファイル（すべては存在しない可能性）
- `category-*`: スキル固有の詳細情報ファイル（存在可否はスキル実装に任せる）

**ヘッダーレベル標準**:

Common系ファイルのヘッダーレベルは統一:

- `common-checklist.md`: H1（`#`）で開始
- `common-output-format.md`: H1（`#`）で開始
- `common-troubleshooting.md`: H2（`##`）で開始（補足情報の位置づけ）
- `common-individual-commands.md`: H2（`##`）で開始（デバッグ情報の位置づけ）

Category系ファイル:

- Title行は H2（`##`）で開始（セクション見出しとしての位置づけ）
- 内容の詳細は H3（`###`）以下で階層化

**例: 標準的なValidation型スキルの構成**:

```
reference/
  ├── common-checklist.md          # 必須
  ├── common-output-format.md      # 必須
  ├── common-troubleshooting.md    # 標準
  ├── common-individual-commands.md # 標準
  └── category-*.md                # スキル固有（security等）
```

**例: 標準的なReview型スキルの構成**:

```
reference/
  ├── common-checklist.md          # 必須
  ├── common-output-format.md      # 必須
  ├── category-global.md           # 横断チェック（スキル固有）
  ├── category-security.md         # セキュリティ詳細（スキル固有）
  ├── category-*.md                # その他詳細情報（スキル固有）
```

### Priority Principle

**Clarity > DRY**: 明確性が保たれる場合のみ冗長性を回避

## Guidelines

### Code Modification Guidelines

#### Writing Style

命令形/不定詞形式使用:

```markdown
❌ You should do X
❌ You need to check Y
✅ Do X
✅ Check Y
✅ To accomplish X, do Y
```

#### Specificity Requirements

曖昧表現禁止、具体的指示:

```markdown
❌ Handle errors appropriately
✅ Return errors with context using fmt.Errorf("operation failed: %w", err)

❌ Optimize for performance
✅ Cache query results for 5 minutes to reduce database load

❌ Retry if the request fails
✅ Retry up to 3 times if request returns 5xx status code
```

**禁止表現**:

- appropriately, as needed, if possible, preferably, ideally
- 適切に、必要に応じて、可能な限り、なるべく、できるだけ
- in some cases, depending on the situation, case by case
- 場合によっては、状況に応じて、ケースバイケース
- etc., and so on, など、等

#### Progressive Disclosure

- SKILL.md: 5,000単語以下
- 詳細情報: `references/`に分離
- 大ファイル(>10k単語): grep パターン記載
- SKILL.md と references 間で情報重複禁止

#### Resource Separation

| Directory     | Purpose                              |
| ------------- | ------------------------------------ |
| `scripts/`    | 実行可能コード（決定的・反復タスク） |
| `references/` | 必要時ロードされるドキュメント       |
| `assets/`     | 出力に使用するファイル（context外）  |

#### Quality Standards

**Ambiguity Elimination (Critical)** - マージ前に必ず修正:

- 不明確条件: "in some cases", "depending on the situation"
- 場合によっては、状況に応じて、ケースバイケース

**Ambiguity Elimination (Important)** - 強い正当化理由がない限り修正:

- 曖昧表現: "appropriately", "as needed", "if possible"
- 不完全列挙: "etc.", "and so on", "など"
- 不完全フォーマット定義: "format like the following"

**Redundancy Reduction**:

- 複数箇所での同一情報繰り返し回避
- 共通パターンは共有 references へ抽出
- 冗長性排除が曖昧さ増加させる場合は冗長性維持（Clarity > DRY）

**Best Practices Compliance**:

- 命令形/不定詞形式全体使用
- 具体的・測定可能指示（数値閾値、明示的条件、具体的API参照のいずれかを含む）
- Progressive Disclosure（SKILL.md < 5,000単語、詳細はreferences/へ）
- リソース分離（scripts/references/assets）
- Clarity > DRY（明確性を損なわない範囲で重複削減）

### Anti-Patterns

**❌ 回避**:

- 巨大 SKILL.md ファイル: 詳細は references へ
- 曖昧指示: 常に具体的に
- 情報重複: DRY 原則
- 二人称言語: 命令形使用

**✅ 推奨**:

- 明確分離: 指示 vs. references vs. code
- 具体的基準: 正確な閾値・条件
- Progressive Disclosure: SKILL.md に本質情報、references に詳細
- 客観的言語: 命令形/不定詞形式

## Review Process

Agent Skills 作成・修正時、以下を優先順位順に確認:

### Critical (マージ前に必ず修正)

1. **Structural Completeness**: 必須セクションすべて存在（Purpose, Input, Output, Scope, Constraints, Failure Behavior）
2. **Ambiguity (Critical)**: 不明確条件を明示的条件に置換
3. **Writing Style**: 命令形/不定詞形式使用（"you should"無）
4. **Out-of-Scope Definition**: 明示的に「やらないこと」を定義

### Important (強い正当化理由がない限り修正)

5. **Ambiguity (Important)**: 曖昧表現を具体的指示に置換
6. **Specificity**: 手続き的指示には数値閾値、明示的条件、具体的API参照のいずれかを含む
7. **Progressive Disclosure**: SKILL.md < 5,000単語（超過時はreferences/へ移動）
8. **Input/Output Format**: 入力・出力の形式を明示的に定義
9. **Single Canonical Path**: 複数の実装経路がある場合、選択基準を明示

### Recommended (可能な場合に修正)

10. **Redundancy**: 不要重複削除（Clarity > DRY原則に従う）
11. **Consistency**: 確立パターン遵守
12. **Resource Separation**: scripts/references/assets 適切分離

## Token Efficiency Strategy

SKILL.mdおよびそれを使用するスキルは、AI context最適化のため以下を必須とする:

### Progressive Disclosure

- **SKILL.md**: 5,000単語以下に制限（本質情報のみ）
- **詳細情報**: references/ に分離、必要時ロード
- **Category-driven Reference Loading**: 検証カテゴリごとに reference ファイル分離し、必要な reference のみ段階的ロード
- **情報重複排除**: SKILL.md と references 間での情報重複禁止

これにより context window を最適化し、AI invocation のレイテンシ・コストを削減。

### Context Optimization Pattern

例: Agent Skills Review スキルは以下を実装

- 4つの deterministic check（sections 存在確認、word count計測等）を scripts で自動化
- 8つの judgment-based check（意味評価、設計判定等）を manual review に特化
- 結果: Automated checks の出力を reference として manual review に活用、context削減

## Script Automation Principle

スキルの検証項目は実装方式に基づいて分類し、deterministic check は scripts/ で自動化すべし。

### Philosophy

**Deterministic Check** (結果が客観的に決定される检証項目):

- 存在確認: Required sections の grep、frontmatter フィールド抽出
- 定量計測: word count (wc), ファイルサイズ、line count
- ディレクトリ/ファイル有無確認: find コマンド
- 実装方式: scripts/ 内で shell/Python等で deterministic に実行
- 出力形式: JSON/CSV等の構造化フォーマット（AI/tool で解析可能）
- 利点: 結果の客観性、AI context削減、実行速度向上

**Judgment-based Check** (人間/AI の判断が必要な検証項目):

- 意味評価: Output 構造の実装妥当性、曖昧表現・推論の検出
- 設計判定: スコープ定義の充足度、pattern alignment
- 文脈的判断: 全体的一貫性、ドメイン知識を要する評価
- 実装方式: Manual review として AI による systematic な評価
- 利点: AI の本来の強み（NLP、context 判断）を活用

### Expected Pattern

**スキル設計時の推奨パターン**:

```
Total checks = Deterministic checks + Judgment-based checks

例: Agent Skills Review
- 4 checks を scripts で自動化（S-01, S-02, Q-07, Q-08）
- 8 checks を manual review（Q-01~Q-06, P-01~P-02）
- スキルの Execution Flow により scripts → manual review の順序で実行
```

### Meta-Pattern: Skills が Philosophy を体現

スキル実装者は以下を提示すべし:

1. SKILL.md に "Philosophy" セクション追加: "このスキルは deterministic check を scripts で自動化し、judgment-based check に AI を特化させる philosophy を実装している"
2. 実装で philosophy を体現: 4 deterministic checks は scripts/ で充実した実装、8 judgment-based checks は reference/ で段階的ロード
3. 結果: スキル自体が推奨ベストプラクティスを示範的に実装（メタ的クレディビリティ向上）

## Governance

### Amendment Rule

3つ以上のSkillsで曖昧さまたは不整合が観測された場合のみ、この指示を修正する。

### Enforcement Actions

- **構造違反**: 必須セクションすべて存在するまでマージをブロック
- **単語数 > 5,000**: 承認前にreferences/へコンテンツ移動
- **Critical違反**: 修正されるまでマージをブロック
- **Important違反**: 正当化または修正が必要
- **Recommended違反**: レビューコメントに記録
