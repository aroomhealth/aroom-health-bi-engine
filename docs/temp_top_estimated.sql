SELECT 
  produto, 
  SUM(receita_total) as valor, 
  SUM(quantidade_comprada) as qtd
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
WHERE 
  data_venda >= '2026-06-01' 
  AND origem_agrupada = 'Site Próprio (E-commerce)'
  AND flag_origem_custo = '3. Custo Estimado (Regra de Segurança)'
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;
