## Incident suppression: per-alarm memory directives

The follow-up skills record human operational decisions about a specific alarm into the
`directives` memory store as a single file named `monitors-<alarm-name>`. Before triaging,
investigating, or taking any mitigation action on a firing alarm, honor that memory.

- Before starting triage, an investigation, a mitigation action, or recording an Issue/PR
  for an alarm, read its `monitors-<alarm-name>` memory in `directives` (the memory
  `description` names the alarm).
- IF the memory's `## Suppression` section is `ACTIVE`: do **not** register the alarm as an
  incident, do **not** start an investigation, do **not** run a mitigation action, and do
  **not** create a GitHub Issue or Linear Issue or PR. Record that it was suppressed by an
  active directive (cite the memory name) and stop.
- IF `## Suppression` is `NONE` or absent: proceed normally. The `## History`, `## Root
  cause`, and `## Incidents` sections are still useful context for a faster triage.
- This per-alarm memory suppression is distinct from the category-level suppression rules
  above (failed PostgreSQL operations, RDS/Redshift scheduled stops). A category rule
  suppresses a whole class of alarms; a `monitors-<alarm-name>` memory suppresses one named
  alarm based on a human decision recorded against it.

### Periodic review of active suppressions

An `ACTIVE` suppression silences a real alarm, so it must not live forever unreviewed.

- Each `## History` suppression bullet carries the date it was set. Treat a suppression
  older than **90 days** as stale: surface it (e.g. in the daily health check) for a human
  to confirm the alarm is still intentionally suppressed, rather than silently keeping it.
- A stale suppression is **not** auto-removed — only a human un-suppression instruction
  (recorded by the follow-up skill as `## Suppression: NONE`) lifts it. The review only
  flags it for a human decision.
