SELECT 
  'Bling (Pedidos)' as fonte, 
  CAST(data AS STRING) as data_registro, 
  COUNT(identificador) as qtd_registros,
  COUNTIF(contato_id IS NOT NULL AND loja_id IS NOT NULL) as infos_nao_nulas
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`
WHERE data IN ('2026-06-14', '2026-06-15')
GROUP BY data

UNION ALL

SELECT 
  'Facebook Ads', 
  CAST(date AS STRING), 
  COUNT(campaign_name),
  COUNTIF(spend IS NOT NULL AND spend > 0)
FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights`
WHERE date IN ('2026-06-14', '2026-06-15')
GROUP BY date

UNION ALL

SELECT 
  'Google Ads', 
  CAST(day AS STRING), 
  COUNT(campaign_name),
  COUNTIF(cost_spend IS NOT NULL AND cost_spend > 0)
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`
WHERE day IN ('2026-06-14', '2026-06-15')
GROUP BY day

ORDER BY data_registro DESC, fonte
