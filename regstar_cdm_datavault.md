# REGSTAR Canonical Data Model - Data Vault 2.0 Implementation

This document provides a complete Data Vault 2.0 implementation for the Transport for NSW (TfNSW) REGSTAR Canonical Data Model (CDM), transforming the existing canonical model into a historical-preserving, audit-ready architecture suitable for enterprise data integration.

## Overview

The REGSTAR CDM consists of 7 enterprise domains:
1. Party Domain
2. Entitlement & Licence Domain  
3. Asset & Registration Domain
4. Compliance & Enforcement Domain
5. Revenue & Finance Domain
6. Permits & Schemes Domain
7. Enterprise Reference Domain

This Data Vault implementation follows DV 2.0 standards with:
- Hash-surrogate keys (using UUIDs consistent with source)
- Mandatory audit columns (load_datetime, record_source, hashdiff)
- SCD Type 2 history tracking
- Clear separation of business keys (hubs), relationships (links), and descriptive attributes (satellites)

## 1. Business Keys Identification

Before modeling, we identify the business keys from the REGSTAR CDM:

### Party Domain
- `party_guid` (UUID) - Primary business key

### Entitlement & Licence Domain
- `licence_guid` (UUID) - Primary business key
- `licence_number` (String) - Alternate business key
- `card_number` (String) - Alternate business key (changes on re-issue)

### Asset & Registration Domain
- `vehicle_asset_guid` (UUID) - Primary business key for vehicle assets
- `vin` (CHAR(17)) - Alternate business key
- `registration_guid` (UUID) - Primary business key for registrations
- `plate_identifier` (String) - Alternate business key

### Compliance & Enforcement Domain
- `sanction_guid` (UUID) - Primary business key
- `offence_notice_ref` (String) - Alternate business key

### Revenue & Finance Domain
- `transaction_guid` (UUID) - Primary business key

### Permits & Schemes Domain
- `permit_guid` (UUID) - Primary business key

### Enterprise Reference Domain
- `licence_class_code` (String) - Business key for licence classes
- `offence_code` (String) - Business key for demerit offences
- `(code_category, code_value)` (String,String) - Business key for system codes
- `cross_ref_id` (UUID) - Primary business key for code cross-reference

## 2. Data Vault Model Architecture

### Naming Conventions
- Hubs: `h_<business_object>`
- Links: `l_<relationship>`
- Satellites: `s_<business_object>` or `s_<business_object>_<context>`
- Link-Satellites: `lsat_<relationship>_<context>`
- Same-As Links: `lsa_<equivalent_objects>`
- Hierarchy Links: `lh_<hierarchy>`
- Hash Keys: `hk_<entity>` or `hk_<entity>_<context>`
- Hashdiffs: `hd_<entity>` or `hd_<entity>_<context>`

### Mandatory DV 2.0 Columns
All tables include:
- `load_datetime` TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
- `record_source` VARCHAR(100) NOT NULL
- `hashdiff` CHAR(64) NOT NULL (SHA-256 of business descriptive attributes)

## 3. Hubs (H)

Hubs represent core business concepts with their business keys.

```sql
-- ==================== HUBS ====================

-- Party Domain Hubs
CREATE TABLE dv_party.h_party (
    hk_party          UUID PRIMARY KEY,           -- Maps to party_guid
    party_guid        UUID NOT NULL UNIQUE,       -- Original business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

-- Entitlement & Licence Domain Hubs
CREATE TABLE dv_entitlement.h_licence (
    hk_licence        UUID PRIMARY KEY,           -- Maps to licence_guid
    licence_guid      UUID NOT NULL UNIQUE,       -- Original business key
    licence_number    VARCHAR(20) NOT NULL,       -- Alternate business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

CREATE TABLE dv_entitlement.h_licence_card (
    hk_licence_card   UUID PRIMARY KEY,           -- Maps to card_number
    card_number       VARCHAR(20) NOT NULL,       -- Business key (changes on re-issue)
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

-- Asset & Registration Domain Hubs
CREATE TABLE dv_asset.h_vehicle_asset (
    hk_vehicle_asset  UUID PRIMARY KEY,           -- Maps to vehicle_asset_guid
    vehicle_asset_guid UUID NOT NULL UNIQUE,      -- Original business key
    vin               CHAR(17) NOT NULL UNIQUE,   -- Alternate business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

CREATE TABLE dv_asset.h_registration (
    hk_registration   UUID PRIMARY KEY,           -- Maps to registration_guid
    registration_guid UUID NOT NULL UNIQUE,       -- Original business key
    plate_identifier  VARCHAR(10) NOT NULL,       -- Alternate business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

-- Compliance & Enforcement Domain Hubs
CREATE TABLE dv_compliance.h_sanction (
    hk_sanction       UUID PRIMARY KEY,           -- Maps to sanction_guid
    sanction_guid     UUID NOT NULL UNIQUE,       -- Original business key
    offence_notice_ref VARCHAR(30) NOT NULL,      -- Alternate business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

-- Revenue & Finance Domain Hubs
CREATE TABLE dv_revenue.h_transaction (
    hk_transaction    UUID PRIMARY KEY,           -- Maps to transaction_guid
    transaction_guid  UUID NOT NULL UNIQUE,       -- Original business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

-- Permits & Schemes Domain Hubs
CREATE TABLE dv_permits.h_permit (
    hk_permit         UUID PRIMARY KEY,           -- Maps to permit_guid
    permit_guid       UUID NOT NULL UNIQUE,       -- Original business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

-- Enterprise Reference Domain Hubs
CREATE TABLE dv_ref.h_licence_class (
    hk_licence_class  UUID PRIMARY KEY,           -- Surrogate hash key
    licence_class_code VARCHAR(10) NOT NULL,      -- Business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

CREATE TABLE dv_ref.h_demerit_offence (
    hk_offence        UUID PRIMARY KEY,           -- Surrogate hash key
    offence_code      VARCHAR(20) NOT NULL,       -- Business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);

CREATE TABLE dv_ref.h_system_code (
    hk_system_code    UUID PRIMARY KEY,           -- Surrogate hash key
    code_category     VARCHAR(50) NOT NULL,       -- Part of business key
    code_value        VARCHAR(50) NOT NULL,       -- Part of business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL,
    CONSTRAINT uq_h_system_code_business_key UNIQUE (code_category, code_value)
);

CREATE TABLE dv_ref.h_code_cross_reference (
    hk_cross_ref      UUID PRIMARY KEY,           -- Maps to cross_ref_id
    cross_ref_id      UUID NOT NULL UNIQUE,       -- Original business key
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL
);
```

## 4. Links (L)

Links represent associations between business concepts (many-to-many relationships or foreign keys).

```sql
-- ==================== LINKS ====================

-- Party to Address Links
CREATE TABLE dv_party.l_party_residential_address (
    hk_party_res_address UUID PRIMARY KEY,
    hk_party             UUID NOT NULL,
    hk_address           UUID NOT NULL,          -- References address hub (to be created)
    load_datetime        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source        VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party),
    FOREIGN KEY (hk_address) REFERENCES dv_party.h_address(hk_address)
);

CREATE TABLE dv_party.l_party_postal_address (
    hk_party_post_address UUID PRIMARY KEY,
    hk_party              UUID NOT NULL,
    hk_address            UUID NOT NULL,          -- References address hub
    load_datetime         TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source         VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party),
    FOREIGN KEY (hk_address) REFERENCES dv_party.h_address(hk_address)
);

-- Entitlement to Party Link
CREATE TABLE dv_entitlement.l_licence_party (
    hk_licence_party UUID PRIMARY KEY,
    hk_licence       UUID NOT NULL,
    hk_party         UUID NOT NULL,
    load_datetime    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source    VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_licence) REFERENCES dv_entitlement.h_licence(hk_licence),
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party)
);

-- Licence to Licence Card Link
CREATE TABLE dv_entitlement.l_licence_card (
    hk_licence_card_link UUID PRIMARY KEY,
    hk_licence           UUID NOT NULL,
    hk_licence_card      UUID NOT NULL,
    load_datetime        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source        VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_licence) REFERENCES dv_entitlement.h_licence(hk_licence),
    FOREIGN KEY (hk_licence_card) REFERENCES dv_entitlement.h_licence_card(hk_licence_card)
);

-- Asset to Registration Link
CREATE TABLE dv_asset.l_vehicle_asset_registration (
    hk_vehicle_reg UUID PRIMARY KEY,
    hk_vehicle_asset UUID NOT NULL,
    hk_registration  UUID NOT NULL,
    load_datetime    TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source    VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_vehicle_asset) REFERENCES dv_asset.h_vehicle_asset(hk_vehicle_asset),
    FOREIGN KEY (hk_registration) REFERENCES dv_asset.h_registration(hk_registration)
);

-- Registration to Party Link
CREATE TABLE dv_asset.l_registration_party (
    hk_reg_party UUID PRIMARY KEY,
    hk_registration UUID NOT NULL,
    hk_party       UUID NOT NULL,
    load_datetime  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source  VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_registration) REFERENCES dv_asset.h_registration(hk_registration),
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party)
);

-- Compliance to Party Link
CREATE TABLE dv_compliance.l_sanction_party (
    hk_sanction_party UUID PRIMARY KEY,
    hk_sanction       UUID NOT NULL,
    hk_party          UUID NOT NULL,
    load_datetime     TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source     VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_sanction) REFERENCES dv_compliance.h_sanction(hk_sanction),
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party)
);

-- Revenue to Party Link
CREATE TABLE dv_revenue.l_transaction_party (
    hk_transaction_party UUID PRIMARY KEY,
    hk_transaction       UUID NOT NULL,
    hk_party             UUID NOT NULL,
    load_datetime        TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source        VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_transaction) REFERENCES dv_revenue.h_transaction(hk_transaction),
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party)
);

-- Revenue to Registration Link (optional)
CREATE TABLE dv_revenue.l_transaction_registration (
    hk_transaction_reg UUID PRIMARY KEY,
    hk_transaction     UUID NOT NULL,
    hk_registration    UUID NULL,                -- Registration can be NULL
    load_datetime      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source      VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_transaction) REFERENCES dv_revenue.h_transaction(hk_transaction),
    FOREIGN KEY (hk_registration) REFERENCES dv_asset.h_registration(hk_registration)
);

-- Revenue to Licence Link (optional)
CREATE TABLE dv_revenue.l_transaction_licence (
    hk_transaction_lic UUID PRIMARY KEY,
    hk_transaction     UUID NOT NULL,
    hk_licence         UUID NULL,                -- Licence can be NULL
    load_datetime      TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source      VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_transaction) REFERENCES dv_revenue.h_transaction(hk_transaction),
    FOREIGN KEY (hk_licence) REFERENCES dv_entitlement.h_licence(hk_licence)
);

-- Permit to Party Link
CREATE TABLE dv_permits.l_permit_party (
    hk_permit_party UUID PRIMARY KEY,
    hk_permit       UUID NOT NULL,
    hk_party        UUID NOT NULL,
    load_datetime   TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source   VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_permit) REFERENCES dv_permits.h_permit(hk_permit),
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party)
);

-- Reference Data Links
CREATE TABLE dv_ref.l_licence_class_prereq (
    hk_licence_class_prereq UUID PRIMARY KEY,
    hk_licence_class        UUID NOT NULL,
    hk_prereq_class         UUID NULL,          -- Prerequisite can be NULL
    load_datetime           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source           VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_licence_class) REFERENCES dv_ref.h_licence_class(hk_licence_class),
    FOREIGN KEY (hk_prereq_class) REFERENCES dv_ref.h_licence_class(hk_licence_class)
);
```

## 5. Satellites (S)

Satellites store descriptive attributes and historical context for hubs and links.

```sql
-- ==================== SATELLITES ====================

-- Party Domain Satellites
CREATE TABLE dv_party.s_party (
    hk_party                UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    party_type_code         VARCHAR(20) NOT NULL,
    legal_name              JSONB NOT NULL,
    identity_verification_level VARCHAR(10) NOT NULL,
    biometric_ref_id        UUID NULL,
    residential_address_guid UUID NOT NULL,
    postal_address_guid     UUID NOT NULL,
    PRIMARY KEY (hk_party, load_datetime),
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party)
);

CREATE TABLE dv_party.s_address (
    hk_address              UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    address_line_1          VARCHAR(100) NOT NULL,
    address_line_2          VARCHAR(100) NULL,
    locality                VARCHAR(50) NOT NULL,
    state_territory         VARCHAR(20) NOT NULL,
    postcode                VARCHAR(10) NOT NULL,
    country_code            CHAR(2) NOT NULL DEFAULT 'AU',
    address_type_code       VARCHAR(20) NOT NULL, -- RESIDENTIAL, POSTAL, etc.
    is_primary              BOOLEAN NOT NULL DEFAULT TRUE,
    PRIMARY KEY (hk_address, load_datetime),
    FOREIGN KEY (hk_address) REFERENCES dv_party.h_address(hk_address)
);

-- Entitlement & Licence Domain Satellites
CREATE TABLE dv_entitlement.s_licence (
    hk_licence              UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    licence_category_code   VARCHAR(10) NOT NULL,
    class_conditions_array  JSONB NOT NULL,
    lifecycle_status_code   VARCHAR(20) NOT NULL,
    effective_period        TSTZRANGE NOT NULL,
    digital_card_status     VARCHAR(20) NULL,
    PRIMARY KEY (hk_licence, load_datetime),
    FOREIGN KEY (hk_licence) REFERENCES dv_entitlement.h_licence(hk_licence)
);

CREATE TABLE dv_entitlement.s_licence_card (
    hk_licence_card         UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    -- Card-specific attributes (if any beyond the card_number itself)
    PRIMARY KEY (hk_licence_card, load_datetime),
    FOREIGN KEY (hk_licence_card) REFERENCES dv_entitlement.h_licence_card(hk_licence_card)
);

-- Asset & Registration Domain Satellites
CREATE TABLE dv_asset.s_vehicle_asset (
    hk_vehicle_asset        UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    engine_number           VARCHAR(50) NULL,
    chassis_number          VARCHAR(50) NULL,
    vehicle_gvm_kg          INT NOT NULL,
    make_model_code         VARCHAR(30) NOT NULL,
    PRIMARY KEY (hk_vehicle_asset, load_datetime),
    FOREIGN KEY (hk_vehicle_asset) REFERENCES dv_asset.h_vehicle_asset(hk_vehicle_asset)
);

CREATE TABLE dv_asset.s_registration (
    hk_registration         UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    usage_code              VARCHAR(20) NOT NULL,
    inspection_status_flag  BOOLEAN NOT NULL DEFAULT FALSE,
    registration_status_code VARCHAR(20) NOT NULL,
    effective_period        TSTZRANGE NOT NULL,
    PRIMARY KEY (hk_registration, load_datetime),
    FOREIGN KEY (hk_registration) REFERENCES dv_asset.h_registration(hk_registration)
);

-- Compliance & Enforcement Domain Satellites
CREATE TABLE dv_compliance.s_sanction (
    hk_sanction             UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    demerit_points_incurred INT NOT NULL DEFAULT 0,
    cumulative_active_points INT NOT NULL,
    sanction_type_code      VARCHAR(20) NOT NULL,
    effective_period        TSTZRANGE NOT NULL,
    PRIMARY KEY (hk_sanction, load_datetime),
    FOREIGN KEY (hk_sanction) REFERENCES dv_compliance.h_sanction(hk_sanction)
);

-- Revenue & Finance Domain Satellites
CREATE TABLE dv_revenue.s_transaction (
    hk_transaction          UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    party_guid              UUID NOT NULL,
    registration_guid       UUID NULL,
    licence_guid            UUID NULL,
    duty_amount_cents       BIGINT NOT NULL,
    fee_amount_cents        BIGINT NOT NULL,
    concession_code         VARCHAR(20) NULL,
    payment_status_code     VARCHAR(20) NOT NULL,
    processed_at            TIMESTAMPTZ NOT NULL,
    PRIMARY KEY (hk_transaction, load_datetime),
    FOREIGN KEY (hk_transaction) REFERENCES dv_revenue.h_transaction(hk_transaction)
);

-- Permits & Schemes Domain Satellites
CREATE TABLE dv_permits.s_permit (
    hk_permit               UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    permit_type_code        VARCHAR(20) NOT NULL,
    medical_fitness_status  VARCHAR(20) NOT NULL,
    effective_period        TSTZRANGE NOT NULL,
    PRIMARY KEY (hk_permit, load_datetime),
    FOREIGN KEY (hk_permit) REFERENCES dv_permits.h_permit(hk_permit)
);

-- Enterprise Reference Domain Satellites
CREATE TABLE dv_ref.s_licence_class (
    hk_licence_class        UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    class_name              VARCHAR(50) NOT NULL,
    description             TEXT NOT NULL,
    gvm_limit_kg            INT NULL,
    min_age_years           INT NOT NULL DEFAULT 17,
    prereq_class_code       VARCHAR(10) NULL,
    towing_allowed_flag     BOOLEAN NOT NULL DEFAULT TRUE,
    display_order           INT NOT NULL DEFAULT 0,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    valid_from              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to                TIMESTAMPTZ NULL,
    PRIMARY KEY (hk_licence_class, load_datetime),
    FOREIGN KEY (hk_licence_class) REFERENCES dv_ref.h_licence_class(hk_licence_class)
);

CREATE TABLE dv_ref.s_demerit_offence (
    hk_offence              UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    offence_title           VARCHAR(150) NOT NULL,
    act_legislation_ref     VARCHAR(100) NOT NULL,
    default_demerit_points  INT NOT NULL DEFAULT 0,
    provisional_points      INT NOT NULL DEFAULT 0,
    double_demerit_eligible BOOLEAN NOT NULL DEFAULT FALSE,
    fine_amount_aud         NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    valid_from              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to                TIMESTAMPTZ NULL,
    PRIMARY KEY (hk_offence, load_datetime),
    FOREIGN KEY (hk_offence) REFERENCES dv_ref.h_demerit_offence(hk_offence)
);

CREATE TABLE dv_ref.s_system_code (
    hk_system_code          UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    display_name            VARCHAR(100) NOT NULL,
    description             TEXT NULL,
    sort_order              INT NOT NULL DEFAULT 0,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    created_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (hk_system_code, load_datetime),
    FOREIGN KEY (hk_system_code) REFERENCES dv_ref.h_system_code(hk_system_code)
);

CREATE TABLE dv_ref.s_code_cross_reference (
    hk_cross_ref            UUID NOT NULL,
    load_datetime           TIMESTAMPTZ NOT NULL,
    hashdiff                CHAR(64) NOT NULL,
    domain_name             VARCHAR(50) NOT NULL,
    canonical_code          VARCHAR(50) NOT NULL,
    target_system           VARCHAR(30) NOT NULL,
    target_code             VARCHAR(50) NOT NULL,
    target_description      VARCHAR(150) NULL,
    is_active               BOOLEAN NOT NULL DEFAULT TRUE,
    valid_from              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valid_to                TIMESTAMPTZ NULL,
    PRIMARY KEY (hk_cross_ref, load_datetime),
    FOREIGN KEY (hk_cross_ref) REFERENCES dv_ref.h_code_cross_reference(hk_cross_ref)
);
```

## 6. Link-Satellites (for transactional measures and contextual attributes)

Link-satellites store metrics, measurements, and contextual data about relationships.

```sql
-- ==================== LINK-SATELLITES ====================

-- Transactional measures for licences
CREATE TABLE dv_entitlement.lsat_licence_status (
    hk_licence_status     UUID PRIMARY KEY,
    hk_licence            UUID NOT NULL,
    load_datetime         TIMESTAMPTZ NOT NULL,
    hashdiff              CHAR(64) NOT NULL,
    lifecycle_status_code VARCHAR(20) NOT NULL,
    effective_period      TSTZRANGE NOT NULL,
    FOREIGN KEY (hk_licence) REFERENCES dv_entitlement.h_licence(hk_licence)
);

-- Transactional measures for registrations
CREATE TABLE dv_asset.lsat_registration_status (
    hk_reg_status         UUID PRIMARY KEY,
    hk_registration       UUID NOT NULL,
    load_datetime         TIMESTAMPTZ NOT NULL,
    hashdiff              CHAR(64) NOT NULL,
    registration_status_code VARCHAR(20) NOT NULL,
    inspection_status_flag BOOLEAN NOT NULL DEFAULT FALSE,
    effective_period      TSTZRANGE NOT NULL,
    FOREIGN KEY (hk_registration) REFERENCES dv_asset.h_registration(hk_registration)
);

-- Transactional measures for sanctions
CREATE TABLE dv_compliance.lsat_sanction_details (
    hk_sanction_details   UUID PRIMARY KEY,
    hk_sanction           UUID NOT NULL,
    load_datetime         TIMESTAMPTZ NOT NULL,
    hashdiff              CHAR(64) NOT NULL,
    demerit_points_incurred INT NOT NULL DEFAULT 0,
    cumulative_active_points INT NOT NULL,
    sanction_type_code    VARCHAR(20) NOT NULL,
    effective_period      TSTZRANGE NOT NULL,
    FOREIGN KEY (hk_sanction) REFERENCES dv_compliance.h_sanction(hk_sanction)
);

-- Financial transaction measures
CREATE TABLE dv_revenue.lsat_transaction_financials (
    hk_transaction_fin    UUID PRIMARY KEY,
    hk_transaction        UUID NOT NULL,
    load_datetime         TIMESTAMPTZ NOT NULL,
    hashdiff              CHAR(64) NOT NULL,
    duty_amount_cents     BIGINT NOT NULL,
    fee_amount_cents      BIGINT NOT NULL,
    concession_code       VARCHAR(20) NULL,
    payment_status_code   VARCHAR(20) NOT NULL,
    processed_at          TIMESTAMPTZ NOT NULL,
    FOREIGN KEY (hk_transaction) REFERENCES dv_revenue.h_transaction(hk_transaction)
);

-- Permit status measures
CREATE TABLE dv_permits.lsat_permit_status (
    hk_permit_status      UUID PRIMARY KEY,
    hk_permit             UUID NOT NULL,
    load_datetime         TIMESTAMPTZ NOT NULL,
    hashdiff              CHAR(64) NOT NULL,
    permit_type_code      VARCHAR(20) NOT NULL,
    medical_fitness_status VARCHAR(20) NOT NULL,
    effective_period      TSTZRANGE NOT NULL,
    FOREIGN KEY (hk_permit) REFERENCES dv_permits.h_permit(hk_permit)
);
```

## 7. Same-As Links (for equivalent keys across systems)

Same-as links connect equivalent business keys from different source systems.

```sql
-- ==================== SAME-AS LINKS ====================

-- Party equivalent keys across systems
CREATE TABLE dv_party.lsa_party_external (
    hk_party_same_as    UUID PRIMARY KEY,
    hk_party            UUID NOT NULL,
    hk_external_party   UUID NOT NULL,          -- External system party hub
    load_datetime       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source       VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party),
    FOREIGN KEY (hk_external_party) REFERENCES dv_party_ext.h_party(hk_party)  -- External hub
);

-- Licence equivalent keys across systems
CREATE TABLE dv_entitlement.lsa_licence_external (
    hk_licence_same_as  UUID PRIMARY KEY,
    hk_licence          UUID NOT NULL,
    hk_external_licence UUID NOT NULL,
    load_datetime       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source       VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_licence) REFERENCES dv_entitlement.h_licence(hk_licence),
    FOREIGN KEY (hk_external_licence) REFERENCES dv_entitlement_ext.h_licence(hk_licence)
);

-- Asset/Vehicle equivalent keys across systems
CREATE TABLE dv_asset.lsa_vehicle_asset_external (
    hk_vehicle_same_as  UUID PRIMARY KEY,
    hk_vehicle_asset    UUID NOT NULL,
    hk_external_vehicle UUID NOT NULL,
    load_datetime       TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source       VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_vehicle_asset) REFERENCES dv_asset.h_vehicle_asset(hk_vehicle_asset),
    FOREIGN KEY (hk_external_vehicle) REFERENCES dv_asset_ext.h_vehicle_asset(hk_vehicle_asset)
);
```

## 8. Hierarchy Links (for hierarchical relationships)

Hierarchy links represent parent-child or hierarchical relationships.

```sql
-- ==================== HIERARCHY LINKS ====================

-- Licence class hierarchy (prerequisite relationships)
CREATE TABLE dv_ref.lh_licence_class_hierarchy (
    hk_licence_class_hierarchy UUID PRIMARY KEY,
    hk_licence_class           UUID NOT NULL,
    hk_parent_class            UUID NULL,
    load_datetime              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source              VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_licence_class) REFERENCES dv_ref.h_licence_class(hk_licence_class),
    FOREIGN KEY (hk_parent_class) REFERENCES dv_ref.h_licence_class(hk_licence_class)
);

-- Organisation hierarchy (if applicable)
CREATE TABLE dv_party.lh_party_organisation_hierarchy (
    hk_party_org_hierarchy UUID PRIMARY KEY,
    hk_party               UUID NOT NULL,
    hk_parent_party        UUID NULL,
    load_datetime          TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source          VARCHAR(100) NOT NULL,
    FOREIGN KEY (hk_party) REFERENCES dv_party.h_party(hk_party),
    FOREIGN KEY (hk_parent_party) REFERENCES dv_party.h_party(hk_party)
);
```

## 9. Reference Tables (Non-History Tables)

Reference tables for static or slowly changing reference data that doesn't require full history tracking.

```sql
-- ==================== REFERENCE TABLES ====================

-- Address types reference
CREATE TABLE dv_party.ref_address_type (
    address_type_code   VARCHAR(20) PRIMARY KEY,
    display_name        VARCHAR(100) NOT NULL,
    description         TEXT NULL,
    is_active           BOOLEAN NOT NULL DEFAULT TRUE
);

-- Licence categories reference
CREATE TABLE dv_entitlement.ref_licence_category (
    licence_category_code VARCHAR(10) PRIMARY KEY,
    display_name          VARCHAR(100) NOT NULL,
    description           TEXT NULL,
    is_active             BOOLEAN NOT NULL DEFAULT TRUE
);

-- Lifecycle status codes reference
CREATE TABLE dv_entitlement.ref_licence_lifecycle_status (
    lifecycle_status_code VARCHAR(20) PRIMARY KEY,
    display_name          VARCHAR(100) NOT NULL,
    description           TEXT NULL,
    is_active             BOOLEAN NOT NULL DEFAULT TRUE
);

-- Registration status codes reference
CREATE TABLE dv_asset.ref_registration_status (
    registration_status_code VARCHAR(20) PRIMARY KEY,
    display_name             VARCHAR(100) NOT NULL,
    description              TEXT NULL,
    is_active                BOOLEAN NOT NULL DEFAULT TRUE
);

-- Usage codes reference
CREATE TABLE dv_asset.ref_usage_code (
    usage_code VARCHAR(20) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Sanction types reference
CREATE TABLE dv_compliance.ref_sanction_type (
    sanction_type_code VARCHAR(20) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Permit types reference
CREATE TABLE dv_permits.ref_permit_type (
    permit_type_code VARCHAR(20) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Medical fitness status reference
CREATE TABLE dv_permits.ref_medical_fitness_status (
    medical_fitness_status VARCHAR(20) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Payment status codes reference
CREATE TABLE dv_revenue.ref_payment_status (
    payment_status_code VARCHAR(20) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Concession codes reference
CREATE TABLE dv_revenue.ref_concession_code (
    concession_code VARCHAR(20) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    description TEXT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);
```

## 10. Indexes for Performance

```sql
-- ==================== INDEXES ====================

-- Hub indexes (beyond primary key)
CREATE INDEX ix_h_party_guid ON dv_party.h_party(party_guid);
CREATE INDEX ix_h_licence_guid ON dv_entitlement.h_licence(licence_guid);
CREATE INDEX ix_h_licence_number ON dv_entitlement.h_licence(licence_number);
CREATE INDEX ix_h_licence_card_number ON dv_entitlement.h_licence_card(card_number);
CREATE INDEX ix_h_vehicle_asset_guid ON dv_asset.h_vehicle_asset(vehicle_asset_guid);
CREATE INDEX ix_h_vehicle_asset_vin ON dv_asset.h_vehicle_asset(vin);
CREATE INDEX ix_h_registration_guid ON dv_asset.h_registration(registration_guid);
CREATE INDEX ix_h_registration_plate ON dv_asset.h_registration(plate_identifier);
CREATE INDEX ix_h_sanction_guid ON dv_compliance.h_sanction(sanction_guid);
CREATE INDEX ix_h_sanction_offence_ref ON dv_compliance.h_sanction(offence_notice_ref);
CREATE INDEX ix_h_transaction_guid ON dv_revenue.h_transaction(transaction_guid);
CREATE INDEX ix_h_permit_guid ON dv_permits.h_permit(permit_guid);
CREATE INDEX ix_h_licence_class_code ON dv_ref.h_licence_class(licence_class_code);
CREATE INDEX ix_h_offence_code ON dv_ref.h_demerit_offence(offence_code);
CREATE INDEX ix_h_system_code_cat_val ON dv_ref.h_system_code(code_category, code_value);
CREATE INDEX ix_h_cross_ref_id ON dv_ref.h_code_cross_reference(cross_ref_id);

-- Link indexes
CREATE INDEX ix_l_party_res_address ON dv_party.l_party_residential_address(hk_party);
CREATE INDEX ix_l_party_post_address ON dv_party.l_party_postal_address(hk_party);
CREATE INDEX ix_l_licence_party ON dv_entitlement.l_licence_party(hk_licence);
CREATE INDEX ix_l_licence_party_party ON dv_entitlement.l_licence_party(hk_party);
CREATE INDEX ix_l_licence_card ON dv_entitlement.l_licence_card(hk_licence);
CREATE INDEX ix_l_vehicle_asset_reg ON dv_asset.l_vehicle_asset_registration(hk_vehicle_asset);
CREATE INDEX ix_l_vehicle_asset_reg_reg ON dv_asset.l_vehicle_asset_registration(hk_registration);
CREATE INDEX ix_l_registration_party ON dv_asset.l_registration_party(hk_registration);
CREATE INDEX ix_l_registration_party_party ON dv_asset.l_registration_party(hk_party);
CREATE INDEX ix_l_sanction_party ON dv_compliance.l_sanction_party(hk_sanction);
CREATE INDEX ix_l_sanction_party_party ON dv_compliance.l_sanction_party(hk_party);
CREATE INDEX ix_l_transaction_party ON dv_revenue.l_transaction_party(hk_transaction);
CREATE INDEX ix_l_transaction_party_party ON dv_revenue.l_transaction_party(hk_party);
CREATE INDEX ix_l_transaction_reg ON dv_revenue.l_transaction_registration(hk_transaction);
CREATE INDEX ix_l_transaction_reg_reg ON dv_revenue.l_transaction_registration(hk_registration);
CREATE INDEX ix_l_transaction_lic ON dv_revenue.l_transaction_licence(hk_transaction);
CREATE INDEX ix_l_transaction_lic_lic ON dv_revenue.l_transaction_licence(hk_licence);
CREATE INDEX ix_l_permit_party ON dv_permits.l_permit_party(hk_permit);
CREATE INDEX ix_l_permit_party_party ON dv_permits.l_permit_party(hk_party);
CREATE INDEX ix_l_licence_class_prereq ON dv_ref.l_licence_class_prereq(hk_licence_class);
CREATE INDEX ix_l_licence_class_prereq_pre ON dv_ref.l_licence_class_prereq(hk_prereq_class);

-- Satellite indexes (for common query patterns)
CREATE INDEX ix_s_party_type ON dv_party.s_party(party_type_code);
CREATE INDEX ix_s_licence_category ON dv_entitlement.s_licence(licence_category_code);
CREATE INDEX ix_s_licence_status ON dv_entitlement.s_licence(lifecycle_status_code);
CREATE INDEX ix_s_registration_status ON dv_asset.s_registration(registration_status_code);
CREATE INDEX ix_s_registration_usage ON dv_asset.s_registration(usage_code);
CREATE INDEX ix_s_sanction_type ON dv_compliance.s_sanction(sanction_type_code);
CREATE INDEX ix_s_transaction_payment ON dv_revenue.s_transaction(payment_status_code);
CREATE INDEX ix_s_transaction_concession ON dv_revenue.s_transaction(concession_code);
CREATE INDEX ix_s_permit_type ON dv_permits.s_permit(permit_type_code);
CREATE INDEX ix_s_permit_fitness ON dv_permits.s_permit(medical_fitness_status);
CREATE INDEX ix_s_licence_class_active ON dv_ref.s_licence_class(is_active);
CREATE INDEX ix_s_offence_active ON dv_ref.s_demerit_offence(is_active);
CREATE INDEX ix_s_system_code_active ON dv_ref.s_system_code(is_active);
CREATE INDEX ix_s_system_code_cat_val ON dv_ref.s_system_code(code_category, code_value);
CREATE INDEX ix_s_cross_ref_active ON dv_ref.s_code_cross_reference(is_active);
CREATE INDEX ix_s_cross_ref_domain ON dv_ref.s_code_cross_reference(domain_name);
CREATE INDEX ix_s_cross_ref_target ON dv_ref.s_code_cross_reference(target_system, target_code);

-- Link-Satellite indexes
CREATE INDEX ix_lsat_licence_status ON dv_entitlement.lsat_licence_status(hk_licence);
CREATE INDEX ix_lsat_reg_status ON dv_asset.lsat_registration_status(hk_registration);
CREATE INDEX ix_lsat_sanction_details ON dv_compliance.lsat_sanction_details(hk_sanction);
CREATE INDEX ix_lsat_transaction_fin ON dv_revenue.lsat_transaction_financials(hk_transaction);
CREATE INDEX ix_lsat_permit_status ON dv_permits.lsat_permit_status(hk_permit);

-- Same-As Link indexes
CREATE INDEX ix_lsa_party_ext ON dv_party.lsa_party_external(hk_party);
CREATE INDEX ix_lsa_party_ext_ext ON dv_party.lsa_party_external(hk_external_party);
CREATE INDEX ix_lsa_licence_ext ON dv_entitlement.lsa_licence_external(hk_licence);
CREATE INDEX ix_lsa_licence_ext_ext ON dv_entitlement.lsa_licence_external(hk_external_licence);
CREATE INDEX ix_lsa_vehicle_ext ON dv_asset.lsa_vehicle_asset_external(hk_vehicle_asset);
CREATE INDEX ix_lsa_vehicle_ext_ext ON dv_asset.lsa_vehicle_asset_external(hk_external_vehicle);

-- Hierarchy Link indexes
CREATE INDEX ix_lh_licence_class ON dv_ref.lh_licence_class_hierarchy(hk_licence_class);
CREATE INDEX ix_lh_licence_class_parent ON dv_ref.lh_licence_class_hierarchy(hk_parent_class);
CREATE INDEX ix_lh_party_org ON dv_party.lh_party_organisation_hierarchy(hk_party);
CREATE INDEX ix_lh_party_org_parent ON dv_party.lh_party_organisation_hierarchy(hk_parent_party);

-- Reference table indexes
CREATE INDEX ix_ref_address_type_active ON dv_party.ref_address_type(is_active);
CREATE INDEX ix_ref_licence_category_active ON dv_entitlement.ref_licence_category(is_active);
CREATE INDEX ix_ref_licence_lifecycle_status_active ON dv_entitlement.ref_licence_lifecycle_status(is_active);
CREATE INDEX ix_ref_registration_status_active ON dv_asset.ref_registration_status(is_active);
CREATE INDEX ix_ref_usage_code_active ON dv_asset.ref_usage_code(is_active);
CREATE INDEX ix_ref_sanction_type_active ON dv_compliance.ref_sanction_type(is_active);
CREATE INDEX ix_ref_permit_type_active ON dv_permits.ref_permit_type(is_active);
CREATE INDEX ix_ref_medical_fitness_status_active ON dv_permits.ref_medical_fitness_status(is_active);
CREATE INDEX ix_ref_payment_status_active ON dv_revenue.ref_payment_status(is_active);
CREATE INDEX ix_ref_concession_code_active ON dv_revenue.ref_concession_code(is_active);
```

## 11. Data Loading Conventions

### Record Source Values
Each ingestion job should set `record_source` to identify the source system:
- `TFNSW_DRIVES_MAIN_DB2` - Mainframe DB2 source
- `TFNSW_DRIVES_VSAM` - VSAM datasets
- `TFNSW_OPAL` - Opal ticketing system
- `TFNSW_GTFS` - General Transit Feed Specification
- `TFNSW_ASSETS` - Asset management system
- `TFNSW_IIOT` - IoT telemetry sensors
- `TFNSW_WEBSITE` - Customer-facing web applications
- `TFNSW_MOBILE_APP` - Mobile applications
- `TFNSW_API_GATEWAY` - External API integrations
- `NEVDIS` - National Exchange of Vehicle and Driver Information
- `DVS` - Document Verification Service
- `POLICE_NSW` - New South Wales Police
- `SERVICE_NSW` - Service NSW platforms
- `LICENCE_NSW` - Licence NSW platform

### Hashdiff Calculation
The `hashdiff` column should be calculated as SHA-256 of all descriptive attributes in the record (excluding hub/hash key, load_datetime, record_source, and the hashdiff itself).

Example for party satellite:
```sql
hashdiff = SHA256(
    CONCAT(
        COALESCE(party_type_code, ''),
        COALESCE(legal_name::text, ''),
        COALESCE(identity_verification_level, ''),
        COALESCE(biometric_ref_id::text, ''),
        COALESCE(residential_address_guid::text, ''),
        COALESCE(postal_address_guid::text, '')
    )
)
```

### Loading Pattern
1. **Stage**: Load raw data into landing area
2. **Hash**: Calculate hash keys and hashdiffs
3. **Hub**: Insert new business keys (if not exists)
4. **Link**: Insert new relationships (if not exists)
5. **Satellite**: Insert new descriptive records (always insert new row with current load_datetime)
6. **Link-Satellite**: Insert new measurement records (always insert new row)

This approach ensures:
- Immutable audit trail
- Point-in-time recoverability
- Source system lineage
- Handling of late-arriving data
- Support for multiple active records (multi-active satellites when needed)

## 12. Migration Strategy from REGSTAR CDM to Data Vault

### Phase 1: Initial Load
1. Extract all current records from REGSTAR CDM tables
2. Generate hash keys for all business keys
3. Load hubs with distinct business keys
4. Load links with distinct relationships
5. Load satellites with all current attributes (using current timestamp as load_datetime)
6. Set record_source to appropriate source system identifier

### Phase 2: Incremental Loading
1. Implement CDC (Change Data Capture) from source systems
2. For each change event:
   - Calculate hash key and hashdiff
   - Check if hub exists; if not, insert
   - Check if link exists; if not, insert
   - Compare hashdiff with most recent satellite record
   - If different or no existing record, insert new satellite record
   - For link-satellites, always insert new measurement records

### Phase 3: Reference Data Handling
1. Load reference tables with current values
2. Implement change detection for reference data updates
3. For frequently changing reference data, consider converting to satellites

## 13. Query Examples

### Current Party Information
```sql
SELECT 
    p.party_guid,
    p.party_type_code,
    p.legal_name,
    p.identity_verification_level,
    a.address_line_1,
    a.locality,
    a.state_territory,
    a.postcode
FROM dv_party.h_party h
JOIN dv_party.s_party p ON h.hk_party = p.hk_party
JOIN dv_party.l_party_residential_address lra ON h.hk_party = lra.hk_party
JOIN dv_party.h_address ha ON lra.hk_address = ha.hk_address
JOIN dv_party.s_address a ON ha.hk_address = a.hk_address
WHERE p.load_datetime = (
    SELECT MAX(load_datetime) 
    FROM dv_party.s_party 
    WHERE hk_party = h.hk_party
)
AND a.load_datetime = (
    SELECT MAX(load_datetime) 
    FROM dv_party.s_address 
    WHERE hk_address = ha.hk_address
)
AND lra.load_datetime = (
    SELECT MAX(load_datetime) 
    FROM dv_party.l_party_residential_address 
    WHERE hk_party = h.hk_party
);
```

### Licence History for a Party
```sql
SELECT 
    l.licence_guid,
    l.licence_number,
    lic.licence_category_code,
    lic.class_conditions_array,
    lic.lifecycle_status_code,
    lic.effective_period,
    lic.digital_card_status,
    lic.load_datetime as effective_from,
    LEAD(lic.load_datetime) OVER (
        PARTITION BY l.hk_licence 
        ORDER BY lic.load_datetime
    ) as effective_to
FROM dv_entitlement.h_licence l
JOIN dv_entitlement.l_licence_party llp ON l.hk_licence = llp.hk_licence
JOIN dv_party.h_party p ON llp.hk_party = p.hk_party
JOIN dv_entitlement.s_licence lic ON l.hk_licence = lic.hk_licence
WHERE p.party_guid = 'target-party-guid'
ORDER BY lic.load_datetime;
```

### Current Registration Status with Vehicle Details
```sql
SELECT 
    r.registration_guid,
    r.plate_identifier,
    r.usage_code,
    r.inspection_status_flag,
    r.registration_status_code,
    r.effective_period,
    va.vin,
    va.engine_number,
    va.chassis_number,
    va.vehicle_gvm_kg,
    va.make_model_code
FROM dv_asset.h_registration r
JOIN dv_asset.s_registration reg ON r.hk_registration = reg.hk_registration
JOIN dv_asset.l_vehicle_asset_regulation lvar ON r.hk_registration = lvar.hk_registration
JOIN dv_asset.h_vehicle_asset va ON lvar.hk_vehicle_asset = va.hk_vehicle_asset
JOIN dv_asset.s_vehicle_asset va_s ON va.hk_vehicle_asset = va_s.hk_vehicle_asset
WHERE reg.load_datetime = (
    SELECT MAX(load_datetime) 
    FROM dv_asset.s_registration 
    WHERE hk_registration = r.hk_registration
)
AND va_s.load_datetime = (
    SELECT MAX(load_datetime) 
    FROM dv_asset.s_vehicle_asset 
    WHERE hk_vehicle_asset = va.hk_vehicle_asset
)
AND lvar.load_datetime = (
    SELECT MAX(load_datetime) 
    FROM dv_asset.l_vehicle_asset_regulation 
    WHERE hk_registration = r.hk_registration
);
```

## 14. Benefits of This Data Vault Implementation

### Auditability & Compliance
- Complete historical trail of all changes
- Clear lineage back to source systems
- Ability to rebuild any point-in-time view
- Support for regulatory reporting requirements

### Agility & Flexibility
- Easy to add new source systems without disrupting existing structures
- Schema evolution without breaking existing loads
- Parallel loading capabilities
- Support for business rule changes over time

### Performance & Scalability
- Hash keys enable efficient joins and lookups
- Immutable loads enable parallel processing
- Separation of concerns improves query performance
- Ability to archive old data while keeping recent data accessible

### Data Quality
- Explicit handling of business keys vs surrogate keys
- Clear identification of data source and timing
- Built-in duplicate detection through hashdiff comparison
- Support for data reconciliation and exception reporting

## 15. Implementation Roadmap

### Sprint 1: Foundation
- Create hubs and links for Party and Entitlement domains
- Implement basic loading scripts
- Establish record_source and hashdiff standards

### Sprint 2: Core Domains
- Add Asset & Registration and Compliance domains
- Implement link-satellites for transactional measures
- Create reference tables

### Sprint 3: Extended Domains
- Add Revenue & Finance and Permits & Schemes domains
- Implement same-as links for external system integration
- Add hierarchy links where applicable

### Sprint 4: Reference & Optimization
- Complete Enterprise Reference Domain
- Add performance indexes
- Implement data validation and quality checks
- Create monitoring and alerting for load processes

### Sprint 5: Documentation & Handoff
- Create comprehensive data dictionary
- Develop operational runbooks
- Train operations team on Data Vault principles
- Establish SLA and monitoring dashboards

---

This Data Vault 2.0 implementation provides a robust, scalable, and audit-ready foundation for the REGSTAR Canonical Data Model that supports both operational reporting and advanced analytics while maintaining complete historical traceability and source system lineage.