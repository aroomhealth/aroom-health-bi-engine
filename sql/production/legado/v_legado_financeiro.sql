-- ==============================================================================
-- VIEW: v_legado_financeiro
-- DATASET: legado
-- DESCRICAO: DRE e fluxo de caixa consolidados via contas a pagar e receber.
--            Categorias de custo via contas_pagar_categorias (item_n1..n4).
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.legado.v_legado_financeiro` AS

-- CONTAS A RECEBER (Entradas)
SELECT
    'Receber'                               AS tipo_lancamento,
    cr.vencimento                           AS data_vencimento,
    cr.data_emissao,
    cr.valor,
    cr.situacao                             AS situacao_id,
    CASE cr.situacao
        WHEN 1 THEN 'Aberto'
        WHEN 2 THEN 'Recebido'
        WHEN 3 THEN 'Parcial'
        ELSE CAST(cr.situacao AS STRING)
    END                                     AS situacao_descricao,
    CAST(NULL AS STRING)                    AS forma_pagamento, -- tabela sem join direto por descricao
    CAST(NULL AS STRING)                    AS origem,
    CAST(NULL AS STRING)                    AS categoria,
    cr.identificador                        AS lancamento_id,
    cr.contato                              AS contato_id

FROM `iron-rex-461220-g4.database_aroom_health.contas_receber` cr

UNION ALL

-- CONTAS A PAGAR (Saídas)
SELECT
    'Pagar'                                 AS tipo_lancamento,
    cp.vencimento                           AS data_vencimento,
    cp.data_emissao,
    cp.valor,
    cp.situacao                             AS situacao_id,
    CASE cp.situacao
        WHEN 1 THEN 'Aberto'
        WHEN 2 THEN 'Pago'
        WHEN 3 THEN 'Parcial'
        WHEN 4 THEN 'Cancelado'
        ELSE CAST(cp.situacao AS STRING)
    END                                     AS situacao_descricao,
    CAST(NULL AS STRING)                    AS forma_pagamento,
    CAST(NULL AS STRING)                    AS origem,
    -- Categoria via contas_pagar_categorias: usa item_n1 como nivel principal
    COALESCE(cat.item_n1, CAST(cp.categoria_id AS STRING)) AS categoria,
    cp.identificador                        AS lancamento_id,
    cp.contato_identificador                AS contato_id

FROM `iron-rex-461220-g4.database_aroom_health.contas_pagar` cp
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.contas_pagar_categorias` cat
    ON cp.categoria_id = cat.categoria_id
