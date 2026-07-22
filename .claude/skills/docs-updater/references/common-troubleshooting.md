## Troubleshooting

- **`skip` true or no actionable `findings`:** Emit four-section report plus PR `## Overview` and `## Summary`; Summary outcome `No documentation impact detected`; stop without edits.
- **Finding path on denylist:** Classify as Watch or Noise / Ignore; do not edit.
- **>3 sections in one file:** Defer file as Watch; recommend manual review.
- **>20 findings:** Fix first 10 High-Priority items; note truncation in Summary.
- **Affected doc file missing:** Skip that file; note in report; continue other findings.
