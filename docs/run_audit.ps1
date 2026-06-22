$q1 = @"
WITH nova AS (
  SELECT pedido_id, SUM(receita_liquida) as nova_liquida, SUM(receita_bruta) as nova_bruta
  FROM ``iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado``
  WHERE DATE(data_venda) BETWEEN '2026-05-01' AND '2026-05-31'
  GROUP BY 1
),
antiga AS (
  SELECT venda_id as pedido_id, SUM(valor_final_calculado) as antiga_liquida, SUM(valor_calculado) as antiga_bruta
  FROM ``iron-rex-461220-g4.database_aroom_health.view_vendas``
  WHERE DATE(data_compra) BETWEEN '2026-05-01' AND '2026-05-31'
  GROUP BY 1
),
comparacao AS (
  SELECT COALESCE(n.pedido_id, a.pedido_id) as pedido_id, IFNULL(n.nova_bruta, 0) as nova_bruta, IFNULL(a.antiga_bruta, 0) as antiga_bruta, IFNULL(n.nova_liquida, 0) as nova_liquida, IFNULL(a.antiga_liquida, 0) as antiga_liquida, (IFNULL(n.nova_liquida, 0) - IFNULL(a.antiga_liquida, 0)) as diff_liquida
  FROM nova n FULL OUTER JOIN antiga a ON n.pedido_id = a.pedido_id
)
SELECT 
  CASE 
    WHEN nova_bruta > 0 AND antiga_bruta = 0 THEN '1. Pedido Capturado pela Nova (Ausente na Antiga)'
    WHEN antiga_bruta > 0 AND nova_bruta = 0 THEN '2. Pedido Ignorado pela Nova (Ex: Cancelados)'
    WHEN nova_bruta > antiga_bruta THEN '3. Volume/Valor Bruto maior na Nova'
    WHEN antiga_bruta > nova_bruta THEN '4. Volume/Valor Bruto maior na Antiga'
    WHEN nova_bruta = antiga_bruta AND ABS(nova_liquida - antiga_liquida) > 0.1 THEN '5. Divergência em Frete/Desconto'
    ELSE '6. Valores Iguais'
  END as motivo,
  COUNT(DISTINCT pedido_id) as qtd_pedidos,
  ROUND(SUM(diff_liquida), 2) as impacto_liquido
FROM comparacao GROUP BY 1 ORDER BY impacto_liquido DESC;
"@

$q2 = @"
WITH nova AS (
  SELECT origem_agrupada as canal, SUM(receita_liquida) as nova_liquida
  FROM ``iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado``
  WHERE DATE(data_venda) BETWEEN '2026-05-01' AND '2026-05-31' GROUP BY 1
),
antiga AS (
  SELECT Canal_Venda as canal, SUM(valor_final_calculado) as antiga_liquida
  FROM ``iron-rex-461220-g4.database_aroom_health.view_vendas``
  WHERE DATE(data_compra) BETWEEN '2026-05-01' AND '2026-05-31' GROUP BY 1
)
SELECT COALESCE(n.canal, a.canal) as canal, ROUND(IFNULL(n.nova_liquida, 0), 2) as nova_liquida, ROUND(IFNULL(a.antiga_liquida, 0), 2) as antiga_liquida, ROUND(IFNULL(n.nova_liquida, 0) - IFNULL(a.antiga_liquida, 0), 2) as diff
FROM nova n FULL OUTER JOIN antiga a ON n.canal = a.canal ORDER BY diff DESC;
"@

$q3 = @"
WITH nova AS (
  SELECT produto, SUM(receita_liquida) as nova_liquida
  FROM ``iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado``
  WHERE DATE(data_venda) BETWEEN '2026-05-01' AND '2026-05-31' GROUP BY 1
),
antiga AS (
  SELECT nome_produto as produto, SUM(valor_final_calculado) as antiga_liquida
  FROM ``iron-rex-461220-g4.database_aroom_health.view_vendas``
  WHERE DATE(data_compra) BETWEEN '2026-05-01' AND '2026-05-31' GROUP BY 1
)
SELECT COALESCE(n.produto, a.produto) as produto, ROUND(IFNULL(n.nova_liquida, 0), 2) as nova_liquida, ROUND(IFNULL(a.antiga_liquida, 0), 2) as antiga_liquida, ROUND(IFNULL(n.nova_liquida, 0) - IFNULL(a.antiga_liquida, 0), 2) as diff
FROM nova n FULL OUTER JOIN antiga a ON UPPER(TRIM(n.produto)) = UPPER(TRIM(a.produto)) ORDER BY ABS(IFNULL(n.nova_liquida, 0) - IFNULL(a.antiga_liquida, 0)) DESC LIMIT 15;
"@

echo "--- DECOMPOSICAO POR MOTIVO ---"
bq query --use_legacy_sql=false --format=prettyjson $q1

echo "--- DECOMPOSICAO POR CANAL ---"
bq query --use_legacy_sql=false --format=prettyjson $q2

echo "--- DECOMPOSICAO POR PRODUTO ---"
bq query --use_legacy_sql=false --format=prettyjson $q3
