### 9. Versioning (VERS)

**VERS-01: required_version Aligns with Project Standards**

- Problem: Terraform version mismatch, overly broad range
- Impact: No operation guarantee, team environment inconsistency
- Recommendation: Specify project standard version range, follow documentation
- Check: required_version matches project standards

**VERS-02: Provider Version Range (>= lower, < upper)**

- Problem: Insufficient provider version pinning, no upper bound
- Impact: Unexpected breaking changes, operation failures
- Recommendation: Appropriate version constraints (`>= 4.0, < 5.0`), set upper bound
- Check: Provider versions have both lower and upper bounds

**VERS-03: External Module Pinning (Avoid SHA/pseudo version)**

- Problem: Fluctuating module versions, SHA direct reference
- Impact: Unexpected changes, build instability
- Recommendation: Pin to tag versions (`?ref=v1.2.3`), semantic versioning
- Check: Modules use tagged versions, not SHA or branch refs
