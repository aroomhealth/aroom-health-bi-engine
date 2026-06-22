SELECT 
  SUM(investimento) as desperdicio_em_ads_ruim,
  SUM(investimento * (2.5 - roas)) as faturamento_perdido_estimado
FROM (
  SELECT 
    data, 
    custo_facebook_ads as investimento, 
    roas_facebook_ads as roas 
  FROM `iron-rex-461220-g4.database_aroom_health.visao_diaria_de_vendas` 
  WHERE data >= '2026-01-01' AND roas_facebook_ads < 2.5
);
