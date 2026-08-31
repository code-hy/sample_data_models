# SOURCE_TO_TARGET_MAPPING.md — Source-to-Target Mapping Template

> **Use for:** Every new model, every migration, every reverse-engineering effort.  
> **Granularity:** One row per target column.  
> **Tooling:** Maintain in markdown (this template) or spreadsheet; generate dbt `sources.yml` + model SQL from it.

---

## Mapping: <Target Model Name>

| Field | Value |
|-------|-------|
| **Target Layer** | staging / core / presentation / feature / serving |
| **Target Model** | `schema.table` or `dbt_model_name` |
| **Target Grain** | "One row per..." |
| **Author** | |
| **Date** | YYYY-MM-DD |
| **Review Status** | Draft / Reviewed / Approved |

---

## Source Systems

| Source System | Database / Schema | Table / Object | Load Type | Cadence | SLA |
|---------------|-------------------|----------------|-----------|---------|-----|
| CRM | `crm_prod.dbo` | `Customer` | CDC | Near real-time | 15 min |
| Billing | `billing_prod.public` | `invoices` | Batch | Daily 02:00 UTC | 06:00 UTC |
| ... | | | | | |

---

## Column Mapping

| # | Target Column | Target Type | Nullable | Source System | Source Table | Source Column | Source Type | Transformation Rule | Business Rule / Notes | Quality Rule |
|---|---------------|-------------|----------|---------------|--------------|---------------|-------------|---------------------|----------------------|--------------|
| 1 | customer_sk | BIGINT | NO | — | — | — | — | `ROW_NUMBER() OVER (ORDER BY customer_id)` | Surrogate key assigned in presentation layer | Unique, Not Null |
| 2 | customer_id | VARCHAR(50) | NO | CRM | Customer | CustomerID | VARCHAR(50) | `TRIM(UPPER(CustomerID))` | Business key from CRM | Unique, Not Null, Domain: CRM format |
| 3 | customer_name | VARCHAR(200) | NO | CRM | Customer | FullName | VARCHAR(200) | `TRIM(FullName)` | Concatenate FirstName + ' ' + LastName if split | Not Null |
| 4 | customer_type_code | VARCHAR(20) | NO | CRM | Customer | CustType | VARCHAR(10) | `CASE WHEN CustType='I' THEN 'INDIVIDUAL' WHEN CustType='O' THEN 'ORGANISATION' ELSE 'UNKNOWN' END` | Map to standard domain | Not Null, Accepted Values: INDIVIDUAL, ORGANISATION, UNKNOWN |
| 5 | customer_status_code | VARCHAR(20) | NO | CRM | Customer | Status | VARCHAR(20) | `UPPER(TRIM(Status))` | — | Not Null, Accepted Values: ACTIVE, INACTIVE, SUSPENDED, CLOSED |
| 6 | email_address | VARCHAR(320) | YES | CRM | Customer | Email | VARCHAR(320) | `LOWER(TRIM(Email))` | PII — tag governance | Format: email regex |
| 7 | phone_number | VARCHAR(50) | YES | CRM | Customer | Phone | VARCHAR(50) | `REGEXP_REPLACE(Phone, '[^0-9+]', '')` | PII — tag governance | Format: E.164 |
| 8 | date_of_birth | DATE | YES | CRM | Customer | DOB | DATE | `DOB` | PII — tag governance | Not future, Age >= 18 |
| 9 | created_dts | TIMESTAMP_NTZ | NO | CRM | Customer | CreatedDate | DATETIME | `CreatedDate AT TIME ZONE 'UTC'` | System timestamp from source | Not Null |
| 10 | updated_dts | TIMESTAMP_NTZ | NO | CRM | Customer | ModifiedDate | DATETIME | `ModifiedDate AT TIME ZONE 'UTC'` | System timestamp from source | Not Null |
| 11 | load_dts | TIMESTAMP_NTZ | NO | — | — | — | — | `CURRENT_TIMESTAMP()` | System load timestamp | Not Null |
| 12 | rec_src | VARCHAR(50) | NO | — | — | — | — | `'CRM'` | Record source for lineage | Not Null |
| 13 | valid_from_dts | TIMESTAMP_NTZ | NO | CRM | Customer | EffectiveFrom | DATETIME | `COALESCE(EffectiveFrom, CreatedDate) AT TIME ZONE 'UTC'` | SCD2 effective start | Not Null |
| 14 | valid_to_dts | TIMESTAMP_NTZ | NO | CRM | Customer | EffectiveTo | DATETIME | `COALESCE(EffectiveTo, '9999-12-31') AT TIME ZONE 'UTC'` | SCD2 effective end | Not Null |
| 15 | is_current | BOOLEAN | NO | — | — | — | — | `CASE WHEN EffectiveTo IS NULL OR EffectiveTo > CURRENT_TIMESTAMP() THEN TRUE ELSE FALSE END` | Current version flag | Not Null |

---

## Transformation Details

### Complex Derivations

| Target Column | Logic (SQL/Pseudocode) | Dependencies |
|---------------|------------------------|--------------|
| `customer_segment` | `CASE WHEN lifetime_value > 10000 THEN 'PREMIUM' WHEN lifetime_value > 1000 THEN 'STANDARD' ELSE 'BASIC' END` | Requires `fact_customer_lifetime_value` |
| `age_at_first_order` | `DATEDIFF('year', date_of_birth, first_order_date)` | Requires `fact_order` |

### Lookups / Reference Data

| Target Column | Reference Table | Lookup Key | Default on Miss |
|---------------|-----------------|------------|-----------------|
| `country_name` | `ref_country` | `country_code` | `'UNKNOWN'` |
| `currency_symbol` | `ref_currency` | `currency_code` | `'$'` |

---

## Data Quality Rules (Executable)

```yaml
# dbt tests generated from this mapping
tests:
  - not_null:
      columns: [customer_sk, customer_id, customer_name, customer_type_code, customer_status_code, created_dts, updated_dts, load_dts, rec_src, valid_from_dts, valid_to_dts, is_current]
  - unique:
      columns: [customer_sk, customer_id]
  - relationships:
      - to: ref('dim_customer_type')
        field: customer_type_code
      - to: ref('dim_customer_status')
        field: customer_status_code
  - accepted_values:
      column: customer_type_code
      values: ['INDIVIDUAL', 'ORGANISATION', 'UNKNOWN']
  - accepted_values:
      column: customer_status_code
      values: ['ACTIVE', 'INACTIVE', 'SUSPENDED', 'CLOSED']
  - freshness:
      warn_after: {count: 4, period: hour}
      error_after: {count: 8, period: hour}
```

---

## Unmapped Source Columns (Audit)

| Source Table | Source Column | Reason Not Mapped |
|--------------|---------------|-------------------|
| CRM.Customer | `MarketingOptIn` | Not required for current analytics scope |
| CRM.Customer | `LegacyID` | Deprecated in source |
| ... | ... | ... |

---

## Change Log

| Date | Author | Change | Reason |
|------|--------|--------|--------|
| YYYY-MM-DD | | Initial version | New model |
| YYYY-MM-DD | | Added `customer_segment` | Marketing request |

---

## Sign-Off

| Role | Name | Signature | Date |
|------|------|-----------|------|
| Data Modeller | | | |
| Data Engineer | | | |
| Domain SME | | | |
| Data Governance | | | |