-- ==============================================================================
-- VIEW: v_legado_estoque
-- DATASET: legado
-- DESCRICAO: Posição de estoque atual por produto e depósito. Cruza
--            bling_estoque_saldos com catálogo e custos reais.
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.legado.v_legado_estoque` AS

SELECT
    es.produto_identificador                AS produto_id,  -- chave real na tabela
    p.codigo                                AS sku,
    p.nome                                  AS nome_produto,

    -- Estoque
    es.deposito_id,
    es.saldo_fisico,
    es.saldo_virtual,
    es.saldo_fisico_total,
    es.saldo_virtual_total,

    -- Custo e valor do estoque
    COALESCE(sc.custo_total_real, p.preco_custo, 0) AS custo_unitario,
    ROUND(es.saldo_fisico * COALESCE(sc.custo_total_real, p.preco_custo, 0), 2) AS valor_estoque_custo,
    ROUND(es.saldo_fisico * COALESCE(p.preco, 0), 2) AS valor_estoque_preco_venda,

    -- Status de cobertura (sem estoque_minimo/maximo — usar saldo_fisico como referencia)
    CASE
        WHEN es.saldo_fisico <= 0   THEN 'Ruptura'
        WHEN es.saldo_fisico <= 5   THEN 'Critico'
        WHEN es.saldo_fisico <= 10  THEN 'Baixo'
        ELSE 'Adequado'
    END                                     AS status_estoque,

    -- Contexto produto
    dp.Categoria_Produto                    AS categoria,
    dp.Categoria_Medidas                    AS categoria_medidas,
    p.preco                                 AS preco_venda,
    p.estoque                               AS estoque_bling,

    DATE(es.synced_at)                      AS data_sincronizacao

FROM `iron-rex-461220-g4.database_aroom_health.bling_estoque_saldos` es
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.produtos` p
    ON es.produto_identificador = p.identificador   -- chave correta
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.depara_produtos` dp
    ON p.codigo = dp.codigo
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.sku_custos_reais` sc
    ON p.codigo = sc.sku

WHERE p.situacao = 'A'
  AND es.saldo_fisico_total IS NOT NULL
