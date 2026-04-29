## 2. Modules (M)

**M-01: Review All .tf Files in Module**

Check: Are all module files reviewed?
Why: Partial file review and missing files cause hidden bugs, inconsistencies, and quality degradation
Fix: Review all `.tf` files in directory

**M-02: Provider Version Appropriateness**

Check: Do provider versions align with project standards?
Why: Inappropriate provider versions, forced latest, and compatibility issues cause incompatibility, bugs, and existing code breakage
Fix: Specify versions matching project requirements, verify breaking changes

**M-03: Clear Responsibility for locals/variables/outputs**

Check: Is there clear separation of variables, locals, and outputs?
Why: Mixed variables/locals/outputs and unclear responsibilities cause reduced readability, maintainability, and understanding difficulty
Fix: Proper file/block placement by purpose, separation of concerns

**M-04: Unified Tags and Naming Prefixes**

Check: Are tagging and naming conventions consistent?
Why: Inconsistent tags and naming with scattered prefixes make resource management difficult, cost allocation impossible, and searches difficult
Fix: Centralized management with common variables/locals, use merge function
