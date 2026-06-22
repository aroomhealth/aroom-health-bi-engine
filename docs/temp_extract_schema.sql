SELECT table_name, column_name, data_type
FROM `iron-rex-461220-g4.database_aroom_health.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name IN ('pedidos_vendas', 'pedidos_vendas_itens', 'produtos', 'bling_canais_venda', 'facebook_ads_insights')
UNION ALL
SELECT table_name, column_name, data_type
FROM `iron-rex-461220-g4.customer_intelligence.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name IN ('customer_profile_enriched', 'growth_engine_vendas_detalhado', 'growth_engine_marketing_roas')
ORDER BY table_name, column_name;
