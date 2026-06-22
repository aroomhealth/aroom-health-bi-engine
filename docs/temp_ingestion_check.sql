SELECT 'Bling (Pedidos de Venda)' as fonte_de_dados, CAST(MAX(data) AS STRING) as ultima_data_recebida 
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`
UNION ALL
SELECT 'Google Ads (Performance)', CAST(MAX(day) AS STRING) 
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`
UNION ALL
SELECT 'Facebook Ads (Insights)', CAST(MAX(date) AS STRING) 
FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights`
