-- ==============================================================================
-- TESTE: item_granularity_check
-- DESCRICAO: Compara o somatorio da receita_total calculada na view com a soma
--            bruta dos itens nos pedidos ativos da tabela raw. 
--            Garante que os joins nao inflaram ou omitiram valores.
-- ==============================================================================

WITH raw_sum AS (
    SELECT 
        SUM(i.valor * i.quantidade) as total_raw
    FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p
    JOIN `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens` i 
        ON p.identificador = i.pedidos_vendas_identificador
    WHERE p.situacao_id NOT IN (12, 105)
),
view_sum AS (
    SELECT 
        SUM(receita_total) as total_view
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
)
SELECT 
    r.total_raw,
    v.total_view,
    (v.total_view - r.total_raw) as discrepancia,
    CASE 
        WHEN ABS(v.total_view - r.total_raw) < 0.01 THEN '✅ PASS'
        ELSE '❌ FAIL - Divergencia entre dados raw e processados'
    END as status
FROM raw_sum r, view_sum v;
