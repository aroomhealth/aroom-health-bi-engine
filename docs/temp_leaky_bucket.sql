SELECT 
  EXTRACT(MONTH FROM data_venda) as mes,
  COUNT(DISTINCT pedido_id) as qtd_pedidos_prejuizo,
  SUM(receita_total) as faturamento_nesses_pedidos,
  SUM(lucro_bruto) as prejuizo_liquido
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
WHERE 
  data_venda >= '2026-01-01'
  AND lucro_bruto < 0
  AND is_produto_ativo = 'Sim'
GROUP BY 1
ORDER BY 1;
