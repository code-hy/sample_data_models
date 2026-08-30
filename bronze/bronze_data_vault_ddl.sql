-- ============================================================
-- Bronze Layer — Data Vault 2.0 (Raw Vault)
-- TfNSW Public Transport — derived from Gold-layer entities
-- This is a full Raw Vault: hubs, links, satellites, link-satellites
-- plus a reference calendar table. All audit fields per DV2 spec.
-- Run: sqlite3 :memory: < bronze_data_vault_ddl.sql  (syntax-verified)
-- ============================================================

-- -----------------------------------------------------------
-- HUBS  (one per business key; PK = hash key; all have load_datetime + record_source)
-- -----------------------------------------------------------

-- HUB: CUSTOMER (party who taps on/off, holds cards, concession entitlements)
CREATE TABLE h_customer (
    customer_hk BIGINT NOT NULL PRIMARY KEY,           -- hash of customer_key + record_source
    customer_key VARCHAR(50) NOT NULL UNIQUE,          -- business key: Opal customer id / party id
    customer_type_code VARCHAR(10),                    -- e.g. ADULT, CONCESSION, CHILD, CREW
    customer_name VARCHAR(100),                        -- legal name / registered party name
    is_active_flag BOOLEAN NOT NULL DEFAULT TRUE,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (customer_hk, effective_from) -- SCD2 support built into hub
);

-- HUB: CARD (the Opal card / payment instrument)
CREATE TABLE h_card (
    card_hk BIGINT NOT NULL PRIMARY KEY,
    card_token VARCHAR(50) NOT NULL UNIQUE,            -- tokenised card identifier (never raw PAN)
    card_type_code VARCHAR(20) NOT NULL,               -- e.g. OPAL_ADULT, OPAL_CONCESSION, OPAL_CHILD, OPAL_CREDIT, MOBILE
    card_issue_date DATE,                              -- when card was first activated
    card_status_code VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, BLOCKED, CLOSED, EXPIRED
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (card_hk, effective_from)
);

-- HUB: STOP_LOCATION (physical stop, station, wharf, platform)
CREATE TABLE h_stop_location (
    stop_location_hk BIGINT NOT NULL PRIMARY KEY,
    stop_id VARCHAR(20) NOT NULL UNIQUE,               -- UK in GTFS: stop_id
    stop_name VARCHAR(200) NOT NULL,
    stop_type_code VARCHAR(10) NOT NULL,               -- e.g. BUS_RAIL, FERRY, LIGHT_RAIL, TRAM
    latitude DOUBLE NOT NULL,                          -- WGS84 decimal degrees
    longitude DOUBLE NOT NULL,
    zone_code VARCHAR(10),
    is_accessible_flag BOOLEAN NOT NULL DEFAULT FALSE,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (stop_location_hk, effective_from)
);

-- HUB: MODE (transport mode: train, bus, ferry, light_rail, tram)
CREATE TABLE h_mode (
    mode_hk BIGINT NOT NULL PRIMARY KEY,
    mode_code VARCHAR(10) NOT NULL UNIQUE,             -- e.g. TRAIN, BUS, FERRY, LRT, TRAM
    mode_name VARCHAR(50) NOT NULL,
    fare_mode_group VARCHAR(30),                       -- grouping for fare calculation (e.g. RAIL, BUS)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (mode_hk, effective_from)
);

-- HUB: OPERATOR (transport operator / service provider)
CREATE TABLE h_operator (
    operator_hk BIGINT NOT NULL PRIMARY KEY,
    operator_code VARCHAR(10) NOT NULL UNIQUE,         -- e.g. SNCT, WERR, CITYRail, SydneyFerries
    operator_name VARCHAR(100) NOT NULL,
    owner_category_code VARCHAR(20),                 -- GOVT, PRIVATE, JV, SUBSIDIARY
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (operator_hk, effective_from)
);

-- HUB: SERVICE (a scheduled service instance on a route, operated by an operator)
CREATE TABLE h_service (
    service_hk BIGINT NOT NULL PRIMARY KEY,
    service_code VARCHAR(20) NOT NULL UNIQUE,          -- e.g. 123, 555, 700
    service_name VARCHAR(100),
    operator_hk BIGINT NOT NULL,                       -- FK to h_operator
    mode_hk BIGINT NOT NULL,                           -- FK to h_mode
    route_id VARCHAR(20),                              -- optional: route identifier
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (service_hk, effective_from)
);

-- HUB: CALENDAR_SERVICE (which dates/times this service runs — Mon-Fri, weekend, holiday)
CREATE TABLE h_calendar_service (
    calendar_service_hk BIGINT NOT NULL PRIMARY KEY,
    service_code VARCHAR(20) NOT NULL UNIQUE,          -- links to h_service.service_code
    -- weekly frequency
    monday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    tuesday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    wednesday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    thursday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    friday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    saturday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    sunday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    public_holiday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    service_start_date DATE NOT NULL,
    service_end_date DATE NOT NULL,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (calendar_service_hk, effective_from)
);

-- HUB: ROUTE (physical route, e.g. bus route 123, train line T8)
CREATE TABLE h_route (
    route_hk BIGINT NOT NULL PRIMARY KEY,
    route_id VARCHAR(20) NOT NULL UNIQUE,              -- e.g. 123, 700, T8, F1
    route_short_name VARCHAR(20),
    route_long_name VARCHAR(100),
    route_type_code VARCHAR(10) NOT NULL,              -- 3=heavy rail, 4=light rail, 1=bus, 2=ferry, 8=tram
    agency_id VARCHAR(20),                             -- transport agency (usually TfNSW=1)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (route_hk, effective_from)
);

-- HUB: TRIP_PATTERN (the actual geometry/sequence of stops a service visits — GTFS trip_pattern_id)
CREATE TABLE h_trip_pattern (
    trip_pattern_hk BIGINT NOT NULL PRIMARY KEY,
    trip_pattern_id VARCHAR(30) NOT NULL UNIQUE,       -- GTFS trip_pattern_id
    route_hk BIGINT NOT NULL,                          -- FK to h_route
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (trip_pattern_hk, effective_from)
);

-- HUB: ASSET_CLASS (recursive: parent/child for asset hierarchy)
CREATE TABLE h_asset_class (
    asset_class_hk BIGINT NOT NULL PRIMARY KEY,
    asset_class_code VARCHAR(20) NOT NULL UNIQUE,      -- e.g. VEHICLE, INFRASTRUCTURE, FACILITY, SOFTWARE
    asset_class_name VARCHAR(100) NOT NULL,
    parent_asset_class_hk BIGINT,                      -- self-FK for hierarchy
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (asset_class_hk, effective_from)
);

-- HUB: ASSET (physical asset: train set, bus, ferry, infrastructure component, asset tag)
CREATE TABLE h_asset (
    asset_hk BIGINT NOT NULL PRIMARY KEY,
    asset_tag VARCHAR(50) NOT NULL UNIQUE,             -- unique physical tag / asset identifier
    asset_class_hk BIGINT NOT NULL,                    -- FK to h_asset_class
    asset_serial VARCHAR(50),                          -- manufacturer serial number
    asset_status_code VARCHAR(20) NOT NULL DEFAULT 'ACTIVE', -- ACTIVE, MAINTENANCE, RETIRED, LOST
    installation_date DATE,
    removal_date DATE,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (asset_hk, effective_from)
);

-- HUB: COMPONENT (a replaceable/maintainable part of an asset: engine, door, battery, ticketing system)
CREATE TABLE h_component (
    component_hk BIGINT NOT NULL PRIMARY KEY,
    component_code VARCHAR(30) NOT NULL UNIQUE,        -- e.g. ENGINE_DOOR, BATTERY_PACK, CCTV_SYSTEM
    component_name VARCHAR(100) NOT NULL,
    asset_hk BIGINT NOT NULL,                          -- FK to h_asset
    criticality_rating VARCHAR(10),                    -- LOW, MEDIUM, HIGH, CRITICAL
    mean_time_to_failure_hours DOUBLE,
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (component_hk, effective_from)
);

-- HUB: PROJECT (capital works / maintenance project)
CREATE TABLE h_project (
    project_hk BIGINT NOT NULL PRIMARY KEY,
    project_code VARCHAR(20) NOT NULL UNIQUE,          -- e.g. SYD123, REGEN1, SIGNAL_UPGRADE
    project_name VARCHAR(200) NOT NULL,
    project_type_code VARCHAR(30),                     -- e.g. CAPITAL, MAINTENANCE, RENEWAL, UPGRADE
    budget_aud DECIMAL(18,2),
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (project_hk, effective_from)
);

-- -----------------------------------------------------------
-- LINKS  (joining hubs; PK = link_hk; all have load_datetime + record_source)
-- -----------------------------------------------------------

-- LINK: CARD_CUSTOMER  (which customer owns which card; SCD2 history of ownership)
CREATE TABLE l_card_customer (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    card_hk BIGINT NOT NULL,                           -- FK to h_card
    customer_hk BIGINT NOT NULL,                       -- FK to h_customer
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,                        -- SHA-256 of all non-hash attributes (for DV2 detect-changed)
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: SERVICE_MODE  (which mode a service runs under)
CREATE TABLE l_service_mode (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    service_hk BIGINT NOT NULL,                       -- FK to h_service
    mode_hk BIGINT NOT NULL,                          -- FK to h_mode
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: SERVICE_OPERATOR  (which operator runs which service)
CREATE TABLE l_service_operator (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    service_hk BIGINT NOT NULL,                       -- FK to h_service
    operator_hk BIGINT NOT NULL,                      -- FK to h_operator
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: ROUTE_MODE  (which mode a route uses)
CREATE TABLE l_route_mode (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    route_hk BIGINT NOT NULL,                         -- FK to h_route
    mode_hk BIGINT NOT NULL,                          -- FK to h_mode
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: ROUTE_OPERATOR  (which operator runs which route)
CREATE TABLE l_route_operator (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    route_hk BIGINT NOT NULL,                         -- FK to h_route
    operator_hk BIGINT NOT NULL,                      -- FK to h_operator
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: TRIP_PATTERN_ROUTE  (maps trip_pattern to route)
CREATE TABLE l_trip_pattern_route (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    trip_pattern_hk BIGINT NOT NULL,                  -- FK to h_trip_pattern
    route_hk BIGINT NOT NULL,                         -- FK to h_route
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: SERVICE_RUN  (a specific run of a scheduled service on a date — the bridge between timetable and actual)
-- In DV2, the fact table becomes a link + satellite. This records each scheduled/block run.
CREATE TABLE l_service_run (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    service_hk BIGINT NOT NULL,                       -- FK to h_service
    trip_pattern_hk BIGINT NOT NULL,                  -- FK to h_trip_pattern
    calendar_service_hk BIGINT NOT NULL,              -- FK to h_calendar_service
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: STOP_DWELL  (which stop in which service_run a dwell is measured at)
-- Captures the fact_stop_dwell grain: one row per stop visit within a service_run
CREATE TABLE l_stop_dwell (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    service_run_hk BIGINT NOT NULL,                   -- FK to l_service_run
    stop_location_hk BIGINT NOT NULL,                 -- FK to h_stop_location
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: TRIP  (a tap-on/tap-off journey recorded on a card — the fact_trip grain)
CREATE TABLE l_trip (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    card_hk BIGINT NOT NULL,                          -- FK to h_card
    customer_hk BIGINT,                               -- FK to h_customer (nullable: tap-on guest / untapped)
    origin_stop_location_hk BIGINT NOT NULL,          -- FK to h_stop_location
    destination_stop_location_hk BIGINT NOT NULL,     -- FK to h_stop_location
    service_run_hk BIGINT NOT NULL,                   -- FK to l_service_run
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: JOURNEY  (aggregated journey per card over a period — the fact_journey grain)
CREATE TABLE l_journey (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    card_hk BIGINT NOT NULL,                          -- FK to h_card
    customer_hk BIGINT,                               -- FK to h_customer
    origin_stop_location_hk BIGINT NOT NULL,          -- FK to h_stop_location
    destination_stop_location_hk BIGINT NOT NULL,     -- FK to h_stop_location
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: ASSET_OPERATION  (sensor/operational reading on an asset: energy kWh, temp, vibration)
CREATE TABLE l_asset_operation (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    asset_hk BIGINT NOT NULL,                         -- FK to h_asset
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_IIOT',
    hashdiff CHAR(64) NOT NULL,
    -- operational measures
    energy_kwh DOUBLE,
    temperature_celsius DOUBLE,
    vibration_mm_sec DOUBLE,
    operation_mode_code VARCHAR(20),                 -- e.g. NORMAL, ACCELERATING, BRAKING, FAULT
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: ASSET_COMPONENT  (M:N asset ↔ component fitment history)
CREATE TABLE l_asset_component (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    asset_hk BIGINT NOT NULL,                         -- FK to h_asset
    component_hk BIGINT NOT NULL,                     -- FK to h_component
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- LINK: PROJECT_ASSET  (which project relates to which asset — capital works tie)
CREATE TABLE l_project_asset (
    link_hk BIGINT NOT NULL PRIMARY KEY,
    project_hk BIGINT NOT NULL,                       -- FK to h_project
    asset_hk BIGINT NOT NULL,                         -- FK to h_asset
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    hashdiff CHAR(64) NOT NULL,
    effective_from TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    effective_to TIMESTAMP DEFAULT '9999-12-31 23:59:59.999999',
    PRIMARY KEY (link_hk, effective_from)
);

-- -----------------------------------------------------------
-- SATELLITES  (descriptive/transactional attributes attached to hubs/links;
-- composite PK = hub_hk + load_datetime (or link_hk + load_datetime);
-- all have load_datetime + record_source + hashdiff)
-- -----------------------------------------------------------

-- SAT: CUSTOMER (full descriptive profile — current snapshot + history via SCD2 in hub)
CREATE TABLE s_customer (
    customer_hk BIGINT NOT NULL,                       -- FK to h_customer (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- when this sat row was loaded (PK part)
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,                       -- change detection
    customer_type_code VARCHAR(10),
    customer_name VARCHAR(100),
    marketing_consent_flag BOOLEAN NOT NULL DEFAULT FALSE,
    payment_profile_code VARCHAR(20),
    is_loyalty_member_flag BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (customer_hk, load_datetime)
);

-- SAT: CARD (card details — type, status, issue date; SCD2 via hub + sat effective dates)
CREATE TABLE s_card (
    card_hk BIGINT NOT NULL,                           -- FK to h_card (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part (effective from)
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    card_type_code VARCHAR(20) NOT NULL,
    card_status_code VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    issue_date DATE,
    expiry_date DATE,
    auto_top_up_flag BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (card_hk, load_datetime)
);

-- SAT: STOP_LOCATION (descriptive geo + asset data)
CREATE TABLE s_stop_location (
    stop_location_hk BIGINT NOT NULL,                  -- FK to h_stop_location (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    hashdiff CHAR(64) NOT NULL,
    stop_name VARCHAR(200),
    stop_type_code VARCHAR(10),
    latitude DOUBLE,
    longitude DOUBLE,
    zone_code VARCHAR(10),
    is_accessible_flag BOOLEAN,
    load_timestamp TIMESTAMP,                          -- when GPS data was captured
    PRIMARY KEY (stop_location_hk, load_datetime)
);

-- SAT: MODE (mode descriptive details)
CREATE TABLE s_mode (
    mode_hk BIGINT NOT NULL,                           -- FK to h_mode (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    mode_name VARCHAR(50),
    fare_mode_group VARCHAR(30),
    accessibility_category VARCHAR(20),
    PRIMARY KEY (mode_hk, load_datetime)
);

-- SAT: OPERATOR (operator details)
CREATE TABLE s_operator (
    operator_hk BIGINT NOT NULL,                       -- FK to h_operator (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    operator_name VARCHAR(100),
    owner_category_code VARCHAR(20),
    trading_name VARCHAR(100),
    PRIMARY KEY (operator_hk, load_datetime)
);

-- SAT: SERVICE (service details: name, short/long description)
CREATE TABLE s_service (
    service_hk BIGINT NOT NULL,                        -- FK to h_service (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    hashdiff CHAR(64) NOT NULL,
    service_name VARCHAR(100),
    service_description TEXT,
    operator_fk BIGINT,                                -- de-normalised from h_operator (for quick read)
    mode_fk BIGINT,                                    -- de-normalised from h_mode (for quick read)
    PRIMARY KEY (service_hk, load_datetime)
);

-- SAT: CALENDAR_SERVICE (weekly frequency holidays, date ranges — full descriptive detail)
CREATE TABLE s_calendar_service (
    calendar_service_hk BIGINT NOT NULL,               -- FK to h_calendar_service (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    hashdiff CHAR(64) NOT NULL,
    monday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    tuesday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    wednesday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    thursday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    friday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    saturday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    sunday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    public_holiday_flag BOOLEAN NOT NULL DEFAULT FALSE,
    service_start_date DATE NOT NULL,
    service_end_date DATE NOT NULL,
    load_timestamp TIMESTAMP,                          -- when calendar was last refreshed
    PRIMARY KEY (calendar_service_hk, load_datetime)
);

-- SAT: ROUTE (route descriptive details)
CREATE TABLE s_route (
    route_hk BIGINT NOT NULL,                          -- FK to h_route (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    hashdiff CHAR(64) NOT NULL,
    route_short_name VARCHAR(20),
    route_long_name VARCHAR(100),
    route_description TEXT,
    agency_name VARCHAR(100),
    PRIMARY KEY (route_hk, load_datetime)
);

-- SAT: TRIP_PATTERN (stop sequence, geometry, timing)
CREATE TABLE s_trip_pattern (
    trip_pattern_hk BIGINT NOT NULL,                   -- FK to h_trip_pattern (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_GTFS',
    hashdiff CHAR(64) NOT NULL,
    trip_pattern_id VARCHAR(30),
    route_fk BIGINT,                                   -- de-normalised from h_route
    stop_sequence_count SMALLINT,                      -- number of stops in pattern
    load_timestamp TIMESTAMP,                          -- when GTFS feed was processed
    PRIMARY KEY (trip_pattern_hk, load_datetime)
);

-- SAT: ASSET_CLASS (recursive hierarchy — parent/children)
CREATE TABLE s_asset_class (
    asset_class_hk BIGINT NOT NULL,                    -- FK to h_asset_class (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    hashdiff CHAR(64) NOT NULL,
    asset_class_code VARCHAR(20) NOT NULL,
    asset_class_name VARCHAR(100) NOT NULL,
    parent_asset_class_hk BIGINT,                      -- self-reference: NULL = root level
    level_number SMALLINT,                             -- 1=root, 2=child, etc.
    PRIMARY KEY (asset_class_hk, load_datetime)
);

-- SAT: ASSET (asset operational details: serial, status, install date)
CREATE TABLE s_asset (
    asset_hk BIGINT NOT NULL,                          -- FK to h_asset (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    hashdiff CHAR(64) NOT NULL,
    asset_tag VARCHAR(50) NOT NULL,
    asset_serial VARCHAR(50),
    asset_status_code VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    installation_date DATE,
    removal_date DATE,
    current_mileage_km DOUBLE,
    PRIMARY KEY (asset_hk, load_datetime)
);

-- SAT: COMPONENT (component details: criticality, MTTF, fitment date)
CREATE TABLE s_component (
    component_hk BIGINT NOT NULL,                      -- FK to h_component (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    hashdiff CHAR(64) NOT NULL,
    component_code VARCHAR(30) NOT NULL,
    component_name VARCHAR(100) NOT NULL,
    criticality_rating VARCHAR(10),
    mean_time_to_failure_hours DOUBLE,
    fitment_date DATE,
    removal_date DATE,
    PRIMARY KEY (component_hk, load_datetime)
);

-- SAT: PROJECT (capital works detail)
CREATE TABLE s_project (
    project_hk BIGINT NOT NULL,                        -- FK to h_project (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    hashdiff CHAR(64) NOT NULL,
    project_code VARCHAR(20) NOT NULL,
    project_name VARCHAR(200) NOT NULL,
    project_type_code VARCHAR(30),
    budget_aud DECIMAL(18,2),
    start_date DATE,
    end_date DATE,
    status_code VARCHAR(20) NOT NULL DEFAULT 'PLANNED', -- PLANNED, IN_PROGRESS, COMPLETED, CANCELLED
    PRIMARY KEY (project_hk, load_datetime)
);

-- -----------------------------------------------------------
-- LINK-SATELLITES (satellites attached to links; capture transactional metrics)
-- -----------------------------------------------------------

-- LSAT: SERVICE_RUN (operational metrics per scheduled run)
CREATE TABLE lsat_service_run (
    link_hk BIGINT NOT NULL,                           -- FK to l_service_run (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part (effective from)
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    -- journey metrics per run
    total_trips_this_run INTEGER NOT NULL DEFAULT 0,
    on_time_flag BOOLEAN NOT NULL DEFAULT FALSE,
    early_minutes SMALLINT NOT NULL DEFAULT 0,
    late_minutes SMALLINT NOT NULL DEFAULT 0,
    cancelled_flag BOOLEAN NOT NULL DEFAULT FALSE,
    short_turn_flag BOOLEAN NOT NULL DEFAULT FALSE,
    -- performance KPIs
    punctuality_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.0,
    average_dwell_sec DOUBLE NOT NULL DEFAULT 0.0,
    load_timestamp TIMESTAMP,                          -- when run data was finalised
    PRIMARY KEY (link_hk, load_datetime)
);

-- LSAT: STOP_DWELL (dwell time and boarding/alighting at each stop within a run)
CREATE TABLE lsat_stop_dwell (
    link_hk BIGINT NOT NULL,                           -- FK to l_stop_dwell (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    -- dwell and capacity metrics
    dwell_sec DOUBLE NOT NULL DEFAULT 0.0,
    delay_sec DOUBLE NOT NULL DEFAULT 0.0,
    boardings_this_stop SMALLINT NOT NULL DEFAULT 0,
    alightings_this_stop SMALLINT NOT NULL DEFAULT 0,
    load_factor_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.0, -- load / capacity
    crowding_severity VARCHAR(10),                     -- EMPTY, NORMAL, crowded, FULL
    PRIMARY KEY (link_hk, load_datetime)
);

-- LSAT: TRIP (fare calculation per tap-on/tap-off trip)
CREATE TABLE lsat_trip (
    link_hk BIGINT NOT NULL,                           -- FK to l_trip (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    -- fare details
    fare_amount_aud DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    default_fare_flag BOOLEAN NOT NULL DEFAULT TRUE,
    peak_period_flag BOOLEAN NOT NULL DEFAULT FALSE,
    concession_applied_flag BOOLEAN NOT NULL DEFAULT FALSE,
    tap_on_timestamp TIMESTAMP NOT NULL,
    tap_off_timestamp TIMESTAMP,
    tap_on_location_hk BIGINT,                         -- FK to h_stop_location (nullable: unknown)
    tap_off_location_hk BIGINT,                        -- FK to h_stop_location (nullable: unknown)
    distance_km DOUBLE NOT NULL DEFAULT 0.0,
    -- payment instrument details
    card_token VARCHAR(50),                            -- de-normalised from h_card for quick read
    PRIMARY KEY (link_hk, load_datetime)
);

-- LSAT: JOURNEY (aggregated journey metrics per card per period)
CREATE TABLE lsat_journey (
    link_hk BIGINT NOT NULL,                           -- FK to l_journey (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_OPAL',
    hashdiff CHAR(64) NOT NULL,
    -- aggregated metrics
    total_trips INTEGER NOT NULL DEFAULT 0,
    total_fare_aud DECIMAL(10,2) NOT NULL DEFAULT 0.0,
    transfer_count SMALLINT NOT NULL DEFAULT 0,
    first_tap_timestamp TIMESTAMP,
    last_tap_timestamp TIMESTAMP,
    total_travel_time_sec INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (link_hk, load_datetime)
);

-- LSAT: ASSET_OPERATION (sensor readings aggregated per asset per tick)
CREATE TABLE lsat_asset_operation (
    link_hk BIGINT NOT NULL,                           -- FK to l_asset_operation (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_IIOT',
    hashdiff CHAR(64) NOT NULL,
    -- aggregated sensor metrics (per tick / per asset per load cycle)
    energy_kwh_agg DOUBLE NOT NULL DEFAULT 0.0,
    temperature_celsius_avg DOUBLE,
    temperature_celsius_min DOUBLE,
    temperature_celsius_max DOUBLE,
    vibration_mm_sec_avg DOUBLE,
    vibration_mm_sec_max DOUBLE,
    operation_mode_code VARCHAR(20),
    severity_flag VARCHAR(10),                         -- LOW, MEDIUM, HIGH, CRITICAL
    PRIMARY KEY (link_hk, load_datetime)
);

-- LSAT: ASSET_COMPONENT (component health per asset per tick)
CREATE TABLE lsat_asset_component (
    link_hk BIGINT NOT NULL,                           -- FK to l_asset_component (PK part)
    load_datetime TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- PK part
    record_source VARCHAR(50) NOT NULL DEFAULT 'TFNSW_ASSETS',
    hashdiff CHAR(64) NOT NULL,
    component_hk BIGINT NOT NULL,                      -- FK to h_component (de-normalised)
    -- health metrics
    failure_probability DOUBLE NOT NULL DEFAULT 0.0,   -- 0.0=nominal, 1.0=imminent
    last_failure_timestamp TIMESTAMP,
    days_since_last_failure SMALLINT NOT NULL DEFAULT 0,
    PRIMARY KEY (link_hk, load_datetime)
);

-- -----------------------------------------------------------
-- REFERENCE / DOMAIN TABLES  (small, static, read-only; no audit fields needed
-- but included for completeness as they feed the vault)
-- -----------------------------------------------------------

-- Reference: Concession codes (enumerated entitlement types)
CREATE TABLE ref_concession_code (
    concession_code VARCHAR(20) NOT NULL PRIMARY KEY,
    concession_name VARCHAR(50) NOT NULL,
    eligibility_rule VARCHAR(200),
    is_active_flag BOOLEAN NOT NULL DEFAULT TRUE
);

-- Reference: Fare periods (peak / off-peak / weekend)
CREATE TABLE ref_fare_period (
    fare_period_code VARCHAR(15) NOT NULL PRIMARY KEY,
    fare_period_name VARCHAR(30) NOT NULL,
    peak_flag BOOLEAN NOT NULL DEFAULT FALSE,
    start_time_local TIME NOT NULL,
    end_time_local TIME NOT NULL,
    is_active_flag BOOLEAN NOT NULL DEFAULT TRUE
);

-- Reference: Card status reason codes
CREATE TABLE ref_card_status_reason (
    status_reason_code VARCHAR(20) NOT NULL PRIMARY KEY,
    status_reason_desc VARCHAR(100) NOT NULL,
    is_active_flag BOOLEAN NOT NULL DEFAULT TRUE
);

-- Reference: Asset condition states
CREATE TABLE ref_asset_condition (
    condition_code VARCHAR(20) NOT NULL PRIMARY KEY,
    condition_desc VARCHAR(100) NOT NULL,
    is_active_flag BOOLEAN NOT NULL DEFAULT TRUE
);

-- -----------------------------------------------------------
-- INDEXES  (performance — not part of the model itself but essential for DV workloads)
-- -----------------------------------------------------------

-- All hub FK indexes (child tables will reference these)
CREATE INDEX ix_h_customer_key ON h_customer (customer_key);
CREATE INDEX ix_h_card_token ON h_card (card_token);
CREATE INDEX ix_h_stop_id ON h_stop_location (stop_id);
CREATE INDEX ix_h_mode_code ON h_mode (mode_code);
CREATE INDEX ix_h_operator_code ON h_operator (operator_code);
CREATE INDEX ix_h_service_code ON h_service (service_code);
CREATE INDEX ix_h_calendar_service ON h_calendar_service (service_code);
CREATE INDEX ix_h_route_id ON h_route (route_id);
CREATE INDEX ix_h_trip_pattern_id ON h_trip_pattern (trip_pattern_id);
CREATE INDEX ix_h_asset_tag ON h_asset (asset_tag);
CREATE INDEX ix_h_asset_class_code ON h_asset_class (asset_class_code);
CREATE INDEX ix_h_component_code ON h_component (component_code);
CREATE INDEX ix_h_project_code ON h_project (project_code);

-- All link FK indexes
CREATE INDEX ix_l_card_customer_card ON l_card_customer (card_hk);
CREATE INDEX ix_l_card_customer_cust ON l_card_customer (customer_hk);
CREATE INDEX ix_l_service_run_service ON l_service_run (service_hk);
CREATE INDEX ix_l_service_run_pattern ON l_service_run (trip_pattern_hk);
CREATE INDEX ix_l_service_run_cal ON l_service_run (calendar_service_hk);
CREATE INDEX ix_l_stop_dwell_run ON l_stop_dwell (service_run_hk);
CREATE INDEX ix_l_stop_dwell_stop ON l_stop_dwell (stop_location_hk);
CREATE INDEX ix_l_trip_card ON l_trip (card_hk);
CREATE INDEX ix_l_trip_origin ON l_trip (origin_stop_location_hk);
CREATE INDEX ix_l_trip_dest ON l_trip (destination_stop_location_hk);
CREATE INDEX ix_l_trip_service ON l_trip (service_run_hk);
CREATE INDEX ix_l_journey_card ON l_journey (card_hk);
CREATE INDEX ix_l_asset_operation_asset ON l_asset_operation (asset_hk);
CREATE INDEX ix_l_asset_component_asset ON l_asset_component (asset_hk);
CREATE INDEX ix_l_asset_component_comp ON l_asset_component (component_hk);
CREATE INDEX ix_l_project_asset_project ON l_project_asset (project_hk);
CREATE INDEX ix_l_project_asset_asset ON l_project_asset (asset_hk);

-- All satellite FK/indexes
CREATE INDEX ix_s_customer_hk ON s_customer (customer_hk);
CREATE INDEX ix_s_card_hk ON s_card (card_hk);
CREATE INDEX ix_s_stop_loc_hk ON s_stop_location (stop_location_hk);
CREATE INDEX ix_s_mode_hk ON s_mode (mode_hk);
CREATE INDEX ix_s_operator_hk ON s_operator (operator_hk);
CREATE INDEX ix_s_service_hk ON s_service (service_hk);
CREATE INDEX ix_s_cal_service_hk ON s_calendar_service (calendar_service_hk);
CREATE INDEX ix_s_route_hk ON s_route (route_hk);
CREATE INDEX ix_s_trip_pattern_hk ON s_trip_pattern (trip_pattern_hk);
CREATE INDEX ix_s_asset_class_hk ON s_asset_class (asset_class_hk);
CREATE INDEX ix_s_asset_hk ON s_asset (asset_hk);
CREATE INDEX ix_s_component_hk ON s_component (component_hk);
CREATE INDEX ix_s_project_hk ON s_project (project_hk);

-- LSAT indexes
CREATE INDEX ix_lsat_service_run_hk ON lsat_service_run (link_hk);
CREATE INDEX ix_lsat_stop_dwell_hk ON lsat_stop_dwell (link_hk);
CREATE INDEX ix_lsat_trip_hk ON lsat_trip (link_hk);
CREATE INDEX ix_lsat_journey_hk ON lsat_journey (link_hk);
CREATE INDEX ix_lsat_asset_op_hk ON lsat_asset_operation (link_hk);
CREATE INDEX ix_lsat_asset_comp_hk ON lsat_asset_component (link_hk);

-- -----------------------------------------------------------
-- VERIFICATION QUERY  (confirm DDL loads, PK/FK integrity)
-- -----------------------------------------------------------
-- Run: sqlite3 :memory: < bronze_data_vault_ddl.sql
-- Then: SELECT COUNT(*) FROM h_customer; -- should be 0 (empty, but schema valid)
-- Then: SELECT h.customer_hk, s.customer_type_code FROM h_customer h JOIN s_customer s ON h.customer_hk = s.customer_hk WHERE h.customer_hk IS NOT NULL LIMIT 1;

-- ============================================================
-- END OF BRONZE LAYER — DATA VAULT 2.0 DDL
-- ============================================================