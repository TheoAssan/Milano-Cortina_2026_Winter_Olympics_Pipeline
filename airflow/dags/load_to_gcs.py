
import io
import os
import tempfile
import zipfile
from datetime import datetime

import pandas as pd
import requests
from airflow.sdk import dag, task

GCS_BUCKET       = "zc-olympicsdatalake-26"
GCP_PROJECT      = "de-zoomcamp26-487314"
GCS_PREFIX       = "Milano-Cortina-2026"
DATA_URL         = (
    "https://www.kaggle.com/api/v1/datasets/download/"
    "piterfm/milano-cortina-2026-olympic-winter-games"
)
CREDENTIALS_PATH = "/opt/airflow/terraform/keys.json"


@dag(
    dag_id="load_to_gcs",
    description="Download Milano Cortina 2026 Olympics ZIP, convert to parquet, and upload to GCS",
    schedule=None,
    start_date=datetime(2026, 1, 1),
    catchup=False,
    tags=["olympics", "gcs"],
)
def load_to_gcs():

    @task()
    def download_and_transform():
        response = requests.get(DATA_URL)
        response.raise_for_status()

        tmp = tempfile.mkdtemp()

        with zipfile.ZipFile(io.BytesIO(response.content)) as zf:
            zf.extractall(tmp)

        files = {}
        for file in os.listdir(tmp):
            if not file.endswith(".csv"):
                continue
            df = pd.read_csv(os.path.join(tmp, file))
            parquet_name = file.replace(".csv", "_winter26.parquet")
            parquet_path = os.path.join(tmp, parquet_name)
            df.to_parquet(parquet_path, index=False, engine="pyarrow")
            files[parquet_name] = parquet_path
            print(f"✓ Ready: {parquet_name}")

        return files

    @task()
    def upload_to_gcs(files):
        from google.cloud import storage

        client = storage.Client(project=GCP_PROJECT)
        bucket = client.bucket(GCS_BUCKET)

        for parquet_name, parquet_path in files.items():
            blob_name = f"{GCS_PREFIX}/{parquet_name}"
            bucket.blob(blob_name).upload_from_filename(parquet_path, content_type="application/octet-stream")
            print(f"✓ gs://{GCS_BUCKET}/{blob_name}")

    files = download_and_transform()
    upload_to_gcs(files)


load_to_gcs()