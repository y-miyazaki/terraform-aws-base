## 9. Versioning (VERS)

**VERS-01: required_version Aligns with Project Standards**

Check: Does required_version match project standards?
Why: Terraform version mismatch and overly broad range cause no operation guarantee and team environment inconsistency
Fix: Specify project standard version range, follow documentation

**VERS-02: Provider Version Range (>= lower, < upper)**

Check: Do provider versions have both lower and upper bounds?
Why: Insufficient provider version pinning and no upper bound cause unexpected breaking changes and operation failures
Fix: Use appropriate version constraints (`>= 4.0, < 5.0`), set upper bound

**VERS-03: External Module Pinning (Avoid SHA/pseudo version)**

Check: Do modules use tagged versions, not SHA or branch refs?
Why: Fluctuating module versions and SHA direct reference cause unexpected changes and build instability
Fix: Pin to tag versions (`?ref=v1.2.3`), use semantic versioning
