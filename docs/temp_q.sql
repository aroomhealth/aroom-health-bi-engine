SELECT familia_produto, objetivo_produto, COUNT(*) as qtd 
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado` 
GROUP BY 1, 2
