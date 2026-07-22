## Troubleshooting

- **`skip` true or empty actionable `failures`:** Emit all four report sections; Summary Outcome `no actionable failures`; stop without edits.
- **Validation tooling missing:** Defer as Watch unless fixing a single line reported in `log_excerpt`.
- **`failure_type` contradicts `log_excerpt`:** Reclassify per `common-checklist.md`; treat detect type as hint only.
- **>3 failures:** Fix first `regression` only at `L2`/`L3`; defer remainder as Watch.
