import subprocess

with open('sql/production/growth_engine_vendas_detalhado.sql', 'r', encoding='utf-8') as f:
    sql_content = f.read()

full_query = "CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado` AS \n" + sql_content

# Write to a clean UTF-8 file without BOM
with open('temp_query.sql', 'w', encoding='utf-8') as f:
    f.write(full_query)

# Run bq query
result = subprocess.run(['bq', 'query', '--use_legacy_sql=false'], stdin=open('temp_query.sql', 'r', encoding='utf-8'), capture_output=True, text=True, shell=True)

print("STDOUT:", result.stdout)
print("STDERR:", result.stderr)
