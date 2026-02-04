---
name: github-actions-review
description: GitHub Actions Workflow code review for correctness, security, and best practices. Use for manual review of workflow files checking design decisions and security patterns requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

# GitHub Actions Workflow Code Review

This skill provides comprehensive guidance for reviewing GitHub Actions Workflow configurations to ensure correctness, security, and best practices compliance.

## Output Language

**IMPORTANT**: Always respond in Japanese (日本語) when performing code reviews。

**日本語で記述する要素**:

- All explanatory text (説明文)
- Problem descriptions (問題の説明)
- Impact assessments (影響の評価)
- Recommendations (推奨事項)
- Check results (チェック結果)

**英語で記述する要素**:

- File paths (ファイルパス)
- Code snippets (コードスニペット)
- Technical identifiers (action names, variable names, secret names)

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on GitHub Actions Workflow pull requests
- Checking workflow configurations before merging
- Ensuring security and compliance standards
- Validating best practices adherence
- Architecture and design review

**Note**: Linting and auto-checkable items (YAML syntax, runs-on missing, step names) are excluded from this review as they should be caught by actionlint/yamllint in CI/CD pipelines.

## Review Process

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the workflow purpose and trigger conditions
- Check if this is new workflow, enhancement, or bug fix
- Verify related documentation updates

### Step 2: Automated Checks First

Verify automated validation has passed:

- `actionlint`
- `ghalint`
- `zizmor`

If automated checks fail, request fixes before manual review.

### Step 3: Systematic Review

Review categories systematically based on the changes. Use the reference documentation for detailed checks in each category.

### Step 4: Report Issues

Report issues following the Output Format below, including only failed checks with specific recommendations.

## Output Format

Review results must be output in structured format:

### Output Elements

1. **Checks** (Review items checklist)
   - Display only failed review items
   - Format: `ItemID ItemName: ❌ Fail`
   - Purpose: Highlight issues requiring attention
   - If all checks pass, output "該当する指摘事項はありません"

2. **Issues** (Detected problems)
   - Display details for each failed item
   - Numbered list format for each problem
   - Each issue includes:
     - Item ID + Item Name
     - File: file path and line number
     - Problem: Description of the issue
     - Impact: Scope and severity
     - Recommendation: Specific fix suggestion with code example

### Output Format Example

```markdown
# GitHub Actions Workflow Code Review結果

## Checks

- SEC-03 pull_request_target の慎重な利用: ❌ Fail

## Issues

**該当する指摘事項はありません** (if all checks pass)

**OR**

1. SEC-03: pull_request_target の慎重な利用
   - File: `.github/workflows/ci.yml` L23
   - Problem: pull_request_targetを使用していますが、適切な保護がありません
   - Impact: 外部PRからのコード実行で任意コード実行・シークレット露出の可能性
   - Recommendation: pull_requestに変更、またはif条件でフォーク検証を追加してください

2. PERF-02: 並列実行の活用
   - File: `.github/workflows/test.yml` L45-60
   - Problem: 順次実行で並列化可能なジョブがあります
   - Impact: CI/CD時間が長く開発速度が低下
   - Recommendation: matrixまたは並列ジョブで実行してください
```

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the workflow being reviewed.

**Global & Base**: Workflow names and triggers → [reference/global.md](reference/global.md)
**Error Handling**: continue-on-error patterns → [reference/error-handling.md](reference/error-handling.md)
**Tool Integration**: Actions and composite actions → [reference/tool-integration.md](reference/tool-integration.md)
**Security**: pull_request_target and secrets → [reference/security.md](reference/security.md)
**Performance**: Caching and parallelization → [reference/performance.md](reference/performance.md)
**Best Practices**: Reusability and maintainability → [reference/best-practices.md](reference/best-practices.md)

## Best Practices

When performing code reviews:

- **建設的・具体的に**: コード例を含む推奨事項、公式ドキュメント参照
- **コンテキスト考慮**: PR目的と要件理解、トレードオフ検討
- **優先度明確化**: "must fix"と"nice to have"の区別
- **セキュリティ見落とし防止**: SEC-\*項目は特に注意深く
- **自動チェック優先**: actionlint/ghalint/zizmor への過度な焦点回避

## Summary

This skill provides:

1. **Comprehensive review guidelines** - 6 categories covering all aspects
2. **Structured output format** - Consistent, parseable review results
3. **Clear process** - Step-by-step review workflow
4. **Prioritization** - Critical vs. minor issues
5. **Actionable recommendations** - Specific fix suggestions with code examples
6. **Domain-specific organization** - Load only relevant categories for efficient token usage

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
