import subprocess

def run_bq(query):
    with open('temp_q.sql', 'w', encoding='utf-8') as f:
        f.write(query)
    res = subprocess.run(['bq', 'query', '--use_legacy_sql=false'], stdin=open('temp_q.sql', 'r', encoding='utf-8'), capture_output=True, text=True, shell=True)
    if res.returncode != 0:
        print("Error STDOUT:\n", res.stdout)
        print("Error STDERR:\n", res.stderr)
        return False
    print("Success")
    return True

print("Dropping ROAS view to unblock upstream...")
run_bq("DROP VIEW IF EXISTS `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas`")

print("Deploying Vendas Detalhado...")
with open('sql/production/growth_engine_vendas_detalhado.sql', 'r', encoding='utf-8') as f:
    vendas_sql = f.read()
run_bq("CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado` AS \n" + vendas_sql)

print("Deploying ROAS...")
with open('sql/production/growth_engine_marketing_roas.sql', 'r', encoding='utf-8') as f:
    roas_sql = f.read()
run_bq("CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas` AS \n" + roas_sql)

print("All done!")
