import os
from google.cloud import bigquery

client = bigquery.Client(project='iron-rex-461220-g4')
dataset = client.get_dataset('iron-rex-461220-g4.customer_intelligence')
print("customer_intelligence location is:", dataset.location)

# Apagar o dataset errado e recriar na location correta
try:
    client.delete_dataset('iron-rex-461220-g4.wallet_for_marketing', delete_contents=True, not_found_ok=True)
except Exception as e:
    print(e)

dataset_id = "iron-rex-461220-g4.wallet_for_marketing"
dataset = bigquery.Dataset(dataset_id)
dataset.location = dataset.location # set to the one we found
dataset.location = client.get_dataset('iron-rex-461220-g4.customer_intelligence').location
dataset = client.create_dataset(dataset, timeout=30)
print("Created dataset {} in location {}".format(dataset_id, dataset.location))

with open("sql/wallet_for_marketing/customer_wallet_snapshot.sql", "r", encoding="utf-8") as f:
    query = f.read()

job_config = bigquery.QueryJobConfig()
query_job = client.query(query, job_config=job_config, location=dataset.location)
query_job.result()
print("Query executada!")
