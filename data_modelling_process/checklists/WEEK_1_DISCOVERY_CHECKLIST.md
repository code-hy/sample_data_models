# WEEK_1_DISCOVERY_CHECKLIST.md — Day-by-Day Week 1 Orientation Checklist

> **Goal:** By end of Week 1, produce a **Current State Assessment** (1-pager, red/amber/green) for your manager.

---

## Day 1 (Monday) — People & Expectations

| Time | Activity | Owner | Done? | Notes |
|------|----------|-------|-------|-------|
| 09:00 | Manager sync — role expectations, 30/60/90, key intros | You + Manager | ☐ | |
| 10:30 | Data Engineering Lead — platform tour, repo access, CI/CD, environments | You + DE Lead | ☐ | |
| 13:00 | Business Analyst (domain priority) — walk a key report end-to-end | You + BA | ☐ | |
| 15:00 | Set up local dev: git, dbt, IDE, data catalog access, query tool | You | ☐ | |
| 16:30 | Start Stakeholder Map (template in `stakeholder_map.xlsx`) | You | ☐ | |

**End-of-day deliverable:** Stakeholder Map v0.1 (10+ names, roles, booked meetings)

---

## Day 2 (Tuesday) — Platform & Governance

| Time | Activity | Owner | Done? | Notes |
|------|----------|-------|-------|-------|
| 09:00 | Platform/Cloud Ops — infra, catalog, lineage, governance tools, access | You + Platform | ☐ | |
| 10:30 | Data Governance — policies, classification, retention, DPIA, glossary owner | You + Gov | ☐ | |
| 13:00 | Shadow pipeline: highest-impact flow (pair with DE) | You + DE | ☐ | |
| 15:30 | Document pipeline: source → extract → stage → transform → present → consume | You | ☐ | |
| 16:30 | Pull existing ERDs, dbt models, glossary — start System Inventory | You | ☐ | |

**End-of-day deliverable:** System Inventory v0.1 (table: system, type, owner, tech, cadence, issues)

---

## Day 3 (Wednesday) — Domain Deep Dive

| Time | Activity | Owner | Done? | Notes |
|------|----------|-------|-------|-------|
| 09:00 | Domain SME (Finance) — "What does 'revenue' mean here? Walk me through the P&L." | You + SME | ☐ | |
| 10:30 | Domain SME (Product) — "What is a 'subscription'? Lifecycle? States?" | You + SME | ☐ | |
| 13:00 | Domain SME (Operations) — "What breaks most often in daily ops?" | You + SME | ☐ | |
| 15:00 | Review artefact audit: ERDs, glossary, dbt, quality reports, lineage, standards | You | ☐ | |
| 16:30 | Identify Quick Win candidates (grain ambiguity, duplicate dimension) | You + DE Lead | ☐ | |

**End-of-day deliverable:** Artefact Audit v0.1 + 3 Quick Win candidates ranked

---

## Day 4 (Thursday) — Quick Win Selection

| Time | Activity | Owner | Done? | Notes |
|------|----------|-------|-------|-------|
| 09:00 | Quick Win review with DE Lead — pick #1 (grain fix) and #2 (canonical dim) | You + DE Lead | ☐ | |
| 10:30 | Draft Quick Win #1: problem, grain fix, DDL, tests, migration plan | You | ☐ | |
| 13:00 | Draft Quick Win #2: target dimension, SCD design, owner, tests | You | ☐ | |
| 15:00 | Peer review Quick Wins with BA + SME | You + BA + SME | ☐ | |
| 16:30 | Finalise Quick Win specs — ready for dev Monday | You | ☐ | |

**End-of-day deliverable:** Two Quick Win spec docs (ready for implementation)

---

## Day 5 (Friday) — Synthesis & Alignment

| Time | Activity | Owner | Done? | Notes |
|------|----------|-------|-------|-------|
| 09:00 | Draft Current State Assessment (1-pager: People, Systems, Artefacts, Processes, Culture) | You | ☐ | |
| 11:00 | Share Assessment with Manager — align priorities, adjust 30/60/90 | You + Manager | ☐ | |
| 13:00 | Week 1 Retro: What surprised me? What do I need next week? | You | ☐ | |
| 14:30 | Book Week 2 meetings: Workshop, Strategic Model kickoff, Standards drafting | You | ☐ | |
| 16:00 | Push all Week 1 artefacts to team wiki/Confluence/Git | You | ☐ | |

**End-of-week deliverable:** **Current State Assessment v1.0** (shared with Manager + Data Lead)

---

## Current State Assessment Template (1-Pager)

```
# Current State Assessment — Week 1
**Date:** YYYY-MM-DD
**Author:** <Name>
**Confidence:** High / Medium / Low per section

## PEOPLE & GOVERNANCE
| Area | R/A/G | Evidence |
|------|-------|----------|
| Data ownership clear | 🟢/🟡/🔴 | |
| Glossary exists + owned | 🟢/🟡/🔴 | |
| Classification policy | 🟢/🟡/🔴 | |
| Privacy/retention compliance | 🟢/🟡/🔴 | |

## SYSTEMS & PLATFORM
| Area | R/A/G | Evidence |
|------|-------|----------|
| Platform inventory complete | 🟢/🟡/🔴 | |
| Ingestion reliability | 🟢/🟡/🔴 | |
| Catalogue/lineage coverage | 🟢/🟡/🔴 | |
| Environments (dev/test/prod) | 🟢/🟡/🔴 | |

## MODELLING & ARTEFACTS
| Area | R/A/G | Evidence |
|------|-------|----------|
| ERDs current + versioned | 🟢/🟡/🔴 | |
| Standards doc exists + enforced | 🟢/🟡/🔴 | |
| Naming conventions followed | 🟢/🟡/🔴 | |
| SCD strategy consistent | 🟢/🟡/🔴 | |

## PROCESSES & QUALITY
| Area | R/A/G | Evidence |
|------|-------|----------|
| Model review gate exists | 🟢/🟡/🔴 | |
| Data quality tests in CI | 🟢/🟡/🔴 | |
| Freshness monitoring | 🟢/🟡/🔴 | |
| Incident retro includes data model | 🟢/🟡/🔴 | |

## TOP 3 RISKS
1. 
2. 
3. 

## TOP 3 OPPORTUNITIES (Quick Wins)
1. 
2. 
3. 

## PRIORITY ASK FOR WEEK 2
- 
- 
- 
```

---

## Week 1 Success Criteria

- [ ] Stakeholder Map: 10+ roles mapped, 8+ meetings booked
- [ ] System Inventory: 100% of known data stores catalogued
- [ ] Artefact Audit: All 6 categories assessed
- [ ] Pipeline Shadow: One critical flow documented end-to-end
- [ ] Quick Wins: 2 spec'd and approved
- [ ] Current State Assessment: Delivered to Manager + Data Lead
- [ ] Access: All tools, repos, catalog, query access working