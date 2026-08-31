# MODEL_REVIEW_CHECKLIST.md — PR / Design Review Checklist

> **Use for:** Every model change PR, new model design review, legacy model assessment  
> **Reviewers:** Senior Data Modeller (lead), Data Engineering Lead, Domain SME, Data Governance, Architecture (as needed)

---

## Section 1: Structural Validation

| # | Check | Pass/Fail | Notes |
|---|-------|-----------|-------|
| 1.1 | Primary key defined and non-nullable? | ☐ | |
| 1.2 | Business key identified and documented? | ☐ | |
| 1.3 | Foreign keys valid (referenced table/PK exists)? | ☐ | |
| 1.4 | Relationship cardinalities correct (1:1, 1:M, M:N)? | ☐ | |
| 1.5 | M:N relationships resolved (bridge/associative entity)? | ☐ | |
| 1.6 | Optionality correct (mandatory vs. optional FK)? | ☐ | |
| 1.7 | Identifying vs. non-identifying relationships correct? | ☐ | |
| 1.8 | No circular dependencies? | ☐ | |
| 1.9 | Composite keys documented with column order? | ☐ | |

---

## Section 2: Business Validation

| # | Check | Pass/Fail | Notes |
|---|-------|-----------|-------|
| 2.1 | Grain explicitly defined ("One row represents...")? | ☐ | |
| 2.2 | Grain matches business process? | ☐ | |
| 2.3 | All business concepts represented? | ☐ | |
| 2.4 | Business rules encoded (constraints, check, triggers)? | ☐ | |
| 2.5 | Lifecycle states modelled (status, dates, transitions)? | ☐ | |
| 2.6 | Historical requirements satisfied (SCD type correct)? | ☐ | |
| 2.7 | Authoritative source identified per attribute? | ☐ | |
| 2.8 | Integration rules documented (multi-source conflicts)? | ☐ | |
| 2.9 | Derived attributes flagged with derivation logic? | ☐ | |

---

## Section 3: Technical / Physical Validation

| # | Check | Pass/Fail | Notes |
|---|-------|-----------|-------|
| 3.1 | Data types appropriate (precision, scale, timezone)? | ☐ | |
| 3.2 | Partitioning strategy defined (if > 100M rows)? | ☐ | |
| 3.3 | Clustering / sort keys aligned with query patterns? | ☐ | |
| 3.4 | Indexes defined for FK lookups and common filters? | ☐ | |
| 3.5 | Compression / encoding specified (columnar)? | ☐ | |
| 3.6 | Incremental strategy defined (merge, append, snapshot)? | ☐ | |
| 3.7 | Late-arriving data handling defined? | ☐ | |
| 3.8 | Schema evolution plan (add/drop/rename columns)? | ☐ | |
| 3.9 | Performance baseline / target documented? | ☐ | |
| 3.10 | Storage cost estimated? | ☐ | |

---

## Section 4: Governance & Quality Validation

| # | Check | Pass/Fail | Notes |
|---|-------|-----------|-------|
| 4.1 | Classification tag applied (public/internal/confidential/restricted)? | ☐ | |
| 4.2 | PII fields identified and tagged? | ☐ | |
| 4.3 | Critical Data Elements (CDEs) tagged? | ☐ | |
| 4.4 | Owner + steward assigned? | ☐ | |
| 4.5 | Retention period documented? | ☐ | |
| 4.6 | Data quality rules defined (not null, unique, domain, RI, freshness)? | ☐ | |
| 4.7 | Lineage to source systems documented? | ☐ | |
| 4.8 | Downstream consumers identified + notified? | ☐ | |
| 4.9 | Business definition on every entity + column? | ☐ | |

---

## Section 5: Methodology & Architecture Alignment

| # | Check | Pass/Fail | Notes |
|---|-------|-----------|-------|
| 5.1 | Modelling methodology appropriate for layer? | ☐ | |
| 5.2 | Translation rules to adjacent layers documented? | ☐ | |
| 5.3 | Conformed dimensions used (no duplicate dims)? | ☐ | |
| 5.4 | Reference data externalised (not hard-coded)? | ☐ | |
| 5.5 | Master data entities linked to MDM / golden record? | ☐ | |
| 5.6 | ADR linked (if deviation or denormalisation)? | ☐ | |

---

## Section 6: Documentation & Metadata

| # | Check | Pass/Fail | Notes |
|---|-------|-----------|-------|
| 6.1 | Entity description (business meaning)? | ☐ | |
| 6.2 | Grain statement? | ☐ | |
| 6.3 | Column descriptions (all)? | ☐ | |
| 6.4 | Column data types + nullable? | ☐ | |
| 6.5 | Source-to-target mapping attached? | ☐ | |
| 6.6 | ERD updated (logical + physical)? | ☐ | |
| 6.7 | Data dictionary entry complete? | ☐ | |
| 6.8 | Changelog entry for this change? | ☐ | |

---

## Section 7: Change Management (for modifications)

| # | Check | Pass/Fail | Notes |
|---|-------|-----------|-------|
| 7.1 | Migration script reviewed (idempotent, rollback)? | ☐ | |
| 7.2 | Backfill plan for NOT NULL / type changes? | ☐ | |
| 7.3 | Deprecation period observed (6 months for breaking)? | ☐ | |
| 7.4 | Consumer impact assessment completed? | ☐ | |
| 7.5 | Communication sent to #data-modelling + consumers? | ☐ | |

---

## Review Outcome

| Reviewer | Role | Approve / Request Changes | Comments |
|----------|------|---------------------------|----------|
| | Senior Data Modeller | ☐ Approve / ☐ Changes | |
| | Data Engineering Lead | ☐ Approve / ☐ Changes | |
| | Domain SME | ☐ Approve / ☐ Changes | |
| | Data Governance | ☐ Approve / ☐ Changes | |
| | Architecture | ☐ Approve / ☐ Changes | |

**Final Decision:** ☐ **Approved** — Merge when CI passes  
**Or:** ☐ **Changes Required** — See comments above

---

## Quick-Reference: Common Fail Patterns

| Pattern | Typical Cause | Fix |
|---------|---------------|-----|
| Missing business key | "We use surrogate keys" | Add business key column + unique constraint |
| Grain ambiguity | Fact table serves multiple processes | Split into separate fact tables per grain |
| M:N not resolved | Direct FK both ways | Create bridge table with its own grain |
| SCD Type 1 on dimension | "Simpler" | Justify in ADR or upgrade to Type 2 |
| No freshness test | Forgotten | Add dbt `freshness` block |
| Classification missing | Not enforced | Add governance meta block |
| Downstream not notified | Assumed "they'll see it" | Tag consumers in PR + Slack |