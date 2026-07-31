# Global / Base (G)

**G-01 (MUST): Set SCRIPT_DIR when sourcing or resolving relative paths**

Check: When the script sources libraries or resolves relative paths, is `SCRIPT_DIR` set?
Why: Missing `SCRIPT_DIR` breaks relative `source` and path resolution
Fix: `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"` — no `export` unless a child process requires it; omit when the script uses only environment variables or absolute paths

**G-02 (SHOULD): No secrets embedded in scripts**

Check: Are API keys, passwords, and tokens not embedded in scripts?
Why: Embedded secrets cause security breaches, credential leakage, Git history pollution
Fix: Use environment variables or AWS Secrets Manager, remove constants

**G-03 (MUST): Order show_usage → parse_arguments → a-z → main**

Check: Is order show_usage→parse_arguments→functions a-z→main last for executable entry scripts?
Why: Inconsistent function order reduces readability and lowers review efficiency
Fix: Place show_usage→parse_arguments→other functions in a-z order→main last

**G-04 (SHOULD): Re-runs are safe when operationally required**

Check: Does the script run without harmful side effects on re-execution when that is an operational requirement?
Why: Re-execution errors and lingering side effects make operations difficult, cause deployment failures, prevent retries
Fix: Check existence, use idempotent operations, execute after state verification
