### 1. Global / Base (G)

**G-01: Set SCRIPT_DIR and Source lib/all.sh**

Check: Is SCRIPT_DIR set and lib/all.sh sourced?
Why: Missing SCRIPT_DIR and common library prevents using common functions, creates execution directory dependency
Fix: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"; source "${SCRIPT_DIR}/../lib/all.sh"`

**G-02: No Hardcoded Secrets**

Check: Are API keys, passwords, and tokens not embedded in scripts?
Why: Embedded secrets cause security breaches, credential leakage, Git history pollution
Fix: Use environment variables or AWS Secrets Manager, remove constants

**G-03: Follow Function Order**

Check: Is order show_usage→parse_arguments→functions a-z→main last?
Why: Inconsistent function order violates project standards, reduces readability, lowers review efficiency
Fix: Place show_usage→parse_arguments→functions a-z→main last

**G-04: Remove Dead Code**

Check: Are there no commented code, unused functions, or unreachable code?
Why: Dead code hinders maintenance, causes confusion, increases unnecessary lines
Fix: Use git history, remove dead code, manage TODO comments appropriately

**G-05: Use error_exit for Error Handling**

Check: Is error_exit function used on errors?
Why: Direct exit 1 execution skips cleanup, inconsistent error messages, difficult debugging
Fix: Use error_exit function for unified error handling

**G-06: Script Idempotency**

Check: Does script run without errors on re-execution?
Why: Re-execution errors and lingering side effects make operations difficult, cause deployment failures, prevent retries
Fix: Check existence, use idempotent operations, execute after state verification
