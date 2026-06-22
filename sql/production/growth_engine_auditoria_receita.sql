-- ==============================================================================
-- VIEW: growth_engine_auditoria_receita
-- DATASET: customer_intelligence
-- DESCRICAO: Cubo de auditoria para comparar a visão ANTIGA de vendas
--            (view_vendas) com a visão NOVA detalhada (Unit Economics).
--            Utilizado no Looker Studio para análise de divergência de receita.
-- ==============================================================================

WITH old_sales AS (
    SELECT 
        DATE(data_compra) as data_venda,
        CASE 
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(Canal_Venda, '')), r'site|magento|loja aroom') THEN 'Site Próprio (E-commerce)'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(Canal_Venda, '')), r'mercado|livre|meli') THEN 'Mercado Livre'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(Canal_Venda, '')), r'shopee') THEN 'Shopee'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(Canal_Venda, '')), r'amazon') THEN 'Amazon'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(Canal_Venda, '')), r'b2b|atacado|revenda') THEN 'B2B / Atacado'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(Canal_Venda, '')), r'loja física|venda direta') THEN 'Loja Física / Venda Direta'
            ELSE 'Outros' 
        END as canal,
        nome_produto as produto,
        SUM(valor) as receita_bruta_antiga,
        SUM(valor_final_calculado) as receita_liquida_antiga,
        SUM(quantidade) as qtd_antiga
    FROM `iron-rex-461220-g4.database_aroom_health.view_vendas`
    WHERE situacao_id NOT IN (12, 105)
    GROUP BY 1, 2, 3
),
new_sales AS (
    SELECT 
        data_venda,
        origem_agrupada as canal,
        produto,
        ANY_VALUE(familia_produto) as familia_produto,
        ANY_VALUE(objetivo_produto) as objetivo_produto,
        ANY_VALUE(etapa_jornada_produto) as etapa_jornada_produto,
        ANY_VALUE(nivel_especializacao) as nivel_especializacao,
        ANY_VALUE(faixa_valor_produto) as faixa_valor_produto,
        ANY_VALUE(potencial_recorrencia) as potencial_recorrencia,
        ANY_VALUE(categoria_produto) as categoria_produto,
        ANY_VALUE(subcategoria_produto) as subcategoria_produto,
        SUM(receita_liquida) as receita_liquida_nova,
        SUM(receita_bruta) as receita_bruta_nova,
        SUM(quantidade_comprada) as qtd_nova
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
    GROUP BY 1, 2, 3
)
SELECT 
    COALESCE(n.data_venda, o.data_venda) as data_venda,
    COALESCE(n.canal, o.canal) as canal,
    COALESCE(n.produto, o.produto) as produto,
    
    n.familia_produto,
    n.objetivo_produto,
    n.etapa_jornada_produto,
    n.nivel_especializacao,
    n.faixa_valor_produto,
    n.potencial_recorrencia,
    n.categoria_produto,
    n.subcategoria_produto,
    
    IFNULL(n.qtd_nova, 0) as qtd_nova,
    IFNULL(o.qtd_antiga, 0) as qtd_antiga,
    
    IFNULL(o.receita_bruta_antiga, 0) as receita_bruta,
    IFNULL(n.receita_bruta_nova, 0) as receita_bruta_nova,
    
    IFNULL(o.receita_liquida_antiga, 0) as receita_liquida,
    IFNULL(n.receita_liquida_nova, 0) as receita_liquida_nova,
    
    -- Cálculos de Diferença (Deltas)
    (IFNULL(n.receita_bruta_nova, 0) - IFNULL(o.receita_bruta_antiga, 0)) as diferenca_bruta,
    (IFNULL(n.receita_liquida_nova, 0) - IFNULL(o.receita_liquida_antiga, 0)) as diferenca_liquida
FROM new_sales n
FULL OUTER JOIN old_sales o 
    ON n.data_venda = o.data_venda 
    AND n.canal = o.canal 
    AND n.produto = o.produto
