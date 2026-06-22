from google.cloud import bigquery
import os

client = bigquery.Client(project='iron-rex-461220-g4')
query = "SELECT routine_definition FROM `iron-rex-461220-g4.database_aroom_health.INFORMATION_SCHEMA.ROUTINES` WHERE routine_name = 'proc_atualizar_visao_diaria_de_vendas'"
results = client.query(query).result()

for row in results:
    with open('c:\\Users\\arthu\\.antigravity-ide\\aroom-health-bi-engine\\docs\\old_proc.sql', 'w', encoding='utf-8') as f:
        f.write(row.routine_definition)
