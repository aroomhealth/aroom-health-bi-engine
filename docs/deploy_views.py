import os
from google.cloud import bigquery

client = bigquery.Client(project='iron-rex-461220-g4')
location = "us-central1"

job_config = bigquery.QueryJobConfig()

print("Deploying vw_wallet_dashboards...")
with open("sql/wallet_for_marketing/vw_wallet_dashboards.sql", "r", encoding="utf-8") as f:
    query1 = f.read()

query_job1 = client.query(query1, job_config=job_config, location=location)
query_job1.result()
print("vw_wallet_dashboards created successfully!")

print("Deploying vw_customer_cohorts...")
with open("sql/wallet_for_marketing/vw_customer_cohorts.sql", "r", encoding="utf-8") as f:
    query2 = f.read()

query_job2 = client.query(query2, job_config=job_config, location=location)
query_job2.result()
print("vw_customer_cohorts created successfully!")
