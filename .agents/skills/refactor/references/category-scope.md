## Path Scope

### How scope is resolved

| Mode | Allowlist | Denylist |
| ---- | --------- | -------- |
| **Interactive** — no path constraints in prompt or JSON | **Unrestricted** within [Skill-specific limits](#skill-specific-limits) and [ignore conventions](#ignore-conventions) | **None from skill** — follow repository security instructions |
| **Interactive** — user `allowlist` / `denylist` | User allowlist globs only (within skill-specific limits) | User denylist globs |
| **Loop** | Caller `allowlist` — repeated in prompt `## Constraints` as `Allowed paths: …` | Caller `denylist` — enforced by loop-execute verifier (may be empty; not inlined in prompt unless caller criteria mention it) |

Skills do **not** ship a repository-wide default denylist. Per-repo deny rules belong in caller workflows, repository instructions (`AGENTS.md`), or explicit user constraints — not in skill references.

Do **not** treat [Loop caller examples](#loop-caller-examples-this-repository) as interactive scope. Those configure `on-loop-*.yaml` only.

### Ignore conventions

When discovering targets, skip paths ignored by `.gitignore` or `.cursorignore` unless the user explicitly names the path.

Do not edit paths that appear to hold secrets (environment files, credential stores, private keys) even when no denylist is set — follow repository security instructions.

### Skill-specific limits

- Survey all in-scope candidates in one run; apply all marked **apply** in Phase B — do not expand into repo-wide cleanup beyond resolved scope
- Generated agent trees (`.agents/`, `.claude/`, `.cursor/`, …) are not edit targets in the config repo; edit `.apm/packages/` sources instead

### Loop caller examples (this repository)

| Key | Example |
| --- | ------- |
| `allowlist` | `.apm/packages/**`, `scripts/**` |
| `denylist` | *(omitted in `on-loop-refactor.yaml` — set per repository if needed)* |
