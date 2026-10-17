---
name: incident-triage-suppression
description: "Triage-stage skip criteria: before scheduling an investigation, read the per-alarm suppression memory monitors-<alarm-name> in directives and SKIP the incident when its ## Suppression is ACTIVE, so no investigation is dispatched (zero agent cost). Target this skill to the Incident Triage agent type."
---

# Incident triage: skip alarms suppressed by a per-alarm memory

**TRIAGE SKIP-CRITERIA SKILL**: runs in the triage stage, before any investigation is
scheduled. It implements custom skip criteria so that an alarm a human has already decided
to suppress is **dismissed at triage without an investigation** — the expensive RCA stage
never starts, so no agent cost is incurred for a known, already-decided alarm.

Target this skill to the **Incident Triage** agent type (tfvars `agent_types = ["INCIDENT_TRIAGE"]`).

## Why this exists

The follow-up skills record human suppression decisions into the `directives` store as
`monitors-<alarm-name>` (see `linear-issue-pr-followup` / `github-issue-pr-followup`). Those
memories are only useful if the **earliest** gate honors them. Honoring suppression inside
the RCA agent is too late — the investigation has already been dispatched and has already
consumed cost. Triage is the first gate (it runs within seconds of the event and decides
Skip / Link / Proceed), so this is where a suppressed alarm must be stopped.

## Input

- The incoming incident: its title (contains the CloudWatch alarm name), description, account, region, and time.
- The `directives` memory store (per-alarm memories named `monitors-<alarm-name>`).

## Skip criteria

At triage, before deciding Proceed:

1. Extract the alarm name from the incident title: the string after the environment prefix
   (`[prd]`/`[stg]`/`[dev]`) and before the first `:`, if present; otherwise the CloudWatch
   alarm name in the description. Convert to lowercase kebab-case (replace spaces and `/` with `-`).
   This is `<alarm-name>`.
2. `get_memory` for `monitors-<alarm-name>` in `directives`.
3. Decision:
   - IF the memory exists AND its `## Suppression` section is `ACTIVE` → **SKIP** this incident.
     Give the skip reason as: suppressed by an active directive `monitors-<alarm-name>`, citing the
     most recent `## History` suppression bullet (date, source Issue ID, commenter, verbatim reason).
     Do **not** schedule an investigation.
   - ELSE (memory absent, or `## Suppression` is `NONE`/absent) → do not skip on this criterion;
     let normal triage correlation proceed (Link to an active related investigation, or Proceed).

## Scope and cautions

- This skill only decides **skip vs. not-skip** for the memory-based suppression criterion. It does
  not override triage correlation (Linked) for genuinely new, non-suppressed incidents.
- Skip is **reversible**: a human can unskip an incident in the web app (it is then rescheduled as
  an independent investigation), and an un-suppression comment flips the memory to `## Suppression:
  NONE` so future occurrences are no longer skipped.
- Do not skip on anything other than an `ACTIVE` per-alarm suppression memory. Category-level
  suppression (failed PostgreSQL operations, RDS/Redshift scheduled stops) is handled by the
  GENERIC `AGENTS.md` rules, not by this skill.
- Read-only: this skill reads memory and emits a triage decision. It does not write memory, post
  comments, or change resources.

<!-- last_verified: 2026-10-17 (triage skip-criteria; review quarterly) -->
