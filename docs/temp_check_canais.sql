SELECT 
  COALESCE(c.canal_edit, c.canal) as canal, 
  origem_agrupada,
  SUM(receita_total) as valor
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado` v
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.bling_canais_venda` c ON CAST(v.id_da_loja_origem AS STRING) = CAST(c.id_canal AS STRING)
WHERE data_venda = '2026-06-16'
GROUP BY 1, 2
ORDER BY 3 DESC;
