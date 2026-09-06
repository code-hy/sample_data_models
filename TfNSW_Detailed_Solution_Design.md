
# Detailed Solution Design (DSD) Document
## Transport for NSW (TfNSW) Enterprise Data Analytics Platform

**Document Version:** 1.0  
**Date:** 6 September 2026  
**Status:** Approved for Delivery  
**Owner:** Enterprise Data Analytics Architect  

---

## 1. Document Control

### 1.1 Purpose
The purpose of this Detailed Solution Design (DSD) document is to translate the approved **TfNSW Enterprise Data Analytics Architecture** into exact engineering specifications. It bridges the gap between high-level architectural principles and the physical implementation of the data platform.

### 1.2 Scope
This document covers the physical and logical design of the **Bronze (Data Vault 2.0 Raw Vault)** and **Gold (Kimball Dimensional)** layers, including conformed dimensions, source-to-target mappings, temporal semantics, spatial design, and data quality rules.

### 1.3 Target Audience
* Data Engineers (Pipeline implementation)
* Data Modellers (Physical schema creation)
* Analytics Engineers (Transformation logic & dbt/SQL)
* BI Developers (Semantic layer & dashboarding)
* Platform/DevOps Engineers (Infrastructure as Code)

---

## 2. Architecture Overview & Layering Strategy

The solution adheres strictly to the Medallion Architecture, augmented by Data Vault 2.0 for historised integration and Kimball methodologies for business consumption.

| Layer | Pattern | Purpose | Storage Format |
| :--- | :--- | :--- | :--- |
| **Ingestion** | Raw Landing | Immutable capture of API, Batch, and Stream payloads. | JSON / Parquet (Raw) |
| **Bronze** | Data Vault 2.0 Raw Vault | Enterprise-wide historised integration. Preserves source grain, handles late-arriving data, and maintains auditability. | Delta Lake |
| **Gold** | Kimball Dimensional | Conformed, business-ready data products optimised for BI, ML, and Semantic layers. | Delta Lake (Z-Ordered) |
| **Semantic** | Metrics Layer | Certified business definitions (e.g., "On-Time Performance") decoupled from BI tools. | Tabular / DirectQuery |

---

## 3. Bronze Layer Detailed Design (Data Vault 2.0 Raw Vault)

The Bronze layer implements a **Data Vault 2.0 Raw Vault**. It is designed to absorb volatility from source systems (GTFS, Opal, Asset Registers) without breaking downstream Gold models.

### 3.1 Conceptual Model & Naming Conventions
All Bronze tables follow standard Data Vault naming conventions to ensure consistency across the `bronze_data_vault_ddl.sql`.

* **Hubs (`hub_`)**: Core business keys (e.g., `hub_route`, `hub_stop_location`, `hub_asset`).
* **Links (`link_`)**: Relationships and transactions (e.g., `link_route_stop`, `link_trip_pattern`).
* **Satellites (`sat_`)**: Context and descriptive attributes (e.g., `sat_gtfs_trip`, `sat_asset_condition`).

### 3.2 Key Bronze Entities (TfNSW Context)

| Entity Type | Table Name | Business Key | Description |
| :--- | :--- | :--- | :--- |
| **Hub** | `hub_stop_location` | `stop_id` | Master list of all physical stops, stations, wharves. |
| **Hub** | `hub_route` | `route_id` | Master list of transport routes (Bus, Train, Ferry). |
| **Hub** | `hub_asset` | `asset_id` | Physical infrastructure (rolling stock, tracks, signals). |
| **Link** | `link_trip_pattern` | `trip_id`, `route_id` | Connects a specific scheduled trip to its logical route. |
| **Link** | `link_route_stop` | `route_id`, `stop_id` | Defines the sequence of stops on a route. |
| **Satellite** | `sat_gtfs_trip` | `trip_id` | Stores static GTFS trip attributes (headsign, direction). |
| **Satellite** | `sat_gtfs_rt_event` | `trip_id`, `stop_id` | Stores real-time GTFS-R updates (delay, actual times). |
| **Satellite** | `sat_opal_tap` | `card_id`, `tap_time` | Stores Opal card tap-on/tap-off events. |

### 3.3 Physical Design Specifications (Delta Lake)
* **Partitioning:** All Satellite tables partitioned by `load_date` (or `ingestion_date`) to optimise incremental loads.
* **Hashing:** SHA-256 hashing for Hub Keys (`hk_`) and Hash Differences (`hd_`) for Satellites to detect changes.
* **Metadata Columns:** Every table must include `load_dts` (timestamp), `record_source` (system name), and `load_id` (batch ID).

---

## 4. Gold Layer Detailed Design (Kimball Dimensional Models)

The Gold layer consists of three interconnected dimensional models that share a **Conformed Core** to allow cross-domain analytics (e.g., linking Customer Patronage to Asset Maintenance).

### 4.1 The Conformed Core (Shared Dimensions)
These dimensions are built once and referenced across all three Gold models to ensure enterprise consistency.

| Conformed Dimension | Primary Key | Description & Grain |
| :--- | :--- | :--- |
| `dim_time` | `time_key` | Minute, Hour, Day, Week, Month, Financial Year. |
| `dim_mode` | `mode_key` | METRO, TRAIN, BUS, FERRY, LRT, COACH. |
| `dim_operator` | `operator_key` | The entity running the service / holding the asset. |
| `dim_stop_location` | `stop_location_key` | Geography of 292 stations, 27k bus stops, 48 wharves. |
| `dim_customer_party` | `customer_key` | Anonymised/hashed representation of the traveller. |
| `dim_asset` | `asset_key` | Specific physical asset (train set, signal box). |

---

### 4.2 Model 01: Customer Patronage & Journey
*Objective: Customer-centric fare & patronage analytics ("single view of customer").*

**Business Process:** Passenger travelling from origin to destination using Opal or contactless payment.  
**Grain:** One row per individual journey leg (tap-on to tap-off).

| Table | Type | Key Attributes / Measures |
| :--- | :--- | :--- |
| `fact_journey` | Fact | `journey_duration_mins`, `fare_paid`, `transfer_count` |
| `fact_trip` | Fact | `tap_on_time`, `tap_off_time`, `distance_travelled` |
| `dim_card` | Dimension | Card type (Opal, Contactless, Concession), Anonymised ID |
| `dim_route` | Dimension | Route short name, long name, mode group |

---

### 4.3 Model 02: Network & Service Performance
*Objective: Timetabling + on-time performance (OTP) & reliability (GTFS backbone).*

**Business Process:** A scheduled transport service executing its route and stopping at locations.  
**Grain:** One row per service-trip-stop event.

| Table | Type | Key Attributes / Measures |
| :--- | :--- | :--- |
| `fact_service_run` | Fact | `scheduled_time`, `actual_time`, `delay_seconds`, `is_cancelled` |
| `fact_stop_dwell` | Fact | `dwell_time_seconds`, `door_open_time`, `passenger_load` |
| `dim_trip_pattern` | Dimension | Direction, Shape ID, Sequence order |
| `dim_calendar_service`| Dimension | Service exceptions, holiday calendars, operational days |

---

### 4.4 Model 03: Asset Register & Predictive Maintenance
*Objective: Asset hierarchy, condition monitoring, predictive maintenance, net-zero.*

**Business Process:** Monitoring asset health and executing maintenance work orders.  
**Grain:** One row per daily asset operation snapshot or per work order event.

| Table | Type | Key Attributes / Measures |
| :--- | :--- | :--- |
| `fact_asset_operation` | Fact | `energy_consumed_kwh`, `fault_codes`, `mileage_run` |
| `fact_work_order` | Fact | `planned_cost`, `actual_cost`, `downtime_hours`, `mtbf` |
| `dim_asset_class` | Dimension | Hierarchy (e.g., Rolling Stock -> EMU -> Sub-system) |
| `dim_component` | Dimension | Specific replaceable parts within an asset |

---

## 5. Source-to-Target Mapping (STM) & Transformation Logic

This section defines the exact SQL/transformation logic required to move data from Bronze to Gold.

### 5.1 Example STM: `fact_service_run` (Gold) from Data Vault (Bronze)

**Target Table:** `gold.fact_service_run`  
**Grain:** One record per `trip_id` + `stop_id` + `service_date`.

| Source (Bronze DV) | Transformation Logic | Target (Gold) |
| :--- | :--- | :--- |
| `hub_trip.hk_trip` | Join key | `trip_id` (Natural Key for debugging) |
| `hub_stop.hk_stop` | Join key | `stop_location_key` (Surrogate Key) |
| `sat_gtfs_trip.scheduled_arrival` | Base time | `scheduled_time` |
| `sat_gtfs_rt_event.actual_arrival` | Base time | `actual_time` |
| *Derived Logic* | `DATEDIFF(second, scheduled, actual)` | `delay_seconds` |
| *Derived Logic* | `CASE WHEN delay_seconds > 299 THEN 1 ELSE 0 END` | `is_late_flag` (Based on TfNSW OTP rule) |

### 5.2 Transformation Framework (dbt / Spark SQL)
* **Incremental Loads:** Use `MERGE INTO` (Delta Lake) on the Gold tables based on the natural key composite (`trip_id`, `stop_id`, `service_date`) to handle late-arriving GTFS-R updates.
* **Watermarks:** Streaming ingestion (e.g., Databricks Structured Streaming) must use a watermark of 2 hours to handle delayed vehicle position pings before triggering Gold aggregations.

---

## 6. Temporal & Spatial Semantics Design

### 6.1 Time Architecture
Transport analytics requires strict separation of time concepts. The DSD mandates the following columns in relevant Bronze Satellites and Gold Facts:
1. **`service_date`**: The operational day (e.g., a 2:00 AM trip belongs to the previous day's service date).
2. **`scheduled_time`**: From GTFS static feed.
3. **`actual_time`**: From GTFS-R / GPS sensors.
4. **`ingestion_time`**: When the platform received the payload (System clock).
5. **`correction_time`**: When a source system revised a previous event (used for restatement logic).

### 6.2 Spatial Architecture
* **Coordinate Reference System (CRS):** All spatial data must be normalised to **EPSG:7844** (GDA2020) for NSW.
* **Geometry Storage:** `dim_stop_location` will store `latitude`, `longitude`, and a `geography` (Point) data type for native spatial joins (e.g., ST_Distance).
* **Network Topology:** `link_route_stop` will include a `sequence_order` and `shape_id` to allow routing engines to reconstruct the exact path taken, rather than just straight-line distances between stops.

---

## 7. Data Quality, Governance & Security Design

### 7.1 Data Quality (DQ) Rules & Observability
Implemented via Great Expectations or native dbt tests.

| Layer | DQ Check | Threshold | Action on Failure |
| :--- | :--- | :--- | :--- |
| **Bronze** | **Completeness:** `hk_trip` NOT NULL | 100% | Fail Pipeline (Quarantine data) |
| **Bronze** | **Freshness:** `load_dts` < 15 mins ago | 95% | Alert Data Ops (Degraded mode) |
| **Gold** | **Validity:** `delay_seconds` IS NUMERIC | 100% | Coalesce to 0, flag in `dq_audit_log` |
| **Gold** | **Referential:** `stop_location_key` EXISTS | 99.9% | Create "Unknown" dimension record |

### 7.2 Security & Access Control
* **Row-Level Security (RLS):** Applied at the Semantic/Gold layer. An operator (e.g., "Transdev") can only query `fact_service_run` where `dim_operator.operator_name = 'Transdev'`.
* **Column-Level Security (CLS):** `dim_customer_party` attributes are masked. Only aggregated cohort data is visible to standard analysts.
* **Audit:** All queries against Gold layer logged to a central SIEM for compliance with NSW privacy directives.

---

## 8. Environment Design & CI/CD Strategy

### 8.1 Environment Segregation
| Environment | Purpose | Data Strategy | Compute |
| :--- | :--- | :--- | :--- |
| **DEV** | Pipeline development, unit testing | Synthetic / Mock GTFS data | Serverless SQL / Small Clusters |
| **TEST** | Integration testing, DQ validation | Masked subset of PROD Bronze | Standard Clusters |
| **UAT** | Business User Acceptance Testing | Full PROD data (Read-Only for users) | Prod-equivalent |
| **PROD** | Live operations, BI, AI/ML | Full live ingestion and history | Auto-scaling Clusters |

### 8.2 CI/CD Pipeline (GitHub Actions / Azure DevOps)
1. **Commit:** Developer pushes SQL/dbt changes to feature branch.
2. **Build:** Pipeline compiles SQL, runs unit tests against DEV.
3. **Deploy:** Infrastructure as Code (Terraform) provisions Delta tables if schema changed.
4. **Test:** Runs integration tests against TEST environment.
5. **Release:** Promotes code to PROD via automated deployment pipeline.

---

## 9. Sign-off & Approval

| Role | Name | Signature | Date |
| :--- | :--- | :--- | :--- |
| **Enterprise Data Architect** | [Name] | __________________ | [Date] |
| **Lead Data Modeller** | [Name] | __________________ | [Date] |
| **Domain Owner (Network)** | [Name] | __________________ | [Date] |
| **Domain Owner (Assets)** | [Name] | __________________ | [Date] |
| **Platform Engineering Lead**| [Name] | __________________ | [Date] |

---
*End of Detailed Solution Design Document*

