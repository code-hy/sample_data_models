
# TfNSW Enterprise Data Analytics Architecture: Next Steps & Implementation Roadmap

**Document Purpose:** To transition the TfNSW Enterprise Data Analytics Architecture (DAA) from *Architecture Approval* into *Delivery Mobilisation and Implementation*, ensuring the delivered solution remains true to the design and achieves TfNSW’s intended business outcomes.

**Guiding Principle:** 
> **Approved Architecture → Detailed Design → Build → Test → Deploy → Operate → Optimise**

---

## 1. Architecture Approval → Architecture Baseline
*Formally baseline the approved architecture to establish a single source of truth for the delivery team.*

* **Record Architecture Decision & Approval:** Log approval of the TfNSW Enterprise Data Analytics Architecture v1.0 (dated 4 September 2026) in the enterprise architecture repository (e.g., LeanIX, Ardoq).
* **Capture Assumptions, Constraints & Exclusions:** 
  * *Assumption:* Public/open data patterns (GTFS, GTFS-R, Opal, Crash Data) are representative of internal data structures.
  * *Constraint:* Strict adherence to NSW Privacy and Personal Information Protection Act (PPIPA) regarding travel-pattern reconstruction.
  * *Exclusion:* Direct integration with unpublished legacy internal ticketing systems in Phase 1 (rely on approved authoritative sources).
* **Record Architecture Decision Records (ADRs):** Baseline ADR-001 through ADR-009 (e.g., ADR-001: Lakehouse foundation, ADR-003: Historised integration via Data Vault, ADR-007: Spatial first-class).
* **Establish Change-Control Process:** Any deviation from the baseline Medallion + Data Vault + Dimensional + Semantic pattern requires a formal Architecture Change Request (ACR) reviewed by the Enterprise Analytics Architect.
* **Confirm Principles:** Delivery must follow the core principle: *Medallion, Data Vault, dimensional modelling, data products, and semantic models are complementary patterns serving different purposes.*

**🏆 Key Deliverable:** **Approved & Baselined Data Analytics Architecture (DAA) Register**

---

## 2. Convert Architecture into a Delivery Roadmap
*Translate the high-level architecture into actionable, phased delivery work packages aligned with the TfNSW 18-month strategic roadmap.*

| Architecture Area | Delivery Work Package | TfNSW Specific Context |
| :--- | :--- | :--- |
| **Data Sources** | Source Onboarding & Profiling | GTFS, GTFS-R, Opal, Road Traffic Counts, NSW Crash Data, Asset Registers. |
| **Data Ingestion** | Pipelines / APIs / CDC / Streaming | Batch for static GTFS; Event-driven streaming (e.g., Kafka/Event Hubs) for GTFS-R Vehicle Positions. |
| **Data Platform** | Lakehouse Implementation | Azure Databricks / Microsoft Fabric setup with Delta Lake, spatial extensions (GeoPandas/PostGIS). |
| **Data Modelling** | Conceptual → Logical → Physical | Bronze (Source-aligned) → Silver (Data Vault Hubs/Links/Satellites) → Gold (Star Schema: `FACT_SERVICE_PERFORMANCE`). |
| **Data Quality** | DQ Rules & Monitoring Framework | Completeness, spatial integrity, temporal validity (scheduled vs. actual vs. ingestion time), sensor availability flags. |
| **Data Governance** | Ownership, Classification, Lineage | Domain Data Owners assigned; OpenLineage/Marquez implementation; Business Glossary populated. |
| **Security** | RBAC, Masking, Encryption | Row-Level Security (RLS) for regional operators; Column-Level Security (CLS) for PII; dynamic data masking. |
| **Analytics** | Semantic Models / Marts | Certified metrics layer (e.g., "On-time performance", "Journey reliability") decoupled from BI tools. |
| **BI / AI** | Dashboards & Governed RAG | Power BI Executive/Operations dashboards; Phase 7 RAG assistant over approved project docs. |
| **DevOps** | CI/CD & Infrastructure Automation | Terraform/Bicep for IaC; automated testing in CI/CD pipelines for data models and DQ rules. |
| **Operations** | Monitoring, Support & Runbooks | FinOps cost monitoring, pipeline freshness alerts, hypercare support model. |

**🏆 Key Deliverable:** **DAA Implementation Roadmap (Phased 1–7 over 18 months)**

---

## 3. Detailed Solution Design
*The Data Analytics Architect works with Solution Architects, Data Engineers, and Modellers to define exactly **how** it will be built.*

* **Logical Data Architecture:** Source → Ingestion → Bronze (Preservation) → Silver (Canonical/Data Vault) → Gold (Business Data Products) → Semantic Layer → Consumption (BI/ML/AI).
* **Physical Data Architecture:** 
  * *Storage:* Delta Lake (Bronze/Silver/Gold) with Z-ordering on `service_date` and `route_id`.
  * *Compute:* Serverless SQL for BI querying; Spark clusters for heavy Silver/Gold transformations.
* **Source-to-Target Mapping (Example: Service Performance):**
  * *Source:* GTFS `trips.txt`, `stop_times.txt` + GTFS-R `trip_updates.pb`.
  * *Bronze:* Raw JSON/Parquet with `ingestion_timestamp`.
  * *Silver:* `HUB_TRIP`, `HUB_STOP`, `LINK_TRIP_STOP`, `SAT_TRIP_PERFORMANCE` (with `effective_from`/`effective_to`).
  * *Gold:* `FACT_SERVICE_PERFORMANCE` (Grain: one row per service-trip-stop event).
* **Temporal Semantics Design:** Explicit columns for `service_date`, `scheduled_time`, `actual_time`, `ingestion_time`, and `correction_time`. Watermarks configured for late-arriving GTFS-R events.
* **Spatial Design:** Conformed `LOCATION_ID` with explicit Coordinate Reference System (CRS, e.g., EPSG:7844 for NSW). Geometry stored alongside business keys.
* **Data Quality Rules:** 
  * *Validity:* `actual_time` must be within ±24 hours of `scheduled_time`.
  * *Spatial Integrity:* Coordinates must fall within NSW bounding box.
  * *Reconciliation:* Daily trip counts must reconcile to source control totals.
* **Environment Design:** Strict segregation of `Dev` → `Test` → `UAT` → `Production` with synthetic/masked data in lower environments.

**🏆 Key Deliverable:** **Detailed Solution Design Document (DSD) & Source-to-Target Mapping Specifications**

---

## 4. Create the Backlog
*Break the architecture into implementable Agile stories. Example Epic:*

**Epic: Network Service Performance Analytics Platform**

* **Story 1: Source Onboarding (GTFS/GTFS-R)** 
  * *Req:* Ingest static and real-time transport data. 
  * *AC:* Data lands in Bronze Delta within 5 mins of API availability. 
  * *NFR:* 99.9% ingestion success rate.
* **Story 2: Silver Historised Integration (Data Vault)**
  * *Req:* Create canonical, historised view of trips and stops. 
  * *AC:* Hubs and Satellites created with hash keys and load dates. 
  * *Arch Ref:* ADR-003.
* **Story 3: Gold Dimensional Model**
  * *Req:* Build `FACT_SERVICE_PERFORMANCE`. 
  * *AC:* Star schema with `DIM_DATE`, `DIM_TIME`, `DIM_ROUTE`, `DIM_SERVICE`. Grain explicitly documented.
* **Story 4: Semantic Metric Certification**
  * *Req:* Define "On-time performance". 
  * *AC:* Metric logic reviewed and signed off by Public Transport Performance Domain Owner.
* **Story 5: Data Quality & Observability**
  * *Req:* Implement DQ checks. 
  * *AC:* Pipeline fails or flags warning if `route_id` referential integrity is < 99%.
* **Story 6: Security & Access Control**
  * *Req:* Implement RLS. 
  * *AC:* Operators only see data for their assigned routes. PII columns masked.
* **Story 7: Power BI Dashboard**
  * *Req:* Operations BI dashboard. 
  * *AC:* Connects *only* to the Semantic Layer, not direct Gold tables.
* **Story 8: Deployment & CI/CD**
  * *Req:* Automated deployment. 
  * *AC:* Infrastructure and data pipelines deployed via Terraform and GitHub Actions.

**🏆 Key Deliverable:** **Prioritised Product Backlog in Jira/Azure DevOps with DoD (Definition of Done)**

---

## 5. Build the Data Foundation First
*Enforce the discipline of building the pipeline top-to-bottom for a single domain before expanding.*

```text
[Operational Sources] GTFS, GTFS-R, Opal, Crash Data
       ↓ (API / Streaming / Batch)
[Ingestion Layer]    Automated, metadata-rich ingestion
       ↓
[Bronze / Raw]       Immutable, source-aligned Delta tables
       ↓ (Validation, Standardisation, Deduplication)
[Silver / Curated]   Data Vault (Hubs, Links, Satellites) + Temporal History
       ↓ (Business Logic, Aggregation, Conformed Dimensions)
[Gold / Products]    FACT_SERVICE_PERFORMANCE, DIM_ROUTE, DIM_LOCATION
       ↓ (Business Logic Encapsulation)
[Semantic Layer]     Certified Metrics (On-time %, Delay mins, Cancellation rate)
       ↓
[Consumption]        Power BI (Ops/Exec Dashboards), ML (Delay Prediction), AI (RAG)
```

**🏆 Key Deliverable:** **End-to-End Vertical Slice (MVP) for "Service Performance"**

---

## 6. Data Governance and Security
*Critical for Australian Government (TfNSW). Confirm before production:*

* **Data Ownership:** Formal RACI matrix signed by Domain Data Owners (e.g., Public Transport Performance, Road Safety).
* **Data Classification:** Tag all datasets (e.g., `OFFICIAL: Sensitive` for travel patterns; `OFFICIAL: Public` for aggregated GTFS).
* **PII/Sensitive Handling:** Travel data must undergo privacy impact assessment (aggregation, spatial generalisation, minimum cohort sizes to prevent re-identification).
* **Access Control:** Azure AD integration. RBAC for platform access; RLS/CLS for data access.
* **Data Retention:** Bronze (7 years for audit), Silver (7 years), Gold (rolling 5 years), adhering to NSW State Records Act.
* **Metadata & Lineage:** Automated lineage from Source → Bronze → Silver → Gold → Semantic → Power BI Report.
* **Regulatory/Audit:** All access to `OFFICIAL: Sensitive` data logged and reviewed quarterly.

**🏆 Key Deliverable:** **Governance & Security Sign-off Package (including Privacy Impact Assessment)**

---

## 7. Build → Test → Validate
*The architect’s role shifts to assurance and unblocking.*

* **Development Assurance:** 
  * Peer review of Data Vault modelling (hash keys, satellite structures).
  * Review of Spark/SQL transformation code for performance (e.g., partition pruning, Z-ordering).
* **Testing Gates:**
  * *Unit Testing:* dbt or Great Expectations tests on Silver/Gold transformations.
  * *Integration Testing:* End-to-end data flow from GTFS-R API to Power BI semantic model.
  * *Data Quality Testing:* Automated DQ dashboards showing completeness, validity, and freshness.
  * *Performance Testing:* Gold layer queries must return < 3 seconds for standard BI aggregations.
  * *Security Testing:* Penetration testing and RLS validation (e.g., verify Operator A cannot see Operator B's data).
* **Architecture Assurance:** Monthly Architecture Review Board (ARB) check: *Does the implementation still conform to ADR-001 through ADR-009?*

**🏆 Key Deliverable:** **Architecture Assurance & Testing Sign-off Reports**

---

## 8. Production Readiness
*Conduct a formal Architecture / Solution Readiness Review before go-live.*

- [ ] Architecture implemented per baselined DAA and ADRs
- [ ] Data models (Bronze/Silver/Gold) reviewed and approved by Lead Data Modeller
- [ ] Data pipelines tested end-to-end with production-volume data
- [ ] Data quality thresholds met and monitoring alerts configured
- [ ] Security controls (RBAC, RLS, CLS, Encryption) implemented and penetration tested
- [ ] Access model approved by Domain Data Owner and CISO
- [ ] End-to-end lineage documented and visible in data catalog
- [ ] Business glossary and metadata populated for all Gold/Semantic assets
- [ ] Performance acceptable (meets NFRs for latency and query response)
- [ ] Disaster recovery and data replay (for late GTFS-R events) tested
- [ ] Monitoring (Datadog/Azure Monitor) and alerting implemented
- [ ] Operational runbook completed (including rollback procedures)
- [ ] Support team (L1/L2/L3) trained on incident management
- [ ] Deployment process tested via CI/CD pipeline
- [ ] Business UAT completed and signed off by Product Owner
- [ ] Production approval obtained from Change Advisory Board (CAB)

**🏆 Key Deliverable:** **Production Readiness Review (PRR) Sign-off**

---

## 9. Go-Live and Transition to Operations
*Deploy → Monitor → Stabilise → Handover.*

The architecture team participates in a **2-to-4 week Hypercare period**.

* **Monitor:** 
  * Pipeline failures (e.g., GTFS-R stream disconnects).
  * Data freshness (e.g., Semantic layer updated within 5 minutes of source event).
  * Data quality anomalies (e.g., sudden drop in `route_id` validity).
  * Platform performance and FinOps cost anomalies.
  * Security incidents or unauthorised access attempts.
  * User adoption metrics (Power BI active users).
* **Stabilise:** Address technical debt, tune slow-running Gold transformations, refine DQ thresholds based on real-world noise.
* **Handover:** Formal transition to BAU Platform and Data Operations teams.

**🏆 Key Deliverable:** **Hypercare Report & BAU Handover Certificate**

---

## 10. Continuous Architecture
*Establish an Architecture Review & Optimisation cycle to prevent architectural decay.*

```text
                    ┌──────────────────┐
                    │ Architecture     │
                    │ Approval         │
                    └────────┬─────────┘
                             ↓
                    Detailed Design
                             ↓
                       Build / Test
                             ↓
                         Deploy
                             ↓
                       Operate
                             ↓
                       Monitor (FinOps, DQ, Performance)
                             ↓
                     Optimise / Evolve (e.g., new AI/RAG use cases)
                             │
                             └──────────────┐
                                            ↓
                                  Quarterly Architecture Review
```

### The Data Analytics Architect's Role Evolution

| Phase | Architect's Primary Role | TfNSW Context Example |
| :--- | :--- | :--- |
| **Before approval** | **Design & convince** | Advocating for Data Vault + Dimensional hybrid over a single monolithic warehouse. |
| **Approval** | **Defend & baseline** | Formalising ADR-007 (Spatial first-class) and ADR-009 (Governed AI). |
| **Detailed design** | **Guide & govern** | Ensuring temporal semantics (scheduled vs. actual vs. ingestion time) are correctly modelled. |
| **Build** | **Assure & unblock** | Resolving disputes between Data Engineers and BI Developers on Gold layer grain. |
| **Testing** | **Validate** | Verifying that RLS correctly isolates operator data in UAT. |
| **Go-live** | **Approve readiness** | Signing off the Production Readiness Review checklist. |
| **Operations** | **Monitor & optimise** | Reviewing FinOps reports to optimise Delta Lake vacuuming and cluster sizing. |
| **Future changes** | **Evolve architecture** | Designing the integration of new AI/RAG capabilities (Phase 7) over certified metrics. |

---

## The Most Important Next Step (Immediate Action Plan)

As the Data Analytics Architect, execute this sequence in the next 30 days:

1. **Baseline Architecture:** Publish the DAA v1.0 to the enterprise repository.
2. **Identify Conditions/Gaps:** Document any assumptions from the PRR that need validation during Phase 1.
3. **Create Implementation Roadmap:** Finalise the 18-month phased plan with Product Management.
4. **Define Detailed Design Work Packages:** Issue the DSD templates to the engineering leads.
5. **Establish Delivery Backlog:** Work with Agile Delivery Managers to populate Jira/ADO with the foundational "Service Performance" epic.
6. **Assign Roles:** Confirm availability of Lead Data Modeller, Data Engineers, and Governance Stewards.
7. **Conduct Design Assurance:** Schedule weekly architecture syncs during the initial build phase.
8. **Prepare for PRR:** Pre-populate the Production Readiness checklist for the Phase 1 MVP.

> *Architecture approval is not the end of the architect's job—it is the point where the architect moves from "designing the solution" to "ensuring the delivered solution remains true to the design and delivers the intended business outcomes."*
