# Scope

## Allowed

- New test files and new test cases under the paths in `Allowed paths`. In interactive mode, which has no `Allowed paths`, use the repository's existing test directories.
- A caller may restrict the stack or test framework (for example Bats only); the caller instructions win over stack discovery.

## Not allowed

- Any file outside `Allowed paths` (production code, workflows, docs, config).
- Deleting, skipping, commenting out, or loosening existing tests or assertions.
- Tests that call real network services, real cloud APIs, or use real credentials.

## Denylist

The automation checker enforces the platform default denylist. Treat denylisted paths as Watch and never edit them.

## Target size

One target per run. A target is one production file (or one public unit inside it) and its paired test file.
