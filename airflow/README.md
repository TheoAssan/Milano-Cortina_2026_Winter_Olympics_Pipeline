Airflow & DLT Pipeline Setup

## Quick Start

Initialize Airflow directories and environment:

```bash
mkdir -p ./dags ./logs ./plugins ./config
echo -e "AIRFLOW_UID=$(id -u)" > .env
```

## Overview

This Airflow setup includes a **DLT-powered pipeline** that automatically:
- ✅ Downloads Olympic Games data from Kaggle
- ✅ Extracts and processes the data
- ✅ Loads it directly to your GCS bucket using DLT
- ✅ Verifies the upload was successful

**No additional authentication needed** — just trigger the DAG from the Airflow UI!

## Prerequisites

1. ✅ **GCS Bucket** created via Terraform (already done: `zc-olympicsdatalake-26`)
2. ✅ **GCP Service Account Credentials** in `terraform/keys.json` (already in place)
3. ✅ **Docker & Docker Compose** installed on your system

## Building & Running the Pipeline

### 1. Build the Docker Image

```bash
cd /workspaces/zoomcamp-pipeline/airflow
docker-compose build
```

This installs all required dependencies including:
- Apache Airflow with Google Cloud providers
- DLT with GCS destination support
- Google Cloud Storage and BigQuery clients

### 2. Start Airflow Services

```bash
docker-compose up -d
```

Wait for services to be healthy (30-60 seconds):
```bash
docker-compose ps
```

### 3. Access the Airflow UI

- **URL:** http://localhost:8080
- **Username:** airflow
- **Password:** airflow

### 4. Trigger the DAG

1. Open the Airflow UI
2. Find the DAG: `olympics_kaggle_gcs_dlt_pipeline`
3. Click the play button (►) to trigger
4. Monitor progress in real-time

## How It Works

### DAG: `olympics_kaggle_gcs_dlt_pipeline`

The pipeline consists of 5 tasks:

```
setup_gcp_credentials 
    ↓
download_kaggle_data (downloads ~1-2 GB)
    ↓
extract_and_prepare_data (unzips and catalogs CSVs)
    ↓
load_to_gcs (DLT loads to GCS)
    ↓
verify_gcs_upload (confirms success)
```

### Configuration Details

**GCS Bucket:** `zc-olympicsdatalake-26`
**Data Path:** `gs://zc-olympicsdatalake-26/olympics_data/`
**GCP Project:** `de-zoomcamp26-487314`
**Dataset Name:** `olympics_raw_data`

### Credentials Management

- GCP credentials are automatically mounted from `terraform/keys.json`
- The `GOOGLE_APPLICATION_CREDENTIALS` environment variable is set in the container
- DLT uses these credentials to write directly to GCS
- **No manual authentication steps needed!**

## Troubleshooting

### DAG Not Appearing?
```bash
docker-compose down -v  # Clean up
docker-compose build   # Rebuild
docker-compose up -d   # Start fresh
```

### Check Logs
```bash
# View all logs
docker-compose logs -f airflow-scheduler

# Specific task logs
docker logs <task-id>
```

### Verify GCS Credentials
```bash
docker-compose exec airflow-scheduler \
  python -c "import google.cloud.storage; \
  c = google.cloud.storage.Client(); \
  print('✓ GCS Auth OK')"
```

## File Structure

```
airflow/
├── dags/
│   └── load_to_gcs.py          # Main DLT pipeline DAG
├── docker-compose.yaml          # Docker setup with GCS credentials
├── dockerfile                   # Custom image with DLT
├── requirements.txt             # Python dependencies (includes dlt[gcs])
└── README.md                    # This file
```

## What Gets Uploaded to GCS

The pipeline uploads all CSV files from the Olympic dataset as:
- **Format:** Parquet files (optimized for analytics)
- **Location:** `gs://zc-olympicsdatalake-26/olympics_data/`
- **Tables:** Each CSV becomes a separate table/file

Example structure:
```
gs://zc-olympicsdatalake-26/olympics_data/
├── medals.parquet
├── venues.parquet
├── events.parquet
└── ... (other tables)
```

## Next Steps

After data is loaded:
1. Query the data with BigQuery
2. Create analytics dashboards
3. Schedule the DAG to run on a schedule (update `schedule_interval`)

---

**Note:** For production deployments, consider:
- Using more secure credential management (Google Secret Manager)
- Setting up proper Airflow authentication
- Scaling with Celery workers
- Adding data validation checks
