# Senior Data Modeller — 90-Day Kickstart Playbook

> **Role:** Senior/Lead Data Modeller & Data Architecture Specialist  
> **Mission:** Transform ambiguous business requirements into high-quality, governed, scalable, maintainable, implementation-ready data models.  
> **Philosophy:** Business first. Grain is fundamental. Keys must be deliberate. Explicit over implicit. History is a requirement. Governance by design. Data quality by design. Technology-aware but technology-independent. Simplicity. Traceability.

---

## Phase 0: Before Day 1 (Preparation)

| Action | Why | Done? |
|--------|-----|-------|
| Request org chart, data team structure, reporting lines | Know who owns what | ☐ |
| Ask for: data strategy doc, architecture diagrams, platform inventory, glossary, data catalog link | Hit the ground with context | ☐ |
| Review public filings, investor decks, product pages | Understand the business model | ☐ |
| Prepare your "elevator pitch": what you do, how you help, what you need | Sets expectations immediately | ☐ |

---

## Week 1: Orientation & Discovery

### 1.1 Stakeholder Map (Day 1–2)

Create a living document:

| Role | Name | Domain | Pain Points (suspected) | Meeting Booked? |
|------|------|--------|-------------------------|-----------------|
| Head of Data/Analytics | | | | ☐ |
| Data Engineering Lead | | | | ☐ |
| Platform/Cloud Ops | | | | ☐ |
| Business Analysts (2–3) | | | | ☐ |
| Domain SMEs (Finance, Product, Ops) | | | | ☐ |
| Data Governance/Privacy | | | | ☐ |
| Downstream Consumers (ML, BI, Ops) | | | | ☐ |

**Book 30-min intros with each.** Ask:
> "What's the one data model or integration that causes the most rework today?"

### 1.2 System Inventory (Day 2–3)

Catalogue **every** data store and movement:

| System | Type | Owner | Tech | Ingest Cadence | Known Issues |
|--------|------|-------|------|----------------|--------------|
| PostgreSQL (Orders) | OLTP | Team A | RDS | CDC | No PK on `order_items` |
| Snowflake | DW | Data Eng | Snowflake | Hourly dbt | Duplicated `customer` dims |
| Kafka | Event Bus | Platform | Confluent | Real-time | Schema registry unused |
| S3 (Lake) | Raw/ Bronze | Data Eng | Delta | Batch | No partitioning strategy |

### 1.3 Artefact Audit (Day 3–5)

Collect and assess:

- [ ] Existing ERDs (logical/physical) — *are they current?*
- [ ] Data dictionary / business glossary — *owned by whom?*
- [ ] dbt / SQL transformation code — *naming, tests, docs?*
- [ ] Data quality reports — *any?*
- [ ] Lineage tool (if any) — *coverage?*
- [ ] Modelling standards doc — *exists? enforced?*

**Deliverable by end of Week 1:** One-page **"Current State Assessment"** (red/amber/green per area) shared with your manager.

---

## Week 2–3: Deep Dives & Quick Wins

### 2.1 Shadow a Critical Pipeline (Week 2)

Pick the **highest-impact, most-complained-about** flow (e.g., `orders → warehouse → finance reporting`).  
Trace it end-to-end:

1. Source schema → 2. Extraction → 3. Staging → 4. Transformation → 5. Presentation → 6. Consumption

Document:
- [ ] Grain mismatches
- [ ] Silent truncation / data loss
- [ ] Business rules buried in SQL
- [ ] Missing SCD handling
- [ ] Performance bottlenecks

### 2.2 Quick Win #1: Fix a Grain Ambiguity (Week 2–3)

Find a fact table where **"one row = ?"** cannot be answered in one sentence.  
Propose and implement:
- [ ] Corrected grain definition
- [ ] DDL
- [ ] dbt model
- [ ] Tests
- [ ] Communication to stakeholders

### 2.3 Quick Win #2: Publish a Canonical Dimension (Week 3)

Identify a **conformed dimension** used inconsistently (e.g., `customer`, `product`, `date`).  
Create the **single authoritative version** with:

- [ ] Surrogate key + business key
- [ ] SCD Type 2 (or justified Type 1)
- [ ] Data quality tests
- [ ] Documentation in the catalog
- [ ] Owner assigned

---

## Week 4–6: Establish Foundations

### 3.1 Define / Refresh Modelling Standards (Week 4)

Produce a **living** `MODELLING_STANDARDS.md` covering:

| Section | Content |
|---------|---------|
| Naming Conventions | Tables, columns, keys, indexes, schemas |
| Key Strategy | When surrogate vs. business, hash-key format (Data Vault), composite rules |
| Normalisation Policy | 3NF for integration layer, dimensional for presentation, denormalisation approval gate |
| Temporal Patterns | SCD types per entity class, bitemporal where needed |
| Data Quality | Mandatory tests (not null, uniqueness, referential, domain, freshness) |
| Governance Tags | Classification, owner, retention, PII, critical data element flag |
| Documentation | Required fields per entity/attribute (definition, grain, source, lineage) |
| Review Gate | PR checklist, required reviewers, architectural sign-off |

**Socialise → iterate → ratify with Data Engineering + Architecture leads.**

### 3.2 Choose Your Modelling Methodology Map (Week 4–5)

Explicitly decide **per domain/layer**:

| Layer | Methodology | Rationale |
|-------|-------------|-----------|
| Source Integration | Data Vault 2.x | Multi-source, audit, history, agile ingestion |
| Enterprise / Core | 3NF / Anchor | Single version of truth, normalised |
| Presentation / Analytics | Kimball Dimensional | Query performance, BI friendliness |
| Data Science / ML | Feature Store / Wide Tables | Model-ready, point-in-time correct |
| Operational / Serving | Denormalised / Materialised Views | Latency, access patterns |

Document the **translation rules** between layers (e.g., Vault → Dimensional).

### 3.3 Set Up Model Review Cadence (Week 5)

- [ ] **Weekly:** New/changed model PR reviews (30 min)
- [ ] **Bi-weekly:** Architecture alignment (you + Data Arch + Platform)
- [ ] **Monthly:** Business stakeholder demo (show model → business question answered)

### 3.4 Build the "Model Catalogue" (Week 5–6)

If no catalog exists, spin up a lightweight one (dbt docs + markdown + git, or DataHub/Amundsen/OpenMetadata).  
Minimum viable fields per entity:

```yaml
entity: customer
layer: presentation/dimensional
grain: "One row per unique customer (business key: customer_id)"
primary_key: customer_sk
business_key: customer_id
scd_type: 2
owner: analytics-team
classification: confidential
source_systems: [crm, billing]
last_reviewed: 2026-01-15
```

---

## Week 7–12: Scale Influence

### 4.1 Lead a Cross-Functional Modelling Workshop (Week 7)

Pick a **gently ambiguous** business area (e.g., "What is a *subscription* across Product, Billing, and Support?").  
Run a 90-min session:

1. Event-storm the process
2. Identify concepts, grains, keys
3. Produce a **conceptual model** on whiteboard/Miro
4. Assign owners for logical → physical

**Outcome:** Shared understanding + documented decisions + your credibility as facilitator.

### 4.2 Tackle a Strategic Model (Week 8–10)

Choose **one** high-leverage model that spans domains (e.g., `Party/Account/Relationship`, `Product Hierarchy`, `Financial Chart of Accounts`).  
Deliver:

- [ ] Conceptual → Logical → Physical (all three)
- [ ] Source-to-target mappings
- [ ] SCD strategy
- [ ] Data quality rule set
- [ ] Migration plan (if replacing legacy)
- [ ] ADR (Architecture Decision Record) justifying choices

### 4.3 Embed in the Development Lifecycle (Week 9–12)

| Gate | Your Role |
|------|-----------|
| Sprint Planning | Review tickets for data model impact; flag early |
| Design Review | Mandatory for any schema change; you approve/deny |
| Code Review | Enforce standards, naming, tests, documentation |
| Release | Verify migration scripts, backward compatibility |
| Incident Retro | Root-cause data model contribution; prevent recurrence |

### 4.4 Mentor & Upskill (Ongoing from Week 6)

- [ ] Pair-model with junior engineers
- [ ] Run a monthly "Modelling Clinic" (bring your tricky problem)
- [ ] Curate a reading list: Kimball, Linstedt, Inmon, *Data Modeling Essentials*, *Designing Data-Intensive Applications*

---

## 90-Day Deliverables Checklist

| # | Deliverable | Audience | Status |
|---|-------------|----------|--------|
| 1 | Current State Assessment (1-pager) | Manager, Data Lead | ☐ |
| 2 | System & Artefact Inventory | Team, Architecture | ☐ |
| 3 | Stakeholder Map + Pain Points | Self, Manager | ☐ |
| 4 | Quick Win #1 (Grain Fix) | Consumers, Eng | ☐ |
| 5 | Quick Win #2 (Canonical Dimension) | All downstream | ☐ |
| 6 | MODELLING_STANDARDS.md (v1.0) | Data Eng, Arch, Gov | ☐ |
| 7 | Methodology Map per Layer | Architecture, Platform | ☐ |
| 8 | Model Review Cadence Established | Team, Stakeholders | ☐ |
| 9 | Model Catalogue (MVP) | Whole Data Org | ☐ |
| 10 | Cross-Functional Workshop Output | Business + Tech | ☐ |
| 11 | Strategic Model Package (Conceptual/Logical/Physical + ADR) | Architecture, Governance | ☐ |
| 12 | 90-Day Retro + Next-Quarter Plan | Manager, Peers | ☐ |

---

## Behavioural Anchors (From SOUL.md)

| Situation | Your Reflex |
|-----------|-------------|
| Ambiguous requirement | **Expose it** — document assumption, impact, question |
| "Just add a column" | **Ask grain, key, history, source, consumer** first |
| Pressure to denormalise | **Quantify trade-off** — performance vs. integrity vs. maintenance |
| Legacy model review | **Validate structure + business meaning + governance** — not just syntax |
| New methodology hype | **Map to problem** — Data Vault / Lakehouse / Dimensional only where justified |
| Silent data quality issues | **Design them out** — constraints, tests, contracts at ingestion |

---

## First-Week Script (Copy-Paste for Your Calendar)

```
Mon 09:00  Manager sync — expectations, 30-60-90, key intros
Mon 10:30  Data Engineering Lead — platform tour, repo access, CI/CD
Mon 14:00  Business Analyst (domain X) — walk a report end-to-end
Tue 09:00  Platform/Cloud — infra, catalog, lineage, governance tools
Tue 11:00  Data Governance — policies, classification, retention, DPIA
Tue 15:00  Shadow pipeline: Orders → Warehouse (pair with DE)
Wed 09:00  Domain SME (Finance) — "What does 'revenue' mean here?"
Wed 13:00  Pull existing ERDs, dbt models, glossary — start inventory
Thu 09:00  Quick Win candidate review with DE lead
Thu 14:00  Draft Current State Assessment
Fri 09:00  Share Assessment with Manager — align priorities
Fri 11:00  Week 1 retro: what surprised me, what I need next week
```

---

## Red Flags to Escalate Early

| Signal | Escalate To |
|--------|-------------|
| No business glossary, no owner | Data Governance / CDO |
| Source systems undocumented / no SME access | Architecture / Engineering Lead |
| "We don't do modelling here" culture | Manager + Data Architecture |
| PII in unclassified tables | Privacy / Legal + Platform |
| Migrations run without review | Engineering Lead + CTO |

---

## Your North Star

> **Every model you touch should be: business-accurate, structurally sound, historically honest, governance-ready, and implementable without heroics.**

If you achieve **three** of the 90-day deliverables *and* shift the team from "drawing tables" to "designing data contracts," you've succeeded.

---

*Generated for Hermes Data Architect persona — see `SOUL.md` for full identity definition.*