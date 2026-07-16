## Anti-Patterns (AP)

**AP-01 (SHOULD): Executable Rules on Sourced Libraries**

Check: Are executable-script requirements (`set -euo pipefail`, `main`, entry guard) avoided on sourced library files?
Why: Sourced modules are not entry points; executable guards break `source` usage and duplicate init logic
Fix: Omit shebang guards, `main`, and `parse_arguments` from `lib/*.sh`; match sibling library style

**AP-02 (SHOULD): Preserve DOC Comment Blocks**

Check: Are header and function DOC blocks kept when refactoring?
Why: Removing comments to shorten diffs hides API contracts and breaks review expectations
Fix: Keep DOC blocks; use shell-script-review for documentation quality judgment

**AP-03 (SHOULD): Global Variables Section Required**

Check: Does every function doc block include `Global Variables:` with `None` when no caller globals apply?
Why: Omitting the section makes caller side effects unclear
Fix: Add `Global Variables:` followed by `None` when a function uses only locals

**AP-04 (SHOULD): Consistent Library Comment Style**

Check: Do sibling `lib/*.sh` files share the same comment and separator style?
Why: Mixed styles in one directory increase review cost and drift
Fix: Match the enclosing directory's established library format
