# QUICK_WIN_VALIDATION.md — Criteria to Ship a Quick Win Confidently

> **Use for:** Every Quick Win before implementation. If any criterion is "No," iterate or escalate.

---

## Quick Win Definition

A **Quick Win** is a model fix that:
- Takes ≤ 5 engineering days (design + build + test + deploy)
- Addresses a **known, measurable pain point** (reported by ≥ 2 stakeholders)
- Has **clear success criteria** (testable, observable)
- Requires **no architectural decision** (fits existing standards)
- Can be **reverted** in ≤ 1 hour if wrong

---

## Validation Checklist

### 1. Problem Clarity

| Criterion | Yes/No | Evidence |
|-----------|--------|----------|
| Pain point described in business terms (not technical)? | ☐ | |
| ≥ 2 stakeholders confirm the problem? | ☐ | |
| Current workaround documented? | ☐ | |
| Frequency of pain (daily/weekly/monthly)? | ☐ | |
| Estimated hours wasted per occurrence? | ☐ | |

### 2. Solution Fit

| Criterion | Yes/No | Evidence |
|-----------|--------|----------|
| Root cause identified (not symptom)? | ☐ | |
| Solution follows existing standards? | ☐ | |
| No new methodology introduced? | ☐ | |
| No cross-layer architecture change? | ☐ | |
| Grain fixed / dimension conformed / SCD corrected? | ☐ | |

### 3. Technical Feasibility

| Criterion | Yes/No | Evidence |
|-----------|--------|----------|
| Source data available + accessible? | ☐ | |
| Transformation logic < 100 lines SQL? | ☐ | |
| No schema migration on source system? | ☐ | |
| Downstream consumers ≤ 5? | ☐ | |
| Migration script written + tested? | ☐ | |
| Rollback plan ≤ 1 hour? | ☐ | |

### 4. Quality & Tests

| Criterion | Yes/No | Evidence |
|-----------|--------|----------|
| All mandatory tests defined (not null, unique, RI, domain, freshness)? | ☐ | |
| Test data prepared (edge cases: nulls, dupes, late-arriving)? | ☐ | |
| Performance baseline measured? | ☐ | |
| No regression on existing models? | ☐ | |

### 5. Governance & Communication

| Criterion | Yes/No | Evidence |
|-----------|--------|----------|
| Classification tag applied? | ☐ | |
| Owner + steward assigned? | ☐ | |
| Consumers notified (Slack + PR tag)? | ☐ | |
| Documentation updated (catalogue + dictionary)? | ☐ | |
| Changelog entry prepared? | ☐ | |

### 6. Stakeholder Sign-Off

| Role | Name | Approved? | Date |
|------|------|-----------|------|
| Data Modeller (you) | | ☐ | |
| Data Engineering Lead | | ☐ | |
| Domain SME / BA | | ☐ | |
| Data Governance (if PII/CDE) | | ☐ | |

---

## Quick Win Spec Template (One-Pager)

```
# Quick Win: <Title>
**ID:** QW-XXX
**Date:** YYYY-MM-DD
**Owner:** <Name>
**Target Deploy:** YYYY-MM-DD

## Problem
<Business description. "Finance team cannot reconcile daily revenue because fact_order grain mixes order header and line items.">

## Current State
- Model: `fact_order`
- Grain: Ambiguous (1 row = order header OR line item depending on join)
- Impact: 3 hrs/week manual reconciliation, 2 incidents/month

## Solution
- Split into `fact_order_header` (grain: 1 row per order) + `fact_order_line` (grain: 1 row per line item)
- Conform `dim_order` (degenerate dimension) for header attributes
- Update 3 downstream models

## Success Criteria
- [ ] Finance can reconcile daily revenue in < 5 min (automated)
- [ ] Zero grain-related incidents in 30 days
- [ ] All tests pass (not null, unique, RI, freshness)

## Risk & Mitigation
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| Downstream model break | Medium | High | Deploy behind feature flag; parallel run 2 weeks |
| Historical data mismatch | Low | Medium | Backfill script + validation report |

## Effort Estimate
| Task | Days |
|------|------|
| Design + spec | 0.5 |
| DDL + dbt models | 1.5 |
| Tests + docs | 0.5 |
| Migration + backfill | 1.0 |
| Deploy + validate | 0.5 |
| **Total** | **4.0** |
```

---

## Quick Win Tracker

| ID | Title | Problem Owner | Status | Target | Actual | Outcome |
|----|-------|---------------|--------|--------|--------|---------|
| QW-001 | Fix fact_order grain | Finance Lead | 🟡 In Dev | W2 | | |
| QW-002 | Canonical dim_customer | Marketing Lead | 🟢 Spec Done | W3 | | |
| QW-003 | | | | | | |

---

## Escalation Triggers (Stop & Escalate)

- [ ] Solution requires new methodology (Vault, new layer, etc.)
- [ ] > 5 downstream consumers need coordinated migration
- [ ] Source system change required
- [ ] Data Governance raises compliance blocker
- [ ] Effort estimate > 5 days after detailed design
- [ ] No clear rollback path

**Escalate to:** Data Engineering Lead + Architecture + Manager