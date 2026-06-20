## Troubleshooting

- If input JSON schema validation fails, return `status: failed` and include the schema plus a valid minimal JSON example.
- If `document_type` inference returns multiple candidates or no candidate, stop before write actions and request explicit `document_type`.
- If `docs/` does not exist, create `docs/` first and continue.
- If selected template file is missing, fall back to `general` template and record fallback in report.
- If duplicate check fails, return `status: failed` and stop before write actions.
- If README markers are malformed, skip marker update and report as deferred with reason.
