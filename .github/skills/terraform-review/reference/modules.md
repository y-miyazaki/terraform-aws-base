### 2. Modules (M)

**M-01: Review All .tf Files in Module**

- Problem: Partial file review, missing files
- Impact: Hidden bugs, inconsistencies, quality degradation
- Recommendation: Review all `.tf` files in directory
- Check: All module files reviewed

**M-02: Provider Version Appropriateness**

- Problem: Inappropriate provider versions, forced latest, compatibility issues
- Impact: Incompatibility, bugs, existing code breakage
- Recommendation: Specify versions matching project requirements, verify breaking changes
- Check: Provider versions align with project standards

**M-03: Clear Responsibility for locals/variables/outputs**

- Problem: Mixed variables/locals/outputs, unclear responsibilities
- Impact: Reduced readability, maintainability, understanding difficulty
- Recommendation: Proper file/block placement by purpose, separation of concerns
- Check: Clear separation of variables, locals, and outputs

**M-04: Unified Tags and Naming Prefixes**

- Problem: Inconsistent tags and naming, scattered prefixes
- Impact: Difficult resource management, cost allocation impossible, search difficulties
- Recommendation: Centralized management with common variables/locals, use merge function
- Check: Consistent tagging and naming conventions
