-- ==============================================================================
-- AUDITORIA: Looker Studio Dependencies
-- DESCRICAO: Scripts para validar a saude das colunas criticas consumidas
--            pelos dashboards e relatorios de Business Intelligence.
-- ==============================================================================

-- 1. Verificacao de Nulos nas Colunas de Segmentacao e Medidas do Looker
SELECT 
    COUNT(*) as total_linhas,
    COUNTIF(data IS NULL) as nulo_data,
    COUNTIF(pedido_id IS NULL) as nulo_pedido,
    COUNTIF(item_id IS NULL) as nulo_item,
    COUNTIF(receita_total IS NULL) as nulo_receita,
    COUNTIF(origem_agrupada IS NULL OR origem_agrupada = '') as nulo_origem,
    COUNTIF(categoria_produto IS NULL OR categoria_produto = '') as nulo_categoria,
    COUNTIF(familia_produto IS NULL OR familia_produto = '') as nulo_familia_produto,
    COUNTIF(uf IS NULL OR uf = '') as nulo_uf
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`;


-- 2. Cardinalidade de Campos Chave do Dashboard (Para Evitar Explosoes ou Categorias Estranhas)
SELECT 
    'origem_agrupada' as campo,
    origem_agrupada as valor,
    COUNT(*) as ocorrencias
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
GROUP BY origem_agrupada
UNION ALL
SELECT 
    'familia_produto' as campo,
    familia_produto as valor,
    COUNT(*) as ocorrencias
FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
GROUP BY familia_produto
ORDER BY campo, ocorrencias DESC;
