### 7. Tagging (TAG)

**TAG-01: Name Tag with merge(local.tags, {Name = "..."})**

- Problem: Individual Name tag settings, unused merge function
- Impact: Lack of consistency, tag management difficulties
- Recommendation: Use `merge` function for common tags + individual Name
- Check: Tags use merge pattern with common tags

**TAG-02: Remove Redundant Manual Tags**

- Problem: Duplicate tag definitions, manual tag descriptions
- Impact: Code redundancy, increased maintenance cost, inconsistency risk
- Recommendation: Use common tag locals, eliminate duplicates, follow DRY principle
- Check: No duplicate tag keys; centralized tag management
