# docs-updater Loop Checklist

## Classification

- Stale reference or missing required docs → High-Priority Items (Fixed) at L2+
- Minor drift or needs human judgment → Watch Items (Deferred)
- Out of allowlist or >3 sections in one file → Noise / Ignore or Watch

## Scope Guards

- On loop path, respect caller `allowlist` / `denylist` per `category-scope.md` (allowlist in `## Constraints`; denylist enforced by verifier)
- > 3 sections affected in one doc → defer that file as Watch, recommend manual review
- > 20 findings → fix first 10 High-Priority items, note truncation in Summary

## Output

- Emit all four report sections per `common-output-format-loop.md`
- Include `High-Priority Items (Fixed)` and `Watch Items (Deferred)` headings even when empty
- Before PR synthesis: run `git diff --name-only`; reconcile **Fixes Applied** / **Deferred** per [common-output-format-loop.md](common-output-format-loop.md#fixes--deferred-consistency)
- **Deferred** paths MUST NOT remain in git diff — revert stray edits from earlier attempts

## Error Handling

- `skip` true or no actionable findings → four-section report, empty High-Priority Items, Summary outcome `No documentation impact detected`; stop
- File outside allowlist → classify as Watch or Noise / Ignore
- No findings → same as no-action exit above

## Examples

- Stale workflow reference in a docs table row → High-Priority fix (update the reference)
- Slightly outdated version number → Watch item (low priority)
- Test-only change with no doc impact → Noise / Ignore



