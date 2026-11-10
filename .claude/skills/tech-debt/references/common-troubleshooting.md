# Troubleshooting

- **`skip` true or empty `signals` and `hotspots`:** Emit survey no-op per `common-output-format.md` (Overview explains no-op); do not create `agent_report_file`.
- **Detect `warnings[]` present:** Pass through in Summary; continue classifying available signals.
- **`previous_report` missing:** Proceed without resolved/regression notes; note absence in Overview.
- **Evidence path unreadable:** Classify item as Watch with reason; continue other signals.
- **Critical + High-Priority exceed 25:** Retain all Critical first, then High-Priority; move overflow to Watch with truncation note.
