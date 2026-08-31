# STAKEHOLDER_INTERVIEW_QUESTIONS.md — Structured Interview Questions by Role

> **Use for:** Week 1 discovery interviews (30 min each).  
> **Goal:** Uncover pain points, implicit requirements, tribal knowledge, and political landscape.  
> **Technique:** Ask open questions → listen → probe with "Tell me more" / "What happens when..." / "Who decides..."

---

## Universal Opening (All Roles)

1. "Walk me through the last data-related incident that frustrated you. What happened?"
2. "If you could fix one thing about how data works here, what would it be?"
3. "What's a question you *can't* answer reliably with data today?"
4. "Who do you go to when data looks wrong?"

---

## 1. Head of Data / Analytics / CDO

**Focus:** Strategy, org dynamics, investment, success metrics

| # | Question | Probe For |
|---|----------|-----------|
| 1 | "What's the data strategy? How does modelling fit?" | Explicit vs. implicit strategy; modelling as cost vs. asset |
| 2 | "How do you measure data team success?" | SLAs, trust scores, incident count, time-to-insight |
| 3 | "Where is the biggest technical debt in our data layer?" | Legacy models, point-to-point integrations, undocumented logic |
| 4 | "How are modelling decisions made today? Who has final say?" | Governance maturity; architecture review board? |
| 5 | "What's the relationship with Engineering / Product / Finance?" | Friction points; shadow IT; data contracts? |
| 6 | "What would 'good' look like in 12 months?" | Vision alignment; your mandate |
| 7 | "Any regulatory / compliance deadlines driving work?" | GDPR, CCPA, SOX, industry-specific |
| 8 | "Budget for tooling / training / headcount?" | Constraints; quick wins vs. strategic bets |

---

## 2. Data Engineering Lead / Platform Lead

**Focus:** Pipelines, platforms, standards, operational reality

| # | Question | Probe For |
|---|----------|-----------|
| 1 | "Show me the highest-maintenance pipeline. Why?" | Schema drift, late data, quality fires, manual steps |
| 2 | "What's the stack? (Ingest → Store → Transform → Serve)" | Tool sprawl; modern vs. legacy; lock-in |
| 3 | "How do schema changes propagate today?" | Manual ALTERs, dbt contracts, schema registry, breakage |
| 4 | "What's the testing story? (Unit, integration, data quality)" | dbt tests, Great Expectations, custom, none |
| 5 | "How do you handle late-arriving / corrected data?" | Reprocessing window, idempotency, SCD impact |
| 6 | "Partitioning / clustering / indexing strategy?" | Performance pain; cargo-cult configs |
| 7 | "Environments: dev / test / prod parity?" | Data masking, subsetting, CI/CD gates |
| 8 | "What modelling standards exist? Enforced how?" | sqlfluff, dbt contracts, PR checklist, tribal |
| 9 | "Biggest scaling challenge right now?" | Volume, velocity, variety, team throughput |
| 10 | "If I need a new model in prod, what's the path?" | Ticket → design → review → deploy → monitor |

---

## 3. Business Analyst (Domain-Focused)

**Focus:** Business processes, definitions, reporting pain, consumer needs

| # | Question | Probe For |
|---|----------|-----------|
| 1 | "Walk me through [key business process] end-to-end." | Events, actors, decisions, handoffs, systems |
| 2 | "What are the 3 most important metrics you report?" | Definitions, grain, frequency, audience |
| 3 | "Where do definitions disagree across teams?" | "Active customer", "Revenue", "Churn", "Session" |
| 4 | "What's a report that's *always* wrong or late?" | Root cause: grain, source, logic, freshness |
| 5 | "How do you handle 'as of date' questions?" | Point-in-time capability; snapshot vs. SCD |
| 6 | "What business rules live only in your head / Excel?" | Tribal logic; candidate for model encoding |
| 7 | "Who owns the definition of [core concept]?" | Stewardship gaps; multiple owners |
| 8 | "What's the grain of [key fact table]?" | "One row per..." — test their clarity |
| 9 | "How do you validate data before presenting?" | Manual checks, automated tests, trust |
| 10 | "What would make your life 10x easier?" | Self-serve, conformed dims, faster refresh |

---

## 4. Domain SME (Finance, Product, Ops, Marketing, etc.)

**Focus:** Deep business semantics, edge cases, regulatory, source truth

| # | Question | Probe For |
|---|----------|-----------|
| 1 | "What does **[core term]** mean to *you*? Give examples." | Multiple valid definitions; context dependence |
| 2 | "Walk me through the lifecycle of **[core entity]**." | States, transitions, triggers, timestamps |
| 3 | "What identifies a **[core entity]** uniquely?" | Business key candidates; composite; changes |
| 4 | "When **[core entity]** changes, what history matters?" | SCD requirements; audit; legal |
| 5 | "What are the edge cases that break reports?" | Nulls, duplicates, late corrections, cancellations |
| 6 | "Which system is the *golden source* for **[attribute]**?" | Conflicting sources; reconciliation rules |
| 7 | "What regulations constrain this data?" | Retention, PII, residency, audit trail |
| 8 | "How do you handle **[common scenario: return, refund, upgrade, pause]**?" | Business rule complexity; model implications |
| 9 | "What's a decision you made recently based on data?" | Trust level; latency tolerance; granularity |
| 10 | "Who else cares about this data? Who disagrees with you?" | Stakeholder map; political landscape |

---

## 5. Data Governance / Privacy / Compliance

**Focus:** Policies, classification, retention, access, risk

| # | Question | Probe For |
|---|----------|-----------|
| 1 | "What's the data classification scheme? Show me examples." | Public/Internal/Confidential/Restricted — applied where? |
| 2 | "How is PII identified and protected today?" | Tagging, encryption, masking, access control |
| 3 | "Retention policies — documented? Enforced?" | Per domain; legal holds; archive vs. purge |
| 4 | "Data lineage — what's covered? What's missing?" | Tool coverage; manual gaps; regulatory reliance |
| 5 | "Critical Data Elements (CDEs) — list? Owners?" | Formal programme or ad-hoc |
| 6 | "How are data quality issues escalated?" | Process, SLA, ownership, remediation tracking |
| 7 | "Any upcoming regulatory changes?" | New laws, audit findings, contractual |
| 8 | "Model review — does Governance sign off? On what?" | Gate criteria; your future interaction |
| 9 | "Data sharing agreements (internal/external)?" | Contracts, APIs, extracts, governance |
| 10 | "Biggest compliance risk in current architecture?" | Your priority fix list |

---

## 6. Downstream Consumer (ML Engineer, BI Developer, Ops Analyst, App Developer)

**Focus:** Consumption patterns, latency, grain, interface, pain

| # | Question | Probe For |
|---|----------|-----------|
| 1 | "What tables/views do you query most? Show me a query." | Access patterns; join complexity; performance |
| 2 | "What's the grain you *need* vs. what's *available*?" | Mismatch; aggregation logic in consumer code |
| 3 | "How fresh does data need to be?" | Real-time, hourly, daily — SLA vs. reality |
| 4 | "What breaks when schema changes?" | Contract testing; versioning; communication |
| 5 | "Do you build your own derived tables? Why?" | Gaps in presentation layer; self-serve need |
| 6 | "Point-in-time queries — how do you do them today?" | SCD2 usage; snapshot tables; manual workarounds |
| 7 | "What's the hardest question to answer with current model?" | Missing grain, missing attribute, missing history |
| 8 | "How do you test your data products?" | Unit tests, data contracts, monitoring |
| 9 | "Documentation — where do you look? Is it current?" | Catalogue, wiki, tribal, source code |
| 10 | "If you could change one table, what and how?" | Direct input to your roadmap |

---

## 7. Software Engineer / Backend Developer (Source System Owners)

**Focus:** Source schema, CDC, semantics, change management, partnership

| # | Question | Probe For |
|---|----------|-----------|
| 1 | "What's the data model of [source system]? ERD?" | Normalised? Documented? Versioned? |
| 2 | "How do you expose data changes? (CDC, API, batch, logs)" | Debezium, triggers, outbox, batch extract |
| 3 | "What's the semantics of [key column]? Nullable? Immutable?" | Business meaning vs. technical convenience |
| 4 | "How do you handle schema evolution? Breaking changes?" | Deprecation policy; communication; versioning |
| 5 | "Any known data quality issues in source?" | Nulls, duplicates, invalid codes, drift |
| 6 | "What's the transaction boundary? Consistency model?" | Eventual vs. strong; impact on extraction |
| 7 | "Can we add columns / change types for our needs?" | Partnership model; shared ownership |
| 8 | "How do you test data contracts?" | Schema registry, consumer-driven contracts, none |
| 9 | "Incidents — any caused by downstream data loads?" | Load windows, locking, performance impact |
| 10 | "What would make *your* life easier re: data extraction?" | Better CDC, semantic layer, dedicated replica |

---

## 8. Product Manager / Product Owner (Data as Product)

**Focus:** Data products, roadmap, user needs, prioritisation

| # | Question | Probe For |
|---|----------|-----------|
| 1 | "What data products does the team own? Roadmap?" | Defined products vs. tables; SLAs; consumers |
| 2 | "How do you prioritise data work vs. feature work?" | Capacity allocation; tech debt visibility |
| 3 | "What's the feedback loop from data consumers?" | NPS, tickets, office hours, usage analytics |
| 4 | "Any data mesh / data product thinking here?" | Domain ownership; self-serve platform |
| 5 | "How do you define 'done' for a data deliverable?" | Acceptance criteria; validation; handoff |
| 6 | "What's the biggest blocker to shipping data products?" | Platform, governance, skills, prioritisation |

---

## Interview Template (One Page Per Interview)

```
# Interview: <Role> — <Name>
**Date:** YYYY-MM-DD
**Duration:** 30 min
**Interviewer:** <Your Name>
**Context:** Week 1 Discovery / Ongoing

## Key Insights (3–5 bullets)
- 
- 
- 

## Pain Points Mentioned
| Pain Point | Frequency | Impact | Owner if Known |
|------------|-----------|--------|----------------|
|            |           |        |                |

## Implicit Requirements Surfaced
| Requirement | Source Quote | Confidence |
|-------------|--------------|------------|
|             |              | High/Med/Low |

## Tribal Knowledge / Undocumented Rules
| Rule | Domain | Risk if Lost |
|------|--------|--------------|
|      |        |              |

## Stakeholder Map Updates
| Name | Role | Relationship | Influence | Notes |
|------|------|--------------|-----------|-------|
|      |      |              |           |       |

## Action Items for Me
- [ ] 
- [ ] 
- [ ] 

## Follow-Up Needed?
☐ Yes — schedule deep-dive on: _______________  
☐ No
```

---

## Synthesis After Week 1 Interviews (8–12 interviews)

### Affinity Map Themes

| Theme | Frequency | Roles Mentioning | Priority |
|-------|-----------|------------------|----------|
| Grain ambiguity in fact tables | 6/10 | BA, Finance, ML, DE | 🔴 |
| No canonical customer dimension | 5/10 | Marketing, Finance, Support, BA | 🔴 |
| Schema changes break downstream silently | 7/10 | DE, ML, BI, App Dev | 🟠 |
| PII unclassified in warehouse | 4/10 | Gov, Privacy, DE | 🔴 |
| No model review gate | 5/10 | DE, BA, Arch | 🟠 |
| SCD inconsistent / missing | 6/10 | Finance, BA, DE | 🟠 |
| Tribal knowledge > documentation | 8/10 | All | 🟡 |

### Your Week 2 Priorities (Derived from Synthesis)

1. **Quick Win:** Fix top grain ambiguity (Theme 1)
2. **Quick Win:** Publish canonical customer dimension (Theme 2)
3. **Standards Draft:** Schema change contract + model review gate (Themes 3, 5)
4. **Governance Sync:** PII tagging sprint (Theme 4)
5. **Workshop:** Customer/Subscription definition (Theme 6)

---

## Red Flags in Interviews (Escalate)

| Signal | Likely Meaning | Escalate To |
|--------|----------------|-------------|
| "We don't really do modelling" | Cultural resistance | Manager + Architecture |
| "Source team won't give us CDC" | Organizational silo | Data Eng Lead + VP Eng |
| "Definitions change per report" | No governance | Data Governance + CDO |
| "We fix data in Excel before presenting" | Quality crisis | Manager + Data Eng Lead |
| "No one knows who owns [core concept]" | Accountability vacuum | Manager + Domain Leads |
| "Compliance hasn't looked at warehouse" | Regulatory risk | Privacy/Legal + CDO |

---

## Interview Log (Tracker)

| Date | Role | Name | Theme Tags | Status | Follow-Up |
|------|------|------|------------|--------|-----------|
|      | Head of Data | | | ☐ Done | |
|      | DE Lead | | | ☐ Done | |
|      | BA (Finance) | | | ☐ Done | |
|      | SME (Product) | | | ☐ Done | |
|      | Governance | | | ☐ Done | |
|      | ML Engineer | | | ☐ Done | |
|      | Backend Dev (CRM) | | | ☐ Done | |
|      | Product Owner | | | ☐ Done | |
|      | ... | | | | |