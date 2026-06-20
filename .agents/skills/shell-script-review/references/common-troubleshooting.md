## Troubleshooting

- If no shell scripts are changed in PR, return `status: skipped` with reason.
- If validation output remains unavailable after one rerun request, continue reviewable checks and defer the rest.
- If reference files are missing, report missing reference path and stop to avoid unverifiable review.
