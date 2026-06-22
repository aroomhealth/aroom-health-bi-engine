SELECT 
  produto, 
  origem_agrupada as canal,
  SUM(receita_total) as valor_vendido
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
WHERE data_venda = '2026-06-16' AND is_produto_ativo = 'Não'
GROUP BY 1, 2
ORDER BY 3 DESC;
