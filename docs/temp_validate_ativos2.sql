SELECT 
    flag_origem_custo, 
    COUNT(*) as total_itens_vendidos,
    SUM(receita_total) as receita_total
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
WHERE produto IN (
  SELECT nome FROM `iron-rex-461220-g4.database_aroom_health.produtos` WHERE situacao = 'A'
)
GROUP BY flag_origem_custo
ORDER BY total_itens_vendidos DESC;
