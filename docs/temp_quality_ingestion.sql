SELECT 
  'Bling (Pedidos)' as fonte, 
  CAST(MAX(data) AS STRING) as ultima_data, 
  COUNT(identificador) as qtd_registros_na_ultima_data,
  COUNTIF(contato_id IS NOT NULL AND loja_id IS NOT NULL) as infos_nao_nulas
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`
WHERE data = (SELECT MAX(data) FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`)

UNION ALL

SELECT 
  'Facebook Ads', 
  CAST(MAX(date) AS STRING), 
  COUNT(campaign_name),
  COUNTIF(spend IS NOT NULL AND spend > 0)
FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights`
WHERE date = (SELECT MAX(date) FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights`)

UNION ALL

SELECT 
  'Google Ads', 
  CAST(MAX(day) AS STRING), 
  COUNT(campaign_name),
  COUNTIF(cost_spend IS NOT NULL AND cost_spend > 0)
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`
WHERE day = (SELECT MAX(day) FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`)
