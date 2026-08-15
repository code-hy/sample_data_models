# TfNSW Gold Layer — Data Dictionary

Domain reference: Transport Data Strategy 2022–2025, transportnsw.info, TfNSW Open Data Hub.
Conventions: surrogate keys (`*_sk`) on all dimensions; conformed dimensions shared across marts;
SCD **Type 2** for any dimension where history matters (copy the `scd_start_date`, `scd_end_date`,
`current_flag` triplet). Units: `_aud` = Australian dollars, `_km` = kilometres, `_sec` = seconds.

---

## Model 01 — Customer Patronage & Journey

### Conformed Dimensions

| Table | Key | SCD | Description |
|---|---|---|---|
| **dim_time** | `time_sk` | — | Minute-grained time dimension. `fare_period` reflects peak/off-peak rules (widened 6 Jul 2020; Fri–Sun off-peak from Oct 2023). |
| **dim_mode** | `mode_sk` (`mode_code` UK) | — | The five fare modes + coach/P2P/road. `fare_mode_group` ∈ {metro/train, bus/lightrail, ferry, other}. |
| **dim_operator** | `operator_sk` | Type 2 | Entity that runs the vehicle/run (TfNSW brands ≠ operating entity — operations contracted to Transdev, Keolis Downer, etc.). |
| **dim_stop_location** | `location_sk` | Type 2 | One physical stop/station/wharf. 292 train, 27,556 bus, 48 ferry, 48 light-rail, 13 metro. |
| **dim_service** | `service_sk` | Type 2 | Fare-facing scheduled service (T1, M1, 333, F1...). |
| **dim_customer_party** | `customer_sk` | Type 2 | Registered customer/contact. **Personal data (RESTRICTED)**. |
| **dim_card** | `card_sk` (`card_token` UK) | Type 2 | Fare instrument. `card_type` ∈ Adult, Child/Youth, Senior/Pensioner, Concession, Employee, School, Contactless. SCD records entitlement/registration history. |
| **bridge_card_concession** | `bridge_id` | — | M:N card↔concession eligibility (student enrolment consent, etc.). |
| **fact_trip** | `trip_id` | — | **Grain: one tap-on→tap-off trip.** Distance-based fare; default fare when no tap-off. |
| **fact_journey** | `journey_id` | — | **Grain: one journey (1..=8 trips** linked by transfer rule). Cross-modal / interchange / MaaS view. |
| **agg_patronage_daily** | composite | — | Pre-aggregated grain: service × OD × day × period. |

### Key Business Rules (TfNSW-specific)
- **Trip** = single tap-on→tap-off unit. **Journey** = 1..=8 trips within the 1-hour transfer window (Manly ferry 130 min from tap-on). Same-mode consecutive trips fuse into one tariff = **Trip Advantage**.
- Fares distance-based per fare-mode-group; **peak/off-peak**, **daily/weekly/Sunday caps**, and **transfer discounts** ($2 adult / $1 other) apply.
- Default fare charged when the passenger fails to tap off (max journey time ~5 h trains).
- Card balances: Adult/Senior **$250** max, others **$150**. Auto top-up default threshold **$10**.

### Provenance / audit columns
Every fact carries `record_source` + `load_datetime` so the Gold layer is traceable back to Silver/Bronze (lineage per the Data Strategy's governance enabler).

---

## Model 02 — Network & Service Performance

### Conformed Dimensions

| Table | Key | SCD | Description |
|---|---|---|---|
| **dim_route** | `route_sk` (`route_id`,`agency_id` UK) | Type 2 | GTFS `routes.txt`: named line/corridor (T1, B-Line, F1, L2...). |
| **dim_trip_pattern** | `trip_pattern_sk` (`trip_id` UK) | — | GTFS `trips.txt`: a specific scheduled journey of a route (headsign, direction, shape). |
| **dim_calendar_service** | `calendar_sk` | — | GTFS `calendar.txt`/`calendar_dates.txt`: which days a service operates incl. trackwork/public-holiday exceptions. |
| **bridge_route_stop** | `bridge_id` | — | M:N route↔stop with ordered `stop_sequence`, distance, timing-point flag. |
| **fact_service_run** | `service_run_id` | — | **Grain: one scheduled run per day per trip pattern.** Scheduled vs actual + OTP measures. |
| **fact_stop_dwell** | `dwell_id` | — | **Grain: one stop-visit per run.** Dwell/boarding/crowding for interchange optimisation. |
| **agg_otp_daily** | composite | — | Route × date × period OTP % + reliability KPIs. |

### Key Business Rules
- OTP measured at **timing points** only (a run is 'on time' within a short tolerance; rail also measured with NUW headway for metro).
- `is_timing_point_flag` on `bridge_route_stop` designates where OTP is assessed.
- Trackwork/substitution handled through `dim_calendar_service.exception_type` + `substitution_service_fk`.

---

## Model 03 — Asset Register & Predictive Maintenance

### Conformed Dimensions

| Table | Key | SCD | Description |
|---|---|---|---|
| **dim_asset_class** | `asset_class_sk` | — | Asset taxonomy (rolling stock, stations, track, signal, power, ferry vessel, road asset). Recursive parent for hierarchy. `maintenance_regime` drives scheduling. |
| **dim_asset** | `asset_sk` (`asset_tag` UK) | Type 2 | TAHE/TfNSW asset. `owning_entity` ∈ {TAHE, TfNSW, RTC, lessee}. Fleet ≈ 10,432 vehicles. |
| **dim_component** | `component_sk` | — | Maintainable sub-assembly (door actuator, wheelset, traction motor). `smart_sensor_flag` = IoT-condition-monitored. |
| **bridge_asset_component** | `bridge_id` | — | Fitted/removed part history between asset and component. |
| **dim_project** | `project_sk` | Type 2 | Capital project portfolio (Sydney Metro West, WSA, Parramatta LRT, Digital Systems, SAT). |
| **bridge_project_asset** | `bridge_id` | — | M:N project↔asset (BUILD/UPGRADE/REPLACE/MAINTAIN). |
| **fact_asset_operation** | `operation_id` | — | **Grain: one operational/health/energy event per asset/component.** SCADA/telematics/IoT input to predictive maintenance. |
| **fact_work_order** | `work_order_id` | — | **Grain: one work order.** Breakdown/planned/condition-based. Correlates condition history → failures. |
| **agg_asset_reliability_daily** | composite | — | Reliability % / fault counts / energy for the maintenance dashboard. |

### Key Business Rules
- **Sydney Trains is the #3–5 electricity user in NSW (~1.3% of state total)** — energy telemetry is a first-class measure (Net Zero electricity target met 2021).
- Predictive maintenance enabler: join `fact_asset_operation` (temperature/vibration/fault severities) against `fact_work_order.failure_mode` to build forecasting models.
- Safety-criticality stored on `dim_component.criticality`; P1/P2/P3 on work orders.

---

## Cross-mart integration (conformed, reused dimensions)

| Conformed Dimension | Model 01 | Model 02 | Model 03 |
|---|---|---|---|
| dim_time | ✅ | ✅ | ✅ |
| dim_mode / dim_operator | ✅ | ✅ | — (operator held on asset) |
| dim_stop_location | ✅ | ✅ | ✅ (asset home/base) |
| dim_service / dim_route | ✅ | ✅ | (route ↔ asset via run) |

This shared conformed core is what qualifies these as a **Gold layer** rather than three isolated marts: one network truth, one customer view, one asset register — delivery of the Data Strategy's "consistent and trusted data" and "great data from assets, people, systems and partners" enablers.