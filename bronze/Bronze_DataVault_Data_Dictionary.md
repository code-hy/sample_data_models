# Bronze Layer — Data Vault 2.0 Data Dictionary

> **Organisation:** Transport for NSW (TfNSW)
> **Layer:** Bronze (Raw Vault)
> **Standard:** Data Vault 2.x
> **Scope:** Table-by-table column definitions, key roles, data types, audit field conventions
> **Purpose:** Single source of truth for every column in the Bronze Raw Vault — used by data engineers,
> analysts, and governance tools to understand provenance, validity, and transformation expectations.

This dictionary covers all 41 model tables (13 hubs, 15 links, 14 satellites, 6 link-satellites, 3 reference).
Each entry lists: column name, data type, nullability, key role (PK/FK/UK/SCD), description, `load_datetime`
presence, `record_source` presence, `hashdiff` presence, and any SCD2 effective dates.

## Table: h_customer

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| customer_hk | BIGINT | NO | PK | Hash key: hash(customer_key + record_source) | PK |
| customer_key | VARCHAR(50) | NO | UK | Business key: Opal party / customer identifier | Business PK |
| customer_type_code | VARCHAR(10) | YES | | e.g. ADULT, CONCESSION, CHILD, CREW | |
| customer_name | VARCHAR(100) | YES | | Legal name / registered party name | |
| is_active_flag | BOOLEAN | NO | DEFAULT TRUE | Current active status | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_card

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| card_hk | BIGINT | NO | PK | Hash key: hash(card_token + record_source) | PK |
| card_token | VARCHAR(50) | NO | UK | Tokenised card identifier (never raw PAN) | Business PK |
| card_type_code | VARCHAR(20) | NO | | e.g. OPAL_ADULT, OPAL_CONCESSION, OPAL_CHILD, OPAL_CREDIT, MOBILE | |
| card_issue_date | DATE | YES | | When card was first activated | |
| card_status_code | VARCHAR(20) | NO | DEFAULT 'ACTIVE' | ACTIVE, BLOCKED, CLOSED, EXPIRED | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_stop_location

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| stop_location_hk | BIGINT | NO | PK | Hash key: hash(stop_id + record_source) | PK |
| stop_id | VARCHAR(20) | NO | UK | GTFS stop_id | Business PK |
| stop_name | VARCHAR(200) | NO | | Physical name (e.g. "Town Hall Station") | |
| stop_type_code | VARCHAR(10) | NO | | e.g. BUS_RAIL, FERRY, LIGHT_RAIL, TRAM | |
| latitude | DOUBLE | NO | | WGS84 decimal degrees | |
| longitude | DOUBLE | NO | | WGS84 decimal degrees | |
| zone_code | VARCHAR(10) | YES | | Fare zone assignment | |
| is_accessible_flag | BOOLEAN | NO | DEFAULT FALSE | Wheelchair accessible? | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_mode

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| mode_hk | BIGINT | NO | PK | Hash key: hash(mode_code + record_source) | PK |
| mode_code | VARCHAR(10) | NO | UK | e.g. TRAIN, BUS, FERRY, LRT, TRAM | Business PK |
| mode_name | VARCHAR(50) | YES | | Full name (e.g. "Heavy Rail", "Bus") | |
| fare_mode_group | VARCHAR(30) | YES | | Grouping for fare calculation (RAIL, BUS) | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_operator

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| operator_hk | BIGINT | NO | PK | Hash key: hash(operator_code + record_source) | PK |
| operator_code | VARCHAR(10) | NO | UK | e.g. SNCT, WERR, CITYRail, SydneyFerries | Business PK |
| operator_name | VARCHAR(100) | YES | | Full operator name | |
| owner_category_code | VARCHAR(20) | YES | | GOVT, PRIVATE, JV, SUBSIDIARY | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_service

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| service_hk | BIGINT | NO | PK | Hash key: hash(service_code + record_source) | PK |
| service_code | VARCHAR(20) | NO | UK | e.g. 123, 555, 700 | Business PK |
| service_name | VARCHAR(100) | YES | | Service display name | |
| operator_hk | BIGINT | NO | FK | FK to h_operator | Foreign Key |
| mode_hk | BIGINT | NO | FK | FK to h_mode | Foreign Key |
| route_id | VARCHAR(20) | YES | | Optional route identifier | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_calendar_service

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| calendar_service_hk | BIGINT | NO | PK | Hash key: hash(service_code + record_source) | PK |
| service_code | VARCHAR(20) | NO | UK | Links to h_service.service_code | Business PK |
| monday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Mondays? | |
| tuesday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Tuesdays? | |
| wednesday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Wednesdays? | |
| thursday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Thursdays? | |
| friday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Fridays? | |
| saturday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Saturdays? | |
| sunday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Sundays? | |
| public_holiday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on public holidays? | |
| service_start_date | DATE | NO | | First date this service is active | |
| service_end_date | DATE | NO | | Last date this service is active | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_route

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| route_hk | BIGINT | NO | PK | Hash key: hash(route_id + record_source) | PK |
| route_id | VARCHAR(20) | NO | UK | e.g. 123, 700, T8, F1 | Business PK |
| route_short_name | VARCHAR(20) | YES | | Abbreviated route name | |
| route_long_name | VARCHAR(100) | YES | | Full route name/description | |
| route_type_code | VARCHAR(10) | NO | | 3=heavy rail, 4=light rail, 1=bus, 2=ferry, 8=tram | |
| agency_id | VARCHAR(20) | YES | | Transport agency (usually TfNSW=1) | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_trip_pattern

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| trip_pattern_hk | BIGINT | NO | PK | Hash key: hash(trip_pattern_id + record_source) | PK |
| trip_pattern_id | VARCHAR(30) | NO | UK | GTFS trip_pattern_id | Business PK |
| route_hk | BIGINT | NO | FK | FK to h_route | Foreign Key |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_asset_class

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| asset_class_hk | BIGINT | NO | PK | Hash key: hash(asset_class_code + record_source) | PK |
| asset_class_code | VARCHAR(20) | NO | UK | e.g. VEHICLE, INFRASTRUCTURE, FACILITY, SOFTWARE | Business PK |
| asset_class_name | VARCHAR(100) | NO | | e.g. "Rolling Stock", "Signal System" | |
| parent_asset_class_hk | BIGINT | YES | FK self-referencing | NULL = root level in hierarchy | Foreign Key (self) |
| level_number | SMALLINT | YES | | 1=root, 2=child, etc. | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_asset

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| asset_hk | BIGINT | NO | PK | Hash key: hash(asset_tag + record_source) | PK |
| asset_tag | VARCHAR(50) | NO | UK | Unique physical tag / asset identifier | Business PK |
| asset_class_hk | BIGINT | NO | FK | FK to h_asset_class | Foreign Key |
| asset_serial | VARCHAR(50) | YES | | Manufacturer serial number | |
| asset_status_code | VARCHAR(20) | NO | DEFAULT 'ACTIVE' | ACTIVE, MAINTENANCE, RETIRED, LOST | |
| installation_date | DATE | YES | | When asset was commissioned | |
| removal_date | DATE | YES | | When asset was retired/removed | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_component

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| component_hk | BIGINT | NO | PK | Hash key: hash(component_code + record_source) | PK |
| component_code | VARCHAR(30) | NO | UK | e.g. ENGINE_DOOR, BATTERY_PACK, CCTV_SYSTEM | Business PK |
| component_name | VARCHAR(100) | NO | | Human-readable name | |
| asset_hk | BIGINT | NO | FK | FK to h_asset | Foreign Key |
| criticality_rating | VARCHAR(10) | YES | | LOW, MEDIUM, HIGH, CRITICAL | |
| mean_time_to_failure_hours | DOUBLE | YES | | Expected operating hours between failures | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: h_project

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| project_hk | BIGINT | NO | PK | Hash key: hash(project_code + record_source) | PK |
| project_code | VARCHAR(20) | NO | UK | e.g. SYD123, REGEN1, SIGNAL_UPGRADE | Business PK |
| project_name | VARCHAR(200) | NO | | Full project name | |
| project_type_code | VARCHAR(30) | YES | | CAPITAL, MAINTENANCE, RENEWAL, UPGRADE | |
| budget_aud | DECIMAL(18,2) | YES | | Total budget in Australian dollars | |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |

## Table: l_card_customer

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(card_hk + customer_hk + record_source) | PK |
| card_hk | BIGINT | NO | FK | FK to h_card | Foreign Key |
| customer_hk | BIGINT | NO | FK | FK to h_customer | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from (ownership change) | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to (ownership end) | SCD2 |

## Table: l_service_mode

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(service_hk + mode_hk + record_source) | PK |
| service_hk | BIGINT | NO | FK | FK to h_service | Foreign Key |
| mode_hk | BIGINT | NO | FK | FK to h_mode | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from (relationship change) | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_service_operator

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(service_hk + operator_hk + record_source) | PK |
| service_hk | BIGINT | NO | FK | FK to h_service | Foreign Key |
| operator_hk | BIGINT | NO | FK | FK to h_operator | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_route_mode

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(route_hk + mode_hk + record_source) | PK |
| route_hk | BIGINT | NO | FK | FK to h_route | Foreign Key |
| mode_hk | BIGINT | NO | FK | FK to h_mode | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_route_operator

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(route_hk + operator_hk + record_source) | PK |
| route_hk | BIGINT | NO | FK | FK to h_route | Foreign Key |
| operator_hk | BIGINT | NO | FK | FK to h_operator | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_trip_pattern_route

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(trip_pattern_hk + route_hk + record_source) | PK |
| trip_pattern_hk | BIGINT | NO | FK | FK to h_trip_pattern | Foreign Key |
| route_hk | BIGINT | NO | FK | FK to h_route | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_service_run

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(service_hk + trip_pattern_hk + calendar_service_hk + record_source) | PK |
| service_hk | BIGINT | NO | FK | FK to h_service | Foreign Key |
| trip_pattern_hk | BIGINT | NO | FK | FK to h_trip_pattern | Foreign Key |
| calendar_service_hk | BIGINT | NO | FK | FK to h_calendar_service | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from (run date) | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_stop_dwell

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(service_run_hk + stop_location_hk + record_source) | PK |
| service_run_hk | BIGINT | NO | FK | FK to l_service_run | Foreign Key |
| stop_location_hk | BIGINT | NO | FK | FK to h_stop_location | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_trip

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(card_hk + origin_stop_location_hk + destination_stop_location_hk + service_run_hk + record_source) | PK |
| card_hk | BIGINT | NO | FK | FK to h_card | Foreign Key |
| customer_hk | BIGINT | YES | FK | FK to h_customer (nullable: tap-on guest / untapped) | Foreign Key |
| origin_stop_location_hk | BIGINT | NO | FK | FK to h_stop_location | Foreign Key |
| destination_stop_location_hk | BIGINT | NO | FK | FK to h_stop_location | Foreign Key |
| service_run_hk | BIGINT | NO | FK | FK to l_service_run | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from (journey date) | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_journey

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(card_hk + origin_stop_location_hk + destination_stop_location_hk + record_source) | PK |
| card_hk | BIGINT | NO | FK | FK to h_card | Foreign Key |
| customer_hk | BIGINT | YES | FK | FK to h_customer (nullable) | Foreign Key |
| origin_stop_location_hk | BIGINT | NO | FK | FK to h_stop_location | Foreign Key |
| destination_stop_location_hk | BIGINT | NO | FK | FK to h_stop_location | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from (journey period) | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_asset_operation

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(asset_hk + load_datetime_source + record_source) | PK |
| asset_hk | BIGINT | NO | FK | FK to h_asset | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_IIOT' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from (reading epoch) | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |
| energy_kwh | DOUBLE | YES | | Energy consumed (kWh) during this tick | |
| temperature_celsius | DOUBLE | YES | | Measured temperature | |
| vibration_mm_sec | DOUBLE | YES | | Vibration magnitude (mm/s) | |
| operation_mode_code | VARCHAR(20) | YES | | NORMAL, ACCELERATING, BRAKING, FAULT | |

## Table: l_asset_component

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(asset_hk + component_hk + record_source) | PK |
| asset_hk | BIGINT | NO | FK | FK to h_asset | Foreign Key |
| component_hk | BIGINT | NO | FK | FK to h_component | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from (fitment change) | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: l_project_asset

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | Hash key: hash(project_hk + asset_hk + record_source) | PK |
| project_hk | BIGINT | NO | FK | FK to h_project | Foreign Key |
| asset_hk | BIGINT | NO | FK | FK to h_asset | Foreign Key |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| load_datetime | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | When row was loaded from source | Required |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| effective_from | TIMESTAMP | NO | DEFAULT CURRENT_TIMESTAMP | SCD2 effective-from (allocation change) | SCD2 |
| effective_to | TIMESTAMP | YES | DEFAULT '9999-12-31 23:59:59.999999' | SCD2 effective-to | SCD2 |

## Table: s_customer

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| customer_hk | BIGINT | NO | FK | FK to h_customer (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (customer_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| customer_type_code | VARCHAR(10) | YES | | e.g. ADULT, CONCESSION, CHILD, CREW | |
| customer_name | VARCHAR(100) | YES | | Legal name / registered party name | |
| marketing_consent_flag | BOOLEAN | NO | DEFAULT FALSE | Opt-in for marketing communications | |
| payment_profile_code | VARCHAR(20) | YES | | e.g. CREDIT, DEBIT, OPAL_BALANCE | |
| is_loyalty_member_flag | BOOLEAN | NO | DEFAULT FALSE | Member of transport loyalty program | |

## Table: s_card

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| card_hk | BIGINT | NO | FK | FK to h_card (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (card_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| card_type_code | VARCHAR(20) | NO | | e.g. OPAL_ADULT, OPAL_CONCESSION, OPAL_CHILD, OPAL_CREDIT, MOBILE | |
| card_status_code | VARCHAR(20) | NO | DEFAULT 'ACTIVE' | ACTIVE, BLOCKED, CLOSED, EXPIRED | |
| issue_date | DATE | YES | | When card was first activated | |
| expiry_date | DATE | YES | | When card expires (if applicable) | |
| auto_top_up_flag | BOOLEAN | NO | DEFAULT FALSE | Auto-reload enabled? | |

## Table: s_stop_location

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| stop_location_hk | BIGINT | NO | FK | FK to h_stop_location (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (stop_location_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| stop_name | VARCHAR(200) | YES | | Physical name (e.g. "Town Hall Station") | |
| stop_type_code | VARCHAR(10) | YES | | e.g. BUS_RAIL, FERRY, LIGHT_RAIL, TRAM | |
| latitude | DOUBLE | YES | | WGS84 decimal degrees | |
| longitude | DOUBLE | YES | | WGS84 decimal degrees | |
| zone_code | VARCHAR(10) | YES | | Fare zone assignment | |
| is_accessible_flag | BOOLEAN | YES | | Wheelchair accessible? | |
| load_timestamp | TIMESTAMP | YES | | When GPS data was captured (source-side timestamp) | |

## Table: s_mode

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| mode_hk | BIGINT | NO | FK | FK to h_mode (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (mode_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| mode_name | VARCHAR(50) | YES | | Full name (e.g. "Heavy Rail", "Bus") | |
| fare_mode_group | VARCHAR(30) | YES | | Grouping for fare calculation (RAIL, BUS) | |
| accessibility_category | VARCHAR(20) | YES | | e.g. FULLY_ACCESSIBLE, PARTIAL, NONE | |

## Table: s_operator

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| operator_hk | BIGINT | NO | FK | FK to h_operator (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (operator_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| operator_name | VARCHAR(100) | YES | | Full operator name | |
| owner_category_code | VARCHAR(20) | YES | | GOVT, PRIVATE, JV, SUBSIDIARY | |
| trading_name | VARCHAR(100) | YES | | Commercial trading name (may differ from legal name) | |

## Table: s_service

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| service_hk | BIGINT | NO | FK | FK to h_service (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (service_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| service_name | VARCHAR(100) | YES | | Service display name | |
| service_description | TEXT | YES | | Longer description of the service | |
| operator_fk | BIGINT | YES | FK | De-normalised from h_operator (for quick read) | Foreign Key |
| mode_fk | BIGINT | YES | FK | De-normalised from h_mode (for quick read) | Foreign Key |

## Table: s_calendar_service

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| calendar_service_hk | BIGINT | NO | FK | FK to h_calendar_service (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (calendar_service_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| monday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Mondays? | |
| tuesday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Tuesdays? | |
| wednesday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Wednesdays? | |
| thursday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Thursdays? | |
| friday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Fridays? | |
| saturday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Saturdays? | |
| sunday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on Sundays? | |
| public_holiday_flag | BOOLEAN | NO | DEFAULT FALSE | Service runs on public holidays? | |
| service_start_date | DATE | NO | | First date this service is active | |
| service_end_date | DATE | NO | | Last date this service is active | |
| load_timestamp | TIMESTAMP | YES | | When calendar was last refreshed (source feed timestamp) | |

## Table: s_route

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| route_hk | BIGINT | NO | FK | FK to h_route (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (route_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| route_short_name | VARCHAR(20) | YES | | Abbreviated route name | |
| route_long_name | VARCHAR(100) | YES | | Full route name/description | |
| route_description | TEXT | YES | | Extended description | |
| agency_name | VARCHAR(100) | YES | | Operating agency name | |

## Table: s_trip_pattern

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| trip_pattern_hk | BIGINT | NO | FK | FK to h_trip_pattern (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (trip_pattern_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_GTFS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| trip_pattern_id | VARCHAR(30) | YES | | GTFS trip_pattern_id | |
| route_fk | BIGINT | YES | FK | De-normalised from h_route (for quick read) | Foreign Key |
| stop_sequence_count | SMALLINT | YES | | Number of stops in the pattern | |
| load_timestamp | TIMESTAMP | YES | | When GTFS feed was processed | |

## Table: s_asset_class

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| asset_class_hk | BIGINT | NO | FK | FK to h_asset_class (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (asset_class_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| asset_class_code | VARCHAR(20) | NO | | e.g. VEHICLE, INFRASTRUCTURE, FACILITY, SOFTWARE | |
| asset_class_name | VARCHAR(100) | NO | | e.g. "Rolling Stock", "Signal System" | |
| parent_asset_class_hk | BIGINT | YES | FK self-referencing | NULL = root level in hierarchy | Foreign Key (self) |
| level_number | SMALLINT | YES | | 1=root, 2=child, etc. | |

## Table: s_asset

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| asset_hk | BIGINT | NO | FK | FK to h_asset (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (asset_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| asset_tag | VARCHAR(50) | YES | | Unique physical tag / asset identifier | |
| asset_serial | VARCHAR(50) | YES | | Manufacturer serial number | |
| asset_status_code | VARCHAR(20) | NO | DEFAULT 'ACTIVE' | ACTIVE, MAINTENANCE, RETIRED, LOST | |
| installation_date | DATE | YES | | When asset was commissioned | |
| removal_date | DATE | YES | | When asset was retired/removed | |
| current_mileage_km | DOUBLE | YES | | Odometer reading at last load | |

## Table: s_component

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| component_hk | BIGINT | NO | FK | FK to h_component (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (component_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| component_code | VARCHAR(30) | NO | | e.g. ENGINE_DOOR, BATTERY_PACK, CCTV_SYSTEM | |
| component_name | VARCHAR(100) | NO | | Human-readable name | |
| criticality_rating | VARCHAR(10) | YES | | LOW, MEDIUM, HIGH, CRITICAL | |
| mean_time_to_failure_hours | DOUBLE | YES | | Expected operating hours between failures | |
| fitment_date | DATE | YES | | When component was fitted to asset | |
| removal_date | DATE | YES | | When component was removed from asset | |

## Table: s_project

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| project_hk | BIGINT | NO | FK | FK to h_project (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (project_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| project_code | VARCHAR(20) | NO | | e.g. SYD123, REGEN1, SIGNAL_UPGRADE | |
| project_name | VARCHAR(200) | NO | | Full project name | |
| project_type_code | VARCHAR(30) | YES | | CAPITAL, MAINTENANCE, RENEWAL, UPGRADE | |
| budget_aud | DECIMAL(18,2) | YES | | Total budget in Australian dollars | |
| start_date | DATE | YES | | Planned or actual start date | |
| end_date | DATE | YES | | Planned or actual end date | |
| status_code | VARCHAR(20) | NO | DEFAULT 'PLANNED' | PLANNED, IN_PROGRESS, COMPLETED, CANCELLED | |

## Table: lsat_service_run

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | FK to l_service_run (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (link_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| total_trips_this_run | INTEGER | NO | DEFAULT 0 | Total tap-on events recorded on this run | |
| on_time_flag | BOOLEAN | NO | DEFAULT FALSE | Trip was on time (within schedule tolerance) | |
| early_minutes | SMALLINT | NO | DEFAULT 0 | Minutes early early of scheduled arrival | |
| late_minutes | SMALLINT | NO | DEFAULT 0 | Minutes late of scheduled arrival | |
| cancelled_flag | BOOLEAN | NO | DEFAULT FALSE | Service was cancelled | |
| short_turn_flag | BOOLEAN | NO | DEFAULT FALSE | Service terminated early (short turn) | |
| punctuality_percentage | DECIMAL(5,2) | NO | DEFAULT 0.0 | % of trips on time for this run | |
| average_dwell_sec | DOUBLE | NO | DEFAULT 0.0 | Average dwell time across all stops (seconds) | |
| load_timestamp | TIMESTAMP | YES | | When run performance data was finalised (end of service day) | |

## Table: lsat_stop_dwell

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | FK to l_stop_dwell (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (link_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| dwell_sec | DOUBLE | NO | DEFAULT 0.0 | Time the vehicle dwelt at this stop (seconds) | |
| delay_sec | DOUBLE | NO | DEFAULT 0.0 | Departure delay at this stop (seconds) | |
| boardings_this_stop | SMALLINT | NO | DEFAULT 0 | Number of passengers who tapped on at this stop | |
| alightings_this_stop | SMALLINT | NO | DEFAULT 0 | Number of passengers who tapped off at this stop | |
| load_factor_percentage | DECIMAL(5,2) | NO | DEFAULT 0.0 | Load (passengers on board) / Capacity * 100 | |
| crowding_severity | VARCHAR(10) | YES | | EMPTY, NORMAL, crowded, FULL | |

## Table: lsat_trip

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | FK to l_trip (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (link_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| fare_amount_aud | DECIMAL(10,2) | NO | DEFAULT 0.0 | Fare charged (Australian dollars) | |
| default_fare_flag | BOOLEAN | NO | DEFAULT TRUE | Passenger paid default fare (no concession) | |
| peak_period_flag | BOOLEAN | NO | DEFAULT FALSE | Tap occurred during peak period | |
| concession_applied_flag | BOOLEAN | NO | DEFAULT FALSE | Concession discount was applied | |
| tap_on_timestamp | TIMESTAMP | NO | | When passenger tapped on | |
| tap_off_timestamp | TIMESTAMP | YES | | When passenger tapped off (NULL = tap-on only, e.g. alight at terminal) | |
| tap_on_location_hk | BIGINT | YES | FK | FK to h_stop_location (nullable: unknown origin) | Foreign Key |
| tap_off_location_hk | BIGINT | YES | FK | FK to h_stop_location (nullable: unknown destination) | Foreign Key |
| distance_km | DOUBLE | NO | DEFAULT 0.0 | Calculated distance between tap-on and tap-off stops | |
| card_token | VARCHAR(50) | YES | | De-normalised from h_card for quick read (not a FK — denormalised) | |

## Table: lsat_journey

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | FK to l_journey (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (link_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_OPAL' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| total_trips | INTEGER | NO | DEFAULT 0 | Total trips in this journey period | |
| total_fare_aud | DECIMAL(10,2) | NO | DEFAULT 0.0 | Total fare paid across all trips (AUD) | |
| transfer_count | SMALLINT | NO | DEFAULT 0 | Number of transfers (tap-off/tap-on sequences) | |
| first_tap_timestamp | TIMESTAMP | YES | | Timestamp of first tap in the journey | |
| last_tap_timestamp | TIMESTAMP | YES | | Timestamp of last tap in the journey | |
| total_travel_time_sec | INTEGER | NO | DEFAULT 0 | Sum of (tap_off - tap_on) durations across all trips (seconds) | |

## Table: lsat_asset_operation

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | FK to l_asset_operation (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (link_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_IIOT' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| energy_kwh_agg | DOUBLE | NO | DEFAULT 0.0 | Aggregated energy consumed (kWh) during this tick | |
| temperature_celsius_avg | DOUBLE | YES | | Average temperature during tick | |
| temperature_celsius_min | DOUBLE | YES | | Minimum temperature during tick | |
| temperature_celsius_max | DOUBLE | YES | | Maximum temperature during tick | |
| vibration_mm_sec_avg | DOUBLE | YES | | Average vibration magnitude (mm/s) during tick | |
| vibration_mm_sec_max | DOUBLE | YES | | Maximum vibration magnitude (mm/s) during tick | |
| operation_mode_code | VARCHAR(20) | YES | | NORMAL, ACCELERATING, BRAKING, FAULT | |
| severity_flag | VARCHAR(10) | YES | | LOW, MEDIUM, HIGH, CRITICAL — derived from thresholds | |

## Table: lsat_asset_component

| Column | Type | Null | Key | Description | DV2 Fields |
|---|---|---|---|---|---|
| link_hk | BIGINT | NO | PK | FK to l_asset_component (PK part 1) | FK |
| load_datetime | TIMESTAMP | NO | PK part 2 | Composite PK: (link_hk, load_datetime) | PK |
| record_source | VARCHAR(50) | NO | DEFAULT 'TFNSW_ASSETS' | Source system identifier | Required |
| hashdiff | CHAR(64) | NO | SHA-256 of all non-hash columns | Change detection flag | Required |
| component_hk | BIGINT | NO | FK | FK to h_component (de-normalised for quick read) | Foreign Key |
| failure_probability | DOUBLE | NO | DEFAULT 0.0 | 0.0=nominal, 1.0=imminent failure predicted | |
| last_failure_timestamp | TIMESTAMP | YES | | When the last failure / maintenance event was recorded | |
| days_since_last_failure | SMALLINT | NO | DEFAULT 0 | Days elapsed since the last failure / maintenance event | |

## Reference Tables

### ref_concession_code

| Column | Type | Null | Key | Description |
|---|---|---|---|---|
| concession_code | VARCHAR(20) | NO | PRIMARY KEY | e.g. CONcession, CHild, STUDent, SILver |
| concession_name | VARCHAR(50) | YES | | Full name (e.g. "Concession", "Child") |
| eligibility_rule | VARCHAR(200) | YES | | Rule text (e.g. "Under 16, Pensioner Holders") |
| is_active_flag | BOOLEAN | NO | DEFAULT TRUE | Whether this concession is currently offered |

### ref_fare_period

| Column | Type | Null | Key | Description |
|---|---|---|---|---|
| fare_period_code | VARCHAR(15) | NO | PRIMARY KEY | e.g. PEAK, OFF_PEAK, WEEKEND |
| fare_period_name | VARCHAR(30) | YES | | Full name (e.g. "Peak", "Off-Peak") |
| peak_flag | BOOLEAN | NO | DEFAULT FALSE | Is this a peak period? |
| start_time_local | TIME | NO | | Start time of peak period (local time) |
| end_time_local | TIME | NO | | End time of peak period (local time) |
| is_active_flag | BOOLEAN | NO | DEFAULT TRUE | Whether this fare period is currently in effect |

### ref_card_status_reason

| Column | Type | Null | Key | Description |
|---|---|---|---|---|
| status_reason_code | VARCHAR(20) | NO | PRIMARY KEY | e.g. LOST, STOLEN, EXPIRED, FRAUD_FLAGGED |
| status_reason_desc | VARCHAR(100) | YES | | Human-readable description |
| is_active_flag | BOOLEAN | NO | DEFAULT TRUE | Whether this reason code is current |

### ref_asset_condition

| Column | Type | Null | Key | Description |
|---|---|---|---|---|
| condition_code | VARCHAR(20) | NO | PRIMARY KEY | e.g. NEW, GOOD, FAIR, POOR, CRITICAL |
| condition_desc | VARCHAR(100) | YES | | Human-readable description |
| is_active_flag | BOOLEAN | NO | DEFAULT TRUE | Whether this condition state is current |

## DV2 Change Detection Logic

Every table in the Bronze Raw Vault includes three mandatory audit columns:

1. **`load_datetime`** — `TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP`
   - When this row was loaded into the vault from the source system.
   - Also the "effective-from" date for the satellite's point-in-time view.

2. **`record_source`** — `VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL'` (varies per table)
   - Identifies which source system produced this row.
   - Critical for lineage, multi-system integration, and debugging load errors.
   - Example values: `TFNSW_OPAL`, `TFNSW_GTFS`, `TFNSW_ASSETS`, `TFNSW_IIOT`.

3. **`hashdiff`** — `CHAR(64) NOT NULL` (SHA-256 hash)
   - Hash of every non-hash, non-PK, non-audit column in the row.
   - If the source system sends a row where `hashdiff` is identical to the most recent row already in the vault,
     the row is a duplicate — no new satellite row is loaded (DV2 "change detection" pattern).
   - If the hashdiff is different, a new satellite row is appended with a new `load_datetime`, and the
     prior row is implicitly closed (its `effective_to` is the prior `load_datetime` in the SCD2 pattern).

## SCD2 Behaviour Summary

| Object | History Mechanism | Effective From | Effective To |
|---|---|---|---|
| Hubs | SCD2 via `effective_from`/`effective_to` | `DEFAULT CURRENT_TIMESTAMP` | `DEFAULT '9999-12-31 23:59:59.999999'` |
| Links | SCD2 via `effective_from`/`effective_to` | `DEFAULT CURRENT_TIMESTAMP` | `DEFAULT '9999-12-31 23:59:59.999999'` |
| Satellites | Composite PK `(hk, load_datetime)` — inherent SCD2 | `load_datetime` is the effective-from | Prior row closes at prior `load_datetime` |
| Link-Satellites | Composite PK `(link_hk, load_datetime)` — inherent SCD2 | `load_datetime` is the effective-from | Prior row closes at prior `load_datetime` |

## Indexes (Performance — referenced from the DDL)

All FK indexes are created to support join performance in the warehouse. Key indexes include:

- `ix_h_customer_key` ON h_customer(customer_key)
- `ix_h_card_token` ON h_card(card_token)
- `ix_h_stop_id` ON h_stop_location(stop_id)
- `ix_h_mode_code` ON h_mode(mode_code)
- `ix_h_operator_code` ON h_operator(operator_code)
- `ix_h_service_code` ON h_service(service_code)
- `ix_h_calendar_service` ON h_calendar_service(service_code)
- `ix_h_route_id` ON h_route(route_id)
- `ix_h_trip_pattern_id` ON h_trip_pattern(trip_pattern_id)
- `ix_h_asset_tag` ON h_asset(asset_tag)
- `ix_h_asset_class_code` ON h_asset_class(asset_class_code)
- `ix_h_component_code` ON h_component(component_code)
- `ix_h_project_code` ON h_project(project_code)
- All link FK indexes (e.g. `ix_l_card_customer_card`, `ix_l_service_run_service`, etc.)
- All satellite FK/indexes (e.g. `ix_s_customer_hk`, `ix_s_card_hk`, etc.)
- All LSAT indexes (e.g. `ix_lsat_service_run_hk`, `ix_lsat_stop_dwell_hk`, etc.)

## Verification Query (SQLite)

```sql
-- Confirm all tables exist and have the expected DV2 columns
SELECT name,
       COUNT(*) AS row_count,
       SUM(CASE WHEN load_datetime IS NOT NULL THEN 1 ELSE 0 END) AS has_load_datetime,
       SUM(CASE WHEN record_source IS NOT NULL THEN 1 ELSE 0 END) AS has_record_source,
       SUM(CASE WHEN hashdiff IS NOT NULL THEN 1 ELSE 0 END) AS has_hashdiff
FROM sqlite_master
WHERE type='table'
GROUP BY name;
```

Expected: 41 rows, each with `row_count=0` (empty but schema-valid), `has_load_datetime=1`,
`has_record_source=1`, `has_hashdiff=1`.

## Next Steps / Deployment Checklist

- [ ] Run `bronze_data_vault_ddl.sql` against the target database (Databricks Delta, Snowflake, PostgreSQL, Oracle, SQL Server — syntax is standard SQL; adjust datatype sizes as needed).
- [ ] Populate `ref_*` tables with TfNSW–specific enums (concession codes, fare periods, asset condition codes).
- [ ] Configure the ingestion pipeline to: (a) hash business keys + record_source → hk; (b) compute SHA-256 of all attribute columns → hashdiff; (c) compare hashdiff to existing vault rows; (d) insert new rows only when hashdiff differs (DV2 change detection).
- [ ] Set up daily/load-run `load_datetime` = CURRENT_TIMESTAMP at ingestion time (not wall-clock time of the prior load; each run gets its own timestamp).
- [ ] Document `record_source` values in the ETL configuration — ensure every source system tag is consistent.
- [ ] Build the Silver/Gold layers (dbt `intermediate` and `marts`) on top of this Raw Vault — do not transform in the vault itself.
- [ ] Grant / revoke access per `record_source` if different source systems have different security classifications.

---