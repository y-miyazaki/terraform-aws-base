## Global / Base (G)

**G-01 (MUST): Set SCRIPT_DIR**

Check: Is SCRIPT_DIR set for reliable relative path resolution?
Why: Missing SCRIPT_DIR creates execution directory dependency and breaks relative file references
Fix: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`

**G-02 (SHOULD): No Hardcoded Secrets**

Check: Are API keys, passwords, and tokens not embedded in scripts?
Why: Embedded secrets cause security breaches, credential leakage, Git history pollution
Fix: Use environment variables or AWS Secrets Manager, remove constants

**G-03 (MUST): Follow Function Order**

Check: Is order show_usage→parse_arguments→functions a-z→main last?
Why: Inconsistent function order reduces readability and lowers review efficiency
Fix: Place show_usage→parse_arguments→other functions in a-z order→main last

**G-04 (SHOULD): Remove Dead Code**

Check: Are there no commented code, unused functions, or unreachable code?
Why: Dead code hinders maintenance, causes confusion, increases unnecessary lines
Fix: Use git history, remove dead code, manage TODO comments appropriately

**G-05 (SHOULD): Script Idempotency**

Check: Does script run without errors on re-execution?
Why: Re-execution errors and lingering side effects make operations difficult, cause deployment failures, prevent retries
Fix: Check existence, use idempotent operations, execute after state verification
