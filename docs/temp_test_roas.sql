SELECT data_referencia, sessoes_ga4, investimento_ads, qtd_pedidos_site, receita_bruta_site, taxa_conversao_site 
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas` 
WHERE data_referencia >= '2026-06-01'
ORDER BY data_referencia DESC 
LIMIT 5;
