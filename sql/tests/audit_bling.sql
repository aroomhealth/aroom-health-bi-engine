-- ==============================================================================
-- AUDITORIA: Bling ERP
-- DESCRICAO: Scripts SQL para verificar integridade, duplicados, categorias nulas
--            e status de pedidos da base transacional do Bling.
-- ==============================================================================

-- 1. Unicidade de Pedidos e Itens
SELECT 
    'Pedidos' as tabela,
    COUNT(*) as total_registros,
    COUNT(DISTINCT identificador) as ids_unicos,
    (COUNT(*) - COUNT(DISTINCT identificador)) as duplicados
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`
UNION ALL
SELECT 
    'Itens de Pedidos' as tabela,
    COUNT(*) as total_registros,
    COUNT(DISTINCT identificador) as ids_unicos,
    (COUNT(*) - COUNT(DISTINCT identificador)) as duplicados
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens`
UNION ALL
SELECT 
    'Produtos' as tabela,
    COUNT(*) as total_registros,
    COUNT(DISTINCT identificador) as ids_unicos,
    (COUNT(*) - COUNT(DISTINCT identificador)) as duplicados
FROM `iron-rex-461220-g4.database_aroom_health.produtos`;


-- 2. Range de Datas de Negocio e Ultima Atualizacao
SELECT 
    'Pedidos' as tabela,
    MIN(data) as min_data_negocio,
    MAX(data) as max_data_negocio,
    MIN(created_at) as min_ingestao,
    MAX(created_at) as max_ingestao
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`;


-- 3. Distribuicao de Status de Pedidos (Prevençao de Cancelados)
SELECT 
    situacao_id,
    COUNT(*) as total_pedidos,
    SUM(total_pedidos) OVER() as total_geral,
    ROUND(100 * COUNT(*) / SUM(total_pedidos) OVER(), 2) as percentual
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`
GROUP BY situacao_id
ORDER BY total_pedidos DESC;


-- 4. Completude de Categorias de Produtos
WITH catalog_audit AS (
    SELECT 
        p.identificador as produto_id,
        p.nome as produto,
        p.codigo as sku,
        cat.categoria_produto,
        cat.subcategoria_produto
    FROM `iron-rex-461220-g4.database_aroom_health.produtos` p
    LEFT JOIN (
        SELECT 
            codigo_produto, 
            ANY_VALUE(INITCAP(LOWER(Categoria_Produto_Agrupada))) as categoria_produto,
            ANY_VALUE(INITCAP(LOWER(Categoria_Produto))) as subcategoria_produto
        FROM `iron-rex-461220-g4.database_aroom_health.view_vendas`
        WHERE codigo_produto IS NOT NULL
        GROUP BY codigo_produto
    ) cat ON p.codigo = cat.codigo_produto
)
SELECT 
    COUNT(*) as total_produtos,
    COUNTIF(categoria_produto IS NULL OR categoria_produto = '') as sem_categoria,
    ROUND(100 * COUNTIF(categoria_produto IS NULL OR categoria_produto = '') / COUNT(*), 2) as pct_incompleto
FROM catalog_audit;
