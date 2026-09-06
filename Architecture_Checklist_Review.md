Data Analytics Architect — Project Navigation Cheat Sheet & Checklist

«Purpose: A practical field guide for a Data Analytics Architect entering a new project.
Target audience: Data Analytics Architects, Data Architects, Solution Designers, Data Modellers, Data Engineers and Analytics Leads.»

---

## 1. The 10 Questions to Ask First

Before designing anything, answer these questions:

1. What business problem are we solving?
2. What decision will the analytics enable?
3. Who will consume the outcome?
4. What are the key business processes?
5. What data is required?
6. Where does that data come from?
7. What is the required latency?
   - Real-time
   - Near-real-time
   - Hourly
   - Daily
   - Weekly/monthly
8. How much historical data is required?
9. How will the data be consumed?
   - BI
   - Reporting
   - ML
   - AI
   - API
10. How will we know the solution is successful?

«Architect's golden rule: Don't start with "Should we use Databricks/Fabric/Snowflake?"
Start with "What business decision are we trying to improve?"»

---

## 2. Analytics Architecture Mind Map

                    BUSINESS OUTCOME
                           |
                    BUSINESS QUESTIONS
                           |
                    ANALYTICS USE CASE
                           |
              +------------+------------+
              |                         |
           PEOPLE                   DECISIONS
              |                         |
              +------------+------------+
                           |
                          DATA
                           |
       +-------------------+-------------------+
       |                   |                   |
     SOURCES            INTEGRATION         QUALITY
       |                   |                   |
       +-------------------+-------------------+
                           |
                      DATA PRODUCTS
                           |
              +------------+------------+
              |                         |
           SEMANTIC                 ANALYTICS
           / METRICS                / ML / AI
              |                         |
              +------------+------------+
                           |
                      CONSUMPTION
                           |
                    BUSINESS OUTCOME

Cross-cutting capabilities:

- Governance
- Security
- Privacy
- Metadata
- Lineage
- Data quality
- Cost management
- Operations
- Architecture standards

---

## 3. Phase 1 — Understand the Business

### 3.1 Business Problem

- [ ] What problem are we solving?
- [ ] Why is it important?
- [ ] What happens if we do nothing?
- [ ] Is this strategic, regulatory, operational or tactical?
- [ ] What business process does it support?
- [ ] What decision needs better information?
- [ ] Who owns the decision?
- [ ] **What is explicitly out of scope?**  *(added)*

### 3.2 Stakeholders

Identify:

- [ ] Executive sponsor
- [ ] Business owner
- [ ] Product owner
- [ ] Data owner
- [ ] Data steward
- [ ] Business analysts
- [ ] Data analysts
- [ ] Data engineers
- [ ] Data scientists
- [ ] BI developers
- [ ] Security
- [ ] Privacy
- [ ] Enterprise architecture
- [ ] Platform/cloud team
- [ ] Operations/support
- [ ] **Data product owner**  *(added)*

### 3.3 Key Question

Ask:

«"If I give you perfect data tomorrow, what decision would you make differently?"»

This often exposes the real analytics requirement.

---

## 4. Phase 2 — Identify Analytics Use Cases

Create a use-case matrix.

Use Case| User| Decision| Data| Frequency| Priority
Executive dashboard| Executive| Business performance| Sales, finance| Daily| High
Customer analytics| Marketing| Campaign targeting| Customer, transactions| Daily| High
Fraud detection| Risk| Block transaction| Transactions/events| Real-time| Critical
Forecasting| Planning| Resource allocation| Historical data| Weekly| Medium

For every use case determine:

- [ ] Business objective
- [ ] User
- [ ] Decision
- [ ] KPI
- [ ] Required data
- [ ] Required granularity
- [ ] Required history
- [ ] Required latency
- [ ] Required accuracy
- [ ] Security classification
- [ ] Regulatory requirements

---

## 5. Phase 3 — Understand the Business Processes

Before modelling data, understand the business process.

Banking Example

Customer
   |
Application
   |
Account
   |
Transaction
   |
Payment
   |
Settlement
   |
Statement

Transport Example

Traveller
   |
Journey
   |
Trip
   |
Service
   |
Route
   |
Stop
   |
Network

Ask:

- [ ] What happens first?
- [ ] What happens next?
- [ ] What is the business event?
- [ ] What creates a record?
- [ ] What changes?
- [ ] What is cancelled?
- [ ] What is reversed?
- [ ] What is corrected?
- [ ] What is the lifecycle?

«Architect's trick: Model the business process before modelling the database.»

---

## 6. Phase 4 — Build the Data Domain Map

Identify the major domains.

                    ENTERPRISE
                        |
       +----------------+----------------+
       |                |                |
    Customer          Product         Finance
       |                |                |
       +----------------+----------------+
                        |
                  Transactions
                        |
                Risk / Compliance

TfNSW Example

Customer / Traveller
        |
Journey
        |
Public Transport
        |
Roads ---- Safety
        |
Assets
        |
Projects
        |
Freight
        |
Location / Geography

For each domain identify:

- [ ] Domain owner
- [ ] Key entities
- [ ] Source systems
- [ ] Data products
- [ ] Critical data elements
- [ ] Sensitive data
- [ ] KPIs
- [ ] Consumers

---

## 7. Phase 5 — Source System Discovery

Create a Source Inventory.

Source| Owner| Data| Format| Frequency| Volume| Quality| Criticality
CRM| Sales| Customer| API| Real-time| Medium| High| High
ERP| Finance| Finance| DB| Daily| High| High| Critical
Operations| Operations| Transactions| DB| Real-time| Very High| Medium| Critical
External API| Partner| Reference| API| Hourly| Low| Medium| Medium

### 7.1 Technical

- [ ] Database?
- [ ] API?
- [ ] File?
- [ ] Event stream?
- [ ] SaaS?
- [ ] Mainframe?
- [ ] Legacy?
- [ ] Cloud?
- [ ] On-premises?

### 7.2 Data

- [ ] What entities?
- [ ] What is the grain?
- [ ] Primary key?
- [ ] Business key?
- [ ] Change tracking?
- [ ] History?
- [ ] Deletes?
- [ ] Corrections?
- [ ] Late-arriving data?

### 7.3 Operational

- [ ] SLA?
- [ ] Availability?
- [ ] Maintenance windows?
- [ ] Volume?
- [ ] Growth?
- [ ] Rate limits?
- [ ] Data extraction restrictions?

---

## 8. Phase 6 — Determine the Data Grain

One of the most important responsibilities of the Analytics Architect.

Always complete this sentence:

«"One row represents..."»

Examples:

Transaction

«One row represents one completed banking transaction.»

Service Performance

«One row represents one service-trip-stop event.»

Customer Snapshot

«One row represents one customer at the end of one business day.»

Asset

«One row represents one physical asset at a point in its lifecycle.»

«If you cannot clearly describe the grain, STOP modelling.»

---

## 9. Phase 7 — Identify Facts and Dimensions

Facts

Ask:

«"What happened?"»

Examples:

- Transaction
- Sale
- Payment
- Journey
- Trip
- Crash
- Maintenance event
- Service event

Dimensions

Ask:

«"Who / what / where / when?"»

Examples:

- Customer
- Product
- Account
- Route
- Vehicle
- Location
- Date
- Time
- Operator

Basic Pattern

             DIM_DATE
                 |
DIM_CUSTOMER -- FACT_TRANSACTION -- DIM_PRODUCT
                 |
             DIM_ACCOUNT
                 |
             DIM_LOCATION

---

## 10. Phase 8 — Choose the Modelling Pattern

Don't ask:

«"Should we use Data Vault or Kimball?"»

Ask:

«"What problem does each model need to solve?"»

Bronze

Purpose:

Source preservation

SOURCE → BRONZE

Characteristics:

- Source-aligned
- Raw/minimally transformed
- Replayable
- Auditable
- Preserves source context

---

Silver

Purpose:

Integration and standardisation

BRONZE → SILVER

Possible patterns:

- Canonical model
- Data Vault
- 3NF
- Normalised integration
- Domain model

---

Gold

Purpose:

Business consumption

SILVER → GOLD

Typical patterns:

- Star schema
- Dimensional model
- Aggregates
- Data marts
- Domain data products

---

Semantic Layer

Purpose:

Consistent business meaning

GOLD
 |
SEMANTIC MODEL
 |
CERTIFIED KPIs

---

## 11. Data Vault vs Dimensional — Quick Decision

Requirement| Better Fit
Preserve source history| Data Vault
Auditability| Data Vault
Multiple sources| Data Vault
Rapid source integration| Data Vault
BI reporting| Dimensional
Power BI| Dimensional/Semantic
Business-friendly model| Dimensional
Complex historical integration| Data Vault
ML feature datasets| Purpose-built analytical model
Operational application| Normalised model

A mature architecture may use:

SOURCE
  ↓
BRONZE
  ↓
DATA VAULT / INTEGRATION
  ↓
DIMENSIONAL DATA PRODUCTS
  ↓
SEMANTIC
  ↓
BI / ML / AI

---

## 12. Phase 9 — Determine Latency

Ask:

«"How quickly does the business need the data?"»

Latency| Typical Use Cases
Real-time| Fraud, vehicle location, operational alerts
Near-real-time| Service performance, customer alerts
Intraday| Operational planning
Daily| Executive reporting, finance
Weekly| Forecasting, strategic planning
Monthly| Strategic/regulatory analysis

«Never implement streaming just because streaming is available.»

---

## 13. Phase 10 — Batch vs Streaming

Batch

Use when:

- [ ] Data changes slowly
- [ ] Daily reporting is adequate
- [ ] Processing can be scheduled
- [ ] Simplicity is more important

Streaming

Use when:

- [ ] Decisions must happen quickly
- [ ] Events are continuous
- [ ] Current state matters
- [ ] Customer/operational experience depends on latency

Does latency affect a decision?
          |
        YES
          ↓
      Streaming

          |
         NO
          ↓
        Batch

---

## 14. Phase 11 — Data Pipeline Design

For every pipeline document:

SOURCE
  ↓
INGEST
  ↓
VALIDATE
  ↓
BRONZE
  ↓
TRANSFORM
  ↓
SILVER
  ↓
BUSINESS RULES
  ↓
GOLD
  ↓
SEMANTIC
  ↓
CONSUMPTION

Checklist:

- [ ] Ingestion method
- [ ] Full vs incremental
- [ ] CDC?
- [ ] API?
- [ ] Streaming?
- [ ] File?
- [ ] Error handling
- [ ] Retry
- [ ] Dead-letter handling
- [ ] Deduplication
- [ ] Schema evolution
- [ ] Data validation
- [ ] Monitoring
- [ ] Alerting
- [ ] Reprocessing
- [ ] Backfill
- [ ] Recovery
- [ ] **Testing:**  *(added)*
    - [ ] Data contract testing (source vs ingestion)
    - [ ] Reconciliation testing (source vs target row counts)
    - [ ] Regression testing (when pipelines change)
    - [ ] Acceptance testing (business user validation)

---

## 15. Phase 12 — Incremental Load Checklist

Ask:

- [ ] What identifies a new record?
- [ ] What identifies a changed record?
- [ ] Is there an "updated_timestamp"?
- [ ] Is CDC available?
- [ ] Are deletes captured?
- [ ] Are records corrected?
- [ ] Can data arrive late?
- [ ] Can records arrive out of order?
- [ ] Can the same event arrive twice?
- [ ] How do we replay?

Common patterns:

High-water mark
CDC
Change timestamp
Event ID
Version number
Sequence number
Snapshot comparison

---

## 16. Phase 13 — Historical Data

Ask:

- [ ] How much history?
- [ ] Is history available?
- [ ] Does the source overwrite history?
- [ ] Do we need to reconstruct previous states?
- [ ] Do dimensions change?
- [ ] Do business definitions change?
- [ ] Do network structures change?

Slowly Changing Dimensions

Type 1

Overwrite.

Sydney → Melbourne

History lost.

Type 2

Create a new version.

Customer
Version 1 → Sydney
Version 2 → Melbourne

History preserved.

«Type 2 is frequently important when historical reporting must reflect the state at the time of the event.»

---

## 17. Phase 14 — Data Quality Checklist

Always consider:

Completeness

- [ ] Are required records present?

Accuracy

- [ ] Does the data represent reality?

Validity

- [ ] Are values valid?

Consistency

- [ ] Do systems agree?

Uniqueness

- [ ] Are there duplicates?

Timeliness

- [ ] Is data arriving when expected?

Integrity

- [ ] Do relationships work?

Spatial Quality

Important for geospatial/transport projects:

- [ ] Valid coordinates
- [ ] Correct CRS
- [ ] Valid geometry
- [ ] Network relationships

---

## 18. Data Quality Questions

Ask the source owner:

«"What does bad data look like?"»

Then:

«"How frequently does it occur?"»

Then:

«"What should we do when it occurs?"»

Possible actions:

REJECT
   |
QUARANTINE
   |
CORRECT
   |
IMPUTE
   |
ACCEPT WITH WARNING
   |
PUBLISH

«Never silently fix data.»

---

## 19. Phase 15 — Master Data / Reference Data

Identify:

- [ ] Customer
- [ ] Product
- [ ] Organisation
- [ ] Location
- [ ] Geography
- [ ] Calendar
- [ ] Currency
- [ ] Codes
- [ ] Statuses
- [ ] Operators
- [ ] Assets

Ask:

«"Which system is authoritative?"»

Then:

«"What happens when two systems disagree?"»

---

## 20. Phase 16 — Metadata & Lineage

Every important dataset should answer:

WHERE DID IT COME FROM?
        ↓
WHAT HAPPENED TO IT?
        ↓
WHO OWNS IT?
        ↓
WHAT DOES IT MEAN?
        ↓
WHO CAN USE IT?
        ↓
WHERE IS IT USED?

Checklist:

- [ ] Business definition
- [ ] Technical definition
- [ ] Owner
- [ ] Steward
- [ ] Source
- [ ] Transformation
- [ ] Lineage
- [ ] Classification
- [ ] Retention
- [ ] Quality score
- [ ] SLA
- [ ] Consumer

---

## 21. Phase 17 — Semantic Layer

Create:

BUSINESS TERM
      ↓
BUSINESS DEFINITION
      ↓
DATA ELEMENTS
      ↓
CALCULATION
      ↓
CERTIFIED KPI

Example:

On-time performance

Define:

- Numerator
- Denominator
- Eligibility
- Exclusions
- Time period
- Aggregation
- Source
- Owner

«Don't allow five dashboards to independently calculate the same KPI.»

---

## 22. KPI Checklist

For every KPI:

- [ ] Name
- [ ] Definition
- [ ] Business owner
- [ ] Formula
- [ ] Numerator
- [ ] Denominator
- [ ] Grain
- [ ] Dimensions
- [ ] Filters
- [ ] Exclusions
- [ ] Source
- [ ] Refresh frequency
- [ ] Target
- [ ] Threshold
- [ ] Historical behaviour

---

## 23. Phase 18 — Security

Who can access?

- [ ] Everyone
- [ ] Business unit
- [ ] Region
- [ ] Role
- [ ] Individual

What can they access?

- [ ] Database
- [ ] Table
- [ ] Row
- [ ] Column
- [ ] Report
- [ ] API
- [ ] AI/RAG content

Controls

- [ ] Authentication
- [ ] Authorisation
- [ ] RBAC
- [ ] ABAC
- [ ] Row-level security
- [ ] Column-level security
- [ ] Masking
- [ ] Encryption
- [ ] Audit
- [ ] Secrets management

---

## 24. Phase 19 — Privacy

Ask:

«"Can this dataset identify a person directly or indirectly?"»

Consider:

- [ ] Name
- [ ] Email
- [ ] Phone
- [ ] Customer ID
- [ ] Location
- [ ] Travel patterns
- [ ] Transaction history
- [ ] Device identifiers
- [ ] IP address
- [ ] Behaviour

Then:

COLLECT
   ↓
MINIMISE
   ↓
CLASSIFY
   ↓
PROTECT
   ↓
CONTROL ACCESS
   ↓
RETENTION
   ↓
DELETE / ARCHIVE

**Retention & Lifecycle:**  *(added)*
- [ ] Data retention periods (operational, legal, regulatory)
- [ ] Deletion and anonymisation processes
- [ ] Archival strategies
- [ ] Data purging policies

---

## 25. Phase 20 — Analytics Consumption

Identify every consumer:

                 DATA PRODUCTS
                      |
       +--------------+--------------+
       |              |              |
      BI             ML             AI
       |              |              |
   Dashboard      Prediction       RAG
       |              |              |
   Executives     Data Scientists   Users

Also consider:

- [ ] APIs
- [ ] Operational applications
- [ ] Data extracts
- [ ] External data sharing
- [ ] Regulatory reporting
- [ ] Research
- [ ] Data science notebooks

---

## 26. ML Architecture Checklist

If ML is involved:

- [ ] Business problem
- [ ] Target variable
- [ ] Features
- [ ] Training data
- [ ] Validation data
- [ ] Test data
- [ ] Feature engineering
- [ ] Feature store if required
- [ ] Model registry
- [ ] Model deployment
- [ ] Monitoring
- [ ] Drift detection
- [ ] Retraining
- [ ] Explainability
- [ ] Bias/fairness
- [ ] Security
- [ ] Model retirement

---

## 27. AI / GenAI Architecture Checklist

What is AI actually doing?

- [ ] Summarisation
- [ ] Search
- [ ] Classification
- [ ] Prediction
- [ ] Question answering
- [ ] Recommendation
- [ ] Agentic workflow

RAG

DOCUMENTS
    ↓
CHUNK
    ↓
EMBED
    ↓
VECTOR STORE
    ↓
RETRIEVAL
    ↓
RERANK
    ↓
LLM
    ↓
ANSWER + EVIDENCE

Check:

- [ ] Document authority
- [ ] Metadata
- [ ] Versioning
- [ ] Access control
- [ ] Chunking
- [ ] Retrieval quality
- [ ] Hallucination
- [ ] Prompt injection
- [ ] PII leakage
- [ ] Audit
- [ ] Evaluation

**Additional AI considerations:**  *(added)*
- [ ] Retrieval evaluation metrics (precision, recall, MRR)
- [ ] Document freshness and update mechanisms
- [ ] Feedback loops for continuous improvement
- [ ] Cost monitoring for LLM calls

---

## 28. Phase 21 — Platform Selection

Only select technology after requirements are understood.

Storage

- Lake
- Lakehouse
- Warehouse
- Database

Processing

- SQL
- Spark
- Python
- Streaming

Orchestration

- Workflow
- Data pipelines
- Event-driven

BI

- Power BI
- Tableau
- Other

ML

- ML platform
- Notebooks
- Model registry

AI

- LLM
- RAG
- Vector database
- Agent platform

---

## 29. Technology Decision Matrix

Score platforms against:

Capability| Weight
Business requirements| 20%
Data volume| 10%
Performance| 10%
Real-time| 10%
Security| 10%
Governance| 10%
Integration| 10%
Skills| 5%
Cost| 10%
Vendor strategy| 5%

«Don't let technology drive architecture.»

---

## 30. Phase 22 — Non-Functional Requirements

Always capture:

Performance

- [ ] Query response
- [ ] Dashboard response
- [ ] Pipeline processing

Scalability

- [ ] Data volume
- [ ] Users
- [ ] Concurrent workloads
- [ ] Growth

Availability

- [ ] SLA
- [ ] RTO
- [ ] RPO

Security

- [ ] Access
- [ ] Encryption
- [ ] Audit

Reliability

- [ ] Retry
- [ ] Recovery
- [ ] Replay

Cost  *(expanded)*
- [ ] Storage (hot/cold/archive tiering)
- [ ] Compute (partitioning, clustering, data skipping for optimisation)
- [ ] Streaming
- [ ] AI
- [ ] Data transfer
- [ ] Query cost visibility for end users
- [ ] Cost allocation by team/data product

---

## 31. Phase 23 — Architecture Decision Records

For every significant decision, record:

ADR
 |
 +-- Problem
 |
 +-- Options
 |
 +-- Decision
 |
 +-- Why
 |
 +-- Trade-offs
 |
 +-- Consequences
 |
 +-- Alternatives rejected

Typical ADRs:

- Lakehouse vs warehouse
- Batch vs streaming
- Data Vault vs 3NF
- Star schema vs wide table
- CDC vs batch
- Event bus selection
- Semantic model
- RAG architecture
- Data product boundaries
- Cloud architecture

---

## 32. The One-Page Architecture Diagram

A good Analytics Architect should be able to explain the whole solution on one page.

                     BUSINESS USERS
                           |
                 BI / AI / ML / APIs
                           |
                     SEMANTIC LAYER
                           |
                    DATA PRODUCTS
                           |
        +------------------+------------------+
        |                  |                  |
      GOLD              GOLD              GOLD
   Customer          Operations         Finance
        |                  |                  |
        +------------------+------------------+
                           |
                      SILVER
                Integration / History
                           |
                      BRONZE
                  Source Preservation
                           |
       +-------------------+-------------------+
       |          |          |         |        |
      DB        API        FILE      CDC     EVENTS
       |          |          |         |        |
       +----------+----------+---------+--------+
                           |
                     SOURCE SYSTEMS


   GOVERNANCE | SECURITY | PRIVACY | QUALITY
   METADATA | LINEAGE | MONITORING | COST

---

## 33. Architecture Review Checklist

Business

- [ ] Does it solve the actual business problem?
- [ ] Are outcomes measurable?
- [ ] Are stakeholders identified?

Data

- [ ] Are sources identified?
- [ ] Is grain defined?
- [ ] Are entities defined?
- [ ] Are relationships understood?
- [ ] Is history understood?

Integration

- [ ] Batch/stream decision justified?
- [ ] CDC considered?
- [ ] Error handling?
- [ ] Replay?
- [ ] Backfill?
- [ ] Schema evolution?

Modelling

- [ ] Conceptual model?
- [ ] Logical model?
- [ ] Physical model?
- [ ] Fact grain?
- [ ] Dimensions?
- [ ] History?
- [ ] Reference data?
- [ ] Semantic model?

Analytics

- [ ] Gold data products?
- [ ] Semantic model?
- [ ] KPI definitions?
- [ ] BI requirements?
- [ ] ML requirements?
- [ ] AI requirements?

Governance

- [ ] Data owner?
- [ ] Steward?
- [ ] Catalogue?
- [ ] Lineage?
- [ ] Quality?

---

## 34. Phase 24 — People & Organisational Enablement  *(added)*

- [ ] Training and enablement plan for users and operators
- [ ] Change management approach for new analytics capabilities
- [ ] Communication plan for updates, outages, and new features
- [ ] Community of practice / knowledge sharing sessions
- [ ] Support model (who to contact for issues)
- [ ] Feedback collection mechanism from stakeholders

---

*End of checklist.*
