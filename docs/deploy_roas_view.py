import os
with open(r'c:\Users\arthu\.antigravity-ide\aroom-health-bi-engine\sql\production\growth_engine_marketing_roas.sql', 'r', encoding='utf-8') as f:
    sql = f.read()

full_sql = "CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas` AS\n" + sql

with open(r'c:\Users\arthu\.antigravity-ide\aroom-health-bi-engine\docs\deploy_roas_view.sql', 'w', encoding='utf-8') as f:
    f.write(full_sql)
