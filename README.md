# 🏔️ Milano-Cortina 2026 Winter Olympics — Data Pipeline

An end-to-end data engineering pipeline that ingests, transforms, and models the Milano-Cortina 2026 Winter Olympics dataset for analytics.

## Architecture

```
Kaggle Dataset (CSV)
        │
        ▼
┌──────────────────┐       ┌──────────────────┐
│   Airflow DAG 1  │       │   Airflow DAG 2  │
│   load_to_gcs    │──────▶│  gcs_to_bigquery │
│  (CSV → Parquet) │       │ (Parquet → BQ)   │
└──────────────────┘       └──────────────────┘
        │                          │
        ▼                          ▼
   Google Cloud               BigQuery
   Storage (GCS)             (Raw Tables)
                                   │
                                   ▼
                          ┌─────────────────┐
                          │    dbt Cloud     │
                          │ (Staging → Marts)│
                          └─────────────────┘
                                   │
                                   ▼
                             Star Schema
                          (dims + facts in BQ)
```

## Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Infrastructure** | Terraform | Provisions GCS bucket and BigQuery dataset on GCP |
| **Orchestration** | Apache Airflow (Docker) | Runs data ingestion DAGs |
| **Data Lake** | Google Cloud Storage | Stores raw Parquet files |
| **Data Warehouse** | BigQuery | Hosts raw + transformed tables |
| **Transformation** | dbt Cloud | Builds staging and mart models (star schema) |

## Project Structure

```
├── terraform/                  # GCP infrastructure as code
│   ├── main.tf                 # GCS bucket + BigQuery dataset
│   ├── variables.tf            # Configurable project variables
│   ├── outputs.tf              # Exports values for downstream tools
│   ├── generate_env.sh         # Generates airflow/.env from outputs
│   └── README.MD               # GCP setup + Terraform guide
│
├── airflow/                    # Data ingestion pipeline
│   ├── dags/
│   │   ├── load_to_gcs.py      # DAG 1: Kaggle → Parquet → GCS
│   │   └── gcs_to_bq.py        # DAG 2: GCS Parquet → BigQuery
│   ├── docker-compose.yaml     # Airflow services (LocalExecutor)
│   ├── dockerfile              # Custom image with dependencies
│   ├── requirements.txt        # Pinned Python dependencies
│   └── README.md               # Airflow setup guide
│
├── dbt/                        # Data transformation (dbt Cloud)
│   ├── models/
│   │   ├── staging/            # Clean + type-cast raw tables
│   │   └── marts/core/         # Star schema (dims + facts)
│   ├── seeds/
│   │   └── ioc_codes.csv       # IOC country code lookup
│   ├── dbt_project.yml         # Project config
│   └── README.md               # dbt Cloud setup guide
│
├── Makefile                    # Pipeline execution commands
└── README.md                   # This file
```

## Prerequisites

- **GCP Account** with a project and service account ([setup guide](terraform/README.MD)) | *[ Video Tutorial (Watch first 7 mins only)](https://www.youtube.com/watch?v=Y2ux7gq3Z0o&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=6)*
- **Docker & Docker Compose** for running Airflow
- **Terraform** CLI ([install instructions](terraform/README.MD#-prerequisites))
- **dbt Cloud** account at [cloud.getdbt.com](https://cloud.getdbt.com) | *[📺 Video Tutorial](https://www.youtube.com/watch?v=J0XCDyKiU64&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=32)*

## Quick Start

### 1. Provision Infrastructure (Terraform) ([Configuration](terraform/README.MD#-ConfigureProjectVariables))

> **📺 Video Tutorial:** [GCP Account Setup (Watch first 7 mins only)](https://www.youtube.com/watch?v=Y2ux7gq3Z0o&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=6)

```bash
cd terraform
# Place your GCP service account key as keys.json
# Update project_id in variables.tf with your GCP project ID
terraform init
terraform apply
```

> **Note:** See the [Terraform Setup Guide](terraform/README.MD) for more detailed instructions.

### 2. Generate Environment File

```bash
bash generate_env.sh
# This writes airflow/.env with your GCP config values
```

### 3. Start Airflow & Run DAGs

```bash
cd ../airflow
docker-compose build
docker-compose up -d
```

Open **http://localhost:8080** (login: `airflow` / `airflow`) and trigger the DAGs in order:

1. **`load_to_gcs`** — Downloads the Kaggle dataset, converts CSVs to Parquet, uploads to GCS
2. **`gcs_to_bigquery`** — Loads Parquet files from GCS into BigQuery tables

> **Note:** See the [Airflow Setup Guide](airflow/README.md) for more detailed instructions.

### 4. Transform Data (dbt Cloud)

> **📺 Video Tutorial:** [dbt Cloud Setup Guide](https://www.youtube.com/watch?v=J0XCDyKiU64&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=32)

1. Connect your dbt Cloud project to this repository
2. Set up the BigQuery connection with your service account key
3. Set the `gcp_project_id` variable in your dbt Cloud environment
4. Run:
   ```
   dbt deps → dbt seed → dbt run → dbt test
   ```

See [dbt/README.md](dbt/README.md) for detailed setup instructions.

## Makefile Commands

Run `make help` to see all available commands:

```
  terraform-init      Initialize Terraform providers
  terraform-plan      Preview infrastructure changes
  terraform-apply     Create GCS bucket and BigQuery dataset on GCP
  terraform-destroy   Tear down all GCP resources
  generate-env        Generate airflow/.env from Terraform outputs
  airflow-build       Build the custom Airflow Docker image
  airflow-up          Start all Airflow services (detached)
  airflow-down        Stop all Airflow services
  airflow-reset       Full reset — stop, remove volumes, rebuild, start
  airflow-logs        Tail scheduler logs
```

## Data Model

The dbt layer transforms raw BigQuery tables into a star schema:

**Dimensions:** `dim_athletes`, `dim_countries`, `dim_discipline`, `dim_events`

**Facts:** `fact_athlete_perf`, `fact_country_perf`, `fact_discipline`

See [dbt/README.md](dbt/README.md) for full model documentation.
