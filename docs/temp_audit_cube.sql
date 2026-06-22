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
        SUM(valor_final_calculado) as receita_antiga,
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
    IFNULL(n.qtd_nova, 0) as qtd_nova,
    IFNULL(o.qtd_antiga, 0) as qtd_antiga,
    IFNULL(n.receita_bruta_nova, 0) as receita_bruta_nova,
    IFNULL(n.receita_liquida_nova, 0) as receita_liquida_nova,
    IFNULL(o.receita_antiga, 0) as receita_antiga,
    (IFNULL(n.receita_bruta_nova, 0) - IFNULL(o.receita_antiga, 0)) as diferenca_bruta,
    (IFNULL(n.receita_liquida_nova, 0) - IFNULL(o.receita_antiga, 0)) as diferenca_liquida
FROM new_sales n
FULL OUTER JOIN old_sales o 
    ON n.data_venda = o.data_venda 
    AND n.canal = o.canal 
    AND n.produto = o.produto
ORDER BY diferenca_bruta DESC
LIMIT 5;
