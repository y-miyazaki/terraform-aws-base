---
name: shell-script-review
description: Shell Script code review for correctness, security, maintainability, and best practices. Use for manual review of shell scripts checking design decisions and security patterns requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

# Shell Script Code Review

This skill provides comprehensive guidance for reviewing Shell Script code to ensure correctness, security, maintainability, and best practices compliance.

## Output Language

**IMPORTANT**: Always respond in Japanese (日本語) when performing code reviews, including:

- All explanatory text
- Problem descriptions (問題の説明)
- Impact assessments (影響の評価)
- Recommendations (推奨事項)
- Check results (チェック結果)

Keep only the following in English:

- File paths (ファイルパス)
- Code snippets (コードスニペット)
- Technical identifiers (function names, variable names, command names, etc.)

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on shell script pull requests
- Checking shell scripts before merging
- Ensuring security and best practices adherence
- Validating design decisions and error handling patterns
- Security and maintainability review

**Note**: This guide assumes bash-based shell scripts with common library usage (lib/all.sh).

**Note**: Linting and auto-checkable items (syntax errors, shellcheck warnings) are excluded from this review as they should be caught by validation scripts or CI/CD pipelines.

## Review Process

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the script purpose and use case
- Check if this is new script, enhancement, or bug fix
- Verify related documentation updates

### Step 2: Automated Checks First

Verify automated validation has passed:

- `bash -n` (syntax check)
- `shellcheck` (static analysis)

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
# Shell Script Code Review結果

## Checks

- SEC-01 入力値検証: ❌ Fail

## Issues

**該当する指摘事項はありません** (if all checks pass)

**OR**

1. SEC-01: 入力値検証
   - File: `scripts/deploy.sh` L23
   - Problem: ユーザー入力を検証せずに直接コマンドに使用
   - Impact: コマンドインジェクションのリスク
   - Recommendation: 入力値を正規表現で検証、許可リストで確認してください

2. ERR-03: error_exit使用
   - File: `scripts/backup.sh` L45
   - Problem: エラー時にecho+exit 1を使用、共通関数未使用
   - Impact: 一貫性のないエラーハンドリング、ログ欠如
   - Recommendation: `error_exit "バックアップ失敗"` を使用してください
```

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the code being reviewed.

**Global & Base**: SCRIPT_DIR, lib/all.sh source, basic structure → [reference/global.md](reference/global.md)
**Code Standards**: Naming, quoting, script template compliance → [reference/code-standards.md](reference/code-standards.md)
**Function Design**: Function structure, parameters, return values → [reference/function-design.md](reference/function-design.md)
**Error Handling**: error_exit, cleanup trap, error checking → [reference/error-handling.md](reference/error-handling.md)
**Security**: Input validation, path traversal, privilege escalation → [reference/security.md](reference/security.md)
**Performance**: Command efficiency, unnecessary forks, pipelines → [reference/performance.md](reference/performance.md)
**Testing**: Unit tests, mock functions, bats usage → [reference/testing.md](reference/testing.md)
**Documentation**: Function docstrings, usage examples, comments → [reference/documentation.md](reference/documentation.md)
**Dependencies**: External commands, version requirements, aqua → [reference/dependencies.md](reference/dependencies.md)
**Logging**: log_info, log_warn, log_error usage → [reference/logging.md](reference/logging.md)

## Best Practices

When performing code reviews:

- **建設的・具体的に**: コード例を含む推奨事項、共通ライブラリ参照
- **コンテキスト考慮**: PR目的と要件理解、トレードオフ検討
- **優先度明確化**: "must fix"と"nice to have"の区別
- **MCPツール活用**: serenaでプロジェクト構造確認、grep_searchでパターン検索
- **自動チェック優先**: 構文エラーやshellcheckへの過度な焦点回避
- **セキュリティ見落とし防止**: SEC-\*項目は特に注意深く
- **プロジェクト標準遵守**: lib/all.sh共通ライブラリ活用を重視

## Summary

This skill provides:

1. **Comprehensive review guidelines** - 10 categories covering all aspects
2. **Structured output format** - Consistent, parseable review results
3. **Clear process** - Step-by-step review workflow
4. **Prioritization** - Critical vs. minor issues
5. **Actionable recommendations** - Specific fix suggestions with code examples
6. **Domain-specific organization** - Load only relevant categories for efficient token usage

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
