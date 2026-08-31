# MODELLING_STANDARDS.md — Living Data Modelling Standards

> **Version:** 1.0-draft  
> **Owner:** Senior Data Modeller  
> **Status:** 🟡 Under Review — ratify with Data Engineering + Architecture leads  
> **Last Updated:** YYYY-MM-DD

---

## 1. Naming Conventions

### 1.1 General Principles

- Use **snake_case** for all database objects (tables, columns, indexes, constraints)
- Use **singular** table names (`customer`, not `customers`)
- Use **descriptive, unambiguous** names — avoid abbreviations unless org-standard
- Prefix **surrogate keys** with table name: `customer_sk`, `product_sk`
- Prefix **business keys** with `_bk` or use natural name: `customer_id`, `product_code`
- Suffix **foreign keys** with `_fk` or `_sk` matching referenced table: `customer_sk`

### 1.2 Standard Patterns

| Object | Pattern | Example |
|--------|---------|---------|
| Table (entity) | `<singular_noun>` | `customer`, `order`, `product` |
| Table (fact) | `fact_<business_process>` | `fact_order`, `fact_shipment` |
| Table (dimension) | `dim_<concept>` | `dim_customer`, `dim_date` |
| Table (bridge) | `bridge_<concept_a>_<concept_b>` | `bridge_customer_account` |
| Table (reference) | `ref_<concept>` | `ref_currency`, `ref_country` |
| Primary Key | `<table>_sk` / `<table>_id` | `customer_sk`, `order_id` |
| Business Key | `<table>_bk` / natural name | `customer_id`, `product_code` |
| Foreign Key | `<referenced_table>_sk` | `customer_sk` (in `fact_order`) |
| Surrogate Key (Data Vault) | `h_<hub>_hk`, `l_<link>_hk` | `h_customer_hk`, `l_order_customer_hk` |
| Hashdiff (Data Vault) | `<sat>_hd` | `s_customer_hd` |
| Load Timestamp | `load_dts` / `load_ts` | `load_dts` |
| Record Source | `rec_src` | `rec_src` |
| Effective From | `eff_from_dts` | `eff_from_dts` |
| Effective To | `eff_to_dts` | `eff_to_dts` |
| Current Flag | `is_current` | `is_current` |
| Deleted Flag | `is_deleted` | `is_deleted` |

### 1.3 Schema Namespaces

| Schema | Purpose | Example Tables |
|--------|---------|----------------|
| `raw` / `bronze` | Immutable source landing | `raw_crm_customer` |
| `staging` / `silver` | Cleaned, typed, validated | `stg_customer` |
| `integration` / `vault` | Data Vault (hub/link/sat) | `h_customer`, `l_order_customer` |
| `core` / `enterprise` | 3NF enterprise model | `customer`, `account` |
| `presentation` / `gold` | Dimensional / star schema | `dim_customer`, `fact_order` |
| `feature` / `ml` | ML feature store | `ftr_customer_lifetime_value` |
| `serving` / `ops` | Low-latency operational | `mv_customer_summary` |

---

## 2. Key Strategy

### 2.1 Surrogate Keys

| Use Case | Decision |
|----------|----------|
| Dimension tables (Kimball) | **Always** — `dim_customer.customer_sk` |
| Fact tables | **Never** — fact grain = composite of dimension SKs |
| Data Vault Hubs | **Hash keys** — `MD5(UPPER(TRIM(business_key)))` |
| Data Vault Links | **Hash keys** — concatenated hub HKs |
| 3NF Core Tables | **Case-by-case** — prefer business key if stable, single-column, non-PII |
| Reference Data | **Business key** — `ref_currency.currency_code` |

### 2.2 Business Keys

- **Every entity must have a documented business key** (even if surrogate is PK)
- Business key = **what the business uses to identify the object**
- Document: source system, format, uniqueness scope, change frequency
- If business key changes → SCD Type 2 on dimension / new hub record in Vault

### 2.3 Composite Keys

- Allowed in: bridge tables, fact tables (as PK), reference tables
- **Never** use composite PK in dimension tables (use surrogate)
- Document column order explicitly

---

## 3. Normalisation Policy

| Layer | Target Normal Form | Denormalisation Gate |
|-------|-------------------|---------------------|
| Raw / Bronze | 1NF (as-landed) | N/A — immutable |
| Staging / Silver | 3NF | Only for performance-critical staging views |
| Integration / Vault | 3NF + Vault patterns | Never — Vault is insertion-only |
| Core / Enterprise | 3NF / BCNF | Requires ADR + Architecture sign-off |
| Presentation / Gold | Dimensional (star) | Controlled: junk dims, mini-dims, degenerate dims approved by standard |
| Feature / ML | Wide / denormalised | Expected — document point-in-time logic |
| Serving / Ops | As required by latency | Materialised views with refresh SLA documented |

### 3.1 Denormalisation Approval Checklist

- [ ] Query pattern documented (SQL + frequency)
- [ ] Performance baseline measured (current vs. proposed)
- [ ] Data integrity risk assessed (update anomaly, duplication)
- [ ] Maintenance cost estimated (refresh logic, testing)
- [ ] Architecture lead sign-off recorded in ADR

---

## 4. Temporal Patterns (Slowly Changing Dimensions)

### 4.1 SCD Type Selection Guide

| Entity Class | Default SCD Type | Exceptions |
|--------------|------------------|------------|
| Customer / Party | Type 2 | Type 1 for corrections only (with audit) |
| Product | Type 2 | Type 1 for price corrections |
| Employee | Type 2 | — |
| Organisation / Supplier | Type 2 | — |
| Reference / Code Tables | Type 0 (immutable) | Type 1 if business requests |
| Date Dimension | Type 0 | — |
| Transaction / Event | N/A (immutable) | — |
| Periodic Snapshot | N/A (immutable per period) | — |

### 4.2 Standard SCD Type 2 Columns (All Dimensions)

```sql
valid_from_dts    TIMESTAMP_NTZ NOT NULL,  -- business effective start
valid_to_dts      TIMESTAMP_NTZ NOT NULL,  -- business effective end (9999-12-31 for current)
is_current        BOOLEAN NOT NULL,        -- true for latest version
load_dts          TIMESTAMP_NTZ NOT NULL,  -- system load timestamp
```

### 4.3 Bitemporal (When Required)

Add **system-time** columns for regulatory/audit:
```sql
sys_from_dts      TIMESTAMP_NTZ NOT NULL,  -- when record entered system
sys_to_dts        TIMESTAMP_NTZ NOT NULL,  -- when superseded in system
```

---

## 5. Data Quality — Mandatory Tests

Every model (staging, core, presentation) **must** include:

| Test Category | Minimum Tests | Tool |
|---------------|---------------|------|
| **Not Null** | All PK columns, all FK columns, all mandatory business attributes | dbt `not_null` |
| **Uniqueness** | PK, business key, any alternate key | dbt `unique` |
| **Referential Integrity** | All FKs → referenced PK (including cross-layer) | dbt `relationships` |
| **Domain / Allowed Values** | Every coded attribute (`status_code`, `type_code`, `currency_code`) | dbt `accepted_values` |
| **Freshness** | Max data age per source table (e.g., `stg_customer` ≤ 4 hours) | dbt `freshness` |
| **Row Count** | Minimum/maximum expected rows per load | dbt `expect_table_row_count_to_be_between` |
| **Column Distribution** | No unexpected null spikes, cardinality shifts | Elementary / custom |

### 5.2 Critical Data Elements (CDEs)

- Tag columns with `governance: { cde: true, owner: "<team>", classification: "confidential" }`
- CDEs require: **data quality owner, remediation SLA, lineage to source**

---

## 6. Governance Tags (Required on Every Entity)

Add as dbt `meta` or catalog properties:

```yaml
meta:
  governance:
    owner: "analytics-team"           # team responsible for definition & quality
    steward: "jane.doe@company.com"   # individual SME
    classification: "confidential"    # public | internal | confidential | restricted
    retention_years: 7                # legal/regulatory retention
    pii: false                        # true if contains PII
    cde: false                        # true if Critical Data Element
    source_system: "crm"              # authoritative source
    business_definition: "..."        # one-sentence business meaning
```

---

## 7. Documentation Standards

### 7.1 Per Entity (Table/View)

| Field | Required? | Example |
|-------|-----------|---------|
| `description` | ✅ | "One row per unique customer. Grain: customer_id from CRM." |
| `grain` | ✅ | "One row per customer per effective date range (SCD2)" |
| `primary_key` | ✅ | `customer_sk` |
| `business_key` | ✅ | `customer_id` |
| `scd_type` | ✅ | `2` |
| `source_systems` | ✅ | `["crm", "billing"]` |
| `owner` | ✅ | `analytics-team` |
| `classification` | ✅ | `confidential` |
| `columns[*].description` | ✅ | "Customer's legal given name" |
| `columns[*].data_type` | ✅ | `VARCHAR(100)` |
| `columns[*].nullable` | ✅ | `false` |
| `columns[*].pii` | ⭕ | `true` |
| `columns[*].cde` | ⭕ | `false` |

### 7.2 Per Column (Attribute)

- **No generic names** (`data`, `value`, `desc`, `type`, `code`) without qualification
- Prefer: `customer_type_code`, `order_status_code`, `transaction_amount_usd`
- Document **derivation logic** for calculated columns

---

## 8. Model Review Gate (PR Checklist)

### 8.1 Required Reviews

| Reviewer | Scope |
|----------|-------|
| **Senior Data Modeller (you)** | Structure, grain, keys, relationships, standards compliance |
| **Data Engineering Lead** | Performance, partitioning, incremental strategy, CI/CD |
| **Domain SME / BA** | Business correctness, definitions, rules |
| **Data Governance** | Classification, retention, CDE tags, privacy (if PII) |
| **Architecture** | Cross-layer impact, methodology alignment (if new pattern) |

### 8.2 Merge Criteria

- [ ] All mandatory tests pass (CI)
- [ ] Documentation complete (entity + column level)
- [ ] Governance tags applied
- [ ] ADR linked (if methodology deviation or denormalisation)
- [ ] Migration script reviewed (if breaking change)
- [ ] Downstream impact assessed (catalog lineage + consumer notification)

---

## 9. Methodology Selection Map

| Business Need | Recommended Approach | When NOT to Use |
|---------------|---------------------|-----------------|
| Multi-source integration, audit, history, agile ingestion | **Data Vault 2.x** | Single source, simple analytics, team lacks Vault skills |
| Enterprise single version of truth, normalised | **3NF / Anchor** | High-query-volume analytics, BI self-service |
| BI / self-service analytics, known query patterns | **Kimball Dimensional** | Operational write-heavy, complex multi-hop relationships |
| ML feature engineering, point-in-time correctness | **Feature Store / Wide Tables** | General-purpose reporting |
| Low-latency operational serving | **Materialised Views / Denormalised** | Ad-hoc analytical queries |

**Hybrid is default:** `Sources → Vault → Core 3NF → Dimensional Presentation → Feature Store`

---

## 10. Change Management

| Change Type | Process |
|-------------|---------|
| New column (nullable) | PR + tests + docs — standard review |
| New column (NOT NULL) | PR + migration + backfill plan + consumer sign-off |
| Column rename | PR + migration + alias view (6-month deprecation) + consumer sign-off |
| Column type change | PR + migration + data validation + consumer sign-off |
| Drop column/table | ADR + 6-month deprecation notice + consumer migration confirmation |
| New entity | Full model package (conceptual → logical → physical + ADR) |
| Methodology deviation | ADR + Architecture sign-off |
| SCD type change | ADR + data migration plan + historical rebuild if Type 1→2 |

---

## 11. Tooling & Enforcement

| Concern | Tool | Enforcement |
|---------|------|-------------|
| SQL style / formatting | sqlfluff | CI gate |
| Naming conventions | Custom sqlfluff rules + dbt `contracts` | CI gate |
| Test coverage | dbt + Elementary | PR check (min 80% column coverage) |
| Documentation completeness | dbt docs + custom script | PR check (all required meta fields) |
| Lineage | dbt + DataHub/OpenMetadata | Automated on merge |
| Schema drift detection | schemachange / custom | Daily job + alert |

---

## 12. Versioning & Review Cycle

- **Standards version:** Semantic (MAJOR.MINOR.PATCH)
- **Review cadence:** Quarterly + ad-hoc for methodology changes
- **Change process:** PR to this file → review by Data Modeller + Data Eng Lead + Architecture → merge
- **Communication:** Changelog in `CHANGELOG.md`, announce in #data-modelling channel

---

## Appendix: Quick Reference Card

```
NAMING:     snake_case, singular tables, <table>_sk PK, <ref>_sk FK
KEYS:       Surrogate on dims, hash on Vault, business key always documented
NORMALISE:  Vault=3NF, Core=3NF, Presentation=Star, Serving=Denorm (with ADR)
SCD:        Dim=Type2 default, Ref=Type0, Txn=Immutable, Snap=Immutable
QUALITY:    NotNull, Unique, RI, Domain, Freshness, RowCount — all in dbt
GOVERNANCE: owner, steward, classification, retention, pii, cde, source, definition
DOCS:       Every table + column described, grain explicit, derivation documented
REVIEW:     Modeller + EngLead + SME + Gov + Arch (per scope)
CHANGE:     PR + tests + docs + migration (if breaking) + consumer sign-off
```