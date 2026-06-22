WITH base AS (
    SELECT 
        p.identificador as pedido_id,
        p.data as data_venda,
        c.canal_edit as canal,
        c.canal as canal_raw,
        i.valor * i.quantidade as receita_bruta,
        prod.situacao as is_ativo
    FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p
    JOIN `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens` i ON p.identificador = i.pedidos_vendas_identificador
    LEFT JOIN `iron-rex-461220-g4.database_aroom_health.produtos` prod ON i.produto_id = prod.identificador
    LEFT JOIN `iron-rex-461220-g4.database_aroom_health.bling_canais_venda` c ON CAST(p.loja_id AS STRING) = CAST(c.id_canal AS STRING)
    WHERE p.situacao_id NOT IN (12, 105)
      AND DATE(p.data) BETWEEN '2026-05-01' AND '2026-05-31'
)
SELECT 
    '1. Receita Bruta Total do Bling' as visao,
    SUM(receita_bruta) as receita_bruta,
    COUNT(DISTINCT pedido_id) as qtd_pedidos
FROM base
UNION ALL
SELECT 
    '2. Receita Bruta apenas Site' as visao,
    SUM(receita_bruta),
    COUNT(DISTINCT pedido_id)
FROM base
WHERE REGEXP_CONTAINS(LOWER(COALESCE(canal, canal_raw, '')), r'site|magento|loja aroom')
UNION ALL
SELECT 
    '3. Receita Bruta apenas Produtos Ativos' as visao,
    SUM(receita_bruta),
    COUNT(DISTINCT pedido_id)
FROM base
WHERE is_ativo = 'A'
UNION ALL
SELECT 
    '4. Receita Bruta Produtos Ativos + Site' as visao,
    SUM(receita_bruta),
    COUNT(DISTINCT pedido_id)
FROM base
WHERE REGEXP_CONTAINS(LOWER(COALESCE(canal, canal_raw, '')), r'site|magento|loja aroom')
  AND is_ativo = 'A'
ORDER BY 1 ASC;
