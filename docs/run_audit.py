import subprocess
import json

with open('docs/temp_audit_decomposition.sql', 'r', encoding='utf-8') as f:
    sql_content = f.read()

result = subprocess.run(['bq', 'query', '--use_legacy_sql=false', '--format=json'], input=sql_content, capture_output=True, text=True, shell=True)

print("STDOUT:", result.stdout)
if result.stderr:
    print("STDERR:", result.stderr)
