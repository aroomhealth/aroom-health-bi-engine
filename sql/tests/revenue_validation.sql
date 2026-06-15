-- ==============================================================================
-- TESTE: revenue_validation
-- DESCRICAO: Valida se o faturamento total acumulado bate exatamente com o
--            valor auditado homologado de R$ 9.540.041,07.
-- ==============================================================================

WITH validation AS (
    SELECT 
        SUM(receita_total) as faturamento_calculado,
        9540041.07 as faturamento_esperado
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
)
SELECT 
    faturamento_calculado,
    faturamento_esperado,
    (faturamento_calculado - faturamento_esperado) as diferenca,
    CASE 
        WHEN ABS(faturamento_calculado - faturamento_esperado) < 0.01 THEN '✅ PASS'
        ELSE '❌ FAIL - Faturamento divergente'
    END as status
FROM validation;
