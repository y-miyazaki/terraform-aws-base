## 7. Tagging (TAG)

**TAG-01: Name Tag with merge(local.tags, {Name = "..."})**

Check: Do tags use merge pattern with common tags?
Why: Individual Name tag settings and unused merge function cause lack of consistency and tag management difficulties
Fix: Use `merge` function for common tags + individual Name

**TAG-02: Remove Redundant Manual Tags**

Check: Are there no duplicate tag keys; is tag management centralized?
Why: Duplicate tag definitions and manual tag descriptions cause code redundancy, increased maintenance cost, and inconsistency risk
Fix: Use common tag locals, eliminate duplicates, follow DRY principle
