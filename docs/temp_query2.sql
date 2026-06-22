SELECT 
  COUNT(identificador) as total_skus,
  COUNTIF(preco_custo = 0 OR preco_custo IS NULL) as skus_sem_custo,
  ROUND(COUNTIF(preco_custo = 0 OR preco_custo IS NULL) / COUNT(identificador) * 100, 2) as perc_skus_sem_custo
FROM `iron-rex-461220-g4.database_aroom_health.produtos`
