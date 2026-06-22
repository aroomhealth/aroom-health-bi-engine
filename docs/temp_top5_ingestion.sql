(SELECT 'Bling (Pedidos de Venda)' as fonte_de_dados, CAST(data as STRING) as data_registro, CAST(identificador as STRING) as informacao_adicional
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`
ORDER BY data DESC
LIMIT 5)

UNION ALL

(SELECT 'Google Ads (Performance)', CAST(day as STRING), campaign_name
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`
ORDER BY day DESC
LIMIT 5)

UNION ALL

(SELECT 'Facebook Ads (Insights)', CAST(date as STRING), campaign_name
FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights`
ORDER BY date DESC
LIMIT 5)
