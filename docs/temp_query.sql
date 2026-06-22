SELECT 
  COUNT(item_id) as total_itens_vendidos, 
  COUNTIF(custo_unitario = 0) as itens_sem_custo, 
  ROUND(COUNTIF(custo_unitario = 0) / COUNT(item_id) * 100, 2) as perc_itens_sem_custo, 
  SUM(receita_total) as receita_total_geral, 
  SUM(CASE WHEN custo_unitario = 0 THEN receita_total ELSE 0 END) as receita_no_escuro, 
  ROUND(SUM(CASE WHEN custo_unitario = 0 THEN receita_total ELSE 0 END) / SUM(receita_total) * 100, 2) as perc_receita_no_escuro 
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
