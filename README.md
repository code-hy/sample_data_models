# sample_data_models

Reference data models for NSW public transport (Transport for NSW / Dream Brooklyn demo).

## Contents

| Path | Description |
|---|---|
| `gold/` | **Gold / Medallion layer** sample data models for TfNSW |
| `gold/README.md` | Research: organisation, entities, relationships, medallion mapping |
| `gold/01_customer_patronage.sql` | **Model 01** — Customer patronage & journey (Kimball star) |
| `gold/02_network_service_performance.sql` | **Model 02** — Network & on-time performance (GTFS-inspired) |
| `gold/03_asset_maintenance.sql` | **Model 03** — Asset register & predictive maintenance (3NF backbone) |
| `gold/*_erd.mmd` | Mermaid ERDs per model |
| `gold/data_dictionary.md` | Table / column / key / SCD / business-rule reference |
| `verify_models.py` | Verification harness — transpiles DDL to SQLite and checks parse + FK integrity |

All DDL is **Databricks Delta / Snowflake** dialect. Run the verifier from the repo root:

```bash
python verify_models.py
```

> © State of NSW (Transport for NSW) 2022 — Transport Data Strategy 2022–2025 (CC BY 4.0) informed the domain research; the models themselves are original designs.