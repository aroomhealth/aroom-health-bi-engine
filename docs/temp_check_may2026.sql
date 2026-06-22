SELECT data, custo_google_ads, custo_facebook_ads, roas_facebook_ads 
FROM `iron-rex-461220-g4.database_aroom_health.visao_diaria_de_vendas` 
WHERE data >= '2026-05-01'
ORDER BY data DESC
LIMIT 20;
