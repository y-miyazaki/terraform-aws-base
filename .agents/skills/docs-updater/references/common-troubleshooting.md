## Troubleshooting

- **`skip` true or no documentation impact:** Report no-op; stop without edits.
- **Path outside skill or caller scope:** Skip file; note in report; do not edit.
- **>3 H2 sections in one file:** Stop for that file per UV-04; recommend docs-creator or manual review.
- **Affected doc file missing:** Skip that file; note in report; continue other candidates.
- **`mkdocs.yml` missing:** Skip nav update; continue other patches when applicable.
