SELECT 
  origem_agrupada,
  SUM(receita_total) as valor
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
WHERE data_venda = '2026-06-16' AND is_produto_ativo = 'Sim'
GROUP BY 1
ORDER BY 2 DESC;
