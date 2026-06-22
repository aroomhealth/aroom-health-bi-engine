SELECT 
  DATETIME(TIMESTAMP_MILLIS(last_modified_time), 'America/Sao_Paulo') as google_ads_atualizado_em
FROM `iron-rex-461220-g4.database_aroom_health.__TABLES__`
WHERE table_id = 'google_ads_campaign_performance';

SELECT 
  data_referencia,
  investimento_ads,
  receita_bruta_site,
  lucro_bruto_site,
  roas_blended
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas`
WHERE data_referencia >= '2026-06-01'
ORDER BY data_referencia DESC
LIMIT 10;
