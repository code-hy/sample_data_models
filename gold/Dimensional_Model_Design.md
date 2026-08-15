# Dimensional Model Design

> **Model:** Gold / Medallion layer — Customer Patronage & Journey
> **File:** `gold/01_customer_patronage.sql`
> **Organisation:** Transport for NSW (TfNSW)
> **Method:** Kimball four-step dimensional design process

This document records the design rationale behind the customer patronage
dimensional model. It follows the classic four-step sequence —
**business process → grain → dimensions → facts** — so every object in the
model is traceable back to a real TfNSW operational activity rather than to
guesswork.

---

## Step 1 — Identify the operational activity we are tracking

**The activity is: a passenger paying to travel on the TfNSW public transport
network, and the fare/patronage system recording that journey.**

Concretely, this tracks the **Opal fare-collection and journey-capture process**:
a passenger taps on at their origin stop and taps off at their destination, the
back-office fare engine works out the distance-based tariff, applies peak or
off-peak pricing, and (for registered cards) references their entitlements and
any daily/weekly caps. This is the fundamental "what happened" that nearly every
other TfNSW analytics question (patronage, revenue, crowding, interchange
optimisation, the "single view of customer") ultimately depends on.

The **source event** is a *tap-on / tap-off pair* emitted by the Opal readers and
validated by the Opal fare engine. The **business questions** this model exists to
answer are things like:

- How many trips on route T1 last week, broken out by peak vs off-peak?
- What is the revenue (gross fare) by mode, by card type, by day?
- How do passengers connect between modes within one journey?
- Which stations see the most transfer activity?
- What is the shape of a "typical journey" for a registered customer?

> Note: this is a **transaction fact** design. We also deliver a journey-level
> fact (`fact_journey`) because the same source events roll up naturally, and a
> pre-aggregated mart (`agg_patronage_daily`) for dashboards.

---

## Step 2 — Declare the grain and decide the level of detail

The grain is the single most important decision — everything downstream hangs off
it. We declare **two related grains** because the fares domain genuinely operates
at two levels:

### Primary grain — a closed trip

> **One row in `fact_trip` = one closed trip: a single unit of tap-on → tap-off
> travel by one fare instrument on one service run.**

This is the finest deterministic grain the Opal system supports. It captures the
exact origin/destination pair, the exact time, the mode and the fare for a single
continuous ride. Multiple consecutive same-mode trips are fused by *Trip
Advantage*; tap-on/tap-off events without a valid close produce a *default fare*
row (flagged `default_fare_flag = true`).

### Secondary grain — a completed journey

> **One row in `fact_journey` = one customer journey: a collection of 1..=8 trips
> made within the transfer window (≤ 1 hour after the preceding tap-off; 130 min
> for the Manly ferry).**

TfNSW defines a journey as up to eight trips linked by the transfer rule. We
expose a journey-level fact because customers plan journeys, not trips, and the
data strategy is explicitly pushing towards a customer-centric / MaaS view.

### Level of detail we captured

- **Time:** minute-level tap-on / tap-off timestamps (join to `dim_time`).
- **Place:** station/stop/wharf level origin and destination (join to
  `dim_stop_location`), not just zone.
- **Instrument:** individual card token (hashed) for registered or unregistered
  cards.
- **Price:** exact fare charged, transfer discount, and default-fare flag.
- **Organisation:** operator, mode and service running the trip.

We deliberately capture at the **finest grain the source supports**
(minute × stop × card × run) and let the pre-aggregate mart serve coarse-grained
reporting — so we never lose the ability to drill down to a single tap pair.

---

## Step 3 — Choose the dimensions and list the descriptive details

A **dimension** is the context that answers *who, what, where, when, how*. The
descriptive detail in the table below mirrors the columns in
`01_customer_patronage.sql`.

| Dimension | Key | Descriptive details captured (context around the event) |
|---|---|---|
| **dim_time** | `time_sk` | `calendar_date`, `time_of_day`, `hour_of_day`, `minute_of_day`, `peak_period_flag`, `fare_period` (peak/off-peak/weekday/Sat/Sun per TfNSW rules), `is_weekday`, `is_friday_sat_sun` (off-peak extension since Oct 2023), `calendar_week_start_date`, `calendar_month`, `financial_quarter`, `financial_year`, `iso_week` |
| **dim_mode** | `mode_sk` | `mode_code` (METRO/TRAIN/BUS/FERRY/LRT/COACH/P2P/ROAD/OTHER), `mode_name`, `fare_mode_group` (metro-or-train / bus-or-light-rail / ferry / other), `brand` (Sydney Metro, Sydney Trains, NSW TrainLink…), `active_flag` |
| **dim_operator** | `operator_sk` | `operator_code`, `operator_name`, `owner_category` (state-public / private-contract / SOC), `parent_entity`, `contract_region`, SCD history (`scd_start_date`, `scd_end_date`, `current_flag`) |
| **dim_stop_location** | `location_sk` | `stop_id` (GTFS id), `stop_name`, `stop_type` (train station / metro / bus stop / ferry wharf / light-rail stop / coach), `platform_number`, `latitude`, `longitude`, `zone_id` (Opal zone), `suburb`, `lga_code`, `region`, `accessible_flag`, `bike_parking_flag`, `park_and_ride_flag`, `geom_wkt`, SCD history |
| **dim_service** | `service_sk` | `service_code` (T1, M1, 333, F1…), `service_name`, `mode_fk`, `operator_fk`, `transport_line_flag`, `intercity_flag`, `contract_route_flag`, `effective_start_date`/`effective_end_date`, `current_flag` |
| **dim_customer_party** | `customer_sk` | `customer_key` (opaque/pseudonymised), `first_name`, `last_name`, `date_of_birth`, `gender`, `postcode`, `lga_code`, `email`, `mobile_phone`, `marketing_consent_flag`, `accessibility_need`, SCD history. *(PII — classified RESTRICTED, encrypted at rest.)* |
| **dim_card** | `card_sk` | `card_token` (hashed), `card_type` (Adult / Child-Youth / Senior-Pensioner / Concession / Employee / School / Contactless / Digital Opal / Free travel), `payment_channel`, `load_mechanism`, `auto_top_up_flag`, `auto_top_up_amount` (~$10), `maximum_balance` ($250 adult/senior, $150 other), `issue_date`, `expiry_date` (14-yr), `card_status`, `customer_fk`, SCD history |
| **bridge_card_concession** | `bridge_id` | M:N link between card and concession entitlement: `concession_code` (STUDENT / APPRENTICE / TRAINEE / JOBSEEKER / SENIOR / PENSIONER / DISABILITY / SCHOOL_STUDENT), `entitlement_source`, `verification_status`, `entitlement_start_date`/`end_date`, `verified_date`, `current_flag` |

### Notes on dimension choices

- **`dim_customer_party` and `dim_card` are SCD Type 2** — a customer's
  registration state and a card's entitlement change over time, and we must be
  able to reproduce the state that applied *at the moment of each trip*.
- **Conformed dimensions** (time, mode, operator, stop location) are shared with
  the other gold marts (`02` network performance, `03` asset maintenance) so that
  patronage, on-time performance, and asset facts all speak the same language.
- **`bridge_card_concession`** is a bridge table because a card can hold multiple
  simultaneous concession entitlements that each carry their own verification.

---

## Step 4 — Identify facts and pick the metrics recorded during the event

A **fact** records the measurable outcomes of the event. We capture the metrics
that were genuinely produced during the tap-on → tap-off event by the fare
engine, not invented downstream.

| Fact | Grain | Metrics (measures) recorded during the event | Additivity |
|---|---|---|---|
| **fact_trip** | one closed trip | `distance_km`, `trip_duration_sec`, `fare_amount_aud` (gross, pre-cap), `default_fare_flag`, `peak_period_flag`, `transfer_discount_aud` ($2 adult / $1 other), `trip_advantage_fused_flag`, `trip_sequence_in_journey` | Fare, distance & duration are **fully additive**; boolean flags are semantic qualifiers |
| **fact_journey** | one completed journey (1..=8 trips) | `total_trips`, `modes_used`, `journey_duration_sec`, `total_fare_aud`, `transfer_count`, `interchange_optimality_score` | `total_fare_aud` & `journey_duration_sec` additive; `modes_used`, `transfer_count` are **semi-additive** facts |
| **agg_patronage_daily** | service × origin × destination × date × period | `trip_count`, `passenger_km`, `total_fare_aud` | Pre-aggregated (non-normalised) mart |

### Design rationale for the measures

- **`fare_amount_aud` is the gross tariff before caps** — we keep it raw and let
  downstream reconcile against daily/weekly/Sunday caps and Weekly Travel Rewards,
  so revenue questions remain answerable and auditable.
- **`default_fare_flag`** marks trips where the passenger failed to tap off and
  was charged the default maximum fare — a real operational signal for both
  revenue recovery and customer friction.
- **`transfer_discount_aud`** and **`trip_advantage_fused_flag`** freeze the exact
  fare-engine decisions at the time of the trip, so the model reproduces *why* a
  passenger was charged a given amount.
- Every fact carries **`record_source` and `load_datetime`** so the Gold layer is
  traceable back to Silver/Bronze (lineage), per the TfNSW Data Strategy's
  governance enabler.

---

## Summary — decision trail

| Step | Decision |
|---|---|
| **1. Business process** | Opal fare collection & journey capture in TfNSW public transport |
| **2. Grain** | One closed trip (primary); one completed journey of ≤ 8 trips (secondary) |
| **3. Dimensions** | time, mode, operator, stop location, service, customer party, card (+ concession bridge) — SCD Type 2 where history matters |
| **4. Facts** | fare, distance, duration, transfer discount, default-fare flag (+ journey rollups) |

This traceability — every `dim_*` answering a contextual "who/what/where/when/how"
around a clearly-declared, single row of `fact_trip` — is what makes the model a
Gold-layer dimensional design rather than an arbitrary collection of tables.