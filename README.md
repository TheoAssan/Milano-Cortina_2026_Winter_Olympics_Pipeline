<p align="center">
  <img src="images/logo.png" alt="Milano Cortina 2026" width="150"/> <br>
  <h1> Milano-Cortina 2026 Winter Olympics Data Pipeline</h1>
</p>

<p align = "center"></p>

![Python](https://img.shields.io/badge/Python-3776AB?style=for-the-badge&logo=python&logoColor=white)
![dbt](https://img.shields.io/badge/dbt-FF694B?style=for-the-badge&logo=dbt&logoColor=white)
![Airflow](https://img.shields.io/badge/Airflow-444444?style=for-the-badge&logo=apacheairflow&logoColor=auto)
![GCP](https://img.shields.io/badge/GCP-FFFFFF?style=for-the-badge&logo=googlecloud&logoColor=auto)
![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)



This project builds a cloud-based end-to-end data pipeline to ingest, transform, and analyze the [Milano-Cortina 2026 Winter Olympics dataset](https://www.kaggle.com/datasets/piterfm/milano-cortina-2026-olympic-winter-games) from Kaggle.
Using Terraform for infrastructure-as-code, Apache Airflow for orchestration, dbt for transformation, and BigQuery as the data warehouse, the solution establishes a dimensional star schema that enables fast, intuitive analysis. The result is a governed, self-service analytics platform where users can explore Olympic data independently through Looker Studio.
The analysis answers questions such as:
- which athletes and countries performed best
- how medals are distributed across disciplines and gender 
- and how efficiently countries convert athlete participation into medals.

## Architecture

<p >
  <img src="images/arch.png" alt="System Architecture" width="800"/> <br>
</p>



## Tech Stack

| Layer | Tool | Purpose |
|---|---|---|
| **Infrastructure** | Terraform | Creates GCS bucket and BigQuery dataset on GCP |
| **Orchestration** | Apache Airflow (Docker) | Runs DAGs which download the dataset from kaggle,extracts and converts csv to parquet files and loads to Google Cloud Storage|
| **Data Lake** | Google Cloud Storage | Stores raw Parquet files |
| **Data Warehouse** | BigQuery | Hosts raw + transformed tables |
| **Transformation** | dbt Cloud | Builds staging and mart models (star schema) |
| **Visualization**  | Looker Studio | Presents meaningful data in the form of charts and graphs from transformed dbt models in BigQuery |

---
## Dashboard
### Country Performances 
<p >
  <img src="images/count_perf.png"  width="400"/> 
  <img src="images/count_filt.png" width="400">
</p> 

Country Performances analyzes the performances of the participating countries: 
- **Geographic Location** : shows where the country is located on the world map.
- **Medal standings** : ranks the top 10 nations by medals won using a stacked bar which shows the number of gold, silver and bronze medals won. When a country is selected, it displays the medals won for that singular selected country.
- **Total medals**,**Number of participating countries** : are dynamic scorecards which show the total value of what they represent when unfiltered. When a country is selected, the re-aggregate the values for that singular country selected.
- **Medal Distribution By Discipline** : by default indicates the total number of medals awarded per discipline, when a country is selected, it shows the disciplines in which the medals were obtained.

### Athlete Performances

<p >
  <img src="images/ath_perf.png" width="400"/> 
  <img src="images/ath_filt.png" width="400"/>
</p>

- **Medallists Leaderboard**: Displays the total number of medals,names,countries,gender and discipline of athletes who won medals **only**.This is sorted in descending order. When a country is selected, it displays the medallists and their corresponding data for the selected country.
- **Podium Profile** : Displays the type of medals won by the athletes
- **Number of participating athletes,Gender Doughnut**: By default displays the total number of athletes who participated in the winter olympics segregated by gender.Upon selecting a country, it displays the total number of athletes from that country also segregated by gender.
- **Performance Participation**: Plots The number of athletes presented by each country against the number of medals they won and find the average of both metrics. The metric of the bubble is conversion rate. It is determined by how efficiently a country's athlete participation translated to medal wins. So high number of athletes participation with relatively low medal returns gives a lower conversion rate etc. 

## Prerequisites

- **GCP Account** with a project and service account  | *[ Video Tutorial](https://www.youtube.com/watch?v=Y2ux7gq3Z0o&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=6)*
- **Docker & Docker Compose** for running Airflow
- **Terraform** CLI 
- **dbt Cloud** account | *[ Video Tutorial](https://www.youtube.com/watch?v=J0XCDyKiU64&list=PL3MmuxUbc_hJed7dXYoJw8DoCuVHhGEQb&index=32)*

## Quick Start

### 1. Provision Infrastructure (Terraform) ([Configuration](terraform/README.MD#-ConfigureProjectVariables))

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

> **Note:** See the [Airflow Setup Guide](airflow/README.md) for more detailed instructions.

```bash
cd ../airflow
docker-compose build
docker-compose up -d
```

Forward **http://127.0.0.1:8080** (login: `airflow` / `airflow`) and trigger the DAGs in order:

1. **`load_to_gcs`** — Downloads the Kaggle dataset, converts CSVs to Parquet, uploads to GCS
2. **`gcs_to_bigquery`** — Loads Parquet files from GCS into BigQuery tables



### 4. Transform Data (dbt Cloud)

See [dbt/README.md](dbt/README.md) for detailed setup instructions.

1. Connect your dbt Cloud project to this repository
2. Set up the BigQuery connection with your service account key
3. Set the `gcp_project_id` variable in your dbt Cloud environment
4. Run:

   ```
   dbt build
   ```

The dbt layer transforms raw BigQuery tables into a star schema:

**Dimensions:** `dim_athletes`, `dim_countries`, `dim_discipline`, `dim_events`

**Facts:** `fact_athlete_perf`, `fact_country_perf`, `fact_discipline`

### 5. Visualization 
