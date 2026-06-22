SELECT produto, subcategoria_produto, SUM(receita_liquida) as rec 
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado` 
WHERE familia_produto = '7. Outros' 
GROUP BY 1,2 
ORDER BY 3 DESC 
LIMIT 20
