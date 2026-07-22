## Validation Commands

After edits, run stack-appropriate validation using domain skills named in the prompt **`## Instructions`** section (caller `prompt_instructions`). Do not assume fixed skill paths from this reference.

| Changed area (hint)      | Action                                                                 |
| ------------------------ | ---------------------------------------------------------------------- |
| GitHub Actions workflows | Invoke validation skill from `## Instructions` for workflow/YAML edits |
| Shell scripts            | Invoke validation skill from `## Instructions` for shell edits         |
| Markdown docs            | Invoke validation skill from `## Instructions` for doc edits           |
| Go sources               | Invoke validation skill from `## Instructions` for Go edits            |
| APM packages             | `apm audit --ci` when APM manifest or packages changed                 |

List commands run and their outcome in the report **Summary** section.
