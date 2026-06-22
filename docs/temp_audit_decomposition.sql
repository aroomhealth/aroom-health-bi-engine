WITH nova AS (
  SELECT 
    pedido_id,
    SUM(receita_liquida) as nova_liquida,
    SUM(receita_bruta) as nova_bruta
  FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
  WHERE DATE(data_venda) BETWEEN '2026-05-01' AND '2026-05-31'
  GROUP BY 1
),
antiga AS (
  SELECT 
    venda_id as pedido_id,
    SUM(valor_final_calculado) as antiga_liquida,
    SUM(valor_calculado) as antiga_bruta
  FROM `iron-rex-461220-g4.database_aroom_health.view_vendas`
  WHERE DATE(data_compra) BETWEEN '2026-05-01' AND '2026-05-31'
  GROUP BY 1
),
comparacao AS (
  SELECT 
    COALESCE(n.pedido_id, a.pedido_id) as pedido_id,
    IFNULL(n.nova_bruta, 0) as nova_bruta,
    IFNULL(a.antiga_bruta, 0) as antiga_bruta,
    IFNULL(n.nova_liquida, 0) as nova_liquida,
    IFNULL(a.antiga_liquida, 0) as antiga_liquida,
    (IFNULL(n.nova_liquida, 0) - IFNULL(a.antiga_liquida, 0)) as diff_liquida
  FROM nova n
  FULL OUTER JOIN antiga a ON n.pedido_id = a.pedido_id
)
SELECT 
  CASE 
    WHEN nova_bruta > 0 AND antiga_bruta = 0 THEN 'A. Pedido/Item Capturado pela Nova (Ausente na Antiga)'
    WHEN antiga_bruta > 0 AND nova_bruta = 0 THEN 'B. Pedido/Item Ignorado pela Nova (Cancelados/Excluidos)'
    WHEN nova_bruta > antiga_bruta THEN 'C. Volume/Receita Bruta Maior na NOVA'
    WHEN antiga_bruta > nova_bruta THEN 'D. Volume/Receita Bruta Maior na ANTIGA'
    WHEN ABS(nova_bruta - antiga_bruta) < 0.1 AND ABS(nova_liquida - antiga_liquida) > 0.1 THEN 'E. Divergencia no Rateio de Frete/Desconto'
    ELSE 'F. Valores Iguais'
  END as motivo_diferenca,
  COUNT(DISTINCT pedido_id) as qtd_pedidos,
  SUM(diff_liquida) as impacto_financeiro_liquido,
  SUM(nova_bruta - antiga_bruta) as impacto_financeiro_bruto
FROM comparacao
GROUP BY 1
ORDER BY impacto_financeiro_liquido DESC;
