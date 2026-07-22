<!--
Survey-only PR template for loop-refactor (L1) and interactive survey mode.

Load at synthesis time when mode is survey or level is L1.
loop-finalize extracts ## Overview and ## Summary only (no ## Verification).

Rules:
- Summary contains ### Candidates and optional ### Watch only.
- Do NOT emit ### Changes, ### Deferred, or ## Verification.
- Table when 2+ rows; bullet list when one simple item.
- Omit empty ### subsections.
-->

## Overview

<!--
  GOOD: Surveyed sync scripts under scripts/ and found two duplication blocks worth fixing next and one oversized file to defer.
  BAD:  Refactor loop completed at L1.
-->

<one or two sentences: scope surveyed, candidate count, no edits applied>

## Summary

### Candidates

| Target | Evidence | Suggested approach | Priority |
| ------ | -------- | ------------------ | -------- |
| `path` `symbol()` | <plain-language evidence> | <plain-language fix direction> | high \| medium \| low |

### Watch

| Target | Evidence | Why not now |
| ------ | -------- | ----------- |
| `path` | <plain-language evidence> | <plain-language reason> |
