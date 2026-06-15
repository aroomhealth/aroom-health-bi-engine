-- ==============================================================================
-- TESTE: null_category_check
-- DESCRICAO: Valida se a categorizacao inteligente cobriu todos os produtos e
--            verifica se ha categorias inesperadamente nulas, vazias ou como
--            "Sem Categoria" / "Outros".
-- ==============================================================================

SELECT 
    COUNT(DISTINCT produto) as total_produtos_nao_mapeados,
    ARRAY_AGG(DISTINCT produto LIMIT 10) as exemplos_nao_mapeados,
    CASE 
        WHEN COUNT(*) = 0 THEN '✅ PASS'
        ELSE '⚠️ WARNING - Existem produtos que cairam em fallback vazio ou indefinido'
    END as status
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
WHERE categoria_produto IS NULL 
   OR categoria_produto IN ('', 'Sem Categoria', 'Outros');
