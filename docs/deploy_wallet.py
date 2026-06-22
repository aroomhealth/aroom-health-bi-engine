import os
from google.cloud import bigquery
from google.api_core.exceptions import Conflict

# Configurar o client
client = bigquery.Client(project='iron-rex-461220-g4')

# Nome do dataset e da tabela
dataset_id = "iron-rex-461220-g4.wallet_for_marketing"

# Tentar criar o dataset
dataset = bigquery.Dataset(dataset_id)
dataset.location = "US"
try:
    dataset = client.create_dataset(dataset, timeout=30)
    print("Created dataset {}.{}".format(client.project, dataset.dataset_id))
except Conflict:
    print("Dataset {} already exists".format(dataset_id))

# Ler a query
with open("sql/wallet_for_marketing/customer_wallet_snapshot.sql", "r", encoding="utf-8") as f:
    query = f.read()

# Executar a query
print("Executando a query de snapshot...")
job_config = bigquery.QueryJobConfig()
query_job = client.query(query, job_config=job_config)

query_job.result()  # Esperar finalizar
print("Query executada com sucesso e tabela criada!")
