## Run Ledger and REJECT Retry Policy

Configured via workflow `env` (read by `detect_ci_failures.sh`):

| Variable                         | Default                                  | Description                                                                                                                                             |
| -------------------------------- | ---------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CI_SWEEPER_REJECT_RETRY_POLICY` | `block`                                  | `block` (A): skip any ledgered run. `retry` (B): skip only `pr-created`. `limited` (C): skip `rejected` after max retries. Aliases `a`/`b`/`c` accepted |
| `CI_SWEEPER_REJECT_MAX_RETRIES`  | `3`                                      | Used when policy is `limited` — block after this many REJECT outcomes for the same `workflow_run_id`                                                    |
| `CI_SWEEPER_LEDGER_FILE`         | `.loop/state-ci-sweeper-run-ledger.json` | Ledger path keyed by `workflow_run_id`                                                                                                                  |

On each update, `update_run_ledger.sh` drops `runs` entries whose `updated_at` is older than **30 days** (aligned with `loop-run-log` and state target retention).

Ledger-skipped runs belong in the **Ignored** section of the triage report.
