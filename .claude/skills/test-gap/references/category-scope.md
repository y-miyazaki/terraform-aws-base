# Scope

## Allowed

- New test files and new test cases under the paths in `Allowed paths`. In interactive mode, which has no `Allowed paths`, use the repository's existing test directories.
- A caller may restrict the stack or test framework (for example Bats only); the caller instructions win over stack discovery.

## Not allowed

- Any file outside `Allowed paths` (production code, workflows, docs, config).
- Deleting, skipping, commenting out, or loosening existing tests or assertions.
- Tests that call real network services, real cloud APIs, or use real credentials.

## Denylist

When the caller supplies a denylist (in `## Constraints` or the prompt), never edit denylisted paths: leave them out of `### Candidates` (survey) and list them under `### Deferred` (apply) when they were the chosen target.

## Target size

One target per run. A target is one production file (or one public unit inside it) and its paired test file.
