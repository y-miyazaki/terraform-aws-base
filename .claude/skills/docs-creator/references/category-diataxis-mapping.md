## Diataxis Placement Guide

Directory layout follows [Diataxis](https://diataxis.fr/).

| Quadrant    | Directory           | Purpose                | Characteristics                                        |
| ----------- | ------------------- | ---------------------- | ------------------------------------------------------ |
| Tutorial    | `docs/tutorials/`   | Learning-oriented      | Step-by-step, single happy path, builds understanding  |
| How-To      | `docs/how-to/`      | Task-oriented          | Solves a specific problem, assumes knowledge           |
| Reference   | `docs/reference/`   | Information-oriented   | Describes the system accurately, structured for lookup |
| Explanation | `docs/explanation/` | Understanding-oriented | Why things are the way they are, background, decisions |

Special cases:

- `README.md` → repository root (not under docs/)
- Files that don't fit a quadrant → ask user for explicit `target_file`

## Filename Resolution

1. Derive from topic: "caching architecture" → `caching-architecture.md`
2. Apply kebab-case, lowercase, `.md`
3. Place in the directory matching the quadrant above
4. If a file with the same name exists in a different directory, stop and ask user
