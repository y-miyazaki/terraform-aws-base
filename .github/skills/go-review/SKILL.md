---
name: go-review
description: Go code review for correctness, security, performance, and best practices. Use for manual review of Go code checking design decisions and patterns requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

# Go Code Review

This skill provides comprehensive guidance for reviewing Go code to ensure correctness, security, performance, and best practices compliance.

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
- Technical identifiers (function names, variable names, package names, etc.)

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on Go pull requests
- Checking Go code before merging
- Ensuring security and best practices adherence
- Validating design decisions and architecture patterns
- Performance and concurrency review

**Note**: Linting and auto-checkable items (syntax errors, formatting, golangci-lint) are excluded from this review as they should be caught by validation scripts or CI/CD pipelines.

## Review Process

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the purpose of the changes
- Check if this is new feature, bug fix, or refactoring
- Review related tests and documentation updates

### Step 2: Automated Checks First

Verify automated validation has passed:

- `go fmt`
- `go vet`
- `golangci-lint`
- `go test -race -cover`
- `govulncheck`

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
# Go Code Review結果

## Checks

- ERR-01 Error Wrapping: ❌ Fail

## Issues

**該当する指摘事項はありません** (if all checks pass)

**OR**

1. ERR-01: エラーラップ適切
   - File: `pkg/service/processor.go` L45
   - Problem: エラー文字列のみ返却、スタックトレース欠如
   - Impact: デバッグ困難、エラー発生箇所特定不可
   - Recommendation: `fmt.Errorf("failed to process: %w", err)` でラップ

2. CTX-01: public APIでcontext受け取り
   - File: `internal/handler/api.go` L23
   - Problem: ProcessData関数がcontext.Contextを受け取っていない
   - Impact: タイムアウト制御不可、キャンセル伝播不可、テスト困難
   - Recommendation: `func ProcessData(ctx context.Context, data []byte) error` に変更
```

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the code being reviewed.

**Global & Base**: Package structure, imports, naming basics → [reference/global.md](reference/global.md)
**Context Handling**: context.Context propagation, timeout, cancellation → [reference/context.md](reference/context.md)
**Concurrency**: Goroutines, channels, mutexes, race conditions → [reference/concurrency.md](reference/concurrency.md)
**Code Standards**: Naming, style, idioms, simplicity → [reference/code-standards.md](reference/code-standards.md)
**Function Design**: Function signatures, parameters, return values → [reference/function-design.md](reference/function-design.md)
**Error Handling**: Error types, wrapping, sentinel errors → [reference/error-handling.md](reference/error-handling.md)
**Security**: Input validation, crypto, SQL injection, secrets → [reference/security.md](reference/security.md)
**Performance**: Allocations, string concatenation, preallocation → [reference/performance.md](reference/performance.md)
**Testing**: Test structure, table-driven tests, mocking, coverage → [reference/testing.md](reference/testing.md)
**Architecture**: Package design, interfaces, dependency injection → [reference/architecture.md](reference/architecture.md)
**Documentation**: godoc, comments, examples → [reference/documentation.md](reference/documentation.md)
**Dependencies**: Module management, versioning, security → [reference/dependencies.md](reference/dependencies.md)

## Best Practices

When performing code reviews:

- **建設的・具体的に**: コード例を含む推奨事項、共通ライブラリ参照
- **コンテキスト考慮**: PR目的と要件理解、トレードオフ検討
- **優先度明確化**: "must fix"と"nice to have"の区別
- **MCPツール活用**: serenaでプロジェクト構造確認、grep_searchでパターン検索
- **自動チェック優先**: 構文エラーやgo fmt/vet/golangci-lintへの過度な焦点回避
- **セキュリティ見落とし防止**: SEC-\*項目は特に注意深く
- **Go idiomsの重視**: effective Go、common mistakesに準拠

## Summary

This skill provides:

1. **Comprehensive review guidelines** - 12 categories covering all aspects
2. **Structured output format** - Consistent, parseable review results
3. **Clear process** - Step-by-step review workflow
4. **Prioritization** - Critical vs. minor issues
5. **Actionable recommendations** - Specific fix suggestions with code examples
6. **Domain-specific organization** - Load only relevant categories for efficient token usage

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
