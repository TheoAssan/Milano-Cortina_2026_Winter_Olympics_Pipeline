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
# 🌍 Terraform Configuration Guide

This guide walks you through setting up and running your Terraform project using Google Cloud Platform (GCP).

---

## 📦 Prerequisites

Before you begin, ensure you have Terraform installed on your system so you can run commands like:

```bash
terraform init
terraform plan
terraform apply
```

To make your environment reproducible and avoid manual installation, you can use a VS Code Dev Container.

Create a .devcontainer directory in your project root

Inside it, create a file named devcontainer.json

Paste the following configuration:

```json

{
  "name": "Terraform Codespace",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/terraform:1": {
      "version": "latest"
    }
  }
}
``` 

## ⚙️ Step 1: Configure Project Variables

Replace the `project_id` and credentials-related variables in your Terraform configuration with your actual **Google Cloud Project ID** and service account credentials.

> **Note:**  
> After downloading your GCP service account key (JSON file), copy its contents into a file named `keys.json` inside your Terraform directory.

> **Tip:**  
> You can keep the default file paths and locations provided in this project. However, if you choose to modify them, ensure the changes are consistently reflected across your Terraform configuration files.

---

## 🚀 Step 2: Initialize and Apply Terraform

Ensure you are inside the Terraform directory, then run the following commands:

```bash
terraform init
terraform plan
terraform apply
```

terraform init → Initializes the working directory and installs required providers

terraform plan → Shows a preview of the infrastructure changes

terraform apply → Provisions the resources on GCP