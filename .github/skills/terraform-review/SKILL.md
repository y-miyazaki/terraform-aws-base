---
name: terraform-review
description: Code review guide for Terraform configurations. Use for manual review of Terraform files checking design decisions requiring human judgment. For detailed category-specific checks, see reference/.
license: MIT
---

# Terraform Code Review

This skill provides comprehensive guidance for reviewing Terraform code to ensure correctness, security, maintainability, and best practices compliance.

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
- Technical identifiers (variable names, resource names, module names, etc.)

## When to Use This Skill

This skill is applicable for:

- Performing code reviews on Terraform pull requests
- Checking Terraform configurations before merging
- Ensuring security and compliance standards
- Validating best practices adherence
- Architecture and design review

**Note**: This guide assumes AWS-based Terraform usage. For Azure/GCP environments, some recommendations (especially in the Security section) may need adjustment.

**Note**: Linting and auto-checkable items (syntax errors, naming conventions, terraform fmt/validate, tflint, trivy) are excluded from this review as they should be caught by pre-commit hooks or CI/CD pipelines.

## Review Process

### Step 1: Understand Context

Before starting the review:

- Read the PR description and linked issues
- Understand the purpose of the changes
- Check if this is new infrastructure or modification
- Verify which environment (dev/staging/production) is affected

### Step 2: Automated Checks First

Verify automated checks have passed:

- `terraform fmt -check`
- `terraform validate`
- `tflint`
- `trivy config`

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
     - Recommendation: Specific fix suggestion

### Output Format Example

```markdown
# Terraform Code Review結果

## Checks

- G-02 Secret Hardcoding Prohibition: ❌ Fail

## Issues

**該当する指摘事項はありません** (if all checks pass)

**OR**

1. G-02: Secret Hardcoding Prohibition
   - File: `terraform/modules/api/main.tf` L45
   - Problem: ハードコードされたパスワードが検出されました
   - Impact: セキュリティリスク、Git履歴への機密情報混入
   - Recommendation: variableまたはAWS Secrets Managerを使用してください

2. SEC-03: Resource Policy with Condition
   - File: `terraform/base/s3.tf` L12-15
   - Problem: S3バケットポリシーにCondition句がありません
   - Impact: 意図しないアクセス許可の可能性
   - Recommendation: `aws:SecureTransport` Conditionを追加してください
```

## Available Review Categories

Review categories are organized by domain. Claude will read the relevant category file(s) based on the code being reviewed.

**Global & Base**: Module usage, secrets, versioning, for_each patterns → [reference/global.md](reference/global.md)
**Modules**: Module structure, provider versions, responsibility → [reference/modules.md](reference/modules.md)
**Variables**: Type safety, defaults, descriptions, validation → [reference/variables.md](reference/variables.md)
**Outputs**: Description requirements, sensitive data → [reference/outputs.md](reference/outputs.md)
**Tfvars**: Secret handling, environment separation → [reference/tfvars.md](reference/tfvars.md)
**Security**: Encryption, IAM, resource policies, VPC → [reference/security.md](reference/security.md)
**Tagging**: Tag consistency and requirements → [reference/tagging.md](reference/tagging.md)
**Events & Observability**: Monitoring, alerting, logging → [reference/events.md](reference/events.md)
**Versioning**: Immutable versioning strategies → [reference/versioning.md](reference/versioning.md)
**Naming & Documentation**: Naming conventions, comments → [reference/naming.md](reference/naming.md)
**CI & Lint**: Pre-commit hooks, CI/CD integration → [reference/ci-lint.md](reference/ci-lint.md)
**Patterns**: Design patterns and anti-patterns → [reference/patterns.md](reference/patterns.md)
**State & Backend**: State management, backend configuration → [reference/state.md](reference/state.md)
**Compliance & Policy**: OPA policies, compliance standards → [reference/compliance.md](reference/compliance.md)
**Cost Optimization**: Resource sizing, lifecycle policies → [reference/cost.md](reference/cost.md)
**Performance & Limits**: API limits, parallel exec, large-scale → [reference/performance.md](reference/performance.md)
**Migration & Refactoring**: Import strategies, state migration → [reference/migration.md](reference/migration.md)
**Dependency & Ordering**: depends_on, implicit dependencies → [reference/dependency.md](reference/dependency.md)
**Data Sources & Imports**: Data source usage, imports → [reference/data-sources.md](reference/data-sources.md)

## Best Practices

When performing code reviews:

- **建設的・具体的に**: コード例を含む推奨事項、参考リンク提供
- **コンテキスト考慮**: PR目的と要件理解、トレードオフ検討
- **優先度明確化**: "must fix"と"nice to have"の区別
- **MCP ツール活用**: context7 でモジュールドキュメント確認、serena でプロジェクト構造確認
- **自動チェック優先**: 構文エラーや terraform fmt/validate/tflint/trivy への過度な焦点回避
- **セキュリティ見落とし防止**: SEC-\* 項目は特に注意深く
- **AWS 固有項目の注意**: AWS 固有のチェック項目は他クラウド環境では要調整

## Summary

This skill provides:

1. **Comprehensive review guidelines** - 19 categories covering all aspects
2. **Structured output format** - Consistent, parseable review results
3. **Clear process** - Step-by-step review workflow
4. **Prioritization** - Critical vs. minor issues
5. **Actionable recommendations** - Specific fix suggestions with code examples
6. **Domain-specific organization** - Load only relevant categories for efficient token usage

For detailed checks in each category, refer to the corresponding file in the [reference/](reference/) directory.
