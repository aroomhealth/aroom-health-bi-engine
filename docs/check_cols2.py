import os
from google.cloud import bigquery

client = bigquery.Client(project='iron-rex-461220-g4')
query = """
SELECT column_name 
FROM `iron-rex-461220-g4.customer_intelligence.INFORMATION_SCHEMA.COLUMNS` 
WHERE table_name = 'growth_engine_vendas_detalhado'
"""
query_job = client.query(query)
for row in query_job:
    print(row.column_name)
