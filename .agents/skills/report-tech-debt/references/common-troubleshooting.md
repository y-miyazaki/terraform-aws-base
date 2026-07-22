## Troubleshooting

- **`skip` true or empty `signals` and `hotspots`:** Emit session summary; Outcome `No technical debt signals detected`; do not create `report_file`.
- **Detect `warnings[]` present:** Pass through in Summary; continue classifying available signals.
- **`previous_report` missing:** Proceed without resolved/regression notes; note absence in Summary.
- **Evidence path unreadable:** Classify item as Watch with reason; continue other signals.
- **Critical + High-Priority exceed 25:** Retain all Critical first, then High-Priority; move overflow to Watch with truncation note.
