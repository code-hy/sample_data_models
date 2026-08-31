# MODEL_COMPLETENESS_DEFINITION_OF_DONE.md — Definition of Done for Any Data Model

> **Use for:** Every new model, every model modification, every reverse-engineered model.  
> **A model is NOT "done" until every criterion is met.**

---

## Definition of Done — Mandatory (All Must Pass)

### 1. Business Correctness

- [ ] **Grain defined** — "One row represents..." in one sentence
- [ ] **Business key identified** — What the business uses to identify the entity
- [ ] **Business rules encoded** — Constraints, checks, or documented in dictionary
- [ ] **Lifecycle modelled** — States, transitions, effective dates
- [ ] **History strategy explicit** — SCD type justified and documented
- [ ] **Authoritative source per attribute** — No ambiguity on ownership
- [ ] **Domain SME reviewed + approved** — Signature in catalogue

### 2. Structural Soundness

- [ ] **Primary key** — Defined, non-null, unique (surrogate or business)
- [ ] **Foreign keys** — All relationships valid, cardinality correct
- [ ] **M:N resolved** — Bridge/associative entities with own grain
- [ ] **Optionality correct** — Mandatory vs. optional per business rule
- [ ] **No circular dependencies** — Verified in lineage graph
- [ ] **Normalisation appropriate** — 3NF for core, star for presentation, documented if denormalised

### 3. Technical Implementability

- [ ] **Physical DDL** — Executable on target platform (Snowflake/Databricks/Postgres/Redshift)
- [ ] **Data types** — Precision, scale, timezone correct per attribute
- [ ] **Partitioning** — Defined if table > 100M rows or time-series
- [ ] **Clustering/Sort keys** — Aligned with top 3 query patterns
- [ ] **Incremental strategy** — Merge/append/snapshot with merge keys defined
- [ ] **Late-arriving data** — Handling logic defined (late dimension, late fact)
- [ ] **Schema evolution** — Add/drop/rename column plan documented

### 4. Data Quality (Executable Tests)

- [ ] **Not Null** — All PK, FK, mandatory business attributes
- [ ] **Unique** — PK, business key, alternate keys
- [ ] **Referential Integrity** — All FKs → referenced PK (cross-layer too)
- [ ] **Domain/Allowed Values** — Every coded attribute (`status`, `type`, `currency`)
- [ ] **Freshness** — Max data age SLA per source (`warn_after` / `error_after`)
- [ ] **Row Count** — Min/max expected per load window
- [ ] **Custom Business Rules** — e.g., `amount > 0`, `date <= today`

### 5. Governance & Metadata

- [ ] **Classification** — public / internal / confidential / restricted
- [ ] **PII Tagged** — Every column with personal data
- [ ] **CDE Tagged** — Critical Data Elements identified
- [ ] **Owner + Steward** — Team + individual assigned
- [ ] **Retention** — Years documented, aligns with policy
- [ ] **Lineage** — Source-to-target mapping complete (template filled)
- [ ] **Business Definition** — Every entity + column (one sentence each)
- [ ] **Glossary Links** — Terms linked to business glossary

### 6. Documentation

- [ ] **Entity Catalogue Entry** — Complete (template `ENTITY_CATALOGUE_ENTRY.md`)
- [ ] **Data Dictionary** — Table + column level (markdown or catalog)
- [ ] **ERD** — Logical + Physical (Mermaid `.mmd` + rendered PNG)
- [ ] **Source-to-Target Mapping** — Complete (template `SOURCE_TO_TARGET_MAPPING.md`)
- [ ] **ADR** — Linked if methodology deviation, denormalisation, or breaking change
- [ ] **Changelog** — This version entry added

### 7. Review Gates (All Required Signatures)

| Reviewer | Scope | Signature | Date |
|----------|-------|-----------|------|
| Senior Data Modeller | Structure, grain, keys, standards | | |
| Data Engineering Lead | Performance, partitioning, CI/CD | | |
| Domain SME / BA | Business correctness, definitions | | |
| Data Governance | Classification, PII, retention, CDE | | |
| Architecture | Cross-layer, methodology (if needed) | | |

### 8. Operational Readiness

- [ ] **Migration Script** — Idempotent, rollback tested, backfill plan (if breaking)
- [ ] **Deployment** — CI/CD pipeline passes, feature flag if risky
- [ ] **Monitoring** — Freshness alert, row count anomaly, test failure alert
- [ ] **Runbook** — Common failure modes + remediation steps
- [ ] **Consumer Notification** — Slack + email + catalogue update
- [ ] **Parallel Run** — 2 weeks (if consumer-facing change)

---

## Definition of Ready (For Sprint Planning)

A model ticket is **Ready** when:

- [ ] Business requirements linked (Jira/Linear/GitHub issue)
- [ ] Source system access confirmed
- [ ] SME available for questions
- [ ] Grain defined (or "TBD — needs workshop" flagged)
- [ ] Target layer + methodology identified
- [ ] Dependencies on other models mapped
- [ ] Effort estimated (Story Points)
- [ ] Acceptance criteria = this DoD checklist

---

## Graduation Levels (Maturity Model)

| Level | Name | Criteria |
|-------|------|----------|
| 0 | **Draft** | Conceptual only, no physical design |
| 1 | **Designed** | Logical + Physical complete, DoD 1-3 met |
| 2 | **Implemented** | DDL deployed to dev, tests written, DoD 4 met |
| 3 | **Validated** | All tests pass in CI, SME approved, DoD 5-6 met |
| 4 | **Production** | Deployed to prod, monitoring active, DoD 7-8 met |
| 5 | **Certified** | 90 days stable, zero P1 incidents, consumer satisfaction ≥ 4/5 |

**Only Level 4+ models go in the official Model Catalogue.**

---

## Anti-Patterns That Block "Done"

| Anti-Pattern | Block Level |
|--------------|-------------|
| "We'll document later" | Level 0 |
| No grain statement | Level 0 |
| Business key missing | Level 1 |
| SCD type not decided | Level 1 |
| No tests in CI | Level 2 |
| Governance tags missing | Level 3 |
| No consumer notification | Level 3 |
| Migration untested | Level 4 |
| No monitoring | Level 4 |

---

## Quick Self-Check (Before Submitting PR)

```
□ Can I explain the grain in one sentence to a business user?
□ Does every column have a business definition (not technical)?
□ Are all PK/FK/UK constraints in the DDL?
□ Are dbt tests written for every quality rule?
□ Is the catalogue entry complete enough for a new hire to understand?
□ Have I tagged PII and CDEs?
□ Is there an ADR if I deviated from standards?
□ Can this be rolled back in < 1 hour?
□ Did I notify every downstream consumer?
```