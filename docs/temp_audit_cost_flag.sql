SELECT 
  flag_origem_custo,
  COUNT(DISTINCT pedido_id) as qtd_pedidos,
  SUM(receita_total) as receita_bruta,
  SUM(lucro_bruto) as lucro_bruto_calculado,
  SAFE_DIVIDE(SUM(lucro_bruto), SUM(receita_total)) as margem_bruta_percentual
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
WHERE 
  data_venda >= '2026-06-01' 
  AND origem_agrupada = 'Site Próprio (E-commerce)'
GROUP BY 1
ORDER BY 3 DESC;
