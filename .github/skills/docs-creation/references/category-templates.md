# Document Templates

Use the template matching the document type. Replace all `<placeholder>` values with actual content.
Remove sections that do not apply rather than leaving them empty.

Type model:

- Core types: `specification`, `architecture`, `design_decisions`, `design`, `troubleshooting`, `general`
- Extension types: `module_catalog`, `monitoring`, `performance`, `security_coverage`, `maintenance_notes`, `improvements`
- Project-defined custom types: add a dedicated template section or use `general` as fallback

---

## specification / spec

```markdown
# <Project Name> Functional Specification

This document records the behavioral specifications of <project> that are present in the
implementation but not described in any other document.

## <Major Feature or Pipeline Name>

<Description of the feature or pipeline.>

## <Another Feature>

<Description.>

## Configuration Defaults

| Parameter  | Default   | Notes   |
| ---------- | --------- | ------- |
| `--<flag>` | `<value>` | <notes> |
```

---

## architecture

```markdown
# Architecture Overview

This document provides structural context for AI assistants. It describes the organization
design, account structure, <relevant layout>, and key design decisions.

## <System or Account Structure>

<High-level description.>

- **<Component A>** — <role>
- **<Component B>** — <role>

## <Terraform / Module Layout>

<Directory tree and explanation.>

## Key Design Decisions

See [design_decisions.md](./design_decisions.md) for rationale behind major choices.
```

---

## design_decisions

```markdown
# Design Decisions

Key design decisions and patterns in this repository. Helps AI assistants understand why
things are built a certain way and avoid re-investigating known decisions.

## <Decision Title>

**Decision**: <what was decided>

**Rationale**: <why this approach was chosen>

**Alternatives rejected**:

- <Alternative A> — <reason rejected>
- <Alternative B> — <reason rejected>

## <Another Decision>

<Same structure.>
```

---

## design

```markdown
# Design Document — <Project or Module Name>

## Overview

<One paragraph describing the scope and purpose of this design document.>

## Module Architecture

### <Module or Component Name>

<Description of the module/component.>

```
<directory tree>
```

### Design Policies

- <Policy 1>
- <Policy 2>

## Variable Design

| Variable | Type     | Description   |
| -------- | -------- | ------------- |
| `<name>` | `<type>` | <description> |

## Naming Conventions

<Explain naming patterns used in this project.>
```

---

## module_catalog

```markdown
# Module Catalog

Index of all Terraform modules in this repository with their purpose and usage.

## <Category Name>

### `modules/<path>`

**Purpose**: <what this module manages>

**Inputs**:

| Name    | Type     | Description   |
| ------- | -------- | ------------- |
| `<var>` | `<type>` | <description> |

**Outputs**:

| Name       | Description   |
| ---------- | ------------- |
| `<output>` | <description> |
```

---

## security_coverage

```markdown
# Security Coverage

Coverage matrix for AWS security services managed in this repository.

## Coverage Matrix

| Service   | Implemented | Module           | Notes                                                                     |
| --------- | :---------: | ---------------- | ------------------------------------------------------------------------- |
| <Service> |      ✅      | `modules/<path>` | <notes>                                                                   |
| <Service> |      ❌      | —                | Out of scope. <reason>. See [design_decisions.md](./design_decisions.md). |

## Legend

- ✅ Implemented and managed by this repository
- ❌ Not implemented — reason noted in the Notes column
```

---

## troubleshooting

```markdown
# Troubleshooting

Common issues and their resolutions for <project>.

## <Symptom or Error Message>

**Cause**: <root cause>

**Resolution**:

```sh
<command or steps>
```

**Prevention**: <how to avoid this in future> (optional)

## <Another Issue>

<Same structure.>
```

---

## monitoring

```markdown
# Monitoring

Alert configuration, dashboards, and runbooks for <project>.

## Alerts

| Alert         | Threshold   | Severity           | Runbook                    |
| ------------- | ----------- | ------------------ | -------------------------- |
| `<AlertName>` | <condition> | <Critical/Warning> | [link](#<runbook-section>) |

## Dashboards

<List of dashboards and what they show.>

## Runbooks

### <Alert Name>

1. <Investigation step>
2. <Remediation step>
```

---

## performance

```markdown
# Performance

Benchmarks, known bottlenecks, and tuning guidance for <project>.

## Benchmarks

| Operation   | Baseline | Target  | Notes   |
| ----------- | -------- | ------- | ------- |
| <operation> | <value>  | <value> | <notes> |

## Known Bottlenecks

### <Bottleneck Title>

<Description of the bottleneck and its impact.>

**Mitigation**: <current or recommended approach>

## Tuning

<Configuration parameters that affect performance.>
```

---

## maintenance_notes

```markdown
# Maintenance Notes

Periodic tasks, known operational quirks, and maintenance history for <project>.

## Periodic Tasks

| Task   | Frequency               | Owner  | Notes   |
| ------ | ----------------------- | ------ | ------- |
| <task> | <monthly/quarterly/...> | <team> | <notes> |

## Known Quirks

### <Issue Title>

<Description of the quirk and workaround.>

## History

| Date       | Change        | Author   |
| ---------- | ------------- | -------- |
| YYYY-MM-DD | <description> | <author> |
```

---

## improvements

```markdown
# Improvements

Planned and completed improvements for <project>.

## Planned

| #   | Title   | Priority        | Notes   |
| --- | ------- | --------------- | ------- |
| 1   | <title> | High/Medium/Low | <notes> |

## Completed

| Date       | Title   | PR/Commit |
| ---------- | ------- | --------- |
| YYYY-MM-DD | <title> | <link>    |
```

---

## general

```markdown
# <Document Title>

<One or two sentences describing the document purpose and intended audience.>

## <Section>

<Content.>

## <Section>

<Content.>
```
