## Anti-Patterns (AP)

**AP-01 (SHOULD): Omit set -euo/main/entry guard from sourced libs**

Check: Are executable-script requirements (`set -euo pipefail`, `main`, entry guard) avoided on sourced library files?
Why: Sourced modules are not entry points; executable guards break `source` usage and duplicate init logic
Fix: Omit shebang guards, `main`, and `parse_arguments` from `lib/*.sh`; match sibling library style

**AP-02 (SHOULD): Keep header/function DOC blocks when refactoring**

Check: Are header and function DOC blocks kept when refactoring?
Why: Removing comments to shorten diffs hides API contracts and breaks review expectations
Fix: Keep DOC blocks; judge documentation quality against DOC checklist items

**AP-03 (SHOULD): Function docs include Globals: (or None)**

Check: Does every function doc block include `Globals:` with `None` when no caller globals apply?
Why: Omitting the section makes caller side effects unclear
Fix: Add `Globals:` followed by `None` when a function uses only locals
Reference: [Google Shell Style Guide — Function Comments](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments)

**AP-04 (SHOULD): Match sibling lib/\*.sh comment/separator style**

Check: Do sibling `lib/*.sh` files share the same comment and separator style?
Why: Mixed styles in one directory increase review cost and drift
Fix: Match the enclosing directory's established library format
