-- ==============================================================================
-- VIEW: v_legado_produtos
-- DATASET: legado
-- DESCRICAO: Catálogo enriquecido de produtos cruzando a tabela de produtos
--            do Bling com depara_produtos (categoria/SKU tratado) e
--            sku_custos_reais (custo real de produção/aquisição).
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.legado.v_legado_produtos` AS

SELECT
    p.identificador                                         AS produto_id,
    p.codigo                                                AS sku,
    p.nome                                                  AS nome_produto,
    p.preco                                                 AS preco_venda,
    p.preco_custo                                           AS custo_bling,
    COALESCE(sc.custo_total_real, p.preco_custo)            AS custo_real,

    -- Categoria (via depara_produtos — coluna real: Categoria_Produto)
    dp.Categoria_Produto                                    AS categoria,
    dp.Medidas_Formatadas                                   AS medidas,
    dp.Categoria_Medidas                                    AS categoria_medidas,
    dp.produto_tratado_v2                                   AS nome_tratado,
    dp.flag_full                                            AS flag_full_marketplace,
    dp.gerado_gemini                                        AS categoria_gerada_por_ia,

    -- Métricas de margem
    ROUND(p.preco - COALESCE(sc.custo_total_real, p.preco_custo, 0), 2) AS margem_bruta_unitaria,
    ROUND(SAFE_DIVIDE(
        p.preco - COALESCE(sc.custo_total_real, p.preco_custo, 0),
        NULLIF(p.preco, 0)
    ) * 100, 1)                                             AS pct_margem_bruta,

    -- Status
    p.situacao                                              AS situacao_produto,
    p.tipo                                                  AS tipo_produto,
    p.estoque                                               AS estoque_atual

FROM `iron-rex-461220-g4.database_aroom_health.produtos` p
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.depara_produtos` dp
    ON p.codigo = dp.codigo  -- chave real da depara_produtos
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.sku_custos_reais` sc
    ON p.codigo = sc.sku

WHERE p.situacao = 'A'
