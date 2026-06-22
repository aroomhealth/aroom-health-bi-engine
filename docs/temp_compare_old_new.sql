SELECT 
  N.data_referencia as Data,
  N.investimento_ads as Novo_Invest_Ads,
  (IFNULL(A.custo_facebook_ads,0) + IFNULL(A.custo_google_ads,0)) as Antigo_Invest_Ads,
  
  N.receita_bruta_site as Nova_Receita_Site_Ativos,
  A.total_numveshop as Antiga_Receita_Total,
  
  N.lucro_bruto_site as Novo_Lucro_Bruto,
  
  N.roas_blended as Novo_ROAS_Blended,
  SAFE_DIVIDE(A.total_numveshop, NULLIF((IFNULL(A.custo_facebook_ads,0) + IFNULL(A.custo_google_ads,0)), 0)) as Antigo_ROAS_Blended
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas` N
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.visao_diaria_de_vendas` A
  ON N.data_referencia = A.data
WHERE N.data_referencia BETWEEN '2026-06-13' AND '2026-06-17'
ORDER BY N.data_referencia DESC;
