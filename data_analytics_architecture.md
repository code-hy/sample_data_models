# Data Analytics Architect Checklist

---

## Project Information

| Field | Value |
|-------|-------|
| **Project** | |
| **Date** | |
| **Version** | |
| **Owner** | |
| **Reviewer** | |

---

## 1. Data Strategy & Governance

- [ ] Define business objectives and KPIs for analytics initiatives
- [ ] Establish data governance framework (ownership, policies, standards)
- [ ] Define data quality metrics and monitoring processes
- [ ] Create data catalog and metadata management strategy
- [ ] Ensure regulatory compliance (GDPR, CCPA, HIPAA, SOC2, etc.)
- [ ] Establish data retention and archival policies

---

## 2. Data Ingestion & Integration

- [ ] Identify data sources (databases, APIs, files, streaming, SaaS)
- [ ] Choose ingestion pattern: batch, streaming, or hybrid
- [ ] Design CDC (Change Data Capture) mechanisms
- [ ] Implement data validation at ingestion
- [ ] Plan for schema evolution and backward compatibility
- [ ] Set up data lineage tracking

---

## 3. Data Storage Architecture

- [ ] Select storage layer: Data Lake, Data Warehouse, or Lakehouse
- [ ] Design bronze (raw), silver (cleansed), gold (analytics-ready) zones
- [ ] Choose file formats (Parquet, Delta Lake, Iceberg, ORC)
- [ ] Plan partitioning strategy for query performance
- [ ] Implement compression and cost optimization
- [ ] Design hot/warm/cold storage tiers

---

## 4. Data Processing & Transformation

- [ ] Select processing framework (Spark, dbt, Flink, etc.)
- [ ] Design ETL/ELT pipelines with idempotency
- [ ] Implement data quality checks (Great Expectations, Soda, etc.)
- [ ] Plan for incremental vs. full refresh strategies
- [ ] Design slowly changing dimensions (SCD Type 1, 2, 3)
- [ ] Set up pipeline orchestration (Airflow, Dagster, Prefect)

---

## 5. Data Modeling

- [ ] Choose modeling approach: Kimball, Data Vault, or One Big Table
- [ ] Design dimensional models (facts, dimensions, conformed dimensions)
- [ ] Create surrogate key strategies
- [ ] Define grain for each fact table
- [ ] Plan for late-arriving data and out-of-order events
- [ ] Document entity relationships and business rules

---

## 6. Analytics & BI Layer

- [ ] Select BI tools (Tableau, Power BI, Looker, etc.)
- [ ] Design semantic layer / metrics store
- [ ] Plan for self-service analytics enablement
- [ ] Implement row/column-level security
- [ ] Design caching and query acceleration strategies
- [ ] Set up usage monitoring and query optimization

---

## 7. Advanced Analytics & ML

- [ ] Design feature store architecture
- [ ] Plan ML experiment tracking (MLflow, Weights & Biases)
- [ ] Design model serving infrastructure
- [ ] Implement A/B testing framework
- [ ] Plan for model monitoring and drift detection
- [ ] Ensure reproducibility of ML pipelines

---

## 8. Security & Access Control

- [ ] Implement authentication (SSO, MFA)
- [ ] Design RBAC/ABAC authorization model
- [ ] Enable encryption at rest and in transit
- [ ] Implement network segmentation and private endpoints
- [ ] Set up audit logging and access monitoring
- [ ] Design data masking and tokenization for PII

---

## 9. Scalability & Performance

- [ ] Design for horizontal scaling
- [ ] Plan auto-scaling policies
- [ ] Implement workload isolation (dedicated pools, queues)
- [ ] Design for multi-region or hybrid deployments
- [ ] Plan disaster recovery and backup strategies
- [ ] Set up performance benchmarking and SLAs

---

## 10. Observability & Operations

- [ ] Implement centralized logging
- [ ] Set up monitoring and alerting (freshness, volume, schema)
- [ ] Design incident response runbooks
- [ ] Plan for data pipeline testing (unit, integration, end-to-end)
- [ ] Implement CI/CD for data pipelines (DataOps)
- [ ] Create cost monitoring and chargeback mechanisms

---

## 11. Cloud & Infrastructure

- [ ] Choose cloud provider(s) and multi-cloud strategy
- [ ] Design landing zone architecture
- [ ] Implement infrastructure as code (Terraform, CloudFormation)
- [ ] Plan for containerization (Kubernetes, serverless)
- [ ] Design network topology (VPCs, subnets, peering)
- [ ] Optimize for cloud cost management

---

## 12. Stakeholder Management

- [ ] Document architecture decisions (ADRs)
- [ ] Create data dictionaries and business glossaries
- [ ] Establish SLA/SLO agreements with consumers
- [ ] Plan for training and enablement
- [ ] Design feedback loops for continuous improvement

---

## Architecture Patterns Quick Reference

| Pattern | Description |
|---------|-------------|
| **Lambda** | Batch + speed layer for real-time |
| **Kappa** | Pure streaming processing |
| **Lakehouse** | Unified batch/streaming with ACID |
| **Medallion** | Bronze → Silver → Gold quality progression |
| **Data Mesh** | Domain-oriented decentralized ownership |

---

## Tech Stack Quick Reference

| Layer | Options |
|-------|---------|
| **Ingestion** | Fivetran, Airbyte, Kafka, Kinesis |
| **Storage** | S3, ADLS, GCS, Snowflake, BigQuery, Databricks |
| **Processing** | Spark, dbt, Flink, Trino |
| **Orchestration** | Airflow, Dagster, Prefect, dbt Cloud |
| **BI** | Tableau, Power BI, Looker, Metabase |
| **ML** | SageMaker, Vertex AI, Azure ML, Databricks ML |

---

## Progress Tracker

| Section | Items | Completed | % Done |
|---------|-------|-----------|--------|
| 1. Data Strategy & Governance | 6 | | |
| 2. Data Ingestion & Integration | 6 | | |
| 3. Data Storage Architecture | 6 | | |
| 4. Data Processing & Transformation | 6 | | |
| 5. Data Modeling | 6 | | |
| 6. Analytics & BI Layer | 6 | | |
| 7. Advanced Analytics & ML | 6 | | |
| 8. Security & Access Control | 6 | | |
| 9. Scalability & Performance | 6 | | |
| 10. Observability & Operations | 6 | | |
| 11. Cloud & Infrastructure | 6 | | |
| 12. Stakeholder Management | 5 | | |
| **TOTAL** | **71** | | |

---

*Last updated: [Date]*
