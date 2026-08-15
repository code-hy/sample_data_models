# Transport for NSW (TfNSW) — Deep Research & Gold/Medallion Data Models

> Compiled from Transport Data Strategy 2022–2025 (official TfNSW document), transportnsw.info, the TfNSW Open Data Hub, and public records. All measures and entity names reflect TfNSW's real operating domain.

---

## 1. The Organisation

**Transport for NSW (TfNSW)** is the New South Wales Government transport services and roads agency, established 1 November 2011. It is an agency of — but distinct from — the **NSW Department of Transport**, the ultimate parent entity. It reports to the Minister for Transport, Minister for Roads, and Minister for Regional Transport.

> TfNSW is the integrated transport authority with whole-of-state responsibility for planning, building, operating, and regulating public transport, roads, and maritime transport — freight, private and commercial vehicles, active transport and maritime across NSW.

### Ownership / entity structure (Transport Administration Act 1988)

| Entity | Role | Notes |
|---|---|---|
| **Sydney Trains** | Suburban rail operator | Owns/operates Sydney suburban network |
| **NSW Trains (NSW TrainLink)** | Intercity/regional train + coach | Medium/long-distance + regional |
| **Sydney Metro** | Automated rapid transit | Standalone agency since 2018 |
| **Sydney Ferries** | Ferry operator | Fleet + Balmain shipyard owned; operations contracted (Transdev) |
| **State Transit Authority (STA)** | Bus (government-owned bus co.) | Bulk of contracted Greater Sydney buses |
| **NSW Motorways** | Toll roads / motorways | Post 2019 RMS merger |
| **Transport Service of NSW** | Employer of record | Cannot employ directly itself |
| **Residual Transport Corporation (RTC)** | Asset holder (residual) | Post-2020 |
| **Transport Asset Holding Entity (TAHE)** | Asset owner (rail assets) | SOC since 1 Jul 2020, successor to RailCorp |

Private operators run services under contract (e.g. Transdev ferries/light rail, Keolis Downer light rail); TfNSW owns the network, sets routes/timetables, runs the Opal fare system, and contracts operations.

### Key scale facts (from Transport Data Strategy)

- **$161B** asset portfolio; annual multibillion-dollar transport budget; >$106B property, plant & equipment
- **469M+** public transport trips/year; **16M+** journeys/day on Greater Sydney roads; **>500M tonnes** freight/year; **1.25M** weekly bike riders
- **10,432** fleet vehicles; **292** train stations; **27,556** bus stops; **48** ferry wharves; **48** light rail stops; **13** metro stations
- **9,000+** traffic counters; ~700,000 km of state/regional/local roads monitored
- **750+ million** customer journeys; **53,000+** open-data users on **200+** datasets
- **~29,000** Transport people employed

### Modes / sub-brands

Sydney Metro · Sydney Trains · NSW TrainLink · Buses (Greater Sydney, Blue Mountains, Central Coast, Wollongong) · Sydney Ferries · Sydney Light Rail · Newcastle Transport · Point-to-point (taxi & vehicle hire, regulated by Point to Point Transport Commissioner).

---

## 2. Business Processes (mapped to data domains)

TfNSW's core operating processes, grouped by the domains that the medallion layer must serve:

### 2.1 Customer & Demand ("Voice of Customer" / single-view-of-customer)
- **Fare collection & ticketing** — Opal smartcard, contactless debit/credit, Opal Travel app, OpalPay; cap/top-up/entitlement management.
- **Journey / patronage capture** — tap-on/tap-off events → trips → journeys (max 8 trips/journey); transfer discounts; trip advantage.
- **Customer identity & accounts** — registered Opal cards, concession entitlements (student/senior/pensioner/jobseeker), auto top-up, contact details.
- **Feedback & complaints** — voice-of-customer loops, sentiment, submissions.

### 2.2 Network & Service Delivery
- **Timetabling & planning** — GTFS/TransXChange schedules, route/stop/calendar design, trackwork/variations.
- **Service operations & real-time** — fleet positioning, on-time/early/late performance, unscheduled events, disruption management.
- **Interchange & accessibility** — first/last-mile connectivity, accessibility (SAT/Transport Access Program).

### 2.3 Assets & Infrastructure (predictive asset maintenance)
- **Asset register & condition** — TAHE-owned rolling stock, stations, track, signals, ferries, light rail, road assets.
- **Maintenance & works** — planned/condition-based maintenance, work orders, lifecycle, net-zero energy management.

### 2.4 Roads, Freight & Maritime
- **Traffic & network** — traffic volume counts (9,000+ counters), speed zones, congestion.
- **Freight** — strategic freight model, movement of goods.
- **Maritime** — aids to navigation, port security zones, water safety compliance (140+ vessels).

### 2.5 Safety, Regulation & Enforcement
- **Safety analytics** — crash/incident analysis, road safety improvements.
- **Compliance & licensing** — vehicle/driver licence registration, road rules, point-to-point transport regulation.
- **Security & emergency** — crisis/emergency management, security incidents.

### 2.6 Finance, Investment & Governance
- **Investment prioritisation** — capital project portfolio (Sydney Metro West/Western Sydney Airport, Parramatta LRT, etc.).
- **Financial, people, procurement** — standard enterprise functions.

---

## 3. Medallion (Bronze/Silver/Gold) Mapping for the Gold Layer

The Transport Data Strategy's six **data enablers** are: (1) consistent trusted data & insights, (2) proactive analytics & AI/modelling, (3) skilled connected workforce & data culture, (4) foundational data governance/management/ethics, (5) right platforms to store/connect/manage data, (6) great data from assets/people/systems/partners. The Gold layer is where these enablers converge into **conformed, business-ready, governed** models.

| Medallion layer | Purpose | Example TfNSW content |
|---|---|---|
| **Bronze** (landing) | Raw, as-received, immutable copies | Opal tap events, GTFS feed dumps, SCADA sensor output, crash files |
| **Silver** (conformed/cleaned) | Standardised, deduplicated, integrated, entity-resolved | Standardised trips, resolved geographic & time dimensions, entity-relationship backbone |
| **Gold** (curated marts) | Business-facing, denormalised, conformed, ready for reporting/AI | **Dimensions + Facts** for patronage, service performance, asset health, finance, customer |

**Gold layer design goals for TfNSW:**
- **Conformed dimensions** shared across marts (Location: 292 stations/27k stops/48 wharves; Time; Mode; Service; Asset; Customer; Operator).
- **Grain explicitly declared per fact.**
- **SCD Type 2** on dimension history (e.g. concession entitlements, station ownership, fleet assignment).
- **Consistent data classification & privacy** (customer personal data, geospatial, safety-critical) — per the Strategy's Safe/Ethical principles.
- Modeled to directly power the Strategy's analytics pillars: predictive maintenance, real-time personalised insights, on-time performance, digital twin, and MaaS single-view-of-customer.

---

## 4. Entities & Relationships (summary — the backbone)

**Conformed dimensions (Gold-level reference):**
`dim_time`, `dim_mode`, `dim_operator`, `dim_service` (train line/bus route), `dim_stop_location` (station/wharf/stop), `dim_asset` (rolling stock/vehicle), `dim_customer_party`, `dim_card_entitlement`, `dim_concession`, `dim_contract`, `dim_project`.

**Core facts (Gold-level):**
- `fact_trip` (tap-on→tap-off journey leg) — grain = one tap-pair/trip
- `fact_journey` (aggregate of up to 8 trips) — grain = one customer journey
- `fact_service_run` (OTP) — grain = one scheduled run of a service on a day
- `fact_stop_dwell` — grain = one stop visit
- `fact_traffic_volume` — grain = one counter × interval
- `fact_asset_operation` / `fact_work_order` — grain = one asset event / work order

**Relationships** (Cardinality):
- `dim_operator` 1—M `dim_service` (an operator runs many services; one service belongs to one operator)
- `dim_service` 1—M `fact_service_run`; `fact_service_run` 1—M `fact_stop_dwell`
- `dim_service` M—M `dim_stop_location` (resolved via `fact_stop_dwell` / a `bridge_route_stop`)
- `dim_stop_location` M—M `dim_asset`? No — assets and locations are distinct: a `dim_asset` (train) is assigned to `dim_service` runs over time (SCD).
- `dim_customer_party` 1—M `dim_card` 1—M `fact_trip`; `dim_card` M—M `dim_concession` via bridge (eligibility)
- `dim_project` M—M `dim_asset` via `fact_project_asset` (projects build/maintain assets)

Now see the three sample Gold-layouts:
- **`01_customer_patronage.sql`** — customer-centric patronage fact (single view of customer / voice of customer).
- **`02_network_service_performance.sql`** — GTFS-inspired network + on-time performance.
- **`03_asset_maintenance.sql`** — asset register + predictive maintenance work orders (TAHE/asset enabler).

Each ships with a Mermaid ERD (`*_erd.mmd`) and a `data_dictionary.md`.

---

*Sources: © State of NSW (Transport for NSW) 2022, Transport Data Strategy 2022–2025 (CC BY 4.0); transportnsw.info; TfNSW Open Data Hub; Wikipedia public records as of session date.*