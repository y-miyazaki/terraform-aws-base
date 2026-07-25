## Documentation Maintenance Principles

Portable rules for any repository using docs-updater. Consumer repos may publish domain-specific maintainer guides under `docs/` — read those before patching when present.

## Canonical source rule

- One authoritative document per topic; secondary pages link with relative markdown paths (`.md` extension).
- Do not duplicate architecture diagrams, contract tables, or procedural flows across files.
- When a reference doc exists for a detail, link to it instead of copying paragraphs.

## When to update documentation

Update affected docs in the **same change** as the source when:

| Source change                         | Typical doc impact                                             |
| ------------------------------------- | -------------------------------------------------------------- |
| Deleted / renamed file                | Remove or replace paths in links, tables, lists                |
| New file that belongs in a catalog    | Add row to table/list; update nav                              |
| Config / API / interface shape change | Tables, examples, and names in docs that describe that surface |
| Documentation tree change             | Site nav and generated index when the repo maintains them      |

Use [common-impact-map.md](common-impact-map.md) to triage candidates from `detect_changes.sh` output on the interactive path.

## Reject patterns (do not leave in docs)

- Copy-paste of content that already exists in a canonical doc elsewhere
- Broken or stale relative links after renames/deletes
- Examples that contradict the current file tree or config
- Duplicate diagrams or tables for the same topic — one owner doc, others link
- Contradictory descriptions of the same behavior in overview vs reference docs

## Consumer overlay

When the repository ships maintainer routing (for example `docs/**/MAINTAINER.md`, domain design indexes, or checklist appendices), prefer those paths over inventing new canonical locations. This skill does not embed product-specific path tables.
