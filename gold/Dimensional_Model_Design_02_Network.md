# Dimensional Model Design — Network & Service Performance

> **Model:** Gold / Medallion layer — Network & Service Performance
> **File:** `gold/02_network_service_performance.sql`
> **Organisation:** Transport for NSW (TfNSW)
> **Method:** Kimball four-step dimensional design process

This companion to `Dimensional_Model_Design.md` documents the design of the
**network and on-time performance** gold model. It follows the same four steps —
**business process → grain → dimensions → facts** — and reuses the conformed
dimensions shared with the patronage model (`dim_time`, `dim_mode`,
`dim_operator`, `dim_stop_location`) so both marts speak one data language.

---

## Step 1 — Identify the operational activity we are tracking

**The activity is: TfNSW planning and delivering scheduled public transport
services, and measuring whether each service actually ran on time.**

Two closely coupled operational processes feed this model:

1. **Timetabling & planning** — TfNSW designs routes and timetables, assigns an
   operator and mode to each route, and decides which days a given service
   pattern operates (including exceptions: public holidays, trackwork
   substitutions, special events). This is the *planned* side of the world, and
   it is captured in public feeds TfNSW publishes as **GTFS** and **TransXChange**.

2. **Service operations & real-time** — vehicles actually run those services,
   arrive at and depart from stops, and occasionally run early, run late, get
   short-turned, or get cancelled. This is the *actual* side, captured by
   operations centres, AVL / real-time feeds and the author's OTP (On-Time
   Performance) measurement.

The **source event** here is the pairing of a *scheduled run* with its *actual
run/stop outcomes*. The **business questions** this model answers:

- What is the on-time performance (OTP %) of route T1 by day, by peak/off-peak?
- Which routes are chronically late, and by how many minutes on average?
- Where do dwell times (time a vehicle spends at a stop) hurt the timetable?
- How many services were cancelled or short-turned, and where?
- Which scheduled day patterns (weekdays vs Sat/Sun vs school holidays) differ?

The design is a **transaction/detail fact schema** (each scheduled run and each
stop visit is its own row) plus a pre-aggregated OTP dashboard mart.

---

## Step 2 — Declare the grain and decide the level of detail

Network performance genuinely has **two nested grains**, one per fact table.

### Primary grain — one service run

> **One row in `fact_service_run` = one scheduled run of a trip pattern on one
> calendar day** (e.g. the 08:12 T1 to Gosford on Monday 3 March).

This is the finest deterministic unit of service delivery: a single vehicle doing
a single trip down a line/route on a single day. It carries the *scheduled vs
actual* truth for the whole run, and OTP is declared at this level (a run is "on
time" within a tolerance window, measured at timing points).

### Secondary grain — one stop visit

> **One row in `fact_stop_dwell` = one planned/actual stop visit for one run.**

Because a run *is* a sequence of stop visits, we capture each stop visit
individually. `fact_stop_dwell` is a **child table** of `fact_service_run` (it
has the `service_run_fk`). This lets us analyse dwell times, interchanges, and
crowding at the station level, and it sums back up to the run grain cleanly.

### Level of detail we captured

- **Time:** scheduled and actual arrival/departure timestamps (join to `dim_time`).
- **Place:** station/stop level (join to `dim_stop_location`).
- **Organisation:** route, trip pattern and operator running the service.
- **Calender:** which `service_id` calendar pattern applied, including trackwork /
  exception overrides (`dim_calendar_service`).
- **Vehicle:** the assigned rolling stock / bus (`vehicle_asset_fk`, nullable for
  dynamically allocated buses).

We capture the **finest grain the network feeds support** (run × stop × day) and
let the OTP aggregate mart serve coarse reporting, preserving drill-down to a
single stop visit.

---

## Step 3 — Choose the dimensions and list the descriptive details

A **dimension** answers *who, what, where, when, how* around the event. The detail
below mirrors the columns in `02_network_service_performance.sql`.

| Dimension | Key | Descriptive details captured (context around the event) |
|---|---|---|
| **dim_route** | `route_sk` | `route_id` (GTFS), `agency_id`, `route_short_name` (T1, 333, F1), `route_long_name` (e.g. "North Shore & Western Line"), `route_type` (GTFS: train/metro/bus/ferry/tram/coach), `mode_fk`, `operator_fk`, `start_location_sk`/`end_location_sk` (corridor terminals), `color`, `route_length_km`, SCD history |
| **dim_trip_pattern** | `trip_pattern_sk` | `trip_id` (GTFS), `shape_id` (geometry), `headsign`, `direction_id` (0 outbound / 1 inbound), `wheelchair_accessible`, `bikes_allowed`, `service_id` (calendar pattern), `typical_weekday_flag`/`typical_saturday_flag`/`typical_sunday_flag` |
| **dim_calendar_service** | `calendar_sk` | `service_id`, `service_date`, `operating_flag` (scheduled to run this day), `exception_type` (NONE / PUBLIC_HOLIDAY / TRACKWORK / DISRUPTION / ADDED_SERVICE), `substitution_service_fk` (trackwork replacement), `source` (GTFS calendar vs calendar_dates) |
| **dim_mode** *(conformed)* | `mode_sk` | `mode_code`, `mode_name`, `fare_mode_group`, `brand`, `active_flag` |
| **dim_operator** *(conformed)* | `operator_sk` | `operator_code`, `operator_name`, `owner_category`, `parent_entity`, `contract_region`, SCD history |
| **dim_stop_location** *(conformed)* | `location_sk` | `stop_id`, `stop_name`, `stop_type`, `platform_number`, `latitude`, `longitude`, `zone_id`, `suburb`, `lga_code`, `region`, `accessible_flag`, `bike_parking_flag`, `park_and_ride_flag`, `geom_wkt`, SCD history |
| **bridge_route_stop** | `bridge_id` | M:N route ↔ stop, ordering the calls: `stop_sequence` (GTFS 0-based), `distance_from_start` (km), `is_timing_point_flag` (**where OTP is actually measured**) |

### Notes on dimension choices

- **`dim_route`, `dim_trip_pattern`, and `dim_calendar_service` are the GTFS
  reference backbone** — a curated, time-variant projection of the public GTFS /
  TransXChange feeds. This single network truth is shared so patronage, OTP and
  accessibility marts never drift apart.
- **`bridge_route_stop. is_timing_point_flag`** matters operationally: OTP is
  only measured at designated timing points, so this flag marks exactly where
  `on_time_flag` should be evaluated.
- **`dim_route` and `dim_calendar_service` hold SCD history / exception data** so
  we can reproduce the timetable *as it stood* on any historical day.
- Root cause of re-use: **`dim_mode`, `dim_operator`, `dim_stop_location` are
  conformed** with `01_customer_patronage.sql`, and `dim_stop_location` /
  `dim_time` are shared again with `03_asset_maintenance.sql`.

---

## Step 4 — Identify facts and pick the metrics recorded during the event

A **fact** records the measurable outcome of delivery. We capture the metrics the
operations systems actually produce for each run and each stop visit.

| Fact | Grain | Metrics (measures) recorded during the event | Additivity |
|---|---|---|---|
| **fact_service_run** | one scheduled run on a day | `on_time_flag`, `early_minutes`, `late_minutes`, `cancelled_flag`, `short_turn_flag`, `wait_time_avg_sec` (average excess wait for NUW headways on metro/bus), `dwell_total_sec`, `run_distance_km` | **Semi-additive**: `late_minutes`, `wait_time_avg_sec`, `dwell_total_sec`, `run_distance_km` additive; `on_time_flag` & cancelled/short-turn flags are ratios. `record_source` for lineage |
| **fact_stop_dwell** | one stop visit for one run | `dwell_time_sec` (actual_departure − actual_arrival), `departure_delay_sec` (actual − scheduled), `alighting_count`, `boarding_count`, `load_from_previous` (estimated load on arrival → crowding), `is_timing_point` | `dwell_time_sec` & counts **fully additive**; `departure_delay_sec` & flag semi-additive |
| **agg_otp_daily** | route × date × period | `scheduled_run_count`, `actual_run_count`, `on_time_run_count`, `on_time_percent`, `avg_late_minutes`, `cancelled_run_count`, `system_avg_on_time_percent` | Pre-aggregated mart |

### Design rationale for the measures

- **`fact_service_run` is where OTP is declared** — `on_time_flag` + `early`/
  `late_minutes` freeze the exact tolerance decision made for each run, on the
  exact day and route, so reliability % is auditable and reproducible.
- **`late_minutes` kept separately (not folded into a boolean)** lets us measure
  not just *whether* a service was late but *how late*, which drives mean-late
  and recovery analytics.
- **`fact_stop_dwell.boarding_count / alighting_count / load_from_previous`**
  underpin crowding and interchange optimisation — the Data Strategy's explicit
  "optimise interchange / precinct movement" priority.
- **`wait_time_avg_sec`** captures headway-based excess wait for high-frequency
  metro/bus lines where a fixed "late by N minutes" framing is less meaningful.
- Both facts carry **`record_source`** (GTFS, AVL/real-time, TransXChange) and
  **`load_datetime`** so schedule-truth and actuals are lineage-traceable.

---

## Summary — decision trail

| Step | Decision |
|---|---|
| **1. Business process** | Timetabling & planning + service operations / real-time (OTP) delivery of TfNSW services |
| **2. Grain** | One scheduled run per day (primary); one stop visit per run (secondary, child of run) |
| **3. Dimensions** | route, trip pattern, calendar service (GTFS backbone) + conformed mode, operator, stop location; bridge_route_stop for ordered calls |
| **4. Facts** | OTP flags & minutes, dwell time, delay, boardings/alightings/load, cancellations, distance (+ OTP % aggregate mart) |

Traceability holds here too: every `dim_*` supplies the "who/what/where/when/how"
context around one clearly-declared row of `fact_service_run`, and that fact is a
direct measure of the service-delivery activity captured in Step 1.