from google.cloud import bigquery
import os

def deploy():
    client = bigquery.Client()

    print("Dropping ROAS view to unblock upstream...")
    query = "DROP VIEW IF EXISTS `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas`"
    try:
        client.query(query).result()
        print("Success")
    except Exception as e:
        print("Error:", e)

    print("Deploying Vendas Detalhado...")
    with open('sql/production/growth_engine_vendas_detalhado.sql', 'r', encoding='utf-8') as f:
        vendas_sql = f.read()
    query = "CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado` AS \n" + vendas_sql
    try:
        client.query(query).result()
        print("Success")
    except Exception as e:
        print("Error:", e)

    print("Deploying ROAS...")
    with open('sql/production/growth_engine_marketing_roas.sql', 'r', encoding='utf-8') as f:
        roas_sql = f.read()
    query = "CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas` AS \n" + roas_sql
    try:
        client.query(query).result()
        print("Success")
    except Exception as e:
        print("Error:", e)

    print("Deploying Auditoria...")
    with open('sql/production/growth_engine_auditoria_receita.sql', 'r', encoding='utf-8') as f:
        auditoria_sql = f.read()
    query = "CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_auditoria_receita` AS \n" + auditoria_sql
    try:
        client.query(query).result()
        print("Success")
    except Exception as e:
        print("Error:", e)

    print("All done!")

if __name__ == '__main__':
    deploy()
