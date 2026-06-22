-- 1. Total bruto no Bling no dia 16/06 (sem filtros)
SELECT '1. Bling Bruto' as step, SUM(i.valor * i.quantidade) as valor
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens` i
JOIN `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p ON p.identificador = i.pedidos_vendas_identificador
WHERE p.data = '2026-06-16'

UNION ALL

-- 2. Total no Bling, excluindo cancelados (situacao 12, 105)
SELECT '2. Bling Valido (Sem Cancelados)' as step, SUM(i.valor * i.quantidade) as valor
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens` i
JOIN `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p ON p.identificador = i.pedidos_vendas_identificador
WHERE p.data = '2026-06-16' AND p.situacao_id NOT IN (12, 105)

UNION ALL

-- 3. Total no Bling Valido, apenas para Produtos Ativos
SELECT '3. Bling Valido + Produtos Ativos' as step, SUM(receita_total) as valor
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
WHERE data_venda = '2026-06-16' AND is_produto_ativo = 'Sim'

UNION ALL

-- 4. Total Nuvemshop no dia 16/06 (como a view antiga fazia)
SELECT '4. Nuvemshop (View Antiga)' as step, SUM(subtotal) as valor
FROM `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos`
WHERE DATE(created_at) = '2026-06-16' AND payment_status NOT IN ('refunded', 'voided')
ORDER BY step;
