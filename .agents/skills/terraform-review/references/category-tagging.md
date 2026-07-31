# Tagging (TAG)

**TAG-01 (MUST): Apply Name via merge(local.tags, { Name = "..." })**

Check: Do tags use merge pattern with common tags?
Why: Individual Name tag settings and unused merge function cause lack of consistency and tag management difficulties
Fix: Use `merge` function for common tags + individual Name
