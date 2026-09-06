TRANSPORT FOR NSW

Enterprise Data Analytics Architecture

Research-based architecture case study | APEX Bank-style structure

Version 1.0 | 4 September 2026 Proposed reference architecture — not an official TfNSW internal architecture

# 1. Document Control

# 2. Executive Summary

TfNSW is a strong enterprise Data Analytics Architecture case because transport analytics spans public transport, roads, freight, safety, infrastructure, customers, operators, geography and real-time operational information. Its published Transport Data Strategy identifies priorities including personalised end-to-end journeys, resilient networks, predictive asset maintenance, efficient movement of goods, investment prioritisation, real-time information and proactive analytics, AI and modelling.

The target architecture combines governed lakehouse storage, domain data products, event/streaming ingestion, historised integration, dimensional analytical models, geospatial capability, a semantic/metrics layer, BI, advanced analytics and governed AI/RAG.

The key architecture principle is that Medallion, Data Vault, dimensional modelling, data products and semantic models are complementary patterns serving different purposes.

# 3. Business & Data Context

Transport analytics differs from a typical enterprise warehouse because time, location and network topology are fundamental analytical dimensions. The architecture must reconcile planned versus actual service, rapidly changing network conditions, spatial relationships, multiple operators and varying data quality.

# 4. Strategic Architecture Drivers

# 5. Current-State Reference Hypothesis

This section is an architecture hypothesis rather than a claim about TfNSW's unpublished internal platform.

PUBLIC / PARTNER SOURCES GTFS | GTFS-R | Opal | Roads | Crash | Freight | Geo | Weather | Operators | | | | +----------------+-------------+-------------+ | APIs / files / events | DOMAIN SYSTEMS | Multiple analytical stores | Reports / BI / extracts Likely enterprise challenges: • different identifiers and grains • different refresh rates • scheduled vs actual time • network topology and geospatial joins • source quality / missing sensors • cross-domain KPI inconsistency • privacy and movement-pattern risk

# 6. Public Data Landscape

# 7. Target Enterprise Data Analytics Architecture

TRANSPORT OUTCOMES | +------------------------+-------------------------+ | | | | | Journey Network Safety Economic Community experience resilience / risk activity / places | | | | | +------------------------+-------------------------+ | SEMANTIC / METRICS Reliability | Patronage | Congestion | Safety | Assets Journey | Accessibility | Freight | Investment | Service | DOMAIN DATA PRODUCTS Journey | Service | Network | Customer | Asset | Incident Road | Safety | Freight | Location | Operator | Project | GOLD / ANALYTICS | SILVER / INTEGRATED + HISTORY Data Vault / canonical integration patterns | BRONZE / PRESERVATION | APIs | CDC | Files | Batch | Streaming | Sensors | GOVERNANCE / SECURITY / DQ / LINEAGE

# 8. Architecture Layers

# 9. Enterprise Transport Conceptual Data Model

CUSTOMER / TRAVELLER | JOURNEY / | TRIP LEG FARE | | | SERVICE MODE PAYMENT | ROUTE | STOP / STATION / WHARF | NETWORK SEGMENT | ASSET ---- MAINTENANCE / PROJECT INCIDENT ---- affects ---- NETWORK SEGMENT CRASH ------- occurs ----- LOCATION / ROAD SEGMENT FREIGHT ----- uses ------ ROAD / RAIL / PORT OPERATOR ---- operates -- SERVICE ALERT ------- affects --- SERVICE / STOP / NETWORK

# 10. Modelling Architecture

Use modelling patterns according to purpose. Preserve source data in Bronze; use historised integration where traceability and change history matter; publish star schemas for BI; and expose reusable domain products and certified metrics to consumers.

BRONZE SILVER GOLD Source-aligned -> Canonical / History -> Dimensional GTFS HUB_ROUTE DIM_ROUTE GTFS-R HUB_TRIP DIM_SERVICE Opal HUB_STOP + LINKS FACT_PATRONAGE Traffic HUB_INCIDENT FACT_TRAFFIC Crash HUB_ASSET FACT_SAFETY SATELLITES / HISTORY

## 10.1 Example Service Performance Star Schema

DIM_DATE DIM_TIME DIM_MODE DIM_ROUTE DIM_SERVICE DIM_OPERATOR \ | | | | / FACT_SERVICE_PERFORMANCE scheduled | actual | delay | cancelled | capacity

Grain must be explicit. A practical grain is one row per service-trip-stop event. Patronage can use a different grain, such as service/date/stop/mode, depending on source detail.

# 11. Time & Event Architecture

Scheduled time, actual event time, service date, publication time, ingestion time, correction time and snapshot time are distinct concepts.

- Use event-time processing for streaming.

- Use watermarks and replay for late events.

- Allow controlled restatement of historical aggregates.

- Version network/reference data.

- Retain source provenance where auditability is required.

# 12. Real-Time / Near-Real-Time Architecture

GTFS-R Vehicle Positions --\ GTFS-R Trip Updates -------+--> EVENT INGESTION --> STREAM PROCESSING GTFS-R Alerts -------------/ | Road incidents/sensors ----/ v REAL-TIME STATE | +-----------------------+------------------+ | | | Ops dashboard Customer API Alerts | Historical lakehouse

# 13. Open Data & External Data Architecture

INTERNAL / AUTHORITATIVE DATA | Privacy + security + publication review | v APPROVED PUBLIC DATA PRODUCTS | +------+-------+ | | Open Data Hub Developer APIs | | GTFS | Geo | CSV Journey | Realtime | Researchers / industry / applications

- Treat public data products as governed interfaces.

- Apply aggregation, suppression and privacy controls before release.

- Version schemas and documentation.

- Monitor public freshness and quality.

- Do not expose internal analytical tables directly.

# 14. Privacy & Ethical Analytics

Transport data can reveal movement patterns even when direct identifiers are removed. The architecture therefore treats privacy as a data-product and analytical-design concern, not merely a database security concern.

# 15. Data Governance Operating Model

EXECUTIVE DATA GOVERNANCE | DATA GOVERNANCE | +-------------------+-------------------+ | | | Domain Owners Stewards Architecture | | | +-------------------+-------------------+ | DATA PRODUCTS | Quality | Metadata | Lineage | Access

# 16. Transport Data Products

# 17. Example Data Product Contract — Service Performance

# 18. Semantic / Metrics Architecture

The semantic layer prevents different dashboards from independently defining transport KPIs. Definitions must be owned, versioned and certified.

# 19. BI & Analytics Architecture

DATA PRODUCTS -> GOLD -> SEMANTIC MODEL -> CERTIFIED KPIs | +------------------------+-----------------------+ | | | Executive BI Operations BI Planning BI

# 20. Advanced Analytics / ML

# 21. AI / RAG Architecture

USER | AI ASSISTANT |-----------------------------| v v CERTIFIED METRICS RAG SEARCH | | Governed numbers Policies / reports / project docs | | +-------------+---------------+ | ACCESS CONTROL | LLM | Grounded answer + evidence

Example question: "Why did reliability decline on this corridor last month?"

1. Resolve reliability to the certified semantic metric.

1. Identify corridor, mode, period and eligible services.

1. Calculate variance against the approved baseline.

1. Correlate authorised incidents, alerts and network conditions.

1. Retrieve approved documents when explanatory context is needed.

1. Generate facts first, interpretation second, with evidence.

1. Apply user permissions to every retrieved source.

1. Log the interaction and evidence under applicable policy.

- Numerical KPIs should come from governed metrics, not uncontrolled LLM arithmetic.

- RAG retrieval must enforce source-level and row/attribute-level permissions.

- Treat public/untrusted documents as potential prompt-injection sources.

- Evaluate factuality, retrieval quality, access control and harmful outputs.

# 22. Geospatial Analytics Architecture

POINTS LINES POLYGONS Stops Routes Suburbs Stations Road segments LGAs Wharves Rail corridors Regions Crashes Cycleways Catchments Assets Freight corridors Accessibility areas \ | / \______________|________________/ | CONFORMED LOCATION | SPATIAL ANALYTICS

- Use stable location IDs plus geometry.

- Version network topology and route geometry.

- Store coordinate reference systems explicitly.

- Support spatial joins and nearest-network analysis.

- Separate physical location from customer-facing identity.

- Validate geometry and unexpected movement.

# 23. Data Quality Framework

Road traffic count data illustrates why sensor availability and quality must be explicitly modelled. Consumers should see quality status rather than assuming every observation is equally reliable.

- Attach quality status to datasets/time periods.

- Flag suspect or unavailable sensor periods.

- Mark imputed values explicitly.

- Track quality incidents as metadata.

- Include confidence where material to analytical decisions.

# 24. Metadata & Lineage

Executive KPI: On-time Performance | Semantic measure | Service Performance data product | Gold fact_service_performance | Silver integrated/history | GTFS timetable + GTFS-R updates | Public transport source

# 25. Security Architecture

# 26. Architecture Decision Records

## ADR-001 — Lakehouse foundation

Decision: Use lakehouse/object-storage patterns as the scalable analytical foundation.

Rationale / trade-off: Supports mixed data, historical scale, BI, ML and AI.

## ADR-002 — Domain data products

Decision: Organise trusted analytics around transport domains.

Rationale / trade-off: Creates clear ownership and reusable interfaces.

## ADR-003 — Historised integration

Decision: Use Data Vault-style patterns where provenance/history are important.

Rationale / trade-off: Supports traceability without forcing consumers to query integration models.

## ADR-004 — Dimensional serving

Decision: Use star schemas for BI and common analytical workloads.

Rationale / trade-off: Optimises usability and performance.

## ADR-005 — Semantic metrics

Decision: Certify enterprise transport measures.

Rationale / trade-off: Prevents KPI fragmentation.

## ADR-006 — Event architecture

Decision: Use streaming where latency changes an operational/customer decision.

Rationale / trade-off: Avoids unnecessary complexity/cost.

## ADR-007 — Spatial first-class

Decision: Make locations/network topology conformed enterprise data.

Rationale / trade-off: Enables cross-domain transport analysis.

## ADR-008 — Quality-aware analytics

Decision: Publish quality/confidence status with data.

Rationale / trade-off: Prevents false precision.

## ADR-009 — Governed AI

Decision: AI consumes certified metrics and authorised knowledge.

Rationale / trade-off: Improves trust and reduces uncontrolled exposure.

# 27. Non-Functional Requirements

# 28. Operating Model

# 29. Implementation Roadmap

# 30. End-to-End Use Case — Why Was the 8:00 AM Service Unreliable?

GTFS SCHEDULE ----\ GTFS-R UPDATES -----+--> SERVICE PERFORMANCE PRODUCT VEHICLE POSITIONS --/ | INCIDENTS -----------------------+ WEATHER / EVENTS ----------------+ | SEMANTIC METRICS | Reliability / Delay / Cancel | +-------------+-------------+ | | POWER BI AI | | Trends/corridor "Why was it late?" | | +-------------+-------------+ | Governed evidence

1. Identify service, route, direction, date and stop/segment.

1. Compare scheduled and actual times.

1. Calculate delay/reliability using certified definitions.

1. Correlate incidents, alerts and network context.

1. Determine whether the issue is isolated or corridor-wide.

1. Retrieve approved operational/project documents if context is needed.

1. Present calculated facts separately from generated interpretation.

1. Retain evidence and source references.

# 31. Data Analytics Architect Interview Pack

# 32. 60-Day Upskilling Plan

# 33. Recommended Portfolio Build

# 34. Architecture Review Checklist

# 35. Architecture Assumptions & Limitations

- This is a proposed reference architecture, not an official TfNSW internal design.

- Internal application names, databases, network topology and controls are not asserted unless public.

- Databricks, Microsoft Fabric and Azure are implementation options, not claims about TfNSW's current production platform.

- Public datasets can be incomplete, delayed, corrected or unavailable.

- Public transport and road data have different grains and update frequencies.

- Privacy must be assessed for each use case, particularly movement/travel data.

- Production implementation requires validation with TfNSW enterprise, security, privacy, operational and platform stakeholders.

# 36. Research Sources

TfNSW — Transport Data Strategy 2022–2025 https://www.transport.nsw.gov.au/system/files/media/documents/2023/Transport-Data-Strategy-2022%E2%80%932025.pdf

TfNSW — Corporate Plan 2024–2025 https://www.transport.nsw.gov.au/system/files/media/documents/2024/TfNSW-Corporate-Plan-2024-2025_0.pdf

TfNSW Open Data — Developer / GTFS documentation https://opendata.transport.nsw.gov.au/developers/documentation

TfNSW Open Data Hub https://opendata.transport.nsw.gov.au/

TfNSW Open Data — NSW Crash Data https://opendata.transport.nsw.gov.au/data/dataset/nsw-crash-data

TfNSW Open Data — NSW Roads Traffic Volume Counts API https://opendata.transport.nsw.gov.au/dataset/nsw-roads-traffic-volume-counts-api

TfNSW Open Data — Open Opal Data Documentation https://opendata.transport.nsw.gov.au/dataset/4789edda-acb9-4eba-acc1-327db1a13843/resource/a148d2c0-bf82-44f8-904b-124f20e8a7bb/download/open-opal-data-documentation_0_1.pdf

# 37. Mapping from APEX Bank to TfNSW

Transferable architecture method: business outcome → capability → data domain → source → ingestion → integration → data product → semantic metric → consumption → governance/security → operating model.



| Item | Value |

| --- | --- |

| Organisation | Transport for NSW (TfNSW) |

| Document | Enterprise Data Analytics Architecture |

| Version | 1.0 |

| Purpose | A practical enterprise analytics architecture case study based on publicly available TfNSW information and datasets. |

| Audience | Data Analytics Architects, Data Architects, Solution Designers, Data Modellers, Data Engineers, BI/Analytics, Governance and AI teams |

| Status | Proposed reference architecture / portfolio case study |

| Limitation | Internal TfNSW systems, contracts, security controls and unpublished architecture are not assumed. |





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





| Driver | Architecture implication |

| --- | --- |

| Personalised end-to-end journeys | Integrate schedules, actual service, journey legs, locations and disruption context. |

| Resilient networks | Combine incidents, assets, service state, weather and network topology. |

| Predictive asset maintenance | Historise asset condition, maintenance, failures and utilisation. |

| Efficient freight | Integrate freight flows, corridors, network performance and forecasts. |

| Investment prioritisation | Create consistent measures for demand, safety, reliability, cost and benefits. |

| Real-time information | Support event ingestion and low-latency analytical serving. |

| Trusted analytics | Certified metrics, quality, metadata and lineage. |

| AI / modelling | Governed ML and RAG over approved data and documents. |

| Open data / partnerships | Publish documented, versioned, privacy-safe external data products. |





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





| Layer | Responsibility | Examples |

| --- | --- | --- |

| Source | Operational/partner/public information | Ticketing, timetable, road sensors, assets, projects |

| Ingestion | Reliable movement and operational metadata | API, CDC, files, streaming |

| Bronze | Source preservation | Delta/Parquet/object storage |

| Silver | Validation, standardisation, integration, history | Canonical entities, Data Vault-style models |

| Gold | Business-ready analytical products | Facts, dimensions, aggregates, spatial products |

| Semantic | Certified business meaning | Reliability, patronage, congestion, safety |

| Consumption | BI, ML, APIs, AI | Power BI, notebooks, models, RAG |

| Governance | Ownership, definitions, lineage, quality | Catalogue, glossary, stewardship |

| Security | Access, privacy, audit | RBAC/ABAC, masking, RLS/CLS |

| Operations | Reliability, performance, cost | Monitoring, CI/CD, FinOps |





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





| Use case | Indicative latency | Pattern |

| --- | --- | --- |

| Vehicle position | Seconds/minutes | Streaming |

| Disruption alert | Seconds/minutes | Event-driven |

| Reliability monitoring | Minutes | Streaming + micro-batch |

| Patronage | Daily / selected intraday | Incremental batch |

| Executive reporting | Hourly/daily | Curated batch |

| Demand forecasting | Daily/weekly | Batch ML |

| Asset predictive maintenance | Minutes/hours/daily | Streaming + batch |





| Risk | Control |

| --- | --- |

| Travel-pattern reconstruction | Aggregation, suppression and privacy review |

| Location re-identification | Spatial generalisation / minimum cohorts |

| Dataset linkage | Restrict joins and assess quasi-identifiers |

| Operational sensitivity | Restricted access zones |

| Analyst extracts | Controlled workspaces, expiry and monitoring |

| AI leakage | Retrieval-time authorisation and output controls |

| Public release | Formal privacy/publication assessment |





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





| Metric | Illustrative definition |

| --- | --- |

| On-time performance | Eligible service-stop events within approved punctuality tolerance. |

| Average delay | Average actual minus scheduled time for eligible events. |

| Service completion | Completed eligible trips / planned eligible trips. |

| Patronage | Approved count/estimate of passenger travel activity. |

| Load factor | Passenger load relative to approved capacity. |

| Journey reliability | Journeys meeting approved reliability criteria. |

| Network travel time | Observed travel time for a defined segment/corridor. |

| Congestion index | Observed travel time vs approved baseline. |

| Crash rate | Crashes/casualties normalised by approved exposure. |

| Asset failure rate | Failures relative to asset population/exposure. |

| Freight throughput | Goods volume through a defined corridor/node/time. |

| Accessibility score | Approved measure of service access and community context. |





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





| Model | Potential features | Outcome |

| --- | --- | --- |

| Patronage forecast | Historical demand, timetable, calendar, weather/events | Demand by mode/route/time |

| Delay prediction | Historical delays, service, incidents, weather | Delay risk |

| Crowding prediction | Patronage, capacity, timetable, events | Expected load |

| Asset failure risk | Condition, age, maintenance, utilisation | Failure probability |

| Crash risk | Crash history, road features, speed, traffic, environment | Risk score |

| Congestion forecast | Traffic, incidents, historical patterns | Travel-time forecast |

| Freight demand | Historical flows, economic indicators, capacity | Demand/flow forecast |





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

| AI | Same authorisation model for retrieval and output |





| NFR | Target |

| --- | --- |

| Availability | Tier services by operational importance with explicit SLOs |

| Freshness | Minutes for selected operational streams; daily for planning |

| Scalability | Handle growing event, spatial and historical volumes |

| Performance | Interactive BI within agreed response targets |

| Security | Least privilege, encryption, audit and privacy controls |

| Resilience | Replayable ingestion, retry, checkpoint and recovery |

| Data quality | Automated validation and visible status |

| Lineage | Critical metrics traceable end-to-end |

| Maintainability | Version control, CI/CD and automated tests |

| Interoperability | Open formats/APIs for approved external sharing |

| Cost | Workload classification, incremental processing and lifecycle management |

| AI safety | Access control, grounded retrieval and evaluation |





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

| Change management | Schema and semantic changes versioned and impact assessed |





| Phase | Timing | Deliverables |

| --- | --- | --- |

| 1. Foundation | 0–3 months | Architecture standards, domain catalogue, landing zone, governance |

| 2. Network + service | 3–6 months | GTFS/GTFS-R, routes/stops/operators, service-performance product |

| 3. Patronage + journey | 6–9 months | Travel activity integration, journey analytics, semantic metrics |

| 4. Road + safety | 9–12 months | Traffic, incidents, crash and safety products |

| 5. Assets + projects | 12–15 months | Asset health, maintenance and investment products |

| 6. Advanced analytics | 15–18 months | Demand, reliability, congestion and asset-risk models |

| 7. AI / RAG | 18+ months | Governed analytics assistant and knowledge retrieval |





| Question | Strong answer |

| --- | --- |

| Why is TfNSW complex? | Multiple modes, operators, spatial networks, real-time events, travel activity, assets, safety, freight and projects. |

| Why not one warehouse? | Use a governed analytical foundation plus domain products and workload-specific serving patterns. |

| GTFS vs GTFS-R? | GTFS is scheduled/static information; GTFS-R provides dynamic vehicle, trip-update and alert information. |

| Why is time important? | Scheduled, actual, service, ingestion and correction timestamps have different meanings. |

| Why Data Vault plus dimensional? | Historised integration supports traceability; dimensional models optimise business consumption. |

| What is a data product? | A governed reusable dataset with owner, grain, schema, SLA, quality, security and lineage. |

| How define on-time? | Agree eligible events, tolerance, exclusions and aggregation with the metric owner, then certify it. |

| How build Journey 360? | Conform locations/routes/trips/legs, integrate authorised travel activity and protect privacy. |

| How protect travel data? | Minimise identity, aggregate, control linkage and assess re-identification. |

| When use real-time? | When low latency changes a decision, operation or customer experience. |

| How solve poor sensors? | Track availability/quality, flag suspect periods and expose confidence. |

| Why spatial first-class? | Transport outcomes depend on location and network topology. |

| How solve conflicting KPIs? | Named metric owners, glossary, certified semantic measures and retirement of duplicates. |

| How should AI explain delays? | Use certified metrics, authorised incident/context data and approved documents, separating evidence from inference. |

| How measure architecture success? | Consistency, quality, freshness, lineage, adoption, productivity, reliability and cost. |

| What belongs in Gold? | Curated, stable, business-ready analytical products. |

| What belongs in Bronze? | Source-aligned data retained for controlled reprocessing. |

| How manage route changes? | Effective dating and versioned network/reference data. |

| How handle late events? | Event-time processing, watermarks, replay and controlled restatement. |

| Why is this Analytics Architecture? | It connects acquisition to semantic metrics, BI, ML, AI and business outcomes. |





| Days | Focus | Exercise |

| --- | --- | --- |

| 1–10 | Transport domain | Learn GTFS/GTFS-R, routes/stops/trips, patronage, roads and safety. |

| 11–20 | Analytics architecture | Redraw the target architecture and explain every trade-off. |

| 21–30 | Data products + modelling | Model Service Performance, Patronage and Road Safety. |

| 31–40 | Lakehouse | Build Bronze/Silver/Gold using public datasets. |

| 41–50 | BI + semantic | Build certified reliability, patronage and congestion metrics. |

| 51–55 | Streaming + spatial | Process GTFS-R-style events and spatial network analysis. |

| 56–60 | Architecture leadership | Complete ADRs, NFRs, security, DQ, lineage and present the case. |





| Component | Implementation |

| --- | --- |

| Ingestion | Python/API + scheduled jobs for GTFS, GTFS-R and road datasets |

| Storage | Parquet/Delta; Databricks/Fabric if available |

| Bronze | Raw snapshots with ingestion metadata |

| Silver | Canonical route/stop/trip/service + temporal history |

| Gold | Service performance, patronage, traffic and safety facts |

| Spatial | GeoPandas/PostGIS or platform spatial capability |

| Semantic | Power BI semantic model or equivalent |

| DQ | SQL/custom tests or data-quality framework |

| Lineage | OpenLineage/Marquez or platform catalogue |

| BI | Network performance dashboard |

| ML | Delay or patronage prediction |

| AI | RAG assistant over approved public transport documentation |

| Evidence | ERDs, data dictionary, ADRs, NFRs, lineage and deployment diagrams |





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

| Metric certified? | Business owner and semantic definition approved |

| Latency justified? | Real-time requirement linked to decision |

| Lineage available? | Critical KPI traceable to source |

| AI impact considered? | Retrieval, authorisation and evaluation defined |

| Cost considered? | Compute/storage/streaming trade-offs documented |

| Operational owner? | SLA, monitoring and support model defined |





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

| Semantic layer | Enterprise transport metric layer |

| Banking RAG | Transport policy/operational/project knowledge assistant |


