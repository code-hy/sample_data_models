# ANTI_PATTERN_DETECTION.md — Common Anti-Patterns to Hunt During Reviews

> **Use for:** Model reviews, legacy assessments, code reviews, architecture retros.  
> **Severity:** 🔴 Critical (model fundamentally wrong/unsafe) | 🟠 High (significant design problem) | 🟡 Medium (improvement recommended) | 🟢 Low (style/optimisation)

---

## Category 1: Structural Anti-Patterns

| # | Anti-Pattern | Severity | Detection | Why It's Harmful | Fix |
|---|--------------|----------|-----------|------------------|-----|
| 1.1 | **Generic "Everything" Table** — `entity_data(entity_type, attr_json)` | 🔴 | Table with `entity_type` + JSON/EAV columns | No constraints, no RI, unqueryable, no governance | Split into typed entities |
| 1.2 | **Unresolved M:N** — Two tables with FKs to each other | 🔴 | Circular FK, or join table missing | Data integrity impossible, orphan records | Create bridge table with own grain |
| 1.3 | **Missing Business Key** — Only surrogate PK | 🟠 | PK = `id`/`sk`, no alternate unique column | Cannot integrate, deduplicate, or trace to source | Add business key + unique constraint |
| 1.4 | **Incorrect Grain** — Fact table mixes grains | 🔴 | `COUNT(*) != COUNT(DISTINCT grain_columns)` | Double-counting, wrong aggregates, silent errors | Split into separate fact tables per grain |
| 1.5 | **Overloaded Table** — One table serves multiple processes | 🟠 | > 30 columns, many nullable, multiple `type` codes | Confusing, poor performance, unclear ownership | Vertical partition by process |
| 1.6 | **Repeating Groups** — `attr_1`, `attr_2`, `attr_3` columns | 🔴 | Column name pattern `*_1`, `*_2`, `*_n` | Not 1NF, unqueryable, schema changes for new attrs | Normalise to child table |
| 1.7 | **Circular Dependency** — A → B → C → A (FK or view) | 🔴 | Lineage graph cycle | Load order impossible, refresh breaks | Break cycle: staging, materialised view, or redesign |
| 1.8 | **Orphan Records** — FK values with no parent | 🟠 | `LEFT JOIN parent WHERE parent.pk IS NULL` | Referential integrity broken, reports wrong | Add RI constraint + cleanse + prevent |

---

## Category 2: Key & Identity Anti-Patterns

| # | Anti-Pattern | Severity | Detection | Why It's Harmful | Fix |
|---|--------------|----------|-----------|------------------|-----|
| 2.1 | **Surrogate Key on Fact** — `fact_order.order_sk` PK | 🔴 | Fact table has single-column surrogate PK | Fact grain = composite of dimension SKs; surrogate hides grain | Remove surrogate; PK = composite of dimension SKs |
| 2.2 | **Business Key Changes Without History** — Type 1 on changing key | 🔴 | `customer_id` updates, no SCD2 | History lost, point-in-time wrong | SCD Type 2 on dimension; new hub record in Vault |
| 2.3 | **Composite PK on Dimension** — `dim_customer(customer_id, effective_date)` | 🟠 | Dimension PK is composite | Joins verbose, FKs propagate composite, errors | Surrogate PK (`customer_sk`); composite as alternate key |
| 2.4 | **Meaningful Surrogate** — `customer_sk` encodes region/year | 🟠 | `customer_sk = region*1000000 + sequence` | Couples identity to attributes, breaks on change | Pure surrogate (sequence/hash); attributes in columns |
| 2.5 | **No Alternate Key on Hub (Vault)** — Only hash key | 🟠 | Hub has only `hk`, no `bk` column | Cannot trace to business, debug, or integrate | Store business key column alongside hash key |

---

## Category 3: Temporal / History Anti-Patterns

| # | Anti-Pattern | Severity | Detection | Why It's Harmful | Fix |
|---|--------------|----------|-----------|------------------|-----|
| 3.1 | **Accidental History Destruction** — Type 1 overwrite on Type 2 entity | 🔴 | `UPDATE dim SET attr = val WHERE sk = x` | Point-in-time queries wrong, audit fails | SCD Type 2 merge; never UPDATE dimensions |
| 3.2 | **No `valid_to_dts` on SCD2** — Only `valid_from_dts` | 🟠 | Current version indistinguishable | Cannot query "as of date" reliably | Add `valid_to_dts` + `is_current` flag |
| 3.3 | **Gaps/Overlaps in SCD2 Ranges** — `valid_to_dts != next.valid_from_dts - 1` | 🟠 | `LEAD(valid_from_dts) OVER (...) != valid_to_dts + interval` | Double-count or missing periods in as-of queries | Enforce in merge logic; test with window functions |
| 3.4 | **Transaction Table with Updates** — `fact_order` rows modified | 🔴 | `updated_dts` on fact, or `MERGE` updates facts | Facts are immutable events; updates break audit | Insert new fact row (correction) or use snapshot |
| 3.5 | **Snapshot Without Grain Date** — `fact_daily_balance` no `snapshot_date` | 🔴 | No date column in periodic snapshot | Cannot trend, compare, or replay | Add `snapshot_date` to grain |

---

## Category 4: Dimensional Modelling Anti-Patterns

| # | Anti-Pattern | Severity | Detection | Why It's Harmful | Fix |
|---|--------------|----------|-----------|------------------|-----|
| 4.1 | **Snowflake When Star Needed** — Normalised dimensions in presentation | 🟠 | `dim_customer` → `dim_customer_address` → `dim_city` | Query complexity, BI tool pain, performance | Denormalise to star (unless storage critical) |
| 4.2 | **Non-Conformed Dimensions** — `dim_customer_sales` vs `dim_customer_marketing` | 🔴 | Two dimensions for same concept, different keys/attrs | Cannot drill across, data mismatch | Single conformed dimension; views for filters |
| 4.3 | **Fact Table as Dimension** — Joining `fact_order` for customer name | 🔴 | `SELECT ... FROM fact_order JOIN fact_order f2 ON ...` | Performance, grain confusion, maintenance | Move attributes to proper dimension |
| 4.4 | **Degenerate Dimension Buried** — Order number in fact, not dimension | 🟠 | High-cardinality attribute in fact, no dim | Cannot filter/drill on it efficiently | Create `dim_order` (degenerate) or junk dimension |
| 4.5 | **Non-Additive Fact Without Label** — `account_balance` in fact table | 🟠 | Fact column not SUM-able, no `additivity` tag | Users SUM it and get wrong answers | Tag `additivity: non_additive`; move to snapshot |
| 4.6 | **Junk Dimension Missing** — 10+ low-cardinality flags in fact | 🟠 | `is_new`, `is_returning`, `has_promo`, `is_gift`, ... in fact | Fact wide, bitmap indexes, hard to maintain | Combine into `dim_order_profile` junk dimension |

---

## Category 5: Data Vault Anti-Patterns

| # | Anti-Pattern | Severity | Detection | Why It's Harmful | Fix |
|---|--------------|----------|-----------|------------------|-----|
| 5.1 | **Business Key in Satellite** — Satellite has `customer_id` column | 🔴 | Satellite DDL includes business key | Redundant, update anomaly, violates Vault | Business key only in Hub; Satellite has HK + hashdiff |
| 5.2 | **Link Without Hub** — Link references non-existent Hub | 🔴 | Link HK references Hub not in model | Broken lineage, load fails | Create Hub first; enforce in CI |
| 5.3 | **Same-As Link as Regular Link** — `l_customer_same_as` not flagged | 🟠 | Link connects two Hubs of same type | Point-in-time queries need special handling | Model as Same-As Link; use `PIT` tables |
| 5.4 | **Satellite Split by Source** — `s_customer_crm`, `s_customer_billing` | 🟠 | Multiple satellites for same Hub, same grain | PIT complexity, conflation | Multi-source satellite with `rec_src` in PK |
| 5.5 | **No Hashdiff** — Satellite compares all columns on load | 🟠 | No `hashdiff` column; full column compare | Slow loads, false change detection | Add `hashdiff = MD5(concat(attrs))`; compare only hashdiff |

---

## Category 6: Governance & Quality Anti-Patterns

| # | Anti-Pattern | Severity | Detection | Why It's Harmful | Fix |
|---|--------------|----------|-----------|------------------|-----|
| 6.1 | **PII Unclassified** — `email`, `ssn`, `dob` no tags | 🔴 | Column has PII data, no `pii: true` meta | Compliance breach, no access control | Tag all PII; restrict access; encrypt at rest |
| 6.2 | **Hard-Coded Reference Values** — `CASE WHEN status = 'A' THEN 'Active'` in 50 models | 🟠 | Literal codes in SQL across models | Change requires 50 PRs; inconsistent labels | Reference table `ref_status`; FK + join |
| 6.3 | **No Freshness Test** — Critical table unmonitored | 🟠 | No dbt `freshness` on source/staging | Stale data goes undetected for days | Add freshness SLA per source |
| 6.4 | **Classification Missing** — No `classification` tag on any table | 🟠 | Catalogue entries lack classification | No data handling policy, risk exposure | Tag all entities: public/internal/confidential/restricted |
| 6.5 | **Owner = "Data Team"** — No individual steward | 🟡 | `owner: data-engineering` only | No accountability for definitions/issues | Assign individual steward per domain |
| 6.6 | **Retention Undefined** — Tables kept forever | 🟡 | No `retention_years` in metadata | Storage cost, legal risk, GDPR violation | Define retention per entity; archive/purge job |

---

## Category 7: Naming & Standards Anti-Patterns

| # | Anti-Pattern | Severity | Detection | Why It's Harmful | Fix |
|---|--------------|----------|-----------|------------------|-----|
| 7.1 | **Cryptic Abbreviations** — `cust`, `acct`, `txn`, `amt` | 🟢 | Column/table names < 4 chars, not org-standard | Unreadable, onboarding slow, errors | Use full words: `customer`, `account`, `transaction`, `amount` |
| 7.2 | **Inconsistent Case** — `CustomerID`, `customer_id`, `CUSTOMER_ID` | 🟢 | Mixed case in same schema | Query errors (case-sensitive platforms), confusion | Enforce snake_case via sqlfluff |
| 7.3 | **Reserved Words as Names** — `order`, `group`, `user`, `table` | 🟠 | Table/column = SQL reserved word | Requires quoting everywhere, bugs | Suffix: `order_header`, `user_account` |
| 7.4 | **Generic Column Names** — `value`, `data`, `info`, `details`, `type` | 🟠 | Column name gives zero business meaning | Unusable without context | Qualify: `transaction_amount`, `customer_type_code` |

---

## Detection Toolkit (Automated Checks)

```sql
-- 1. Find tables without PK
SELECT table_name FROM information_schema.tables t
LEFT JOIN information_schema.table_constraints c
  ON t.table_name = c.table_name AND c.constraint_type = 'PRIMARY KEY'
WHERE t.table_schema = 'presentation' AND c.table_name IS NULL;

-- 2. Find FKs without matching PK (orphans)
SELECT fk.table_name, fk.column_name
FROM information_schema.key_column_usage fk
LEFT JOIN information_schema.key_column_usage pk
  ON fk.referenced_table_name = pk.table_name
  AND fk.referenced_column_name = pk.column_name
  AND pk.constraint_name LIKE 'PRIMARY%'
WHERE pk.column_name IS NULL;

-- 3. Find potential M:N without bridge
SELECT t1.table_name, t2.table_name, COUNT(*) as fk_count
FROM information_schema.key_column_usage t1
JOIN information_schema.key_column_usage t2
  ON t1.referenced_table_name = t2.table_name
  AND t2.referenced_table_name = t1.table_name
WHERE t1.constraint_name <> t2.constraint_name
GROUP BY t1.table_name, t2.table_name
HAVING COUNT(*) > 1;

-- 4. Find columns with generic names
SELECT table_name, column_name
FROM information_schema.columns
WHERE column_name IN ('value', 'data', 'info', 'details', 'type', 'code', 'id', 'name', 'desc', 'status')
  AND table_schema = 'presentation';

-- 5. Find SCD2 tables without valid_to_dts
SELECT table_name
FROM information_schema.columns
WHERE table_schema = 'presentation'
  AND column_name = 'valid_from_dts'
  AND table_name NOT IN (
    SELECT table_name FROM information_schema.columns
    WHERE column_name = 'valid_to_dts'
  );
```

---

## Review Workflow Integration

1. **Pre-PR:** Run detection queries → fix 🔴/🟠 before PR
2. **PR Review:** Checklist includes "Anti-pattern scan passed"
3. **Monthly:** Run full scan on production → retro on new findings
4. **Quarterly:** Update this list with new patterns discovered

---

## Quick Reference Card

```
🔴 CRITICAL (Block merge):     Generic table, Unresolved M:N, Wrong grain, Surrogate on fact, Type 1 on changing key, Accidental history loss, Non-conformed dims, Fact as dim, PII unclassified
🟠 HIGH (Fix before prod):     Missing business key, Composite PK on dim, Meaningful surrogate, No valid_to_dts, SCD gaps, Snowflake in presentation, Degenerate dim buried, Non-additive unlabelled, Vault BK in sat, Link w/o hub, Hard-coded refs, No freshness, No classification
🟡 MEDIUM (Track & improve):   No alternate key on hub, Same-as link not flagged, Sat split by source, No hashdiff, Owner=team, Retention undefined
🟢 LOW (Style):                Cryptic abbreviations, Inconsistent case, Reserved words, Generic column names
```