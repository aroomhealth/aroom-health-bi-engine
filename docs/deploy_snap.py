import os
from google.cloud import bigquery

client = bigquery.Client(project='iron-rex-461220-g4')

with open("sql/wallet_for_marketing/customer_wallet_snapshot.sql", "r", encoding="utf-8") as f:
    query = f.read()

job_config = bigquery.QueryJobConfig()
print("Executando snapshot...")
query_job = client.query(query, job_config=job_config, location="us-central1")
query_job.result()
print("Snapshot criado com sucesso na us-central1!")
