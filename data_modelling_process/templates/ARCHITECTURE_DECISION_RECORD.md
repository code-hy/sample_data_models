# ARCHITECTURE_DECISION_RECORD.md — Architecture Decision Record Template

> **Use for:** Any modelling decision with lasting impact — methodology choice, denormalisation, SCD type deviation, new layer, tool adoption, breaking change.

---

# ADR-XXXX: <Short Title>

| Field | Value |
|-------|-------|
| **Status** | Proposed / Accepted / Superseded / Deprecated |
| **Date** | YYYY-MM-DD |
| **Deciders** | <Names + roles> |
| **Consulted** | <Names + roles> |
| **Informed** | <Teams / channels> |
| **Supersedes** | ADR-XXXX (if applicable) |
| **Superseded by** | ADR-XXXX (if applicable) |

---

## Context

**What is the problem?** Describe the business/technical situation forcing a decision.

- Current state:
- Pain point:
- Trigger (incident, new requirement, scale, regulation):

**Constraints & Assumptions**

- Technical:
- Organisational:
- Regulatory:
- Timeline:

---

## Decision

**What we decided:** <One-sentence summary>

**Detailed design:**

```mermaid
erDiagram
    <!-- Optional: conceptual/logical diagram -->
```

**Key rationale:**

- Reason 1:
- Reason 2:
- Reason 3:

---

## Alternatives Considered

| Option | Pros | Cons | Why Rejected |
|--------|------|------|--------------|
| 1. <Name> | | | |
| 2. <Name> | | | |
| 3. <Name> | | | |

---

## Consequences

### Positive

- 
- 

### Negative / Risks

- 
- 

### Mitigations

- 
- 

---

## Implementation Plan

| Step | Owner | Target Date | Done? |
|------|-------|-------------|-------|
| 1. | | | ☐ |
| 2. | | | ☐ |
| 3. | | | ☐ |

---

## Validation Criteria

How we'll know this decision worked:

- [ ] Metric 1:
- [ ] Metric 2:
- [ ] Metric 3:

---

## Related Artefacts

- PR: #XXX
- Model files: `path/to/model.sql`, `path/to/model_erd.mmd`
- Migration script: `path/to/migration.sql`
- Documentation: `path/to/doc.md`
- Downstream impact analysis: `link`

---

## Review Date

**Scheduled review:** YYYY-MM-DD (6 months from acceptance)

**Review outcome:** <To be filled at review>