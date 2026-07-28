## Documentation (DOC)

**DOC-01 (MUST): Header has Description/Usage/Design Rules**

Check: Does file header contain Description/Usage/Design Rules?
Why: Missing header makes script purpose unclear, usage unknown, delays onboarding
Fix: Add standard header with Description/Usage/Design Rules

**DOC-02 (SHOULD): Functions document Globals/Arguments/Outputs/Returns**

Check: Does each function include a description line plus `Globals`, `Arguments`, `Outputs`, and `Returns` sections with explicit `None` when a section does not apply, using the same separator convention as sibling files?
Why: Missing sections or implicit omission reduce review efficiency and hinder maintenance
Fix: Match sibling file style; document all four API sections per [Google Shell Style Guide — Function Comments](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments)
Reference: [Google Shell Style Guide — Function Comments](https://google.github.io/styleguide/shellguide.html#s4.2-function-comments)

**DOC-03 (SHOULD): Globals comment purpose/unit/constraints**

Check: Do global variables have purpose/unit/constraint comments?
Why: Unclear variable purpose causes misuse, bugs, difficult maintenance
Fix: Comment global variables with unit/default value/constraints
