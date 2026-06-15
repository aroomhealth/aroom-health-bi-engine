-- ==============================================================================
-- TESTE: duplicate_check
-- DESCRICAO: Valida se existe alguma duplicacao de linhas na granularidade de item
--            por pedido (pedido_id + item_id). Deve retornar 0 linhas duplicadas.
-- ==============================================================================

WITH duplicate_counts AS (
    SELECT 
        pedido_id,
        item_id,
        COUNT(*) as ocorrencias
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
    GROUP BY pedido_id, item_id
)
SELECT 
    COUNT(*) as total_duplicados,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '❌ FAIL - Existem registros duplicados'
    END as status
FROM duplicate_counts
WHERE ocorrencias > 1;
