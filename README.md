# sample_data_models

Reference data models for NSW public transport — **Transport for NSW (TfNSW)** —
designed as a **Gold / Medallion layer**.

> Start here → **[`gold/README.md`](gold/README.md)** (cross-model design index)

---

## Contents

| Path | Description |
|---|---|
| **`gold/README.md`** | **Entry point** — cross-model index linking all three design write-ups, the shared conformed dimensions, and how the models join |
| `gold/RESEARCH.md` | Deep research: TfNSW organisation, entities, business processes, medallion mapping |
| `gold/Dimensional_Model_Design.md` | 4-step Kimball write-up — **Model 01** Customer Patronage & Journey |
| `gold/Dimensional_Model_Design_02_Network.md` | 4-step Kimball write-up — **Model 02** Network & Service Performance |
| `gold/Dimensional_Model_Design_03_Asset.md` | 4-step Kimball write-up — **Model 03** Asset Register & Predictive Maintenance |
| `gold/01_customer_patronage.sql` + `_erd.mmd` | **Model 01** — Customer patronage & journey (Kimball star) |
| `gold/02_network_service_performance.sql` + `_erd.mmd` | **Model 02** — Network & on-time performance (GTFS-inspired) |
| `gold/03_asset_maintenance.sql` + `_erd.mmd` | **Model 03** — Asset register & predictive maintenance (3NF backbone) |
| `gold/data_dictionary.md` | Table / column / key / SCD / business-rule reference for all three models |
|| `gold/docs/*.png` | Rendered PNG previews of the ERDs and the cross-model flow diagram ||
|| `verify_models.py` | Verification harness — transpiles DDL to SQLite and checks parse + FK integrity ||
|| `bronze/` | **Data Vault 2.0 Raw Vault** — Bronze layer with 41 tables: 13 hubs, 15 links, 14 satellites, 6 link-satellites, 3 reference tables; DDL, conceptual model, data dictionary, and ERD ||

All DDL is **Databricks Delta / Snowflake** dialect. Run the verifier from the
repo root:

```bash
python verify_models.py
```

> © State of NSW (Transport for NSW) 2022 — Transport Data Strategy 2022–2025
> (CC BY 4.0) informed the domain research; the models themselves are original designs.