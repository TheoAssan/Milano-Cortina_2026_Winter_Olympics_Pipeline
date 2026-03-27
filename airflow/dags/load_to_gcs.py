"""
DAG — Milano Cortina 2026 Olympics Data → GCS
=============================================
Downloads the Milano Cortina 2026 Olympic Winter Games dataset as a ZIP
from the Kaggle public API, extracts every CSV inside, and uploads each
raw CSV file as-is to GCS (no format conversion).

Trigger from the Airflow UI — no extra authentication required.
GCP credentials are picked up automatically from the mounted keys.json.
"""

from __future__ import annotations

import io
import json
import logging
import os
import tempfile
import zipfile
from datetime import datetime

import requests
from airflow.decorators import dag, task

log = logging.getLogger(__name__)

# ── Configuration ──────────────────────────────────────────────────────────────
GCS_BUCKET      = "zc-olympicsdatalake-26"
GCP_PROJECT     = "de-zoomcamp26-487314"
DESTINATION_PATH = "olympics_data"    # folder prefix inside the bucket

# Milano Cortina 2026 Olympic Winter Games dataset (ZIP download, no auth needed)
DATA_URL = (
    "https://www.kaggle.com/api/v1/datasets/download/"
    "piterfm/milano-cortina-2026-olympic-winter-games"
)

CREDENTIALS_PATH = "/opt/airflow/terraform/keys.json"

# ── DAG ────────────────────────────────────────────────────────────────────────
default_args = {
    "owner": "airflow",
    "retries": 0,
}


@dag(
    dag_id="olympics_dlt_gcs_pipeline",
    description="Load Milano Cortina 2026 Olympics data from Kaggle to GCS using dlt",
    schedule=None,           # manual trigger only
    start_date=datetime(2024, 1, 1),
    catchup=False,
    default_args=default_args,
    tags=["olympics", "dlt", "gcs", "milano-cortina"],
)
def olympics_dlt_gcs_pipeline():

    @task()
    def verify_credentials() -> str:
        """Confirm the service-account key file is mounted and readable."""
        creds_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS", CREDENTIALS_PATH)
        if not os.path.exists(creds_path):
            raise FileNotFoundError(
                f"GCP credentials not found at {creds_path}. "
                "Ensure keys.json is mounted correctly in docker-compose.yaml."
            )
        with open(creds_path) as f:
            info = json.load(f)
        log.info(
            "✓ Credentials OK  |  project=%s  |  account=%s",
            info.get("project_id"),
            info.get("client_email"),
        )
        return creds_path

    @task()
    def download_and_extract(creds_path: str) -> dict[str, str]:
        """
        Download the ZIP from Kaggle and extract all CSV files to a temp dir.
        Returns {table_name: local_csv_path} for every CSV found in the archive.
        """
        tmp_dir = tempfile.mkdtemp(prefix="milano_olympics_")
        log.info("Downloading dataset from %s …", DATA_URL)

        resp = requests.get(DATA_URL, timeout=300, stream=True)
        resp.raise_for_status()

        # Collect streamed bytes
        raw = io.BytesIO()
        total = 0
        for chunk in resp.iter_content(chunk_size=1024 * 256):
            raw.write(chunk)
            total += len(chunk)
        log.info("Download complete — %d bytes received", total)

        raw.seek(0)
        if not zipfile.is_zipfile(raw):
            raise ValueError(
                "Downloaded content is not a valid ZIP file. "
                f"First 200 bytes: {raw.read(200)}"
            )

        raw.seek(0)
        files: dict[str, str] = {}
        with zipfile.ZipFile(raw) as zf:
            csv_members = [m for m in zf.namelist() if m.lower().endswith(".csv")]
            log.info("ZIP contains %d CSV file(s): %s", len(csv_members), csv_members)

            for member in csv_members:
                # Derive a safe table name from the file's basename
                base = os.path.basename(member)
                table_name = os.path.splitext(base)[0].lower().replace(" ", "_").replace("-", "_")
                out_path = os.path.join(tmp_dir, base)
                with zf.open(member) as src, open(out_path, "wb") as dst:
                    dst.write(src.read())
                files[table_name] = out_path
                log.info("  Extracted '%s' → %s", member, out_path)

        if not files:
            raise RuntimeError(
                "No CSV files found inside the downloaded ZIP. "
                f"ZIP contents: {zipfile.ZipFile(io.BytesIO(raw.getvalue())).namelist()}"
            )

        log.info("Ready to load %d table(s): %s", len(files), list(files.keys()))
        return files

    @task()
    def load_to_gcs(file_map: dict[str, str], creds_path: str) -> list[str]:
        """
        Upload each extracted CSV file to GCS exactly as-is (no conversion).
        Returns a list of GCS blob names that were uploaded.
        """
        from google.cloud import storage

        os.environ.setdefault("GOOGLE_APPLICATION_CREDENTIALS", creds_path)

        client = storage.Client(project=GCP_PROJECT)
        bucket = client.bucket(GCS_BUCKET)

        uploaded: list[str] = []

        for table_name, csv_path in file_map.items():
            filename = os.path.basename(csv_path)          # e.g. medals.csv
            blob_name = f"{DESTINATION_PATH}/{filename}"   # olympics_data/medals.csv
            blob = bucket.blob(blob_name)

            log.info("Uploading %s → gs://%s/%s …", csv_path, GCS_BUCKET, blob_name)
            blob.upload_from_filename(csv_path, content_type="text/csv")
            log.info("  ✓ uploaded  (%d bytes)", blob.size or 0)
            uploaded.append(blob_name)

        log.info("✓ All files uploaded: %s", uploaded)
        return uploaded

    @task()
    def verify_upload(uploaded: list[str], creds_path: str) -> None:
        """List all objects under the destination prefix to confirm the upload."""
        from google.cloud import storage

        os.environ.setdefault("GOOGLE_APPLICATION_CREDENTIALS", creds_path)

        client = storage.Client(project=GCP_PROJECT)
        bucket = client.bucket(GCS_BUCKET)
        blobs = list(bucket.list_blobs(prefix=DESTINATION_PATH))

        log.info("Objects in gs://%s/%s:", GCS_BUCKET, DESTINATION_PATH)
        for blob in blobs:
            log.info("  gs://%s/%s  (%d bytes)", GCS_BUCKET, blob.name, blob.size)

        if not blobs:
            log.warning(
                "No objects found under gs://%s/%s — upload may have failed.",
                GCS_BUCKET, DESTINATION_PATH,
            )
        else:
            log.info(
                "✓ Verification complete — %d file(s) in GCS: %s",
                len(blobs), uploaded,
            )

    # ── Wire up ────────────────────────────────────────────────────────────────
    creds    = verify_credentials()
    files    = download_and_extract(creds)
    uploaded = load_to_gcs(files, creds)
    verify_upload(uploaded, creds)


olympics_dlt_gcs_pipeline()