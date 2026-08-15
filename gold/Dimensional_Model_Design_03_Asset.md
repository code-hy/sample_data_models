# Dimensional Model Design — Asset Register & Predictive Maintenance

> **Model:** Gold / Medallion layer — Asset Register & Predictive Maintenance
> **File:** `gold/03_asset_maintenance.sql`
> **Organisation:** Transport for NSW (TfNSW)
> **Method:** Kimball four-step design process, applied to a 3NF corporate backbone + analytical asset facts

This companion write-up documents the third Gold model. It applies the same
four-step discipline — **business process → grain → dimensions → facts** — but
with an important nuance: because asset management lives and dies on **referential
integrity and a durable asset hierarchy**, the *reference* side of this model is
deliberately **corporate-3NF-normalised** (`dim_asset_class`, `dim_asset`,
`dim_component` with bridge tables), while the *measurement* side uses registered
`fact_asset_operation` and `fact_work_order`. The four steps still hold — they
tell us *what* to model; the 3NF-vs-star choice tells us *how*.

---

## Step 1 — Identify the operational activity we are tracking

**The activity is: TfNSW/TAHE owning, operating, monitoring and maintaining the
physical assets that deliver transport, and using that record to predict when
maintenance is needed.**

Three coupled operational processes feed this model:

1. **Asset ownership & register** — the Transport Asset Holding Entity (TAHE)
   owns rail assets; TfNSW owns fleet vehicles (~10,432) and other assets. Each
   asset has a type, a manufacturer, an owner, an in-service date, and a status
   (in service / maintenance / stored / defect / sold). Assets decompose into a
   **hierarchy** (asset → assembly → component, e.g. a train → wheelset → bearing).

2. **Condition & operations monitoring** — assets continuously produce telemetry:
   energy consumption, distance/hours used, speed, temperature, vibration, and
   fault flags (SCADA, telematics, AVL, IoT sensors). Sydney Trains is among the
   top-5 electricity users in NSW (~1.3% of state total), so energy is a
   first-class measure.

3. **Maintenance planning & execution** — work orders (breakdown, planned,
   condition-based, inspection, modification) are raised against assets and
   components, scheduled, completed, costed, and recorded with failure modes.

The **source events** are (a) each *operational/health reading* from an asset and
(b) each *work order* lifecycle event. The **business questions**:

- Which asset classes fail most often, and after how much usage/km?
- When should the next preventive maintenance happen, given condition trends?
- What is the total cost (labour + material), downtime, and failure-mode mix?
- How much energy does rail traction consume, and is it trending toward net-zero?

The data strategy explicitly calls this the **"predictive asset maintenance"** and
**Net Zero energy** analytics pillar.

---

## Step 2 — Declare the grain and decide the level of detail

Asset data has **two very different grains** because a *reading* and a *work
order* record fundamentally different things.

### Primary grain — one operational/health event

> **One row in `fact_asset_operation` = one operational/health/energy event for
> one asset (optionally a specific component)** — e.g. an hourly energy meter
> read, a run segment, a single condition sample, or a raised fault flag.

This is a **high-volume, event-per-row** grain. It is the raw condition history
that predictive models consume, so it intentionally keeps every sensor sample.

### Secondary grain — one work order

> **One row in `fact_work_order` = one work order (maintenance / defect /
> inspection) raised against an asset or component.**

This is a **lower-volume, transaction-per-work-order** grain. It is the outcome
side: what maintenance happened, at what cost and downtime, and what failed.

### Level of detail we captured

- **Asset:** exact asset (`asset_sk`), and where relevant the failing component
  (`component_fk`) — because predictive maintenance operates at the component
  level (e.g. a door actuator, not the whole train).
- **Time:** event/work-order datetimes (join to `dim_time`).
- **Lo cation:** where the asset was, or the depot/maintenance facility
  (`operation_location_fk`, `location_fk`).
- **Source:** which system produced the reading (`record_source` = SCADA /
  telematics / AVL / energy meter / IoT sensor).

We keep **every sensor sample** (`fact_asset_operation`) so models can forecast,
and **one row per work order** (`fact_work_order`) so cost/downtime/failure
analytics snap to real maintenance events.

---

## Step 3 — Choose the dimensions and list the descriptive details

Because this is a 3NF-style backbone, the "dimensions" are the normalised master
data that describe the asset and its context. The detail below mirrors the columns
in `03_asset_maintenance.sql`.

| Dimension | Key | Descriptive details captured (context around the event) |
|---|---|---|
| **dim_asset_class** | `asset_class_sk` | `asset_class_code` (ROLLING_STOCK / STATION / TRACK / SIGNAL / POWER_SUPPLY / FERRY_VESSEL / ROAD_ASSET / INTERCHANGE / LIGHT_RAIL), `asset_class_name`, `parent_class_fk` (recursive hierarchy), `maintenance_regime` (TIME_BASED / CONDITION_BASED / RUNNING_KM / PREDICTIVE), `replacement_cost_aud` |
| **dim_asset** | `asset_sk` | `asset_tag` (TAHE/fleet id), `asset_class_fk`, `asset_name`, `serial_number`, `manufacturer` (hitachi, Powin, Cubic…), `manufacture_date`, `in_service_date`, `current_operator_fk`, `owning_entity` (TAHE / TfNSW / RTC / private lessee), `location_fk` (depot/base/home station), `asset_status` (IN_SERVICE / MAINTENANCE / STORED / DEFECT / SOLD), SCD history |
| **dim_component** | `component_sk` | `component_code`, `component_name` (traction motor, wheelset, door actuator, HVAC), `asset_class_fk`, `criticality` (CRITICAL / HIGH / MEDIUM / LOW — safety), `mean_time_to_fail_hr` (MTTF benchmark), `smart_sensor_flag` (IoT condition-monitored) |
| **dim_time** *(conformed)* | `time_sk` | shared time hierarchy from the patronage model |
| **bridge_asset_component** | `bridge_id` | M:N asset ↔ component with **fitment history**: `fitted_date`, `removed_date`, `current_flag`, `accumulated_usage_km` |
| **dim_project** | `project_sk` | Capital project that built/upgraded the asset: `project_code`, `project_name`, `project_type` (RAPID_TRANSIT / LIGHT_RAIL / ROADS / ROLLING_STOCK / DIGITAL_SYSTEMS / ACCESSIBILITY), `program`, `status` (PLANNED / UNDERWAY / COMPLETE / CANCELLED), `expected_completion`, SCD history |
| **bridge_project_asset** | `bridge_id` | M:N project ↔ asset with `works_type` (BUILD / UPGRADE / REPLACE / MAINTAIN) |

### Notes on dimension choices

- **`dim_asset_class` is recursive** — a station *contains* signals and power;
  an asset class can itself be a child of another class. This hierarchy drives
  rollups and regime inheritance.
- **`dim_asset` is SCD Type 2** — an asset's operator, owner and status change
  over time (a train moves between operators; ownership passes from RailCorp →
  TAHE). Putting one row per change lets us reproduce *who owned/operated which
  asset when*.
- **`bridge_asset_component.accumulated_usage_km`** is fitment-specific — the
  same component model fitted to a new train starts its usage clock at zero.
- **`dim_component.mean_time_to_fail_hr` and `criticality`** are the benchmarks
  predictive models forecast against.
- **`dim_time` and `dim_stop_location`-style place data are conformed** across the
  three marts, keeping the Gold layer one coherent system of record.

---

## Step 4 — Identify facts and pick the metrics recorded during the event

A **fact** records the measurable outcome. Here the measurements are condition /
energy readings and maintenance outcomes.

| Fact | Grain | Metrics (measures) recorded during the event | Additivity |
|---|---|---|---|
| **fact_asset_operation** | one operational/health/energy event per asset/component | `energy_kwh`, `usage_km`, `usage_hours`, `speed_kmh`, `temperature_c`, `vibration_ms2`, `fault_code`, `severity` (INFO / WARNING / CRITICAL) | **Fully additive**: `energy_kwh`, `usage_km`, `usage_hours`. **Semi-additive**: `temperature_c`, `vibration_ms2`, `speed_kmh` (instantaneous samples, averages not sums); `severity` is a categorical qualifier |
| **fact_work_order** | one work order per asset/component | `labour_hours`, `material_cost_aud`, `total_cost_aud`, `asset_downtime_hours`, `km_at_work_order`, `inspection_finding`, `failure_mode` (door actuator failure, wheel flange wear…) | **Fully additive**: `labour_hours`, `material_cost_aud`, `total_cost_aud`, `asset_downtime_hours`. **Semi-additive**: `wo_status`, `priority`, `failure_mode` are categorical |
| **agg_asset_reliability_daily** | asset class × component × date | `total_operations`, `fault_count`, `critical_fault_count`, `total_energy_kwh`, `reliability_percent` | Pre-aggregated mart (non-normalised) |

### Design rationale for the measures

- **`fact_asset_operation` keeps each sensor/telemetry sample** so failure
  *precursors* (rising temperature, rising vibration, energy anomalies) can be
  correlated with later `fact_work_order.failure_mode` — this is the literal
  **predictive-maintenance pipeline** the Data Strategy asks for.
- **`energy_kwh` is a first-class measure** because rail traction dominates TfNSW
  electricity use (~1.3% of NSW); tracking it per asset/component supports the
  **Net-Zero-by-2025 (electricity, achieved 2021) and 10%-reduction** targets.
- **`fact_work_order.total_cost_aud` = labour + material** is kept as both parts
  and the sum so cost breakdowns disaggregate; `asset_downtime_hours` quantifies
  the availability impact.
- **`severity` on operations and `priority` (P1/P2/P3) on work orders** reflect
  the safety-first ordering TfNSW applies to asset risk.
- Audit columns **`record_source` + `load_datetime`** trace every reading and work
  order back to the producing system (SCADA / telematics / AVL / CMMS).

---

## Summary — decision trail

| Step | Decision |
|---|---|
| **1. Business process** | Asset ownership, condition/energy monitoring, and maintenance execution (predictive-maintenance + net-zero analytics) |
| **2. Grain** | One operational/health event per asset/component (primary); one work order per asset/component (secondary) |
| **3. Dimensions** | asset class, asset, component (# 3NF backbone + bridges) + conformed time; project for capital-ties |
| **4. Facts** | energy, usage, temperature/vibration/severity, fault; work-order cost, downtime, failure mode, KM-at-point; (+ asset-reliability aggregate mart) |

The model balances the two Gold-layer obligations: the normalised reference side
guarantees the asset hierarchy and referential integrity asset-finance and
engineering demand, while the registered fact side feeds the analytics and AI
(e.g. predictive-MTTF, energy forecasting) that the Operational process in Step 1
was set up to enable.