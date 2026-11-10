# Troubleshooting

- **`skip` true or empty actionable `failures`:** Emit survey no-op per `common-output-format.md` (Overview explains no-op); stop without edits.
- **Validation tooling missing:** Defer the failure (Watch in survey, Deferred in apply) unless fixing a single line reported in `log_excerpt`.
- **`failure_type` contradicts `log_excerpt`:** Reclassify per `common-checklist.md`; treat detect type as hint only.
- **>3 failures:** When `agent_edit_allowed` is `true`, fix only the first `regression`; list the remainder under `### Deferred`.
