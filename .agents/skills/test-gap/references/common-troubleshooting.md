# Troubleshooting

- **Detect non-zero exit or `status: "error"`:** Read stdout; stop and report the error text — do not treat it as success-path detect JSON.
- **Detect unavailable (no `git`/`jq`, or the script cannot run):** Gather candidates from the user request and repository tools (file listing, existing test tree); do not silent no-op.
- **Detect `warnings[]` present:** Mention them in Overview; continue with the available hotspots.
- **No candidate outside the ledger:** Emit survey no-op per `common-output-format.md` (Overview explains no-op); do not write files.
- **Repository test layout not found:** Survey only; explain in Overview which layout signals were missing.
- **Target needs a production change to be testable:** Pick the next candidate, or list the target under `### Deferred`.
