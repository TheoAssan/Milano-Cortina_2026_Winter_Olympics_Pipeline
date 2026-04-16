# ☁️ Google Cloud Setup Guide

This project uses **Google Cloud Platform (GCP)** for cloud storage and infrastructure provisioning (via Terraform).

Before running any Terraform configurations, ensure you have a GCP account and a properly configured service account.  

👉 Get started here: [Google Cloud Console](https://console.cloud.google.com/)

---

## Step 1: Create a GCP Project

1. Sign in to Google Cloud using your Google account.
2. Create a new project.
3. Note your **Project ID** — this will be required later for Terraform deployment.

---

## Step 2: Create a Service Account

1. Navigate to **IAM & Admin → Service Accounts**.
2. Create a new service account for your project.
3. Grant it the **Viewer** role (initial setup).
4. Generate and download the service account key file (`.json`).


---

## Step 3: Configure Permissions (Programmatic Access)

1. Go to **IAM & Admin → IAM**.
2. Locate your service account and click the **Edit** (pencil) icon.
3. Add the following roles:  
   - **Storage Admin**  
   - **Storage Object Admin**  
   - **BigQuery Admin**

---

## Step 4: Enable Required APIs

Enable the following APIs for your project:  
- **IAM API**  
- **IAM Credentials API**

You can enable them via: **APIs & Services → Library** in the GCP Console.

---

# 🌍 Terraform Configuration Guide

This guide walks you through setting up and running your Terraform project using Google Cloud Platform (GCP).

---

## 📦 Prerequisites

### Install Terraform

**Linux / WSL:**

```bash
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common

wget -O- https://apt.releases.hashicorp.com/gpg | \
  gpg --dearmor | sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update && sudo apt-get install -y terraform
```
Note: Codespaces have a different way of installing terraform. 


**Verify installation:**
```bash
terraform --version
```

---

## ⚙️ Step 1: Configure Project Variables

1. Copy your GCP service account key (JSON file) into this directory as `keys.json`.

2. Replace the `project_id` default in `variables.tf` with your actual GCP Project ID.

> **Note:** The `keys.json` file is git-ignored for security. Never commit credentials.

> **Tip:** You can keep the default values for `region`, `location`, `gcs_bucket_name`, and `credentials` provided in `variables.tf`. Adjust them if your setup differs.

---

## 🚀 Step 2: Initialize and Apply Terraform

 Run:

```bash
cd terraform
terraform init      # Initializes providers and modules
terraform plan      # Preview infrastructure changes
terraform apply     # Create the GCS bucket and BigQuery dataset
```

---

## 🔗 Step 3: Generate Environment File

After `terraform apply` completes, run the helper script to generate a `.env` file for Airflow:

```bash
bash generate_env.sh
```

This reads the Terraform outputs (`outputs.tf`) and writes `../airflow/.env` with all the GCP configuration values. The Airflow DAGs and docker-compose will pick them up automatically.

---

## 📁 File Structure

```
terraform/
├── main.tf              # GCS bucket + BigQuery dataset resources
├── variables.tf         # Input variables (project_id, region, etc.)
├── outputs.tf           # Exported values for downstream tools
├── generate_env.sh      # Script to generate airflow/.env from outputs
├── keys.json            # Your GCP service account key (git-ignored)
└── README.MD            # This file
```