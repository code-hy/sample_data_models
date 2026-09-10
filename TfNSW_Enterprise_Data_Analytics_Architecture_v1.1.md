# Transport for NSW

## Enterprise Data Analytics Architecture

**Research-based architecture case study | APEX Bank-style structure**

**Version 1.1 | 9 September 2026**

**Proposed reference architecture — not an official TfNSW internal architecture**

*Changes in v1.1: full Semantic / Metrics layer implementation added (§18 rewritten, ADR-010, Appendix A — dbt Semantic Layer definitions for Service Performance), AI/RAG section updated to consume the metrics API, portfolio build and interview pack updated accordingly.*

* * *

## 1. Document Control

| Item | Value |
| --- | --- |
| Organisation | Transport for NSW (TfNSW) |
| Document | Enterprise Data Analytics Architecture |
| Version | 1.1 |
| Purpose | A practical enterprise analytics architecture case study based on publicly available TfNSW information and datasets. |
| Audience | Data Analytics Architects, Data Architects, Solution Designers, Data Modellers, Data Engineers, BI/Analytics, Governance and AI teams |
| Status | Proposed reference architecture / portfolio case study |
| Limitation | Internal TfNSW systems, contracts, security controls and unpublished architecture are not assumed. |
| v1.1 additions | Semantic layer implementation strategy (§18), dbt Semantic Layer artifact (Appendix A), ADR-010, AI metrics API consumption (§21), updated portfolio build (§33) and interview pack (§31). |

* * *

## 2. Executive Summary

TfNSW is a strong enterprise Data Analytics Architecture case because transport analytics spans public transport, roads, freight, safety, infrastructure, customers, operators, geography and real-time operational information. Its published Transport Data Strategy identifies priorities including personalised end-to-end journeys, resilient networks, predictive asset maintenance, efficient movement of goods, investment prioritisation, real-time information and proactive analytics, AI and modelling.

The target architecture combines governed lakehouse storage, domain data products, event/streaming ingestion, historised integration, dimensional analytical models, geospatial capability, a **headless semantic/metrics layer with a governed API for both BI and AI**, BI, advanced analytics and governed AI/RAG.

The key architecture principle is that Medallion, Data Vault, dimensional modelling, data products and semantic models are complementary patterns serving different purposes.

A second principle added in v1.1: **metric definitions are certified once, engine-neutrally, and projected to whatever platform is chosen.** The semantic layer is the control point that prevents KPI fragmentation across dashboards — and the runtime context engine that governs AI (§18, ADR-010).

* * *

## 3. Business & Data Context

Transport analytics differs from a typical enterprise warehouse because time, location and network topology are fundamental analytical dimensions. The architecture must reconcile planned versus actual service, rapidly changing network conditions, spatial relationships, multiple operators and varying data quality.

| Domain | Typical analytics questions |
| --- | --- |
| Public transport | How many people travel, where, when and by mode? |
| Rail / Metro | Are services punctual and where do delays occur? |
| Bus / Ferry / Light Rail | Which routes are under/over capacity and how reliable are they? |
| Journey | How reliable are end-to-end journeys and interchanges? |
| Roads | Where are traffic volumes, speeds and congestion changing? |
| Safety | Where and under what conditions are crashes occurring? |
| Assets | Which infrastructure requires preventative/predictive maintenance? |
| Freight | Where are freight flows and bottlenecks increasing? |
| Investment | Which projects provide the greatest transport outcomes? |
| Sustainability | How can transport efficiency and environmental outcomes be measured? |

* * *

## 4. Strategic Architecture Drivers

| Driver | Architecture implication |
| --- | --- |
| Personalised end-to-end journeys | Integrate schedules, actual service, journey legs, locations and disruption context. |
| Resilient networks | Combine incidents, assets, service state, weather and network topology. |
| Predictive asset maintenance | Historise asset condition, maintenance, failures and utilisation. |
| Efficient freight | Integrate freight flows, corridors, network performance and forecasts. |
| Investment prioritisation | Create consistent measures for demand, safety, reliability, cost and benefits. |
| Real-time information | Support event ingestion and low-latency analytical serving. |
| Trusted analytics | Certified metrics, quality, metadata and lineage. |
| AI / modelling | Governed ML and RAG over approved data, **certified metrics and documents.** |
| Open data / partnerships | Publish documented, versioned, privacy-safe external data products. |

* * *

## 5. Current-State Reference Hypothesis

This section is an architecture hypothesis rather than a claim about TfNSW's unpublished internal platform.

```
PUBLIC / PARTNER SOURCES
 GTFS | GTFS-R | Opal | Roads | Crash | Freight | Geo | Weather | Operators
          |                |             |             |
          +----------------+-------------+-------------+
                           |
                  APIs / files / events
                           |
                    DOMAIN SYSTEMS
                           |
                Multiple analytical stores
                           |
                    Reports / BI / extracts

```

Likely enterprise challenges:

- Different identifiers and grains
- Different refresh rates
- Scheduled vs actual time
- Network topology and geospatial joins
- Source quality / missing sensors
- **Cross-domain KPI inconsistency — every dashboard defines "on-time" differently**
- Privacy and movement-pattern risk

* * *

## 6. Public Data Landscape

| Source / dataset | Nature | Analytics use |
| --- | --- | --- |
| GTFS | Static schedules, stops, routes, trips and shapes | Planned network/service |
| GTFS-Realtime Vehicle Positions | Current vehicle locations | Operations and journey analytics |
| GTFS-Realtime Trip Updates | Dynamic stop/service updates | Delay and reliability |
| GTFS-Realtime Alerts | Service/stop alerts | Disruption analytics |
| Trip Planner APIs | Journey/service information | Journey analytics |
| Opal / travel activity | Patronage and utilisation | Demand and planning |
| Road traffic counts | Hourly/yearly traffic volumes | Demand and network planning |
| Historical traffic / incidents | Road performance context | Congestion analytics |
| NSW Crash Data | Crash, location, vehicles, people and environment | Safety analytics |
| Transport routes | Route/service/operator reference | Conformed master data |
| Facilities / locations | Stops, stations, wharves, interchanges | Spatial reference |
| Freight data | Freight statistics and forecasts | Freight planning |
| Cycleways / active transport | Spatial network | Active transport planning |
| EV charging locations | Spatial infrastructure | EV accessibility |
| Maritime data | Waterway/infrastructure information | Maritime analytics |

* * *

## 7. Target Enterprise Data Analytics Architecture

```
                         TRANSPORT OUTCOMES
                               |
      +------------------------+-------------------------+
      |             |          |            |             |
   Journey       Network     Safety      Economic      Community
  experience    resilience    / risk      activity      / places
      |             |          |            |             |
      +------------------------+-------------------------+
                               |
                       SEMANTIC / METRICS  (headless, governed API)
       Reliability | Patronage | Congestion | Safety | Assets
       Journey | Accessibility | Freight | Investment | Service
                               |
                    DOMAIN DATA PRODUCTS
 Journey | Service | Network | Customer | Asset | Incident
 Road | Safety | Freight | Location | Operator | Project
                               |
                         GOLD / ANALYTICS
                               |
              SILVER / INTEGRATED + HISTORY
           Data Vault / canonical integration patterns
                               |
                    BRONZE / PRESERVATION
                               |
       APIs | CDC | Files | Batch | Streaming | Sensors
                               |
              GOVERNANCE / SECURITY / DQ / LINEAGE

```

* * *

## 8. Architecture Layers

| Layer | Responsibility | Examples |
| --- | --- | --- |
| Source | Operational/partner/public information | Ticketing, timetable, road sensors, assets, projects |
| Ingestion | Reliable movement and operational metadata | API, CDC, files, streaming |
| Bronze | Source preservation | Delta/Parquet/object storage |
| Silver | Validation, standardisation, integration, history | Canonical entities, Data Vault-style models |
| Gold | Business-ready analytical products | Facts, dimensions, aggregates, spatial products |
| Semantic | **Certified business meaning, defined once, served to BI *and* AI via API** | Reliability, patronage, congestion, safety (§18, Appendix A) |
| Consumption | BI, ML, APIs, AI | Power BI, notebooks, models, RAG |
| Governance | Ownership, definitions, lineage, quality | Catalogue, glossary, stewardship |
| Security | Access, privacy, audit | RBAC/ABAC, masking, RLS/CLS |
| Operations | Reliability, performance, cost | Monitoring, CI/CD, FinOps |

* * *

## 9. Enterprise Transport Conceptual Data Model

```
CUSTOMER / TRAVELLER
        |
      JOURNEY
   /     |       TRIP    LEG     FARE
  |       |        |
SERVICE  MODE    PAYMENT
  |
ROUTE
  |
STOP / STATION / WHARF
  |
NETWORK SEGMENT
  |
ASSET ---- MAINTENANCE / PROJECT

INCIDENT ---- affects ---- NETWORK SEGMENT
CRASH ------- occurs ----- LOCATION / ROAD SEGMENT
FREIGHT ----- uses ------ ROAD / RAIL / PORT
OPERATOR ---- operates -- SERVICE
ALERT ------- affects --- SERVICE / STOP / NETWORK

```

| Entity | Definition |
| --- | --- |
| Journey | End-to-end customer movement, potentially with multiple legs. |
| Trip | A planned or observed movement of a service at a particular time. |
| Service | Customer-facing or operational transport service. |
| Route | Logical path/grouping of trips. |
| Stop/Station/Wharf | Passenger access location. |
| Network Segment | Reusable spatial segment of road, rail, cycleway or network. |
| Asset | Physical infrastructure/equipment with lifecycle data. |
| Incident | Operational event affecting service or network state. |
| Crash | Road safety event with location and outcome attributes. |
| Operator | Organisation providing or operating transport services. |
| Patronage Event | Travel activity represented at an approved analytical grain. |
| Freight Movement | Movement of goods represented at an agreed analytical grain. |
| Project | Infrastructure/program investment with scope, cost, status and benefits. |
| Location | Conformed spatial reference across domains. |

* * *

## 10. Modelling Architecture

Use modelling patterns according to purpose. Preserve source data in Bronze; use historised integration where traceability and change history matter; publish star schemas for BI; and expose reusable domain products and certified metrics to consumers.

```
BRONZE                     SILVER                         GOLD
Source-aligned      ->     Canonical / History      ->   Dimensional
GTFS                       HUB_ROUTE                     DIM_ROUTE
GTFS-R                     HUB_TRIP                      DIM_SERVICE
Opal                       HUB_STOP + LINKS              FACT_PATRONAGE
Traffic                    HUB_INCIDENT                  FACT_TRAFFIC
Crash                      HUB_ASSET                     FACT_SAFETY
                           SATELLITES / HISTORY

```

### 10.1 Example Service Performance Star Schema

```
DIM_DATE  DIM_TIME  DIM_MODE  DIM_ROUTE  DIM_SERVICE  DIM_OPERATOR
    \        |         |          |          |            /
             FACT_SERVICE_PERFORMANCE
     scheduled | actual | delay | cancelled | capacity

```

Grain must be explicit. A practical grain is one row per service-trip-stop event. Patronage can use a different grain, such as service/date/stop/mode, depending on source detail.

The Service Performance fact is the measurement model for the certified semantic layer in §18 and Appendix A.

* * *

## 11. Time & Event Architecture

Scheduled time, actual event time, service date, publication time, ingestion time, correction time and snapshot time are distinct concepts.

| Time concept | Example |
| --- | --- |
| Service date | Date the trip operates |
| Scheduled event time | Planned arrival |
| Actual event time | Observed arrival |
| Ingestion time | When the platform received the event |
| Publication time | When an API exposed it |
| Correction time | When a source corrected it |
| Snapshot time | Time a network/asset state was observed |
| Effective-from/to | Validity of route/master data |

- Use event-time processing for streaming.
- Use watermarks and replay for late events.
- Allow controlled restatement of historical aggregates.
- Version network/reference data.
- Retain source provenance where auditability is required.

**Semantic layer consequence (v1.1):** `service_date` — not calendar or ingestion date — is the aggregation time dimension for reliability metrics, so a trip running after midnight is attributed to the day it *operates*. Period-over-period metrics use the semantic layer's time spine, making restatement safe.

* * *

## 12. Real-Time / Near-Real-Time Architecture

```
GTFS-R Vehicle Positions --\
GTFS-R Trip Updates -------+--> EVENT INGESTION --> STREAM PROCESSING
GTFS-R Alerts -------------/                         |
Road incidents/sensors ----/                         v
                                                REAL-TIME STATE
                                                      |
                              +-----------------------+------------------+
                              |                       |                  |
                         Ops dashboard          Customer API         Alerts
                              |
                         Historical lakehouse

```

| Use case | Indicative latency | Pattern |
| --- | --- | --- |
| Vehicle position | Seconds/minutes | Streaming |
| Disruption alert | Seconds/minutes | Event-driven |
| Reliability monitoring | Minutes | Streaming + micro-batch |
| Patronage | Daily / selected intraday | Incremental batch |
| Executive reporting | Hourly/daily | Curated batch |
| Demand forecasting | Daily/weekly | Batch ML |
| Asset predictive maintenance | Minutes/hours/daily | Streaming + batch |

* * *

## 13. Open Data & External Data Architecture

```
INTERNAL / AUTHORITATIVE DATA
          |
 Privacy + security + publication review
          |
          v
 APPROVED PUBLIC DATA PRODUCTS
          |
   +------+-------+
   |              |
Open Data Hub   Developer APIs
   |              |
GTFS | Geo | CSV  Journey | Realtime
   |
Researchers / industry / applications

```

- Treat public data products as governed interfaces.
- Apply aggregation, suppression and privacy controls before release.
- Version schemas and documentation.
- Monitor public freshness and quality.
- Do not expose internal analytical tables directly.

* * *

## 14. Privacy & Ethical Analytics

Transport data can reveal movement patterns even when direct identifiers are removed. The architecture therefore treats privacy as a data-product and analytical-design concern, not merely a database security concern.

| Risk | Control |
| --- | --- |
| Travel-pattern reconstruction | Aggregation, suppression and privacy review |
| Location re-identification | Spatial generalisation / minimum cohorts |
| Dataset linkage | Restrict joins and assess quasi-identifiers |
| Operational sensitivity | Restricted access zones |
| Analyst extracts | Controlled workspaces, expiry and monitoring |
| AI leakage | Retrieval-time authorisation and output controls |
| Public release | Formal privacy/publication assessment |

* * *

## 15. Data Governance Operating Model

```
                 EXECUTIVE DATA GOVERNANCE
                           |
                    DATA GOVERNANCE
                           |
       +-------------------+-------------------+
       |                   |                   |
  Domain Owners        Stewards          Architecture
       |                   |                   |
       +-------------------+-------------------+
                           |
                      DATA PRODUCTS
                           |
             Quality | Metadata | Lineage | Access

```

| Role | Accountability |
| --- | --- |
| Enterprise Analytics Architect | End-to-end analytics architecture and standards |
| Domain Data Owner | Business meaning, quality and authorised use |
| Data Steward | Definitions, metadata and quality coordination |
| Network/Asset Owner | Authoritative network/asset information |
| Operator Data Owner | Service/operator data quality |
| Privacy/Security | Privacy, security and threat controls |
| Platform Owner | Availability, scalability, performance and cost |
| Analytics Product Owner | Business outcome and adoption |
| Data Custodian | Operational handling and access implementation |

* * *

## 16. Transport Data Products

| Product | Core content | Consumers |
| --- | --- | --- |
| Network | Routes, stops, stations, segments, facilities | Planning, journey, BI |
| Service | Schedules, trips, operators, actuals | Operations, reliability |
| Journey | Journey/leg/interchange information | Customer, planning |
| Patronage | Travel activity/utilisation | Planning, service design |
| Road Performance | Traffic, speeds, incidents | Road operations/planning |
| Safety | Crash and risk analytics | Safety/planning |
| Asset Health | Condition, maintenance, failure | Asset management |
| Freight | Flows, forecasts, corridors | Freight planning |
| Location | Conformed spatial entities | All domains |
| Project/Investment | Cost, milestones, benefits | Investment planning |
| Environment | Emissions/environment context | Sustainability |

* * *

## 17. Example Data Product Contract — Service Performance

| Element | Specification |
| --- | --- |
| Owner | Public Transport Performance domain |
| Purpose | Trusted punctuality, cancellation and service performance. |
| Grain | One record per service-trip-stop event. |
| Sources | Timetable + GTFS-R + approved operational sources. |
| Freshness | Minutes for operational view; daily reconciliation. |
| Quality | Completeness, validity, duplicates, referential integrity. |
| Business definitions | Delay, cancellation, early/on-time and completion certified by owner. |
| Security | Role-appropriate access. |
| Lineage | Source → transformation → product → metric → report. |
| Change policy | Versioned schema and semantic changes. |

* * *
## 18. Semantic / Metrics Architecture *(rewritten in v1.1)*

The semantic layer prevents different dashboards — and different AI agents — from independently defining transport KPIs. Definitions must be **owned, versioned and certified once**, then served identically to every consumer: Power BI, notebooks, APIs, ML features and the RAG assistant (§21).

### 18.1 Implementation strategy — engine-neutral definitions, platform-native projection

**Decision (ADR-010):** Use **dbt Semantic Layer (MetricFlow) YAML as the certification artefact** — the engine-neutral source of truth for metric definitions — and **project** those definitions onto whichever platform is selected (Power BI semantic models on Fabric, or Unity Catalog metrics/Genie on Databricks). The YAML survives the platform decision in §35; the platform projection is a render target, not a re-definition.

Rationale:

1. **One definition, every consumer.** §8 lists BI *plus* ML, APIs and AI as consumers. A headless metrics layer serves "On-time performance" identically to a dashboard, a notebook, and step 1 of the §21 RAG flow — resolving a metric becomes an API call, not prompt engineering.
2. **Aligns with the medallion/data-product structure.** Metrics sit directly on Gold facts with explicit grain declarations, matching the grain-first principle (§34). Trip-grain KPIs (`service_completion`) are computed with `count_distinct` at trip grain so stop-level rows cannot pollute them.
3. **Vendor escape hatch.** Databricks, Fabric and Azure are implementation options (§35), not claims. Certifying metrics in engine-neutral YAML avoids lock-in; the platform only executes what the YAML certifies.
4. **AI-governance ready.** The governed semantic layer is the runtime context engine that stops agents hallucinating business metrics — the AI assistant never computes a KPI itself, it calls the certified metric and cites its definition.

| If platform is... | Projection target | Trade-off |
| --- | --- | --- |
| **Microsoft Fabric** (probable NSW Gov context) | Power BI semantic models (Direct Lake) + Fabric metrics | Native to BI; weaker headless API for agents |
| **Databricks** | Unity Catalog metrics + Genie/AI-BI dashboards | Best agentic path; ties you to Databricks |
| **Cloud-agnostic OSS** | MetricFlow headless or Cube | Maximum portability; you own serving |

### 18.2 Certified metric catalogue

| Metric | Illustrative definition |
| --- | --- |
| On-time performance | Eligible service-stop events within approved punctuality tolerance. |
| Average delay | Average actual minus scheduled time for eligible events. |
| P90 delay | 90th percentile of actual-minus-scheduled delay (tail latency). |
| Service completion | Completed eligible trips / planned eligible trips. |
| Cancellation rate | Cancelled trips as % of planned trips. |
| Patronage | Approved count/estimate of passenger travel activity. |
| Load factor | Passenger load relative to approved capacity. |
| Journey reliability | Journeys meeting approved reliability criteria. |
| Network travel time | Observed travel time for a defined segment/corridor. |
| Congestion index | Observed travel time vs approved baseline. |
| Crash rate | Crashes/casualties normalised by approved exposure. |
| Asset failure rate | Failures relative to asset population/exposure. |
| Freight throughput | Goods volume through a defined corridor/node/time. |
| Accessibility score | Approved measure of service access and community context. |

### 18.3 Design rules

- **Eligibility and exclusions live in the metric, not in reports.** Tolerances, exclusions (planned works, special events) and quality filters are versioned metric parameters — change certification in one YAML file, every consumer updates.
- **Quality is a first-class dimension.** `data_quality_status` (certified / suspect / imputed / sensor_unavailable) is queryable; certified metrics filter unavailable sensors, but consumers *can* query suspect periods deliberately (§23, ADR-008).
- **Grain discipline.** Event-grain metrics aggregate from `service_event`; trip-grain metrics use `count_distinct trip_id`. A metric declares its grain; never derive trip KPIs from stop-level sums.
- **Time semantics follow §11.** `service_date` is the aggregation dimension; scheduled/actual timestamps remain queryable; period-over-period uses the time spine (restatement-safe).
- **Certification metadata travels with the metric.** Every certified metric carries owner, version and certification date (`meta` block), giving §24 lineage a defined endpoint: source → product → semantic → report.
- **Security underneath, meaning on top.** Row/column security (§25) is enforced by the platform below the semantic layer; the semantic layer applies business meaning over already-authorised data. If Iceberg + catalog-level cross-engine ABAC is later adopted, the same enforcement carries over unchanged.
- **Load factor is a separate semantic model.** It joins patronage (different grain) via conformed `route`/`service`/`stop` entities — never force it into the Service Performance fact.

### 18.4 Reference implementation

The full dbt Semantic Layer definitions for the Service Performance star schema (§10.1) — semantic models, measures and certified metrics — are provided in **Appendix A** and are intended to live in the repo at:

```
models/service_performance/
├── schema.yml                    # dbt model tests (contract enforcement)
├── fct_service_performance.sql   # Gold fact - grain: service-trip-stop event
├── dim_route.sql / dim_operator.sql
└── semantic_models_service_performance.yml   # Appendix A
```

* * *

## 19. BI & Analytics Architecture

```
DATA PRODUCTS -> GOLD -> SEMANTIC MODEL (certified YAML, projected to platform)
                                      |
             +------------------------+-----------------------+
             |                        |                       |
        Executive BI            Operations BI            Planning BI
        (certified KPIs)        (certified KPIs)        (certified KPIs)
                                      |
                               ML features / APIs / AI
```

| Dashboard | Key measures |
| --- | --- |
| Network Executive | Patronage, reliability, service completion, congestion, safety |
| Public Transport Operations | Delays, cancellations, vehicle/service state, incidents |
| Customer Journey | Journey time, interchange, disruption, accessibility |
| Road Network | Traffic, travel time, incidents, congestion |
| Road Safety | Crash frequency/severity and location risk |
| Asset Health | Condition, failure, maintenance backlog, risk |
| Freight | Volume, corridor performance and bottlenecks |
| Investment | Cost, schedule, demand, benefits and risk |

Every dashboard consumes certified metrics from the semantic layer (§18); ad-hoc local measures must reference a certified definition or be routed through certification.

* * *

## 20. Advanced Analytics / ML

| Model | Potential features | Outcome |
| --- | --- | --- |
| Patronage forecast | Historical demand, timetable, calendar, weather/events | Demand by mode/route/time |
| Delay prediction | Historical delays, service, incidents, weather | Delay risk |
| Crowding prediction | Patronage, capacity, timetable, events | Expected load |
| Asset failure risk | Condition, age, maintenance, utilisation | Failure probability |
| Crash risk | Crash history, road features, speed, traffic, environment | Risk score |
| Congestion forecast | Traffic, incidents, historical patterns | Travel-time forecast |
| Freight demand | Historical flows, economic indicators, capacity | Demand/flow forecast |

Feature definitions for ML should reference certified semantic measures where the feature *is* a business concept (e.g. "average delay on this route last 30 days"), keeping training/serving consistency with BI.

* * *

## 21. AI / RAG Architecture

```
USER
 |
AI ASSISTANT
 |-----------------------------|
 v                             v
CERTIFIED METRICS API      RAG SEARCH
 (semantic layer §18)         |
 |                             |
Governed numbers          Policies / reports /
                          project docs
 |                             |
 +-------------+---------------+
               |
        ACCESS CONTROL
               |
              LLM
               |
      Grounded answer + evidence
                  +
   Citation of certified metric definition

```

Example question: **"Why did reliability decline on this corridor last month?"**

1. Resolve reliability to the certified semantic metric via the **metrics API** (`on_time_performance(corridor, period)`) — the agent never computes the KPI itself.
2. Identify corridor, mode, period and eligible services.
3. Calculate variance against the approved baseline **through the same certified metric with period-over-period enabled**.
4. Correlate authorised incidents, alerts and network conditions.
5. Retrieve approved documents when explanatory context is needed.
6. Generate facts first, interpretation second, with evidence **including the metric's certified definition and version**.
7. Apply user permissions to every retrieved source.
8. Log the interaction, metric version and evidence under applicable policy.

Guiding principles:

- Numerical KPIs come from the governed metrics API, not uncontrolled LLM arithmetic.
- **Agents are privileged runtime identities, not users** — dedicated agent identity, scoped permissions and audit trail; do not reuse human service accounts.
- RAG retrieval must enforce source-level and row/attribute-level permissions.
- Treat public/untrusted documents as potential prompt-injection sources.
- Evaluate factuality, retrieval quality, access control and harmful outputs.

* * *

## 22. Geospatial Analytics Architecture

```
POINTS             LINES                 POLYGONS
Stops              Routes                Suburbs
Stations           Road segments         LGAs
Wharves            Rail corridors        Regions
Crashes            Cycleways             Catchments
Assets             Freight corridors     Accessibility areas
        \               |                 /
         \______________|________________/
                        |
                 CONFORMED LOCATION
                        |
                 SPATIAL ANALYTICS

```

- Use stable location IDs plus geometry.
- Version network topology and route geometry.
- Store coordinate reference systems explicitly.
- Support spatial joins and nearest-network analysis.
- Separate physical location from customer-facing identity.
- Validate geometry and unexpected movement.

* * *

## 23. Data Quality Framework

| Dimension | Transport example | Control |
| --- | --- | --- |
| Completeness | Required fields present in every trip | Completeness tests |
| Validity | Time values within expected ranges | Business rules |
| Uniqueness | No duplicate event after deduplication | Event keys |
| Consistency | Trip references valid route/stop/operator | Reference checks |
| Accuracy | Traffic counts within expected source behaviour | Statistical/sensor checks |
| Timeliness | Real-time feed meets freshness target | Freshness monitoring |
| Spatial integrity | Coordinates/geometry valid | Spatial validation |
| Reconciliation | Aggregates reconcile to approved control totals | Control totals |

Road traffic count data illustrates why sensor availability and quality must be explicitly modelled. Consumers should see quality status rather than assuming every observation is equally reliable.

- Attach quality status to datasets/time periods.
- Flag suspect or unavailable sensor periods.
- Mark imputed values explicitly.
- Track quality incidents as metadata.
- Include confidence where material to analytical decisions.

**Semantic layer consequence (v1.1):** quality status is a queryable semantic dimension; certified metrics filter `sensor_unavailable`, and imputed values are visibly marked rather than silently blended into KPIs.

* * *

## 24. Metadata & Lineage

```
Executive KPI: On-time Performance  (semantic metric, version, owner)
        |
Semantic measure (certified YAML - Appendix A)
        |
Service Performance data product (contract §17)
        |
Gold fact_service_performance
        |
Silver integrated/history
        |
GTFS timetable + GTFS-R updates
        |
Public transport source

```

| Metadata | Example |
| --- | --- |
| Business | Definition of on-time performance |
| Technical | Schema, column, API endpoint |
| Operational | Last load, row count, latency |
| Quality | Completeness, sensor availability |
| Lineage | Source → product → semantic → report |
| Security | Classification and permitted roles |
| Spatial | Geometry, CRS, network version |
| AI | Document/index/model version |
| Change | Schema/business-rule version |

* * *

## 25. Security Architecture

| Control | Design |
| --- | --- |
| Identity | Enterprise identity and strong authentication |
| Least privilege | Role/attribute-based data-product access |
| PII protection | Classification, minimisation, masking and controlled joins |
| Operational sensitivity | Separate sensitive operational datasets |
| Row-level security | Regional/organisational restrictions where required |
| Column-level security | Restrict personal/sensitive attributes |
| Encryption | At rest and in transit |
| Network | Private connectivity for sensitive workloads where required |
| Audit | Centralised data/admin access logs |
| Retention | Dataset-specific retention/deletion rules |
| AI | Same authorisation model for retrieval and output, **dedicated agent identity** |

* * *

## 26. Architecture Decision Records

- **ADR-001 — Lakehouse foundation**
  - **Decision:** Use lakehouse/object-storage patterns as the scalable analytical foundation.
  - **Rationale / trade-off:** Supports mixed data, historical scale, BI, ML and AI.
- **ADR-002 — Domain data products**
  - **Decision:** Organise trusted analytics around transport domains.
  - **Rationale / trade-off:** Creates clear ownership and reusable interfaces.
- **ADR-003 — Historised integration**
  - **Decision:** Use Data Vault-style patterns where provenance/history are important.
  - **Rationale / trade-off:** Supports traceability without forcing consumers to query integration models.
- **ADR-004 — Dimensional serving**
  - **Decision:** Use star schemas for BI and common analytical workloads.
  - **Rationale / trade-off:** Optimises usability and performance.
- **ADR-005 — Semantic metrics**
  - **Decision:** Certify enterprise transport measures.
  - **Rationale / trade-off:** Prevents KPI fragmentation.
- **ADR-006 — Event architecture**
  - **Decision:** Use streaming where latency changes an operational/customer decision.
  - **Rationale / trade-off:** Avoids unnecessary complexity/cost.
- **ADR-007 — Spatial first-class**
  - **Decision:** Make locations/network topology conformed enterprise data.
  - **Rationale / trade-off:** Enables cross-domain transport analysis.
- **ADR-008 — Quality-aware analytics**
  - **Decision:** Publish quality/confidence status with data.
  - **Rationale / trade-off:** Prevents false precision.
- **ADR-009 — Governed AI**
  - **Decision:** AI consumes certified metrics and authorised knowledge.
  - **Rationale / trade-off:** Improves trust and reduces uncontrolled exposure.
- **ADR-010 — Semantic layer implementation** *(v1.1)*
  - **Decision:** Use engine-neutral dbt Semantic Layer (MetricFlow) YAML as the certification artefact for all enterprise metrics; project onto the selected platform (Power BI semantic models / Unity Catalog metrics) as a render target, never a re-definition.
  - **Rationale / trade-off:** One certified definition serves BI, ML, APIs and AI; survives the unresolved platform decision (§35); prevents both KPI fragmentation and vendor lock-in. Cost: an additional YAML artefact to govern and a projection step to maintain.

* * *

## 27. Non-Functional Requirements

| NFR | Target |
| --- | --- |
| Availability | Tier services by operational importance with explicit SLOs |
| Freshness | Minutes for selected operational streams; daily for planning |
| Scalability | Handle growing event, spatial and historical volumes |
| Performance | Interactive BI within agreed response targets |
| Security | Least privilege, encryption, audit and privacy controls |
| Resilience | Replayable ingestion, retry, checkpoint and recovery |
| Data quality | Automated validation and visible status |
| Lineage | Critical metrics traceable end-to-end, **including semantic definition version** |
| Maintainability | Version control, CI/CD and automated tests |
| Interoperability | Open formats/APIs for approved external sharing |
| Cost | Workload classification, incremental processing and lifecycle management |
| AI safety | Access control, grounded retrieval, **certified metrics API**, evaluation |

* * *

## 28. Operating Model

| Capability | Operating practice |
| --- | --- |
| Data engineering | Reusable ingestion, CI/CD and automated tests |
| Data modelling | Conceptual/logical/physical standards and grain-first modelling |
| Analytics engineering | Gold transformations and semantic-ready datasets |
| BI | Certified semantic models and report standards |
| Governance | Owners, glossary, stewardship, quality and lineage |
| Platform | Capacity, reliability, performance and cost monitoring |
| Data science | Feature engineering, model evaluation and deployment |
| AI | RAG/model evaluation, safety and access control |
| Incident management | Data incidents classified by business impact |
| Change management | Schema **and semantic-metric** changes versioned and impact assessed |

* * *

## 29. Implementation Roadmap

| Phase | Timing | Deliverables |
| --- | --- | --- |
| 1. Foundation | 0–3 months | Architecture standards, domain catalogue, landing zone, governance |
| 2. Network + service | 3–6 months | GTFS/GTFS-R, routes/stops/operators, service-performance product |
| 3. Patronage + journey | 6–9 months | Travel activity integration, journey analytics, semantic metrics |
| 4. Road + safety | 9–12 months | Traffic, incidents, crash and safety products |
| 5. Assets + projects | 12–15 months | Asset health, maintenance and investment products |
| 6. Advanced analytics | 15–18 months | Demand, reliability, congestion and asset-risk models |
| 7. AI / RAG | 18+ months | Governed analytics assistant and knowledge retrieval |

*v1.1 note:* Phase 3 deliverable "semantic metrics" is now concretely specified: the dbt Semantic Layer YAML (Appendix A pattern) certified by domain owners, with the first platform projection (e.g. Power BI semantic model) built in the same phase.

* * *

## 30. End-to-End Use Case — Why Was the 8:00 AM Service Unreliable?

```
GTFS SCHEDULE ----\
GTFS-R UPDATES -----+--> SERVICE PERFORMANCE PRODUCT
VEHICLE POSITIONS --/             |
INCIDENTS -----------------------+
WEATHER / EVENTS ----------------+
                                  |
                         SEMANTIC METRICS (certified API)
                                  |
                    Reliability / Delay / Cancel
                                  |
                    +-------------+-------------+
                    |                           |
                 POWER BI                     AI
              (projected semantic          (metrics API call,
               model, certified)           cites definition)
                    |                           |
                    +-------------+-------------+
                                  |
                         Governed evidence

```

1. Identify service, route, direction, date and stop/segment.
2. Compare scheduled and actual times.
3. Calculate delay/reliability using certified definitions **via the semantic layer**.
4. Correlate incidents, alerts and network context.
5. Determine whether the issue is isolated or corridor-wide.
6. Retrieve approved operational/project documents if context is needed.
7. Present calculated facts separately from generated interpretation.
8. Retain evidence, **metric version and definition reference**.

* * *

## 31. Data Analytics Architect Interview Pack

| Question | Strong answer |
| --- | --- |
| Why is TfNSW complex? | Multiple modes, operators, spatial networks, real-time events, travel activity, assets, safety, freight and projects. |
| Why not one warehouse? | Use a governed analytical foundation plus domain products and workload-specific serving patterns. |
| GTFS vs GTFS-R? | GTFS is scheduled/static information; GTFS-R provides dynamic vehicle, trip-update and alert information. |
| Why is time important? | Scheduled, actual, service, ingestion and correction timestamps have different meanings. |
| Why Data Vault plus dimensional? | Historised integration supports traceability; dimensional models optimise business consumption. |
| What is a data product? | A governed reusable dataset with owner, grain, schema, SLA, quality, security and lineage. |
| How define on-time? | Agree eligible events, tolerance, exclusions and aggregation with the metric owner, then **certify it once in the semantic layer (Appendix A) so every consumer inherits it**. |
| **Why a headless semantic layer instead of Power BI measures alone?** *(v1.1)* | **BI tools, notebooks, APIs and AI agents all consume one certified definition; the YAML survives platform changes; agents call a metrics API instead of computing KPIs.** |
| **How do you stop an AI agent hallucinating a KPI?** *(v1.1)* | **Agents never compute metrics — they call the certified metrics API and cite the definition and version; the semantic layer is the runtime context engine.** |
| How build Journey 360? | Conform locations/routes/trips/legs, integrate authorised travel activity and protect privacy. |
| How protect travel data? | Minimise identity, aggregate, control linkage and assess re-identification. |
| When use real-time? | When low latency changes a decision, operation or customer experience. |
| How solve poor sensors? | Track availability/quality, flag suspect periods and expose confidence **as a queryable semantic dimension**. |
| Why spatial first-class? | Transport outcomes depend on location and network topology. |
| How solve conflicting KPIs? | Named metric owners, glossary, **certified semantic measures defined once in engine-neutral YAML**, and retirement of duplicates. |
| How should AI explain delays? | Use certified metrics via API, authorised incident/context data and approved documents, separating evidence from inference. |
| How measure architecture success? | Consistency, quality, freshness, lineage, adoption, productivity, reliability and cost. |
| What belongs in Gold? | Curated, stable, business-ready analytical products. |
| What belongs in Bronze? | Source-aligned data retained for controlled reprocessing. |
| How manage route changes? | Effective dating and versioned network/reference data. |
| How handle late events? | Event-time processing, watermarks, replay and controlled restatement. |
| Why is this Analytics Architecture? | It connects acquisition to semantic metrics, BI, ML, AI and business outcomes. |

* * *

## 32. 60-Day Upskilling Plan

| Days | Focus | Exercise |
| --- | --- | --- |
| 1–10 | Transport domain | Learn GTFS/GTFS-R, routes/stops/trips, patronage, roads and safety. |
| 11–20 | Analytics architecture | Redraw the target architecture and explain every trade-off, **including ADR-010**. |
| 21–30 | Data products + modelling | Model Service Performance, Patronage and Road Safety. |
| 31–40 | Lakehouse | Build Bronze/Silver/Gold using public datasets. |
| 41–50 | BI + semantic | **Author the Service Performance semantic layer (Appendix A): entities, measures, certified metrics, quality dimensions; project to a BI semantic model.** |
| 51–55 | Streaming + spatial | Process GTFS-R-style events and spatial network analysis. |
| 56–60 | Architecture leadership | Complete ADRs, NFRs, security, DQ, lineage and present the case. |

* * *

## 33. Recommended Portfolio Build

| Component | Implementation |
| --- | --- |
| Ingestion | Python/API + scheduled jobs for GTFS, GTFS-R and road datasets |
| Storage | Parquet/Delta; Databricks/Fabric if available |
| Bronze | Raw snapshots with ingestion metadata |
| Silver | Canonical route/stop/trip/service + temporal history |
| Gold | Service performance, patronage, traffic and safety facts |
| Spatial | GeoPandas/PostGIS or platform spatial capability |
| Semantic | **dbt Semantic Layer (MetricFlow) YAML certified metrics (Appendix A), projected to Power BI semantic model or equivalent** |
| DQ | SQL/custom tests or data-quality framework |
| Lineage | OpenLineage/Marquez or platform catalogue |
| BI | Network performance dashboard **built only on certified metrics** |
| ML | Delay or patronage prediction **using certified semantic measures as features where the feature is a business concept** |
| AI | RAG assistant over approved public transport documentation, **resolving KPIs via the metrics API** |
| Evidence | ERDs, data dictionary, ADRs, NFRs, lineage and deployment diagrams |

* * *

## 34. Architecture Review Checklist

| Question | Pass criterion |
| --- | --- |
| Business outcome identified? | Named transport decision and measurable outcome |
| Owner identified? | Domain owner/steward recorded |
| Grain defined? | Fact grain stated in one sentence |
| Source authoritative? | System/source documented |
| Temporal semantics defined? | Service/actual/ingestion/correction separated |
| Spatial semantics defined? | Location/network IDs and versioning documented |
| Quality measurable? | Rules, thresholds and actions defined |
| Security classified? | Access/privacy controls documented |
| Metric certified? | **Business owner, semantic YAML definition, version and platform projection approved** |
| Latency justified? | Real-time requirement linked to decision |
| Lineage available? | Critical KPI traceable to source **and to certified metric definition** |
| AI impact considered? | **Metrics API resolution**, retrieval, authorisation and evaluation defined |
| Cost considered? | Compute/storage/streaming trade-offs documented |
| Operational owner? | SLA, monitoring and support model defined |

* * *

## 35. Architecture Assumptions & Limitations

- This is a proposed reference architecture, not an official TfNSW internal design.
- Internal application names, databases, network topology and controls are not asserted unless public.
- Databricks, Microsoft Fabric and Azure are implementation options, not claims about TfNSW's current production platform.
- **The semantic layer (§18, ADR-010) is deliberately engine-neutral so the platform decision does not invalidate certified metric definitions.**
- Public datasets can be incomplete, delayed, corrected or unavailable.
- Public transport and road data have different grains and update frequencies.
- Privacy must be assessed for each use case, particularly movement/travel data.
- Production implementation requires validation with TfNSW enterprise, security, privacy, operational and platform stakeholders.

* * *

## 36. Research Sources

- TfNSW — Transport Data Strategy 2022–2025
- TfNSW — Corporate Plan 2024–2025
- TfNSW Open Data — Developer / GTFS documentation
- TfNSW Open Data Hub
- TfNSW Open Data — NSW Crash Data
- TfNSW Open Data — NSW Roads Traffic Volume Counts API
- TfNSW Open Data — Open Opal Data Documentation

* * *

## 37. Mapping from APEX Bank to TfNSW

| APEX Bank concept | TfNSW equivalent |
| --- | --- |
| Customer | Traveller / customer / community |
| Transaction | Journey / service / traffic / maintenance event |
| Product | Transport service / mode / network offering |
| Customer 360 | Journey/customer/community insight |
| Branches | Stops/stations/wharves/road locations |
| Financial KPI | Patronage, reliability, congestion, safety and investment KPIs |
| Transaction streaming | Vehicle/service/incident/traffic event streaming |
| Risk analytics | Safety, disruption and operational risk |
| Semantic layer | Enterprise transport metric layer **(dbt Semantic Layer, Appendix A)** |
| Banking RAG | Transport policy/operational/project knowledge assistant |

**Transferable architecture method:**

Business outcome → capability → data domain → source → ingestion → integration → data product → **certified semantic metric (YAML)** → consumption → governance/security → operating model.

* * *
## Appendix A — dbt Semantic Layer Definitions: Service Performance

*Reference implementation for §18.4. Engine-neutral certification artefact (ADR-010); project to the selected platform as a render target. File location in repo: `models/service_performance/semantic_models_service_performance.yml`.*

```yaml
# =============================================================================
# TfNSW Enterprise Data Analytics Architecture - Service Performance
# dbt Semantic Layer (MetricFlow) definitions
# Version 1.0 | 9 September 2026
#
# Grain: one row per service-trip-stop event (Architecture §10.1, §17)
# Source model: ref('fct_service_performance') built from the Gold star schema
#   FACT_SERVICE_PERFORMANCE x DIM_DATE/DIM_TIME/DIM_MODE/DIM_ROUTE/
#   DIM_SERVICE/DIM_OPERATOR (and DIM_STOP if maintained separately)
#
# Design principles applied:
#   - ADR-005 : every certified metric defined once, owned, versioned
#   - §17      : eligibility/exclusion rules live in the metric, not in reports
#   - §23/ADR-008: data quality status is a queryable dimension
#   - §11      : scheduled vs actual time semantics are separate concepts
#   - §24      : lineage = source -> product -> semantic -> report
# =============================================================================

semantic_models:

  # ---------------------------------------------------------------------------
  # FACT: SERVICE PERFORMANCE (the measurement model)
  # ---------------------------------------------------------------------------
  - name: service_performance
    label: Service Performance
    description: >
      One row per service-trip-stop event, carrying scheduled and actual
      arrival/departure times, delay, cancellation status and capacity.
      Certified by the Public Transport Performance domain owner (§17).
    model: ref('fct_service_performance')

    defaults:
      agg_time_dimension: service_date

    entities:
      - name: service_event
        type: primary
        expr: service_event_key
        description: Surrogate key - one row per service-trip-stop event.
      - name: trip
        type: foreign
        expr: trip_id
        description: GTFS trip identifier (links to trip/source lineage §24).
      - name: route
        type: foreign
        expr: route_id
        description: Conformed route (DIM_ROUTE, versioned §11).
      - name: service
        type: foreign
        expr: service_id
        description: Customer-facing service identifier (DIM_SERVICE).
      - name: operator
        type: foreign
        expr: operator_id
        description: Operating organisation (DIM_OPERATOR).
      - name: stop
        type: foreign
        expr: stop_id
        description: Stop/station/wharf (conformed spatial reference §22).

    dimensions:
      # --- Time semantics (§11): each time concept is distinct -------------
      - name: service_date
        type: time
        label: Service Date
        description: Date the trip operates (not the calendar date of ingestion).
        type_params:
          time_granularity: day
      - name: scheduled_arrival_ts
        type: time
        label: Scheduled Arrival
        type_params:
          time_granularity: minute
      - name: actual_arrival_ts
        type: time
        label: Actual Arrival
        type_params:
          time_granularity: minute
      - name: hour_of_day
        type: categorical
        label: Hour of Day
        description: Derived from scheduled event time for peak/off-peak analysis.
        expr: scheduled_hour
      - name: peak_period
        type: categorical
        label: Peak Period
        description: AM peak / PM peak / inter-peak / weekend, per approved calendar.
        expr: peak_period_code

      # --- Conformed reference dimensions ----------------------------------
      - name: mode
        type: categorical
        label: Transport Mode
        expr: mode_code            # train | metro | bus | ferry | light_rail
      - name: network_version
        type: categorical
        label: Network Version
        description: Version of route/stop topology effective for this event (§11).
        expr: network_version_id

      # --- Eligibility & certification (§17, §18) ---------------------------
      - name: event_eligible
        type: categorical
        description: Whether the event is eligible for reliability KPIs.
        expr: is_eligible
      - name: exclusion_reason
        type: categorical
        description: Approved exclusion code (planned works, special event, etc.).
        expr: exclusion_reason_code
      - name: cancellation_status
        type: categorical
        description: completed | cancelled | partial
        expr: cancellation_status

      # --- Quality awareness (§23, ADR-008) ---------------------------------
      - name: data_quality_status
        type: categorical
        description: >
          Quality flag for this event period - certified, suspect,
          imputed, or sensor_unavailable. Consumers filter, never assume.
        expr: data_quality_status
      - name: is_imputed
        type: categorical
        description: True where actual time was imputed rather than observed.
        expr: is_imputed_flag

    measures:
      - name: total_events
        description: Count of all service-trip-stop events.
        agg: count
        expr: service_event_key
        create_metric: true        # exposes simple metric automatically
      - name: eligible_events
        description: Events eligible for certified reliability KPIs.
        agg: sum
        expr: case when is_eligible = true then 1 else 0 end
      - name: on_time_events
        description: >
          Eligible events arriving/departing within approved punctuality
          tolerance (tolerance parameter owned by metric definition).
        agg: sum
        expr: case when is_eligible = true and is_on_time = true then 1 else 0 end
      - name: total_delay_minutes
        description: Sum of (actual - scheduled) minutes across eligible events.
        agg: sum
        expr: case when is_eligible = true then delay_minutes else 0 end
      - name: abs_delay_minutes
        description: Sum of absolute delay (early + late) for tolerance studies.
        agg: sum
        expr: case when is_eligible = true then abs(delay_minutes) else 0 end
      - name: completed_trips
        description: Trips completed (head-level completion, not stop-level).
        agg: sum
        expr: trip_completed_flag
      - name: planned_trips
        description: Distinct planned trips in scope (eligible + planned to run).
        agg: count_distinct
        expr: case when is_planned = true then trip_id end
      - name: cancelled_trips
        description: Trips cancelled.
        agg: count_distinct
        expr: case when cancellation_status = 'cancelled' then trip_id end
      - name: p90_delay_minutes
        description: 90th percentile delay across eligible events (tail latency).
        agg: percentile
        agg_params:
          percentile: 0.9
          use_discrete_percentile: true
        expr: case when is_eligible = true then delay_minutes end
      - name: total_capacity
        description: Approved seating/vehicle capacity on eligible events.
        agg: sum
        expr: case when is_eligible = true then capacity else 0 end

  # ---------------------------------------------------------------------------
  # DIMENSION: ROUTE (conformed reference, versioned §11)
  # ---------------------------------------------------------------------------
  - name: route
    label: Route
    description: Conformed route dimension with effective-dated versions.
    model: ref('dim_route')
    entities:
      - name: route
        type: primary
        expr: route_id
      - name: operator
        type: foreign
        expr: current_operator_id
    dimensions:
      - name: route_name
        type: categorical
      - name: mode
        type: categorical
        expr: mode_code
      - name: effective_from
        type: time
        type_params:
          time_granularity: day
      - name: effective_to
        type: time
        type_params:
          time_granularity: day
    measures:
      - name: route_count
        agg: count_distinct
        expr: route_id
        create_metric: true

  # ---------------------------------------------------------------------------
  # DIMENSION: OPERATOR
  # ---------------------------------------------------------------------------
  - name: operator
    label: Operator
    description: Transport operating organisations.
    model: ref('dim_operator')
    entities:
      - name: operator
        type: primary
        expr: operator_id
    dimensions:
      - name: operator_name
        type: categorical
      - name: operator_type
        type: categorical        # government | contracted | private
    measures:
      - name: operator_count
        agg: count_distinct
        expr: operator_id
        create_metric: true


# =============================================================================
# CERTIFIED METRICS (§18) - owned, versioned, single definition
# =============================================================================
metrics:

  # --- Reliability -----------------------------------------------------------
  - name: on_time_performance
    label: On-time Performance (%)
    description: >
      Eligible service-trip-stop events within approved punctuality tolerance,
      divided by eligible events. Certified by Public Transport Performance.
      Tolerance and exclusions are parameters of THIS metric only.
    type: ratio
    type_params:
      numerator: on_time_events
      denominator: eligible_events
    filter: |
      {{ Dimension('service_event__data_quality_status') }} <> 'sensor_unavailable'
    meta:
      owner: public_transport_performance_domain
      metric_version: "1.0"
      certified: true
      certification_date: "2026-09-09"

  - name: average_delay_minutes
    label: Average Delay (minutes)
    description: >
      Mean actual-minus-scheduled minutes across eligible events.
      Positive = late, negative = early.
    type: simple
    type_params:
      measure: total_delay_minutes
    filter: |
      {{ Dimension('service_event__data_quality_status') }} <> 'sensor_unavailable'

  - name: average_abs_delay_minutes
    label: Average Absolute Delay (minutes)
    description: Mean |delay| across eligible events (early or late).
    type: simple
    type_params:
      measure: abs_delay_minutes

  - name: service_completion
    label: Service Completion (%)
    description: >
      Completed eligible trips / planned eligible trips (§18).
      Trip-grain metric; do not compute from stop-level events.
    type: ratio
    type_params:
      numerator: completed_trips
      denominator: planned_trips
    filter: |
      {{ Dimension('service_event__event_eligible') }} = true

  # --- Latency distribution (executive threshold reporting) ------------------
  # p90 delay shows the tail that averages hide; requires the percentile
  # measure defined on the fact semantic model below.

  - name: p90_delay
    label: P90 Delay (minutes)
    description: 90th percentile of actual-minus-scheduled delay on eligible events.
    type: simple
    type_params:
      measure: p90_delay_minutes

  # --- Cancellation ----------------------------------------------------------
  - name: cancellation_rate
    label: Cancellation Rate (%)
    description: Cancelled trips as % of planned trips.
    type: ratio
    type_params:
      numerator: cancelled_trips
      denominator: planned_trips

  # --- Capacity context ------------------------------------------------------
  - name: average_capacity
    label: Average Capacity per Eligible Event
    type: simple
    type_params:
      measure: total_capacity
    filter: |
      {{ Dimension('service_event__event_eligible') }} = true

  # --- Time-spine (period-over-period, §11 restatement-safe) -----------------
  - name: otp_period_over_period
    label: OTP Change vs Previous Period (pp)
    type: derived
    type_params:
      expr: "{{ metric('on_time_performance') }} - {{ metric('on_time_performance', lag=1, over=[Dimension('service_event__service_date')]) }}"
      metrics:
        - name: on_time_performance
```

**Production notes for Appendix A:**

1. **`is_on_time` tolerance** — the YAML assumes the Gold fact carries an `is_on_time` boolean. If tolerance is mode-dependent (e.g. ±5 min trains, ±2 min metro), compute it in the Gold fact from a tolerance reference table, not in the semantic layer.
2. **Load factor** — keep as a separate `patronage` semantic model; derive the metric by joining via `route`/`service`/`stop` entities. Do not force it into this fact.
3. **Punctuality distribution** — for early/on-time/minor/major bands, add a `delay_band` categorical dimension to the fact with `sum_boolean` measures per band, rather than percentile gymnastics.
4. **Companion contract tests** — enforce §17 with `schema.yml` tests: `service_event_key` unique/not-null, foreign keys to `dim_route`/`dim_operator`, accepted values for `cancellation_status` and `data_quality_status`, and freshness SLAs.

* * *

_TfNSW Enterprise Data Analytics Architecture | Version 1.1 | 9 September 2026_
