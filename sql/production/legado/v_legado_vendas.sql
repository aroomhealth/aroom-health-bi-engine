-- ==============================================================================
-- VIEW: v_legado_vendas
-- DATASET: legado
-- DESCRICAO: Consolida os pedidos brutos dos marketplaces (Mercado Livre,
--            Nuvemshop e Shopee) enriquecidos com o pedido correspondente no
--            Bling. Útil para rastrear status de entrega, fulfillment e dados
--            do comprador que o Bling não replica.
--            IMPORTANTE: O faturamento financeiro já está consolidado em
--            pedidos_vendas via loja_id. Esta view agrega dados OPERACIONAIS.
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.legado.v_legado_vendas` AS

WITH bling_base AS (
    SELECT
        pv.identificador    AS pedido_bling_id,
        pv.numero           AS numero_pedido_bling,
        pv.data             AS data_pedido,
        pv.total            AS valor_total,
        pv.loja_id,
        pv.situacao_id,
        c.canal_edit        AS canal_venda
    FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` pv
    LEFT JOIN `iron-rex-461220-g4.database_aroom_health.bling_canais_venda` c
        ON CAST(pv.loja_id AS STRING) = CAST(c.id_canal AS STRING)
    WHERE pv.situacao_id NOT IN (12, 105)
)

-- Mercado Livre
SELECT
    'Mercado Livre'                         AS marketplace,
    CAST(ml.number AS STRING)               AS numero_pedido_marketplace,
    ml.contact_name                         AS nome_comprador,
    ml.contact_email                        AS email_comprador,
    ml.contact_identification               AS cpf_comprador,
    ml.status                               AS status_marketplace,
    ml.status_detail                        AS detalhe_status,
    ml.payment_status                       AS status_pagamento,
    ml.financial_status                     AS status_financeiro,
    ml.fulfillment_status                   AS status_entrega,
    CAST(NULL AS DATE)                      AS data_pedido_marketplace,
    b.pedido_bling_id,
    b.data_pedido,
    b.valor_total,
    b.canal_venda
FROM `iron-rex-461220-g4.database_aroom_health.mercadolivre_pedidos` ml
LEFT JOIN bling_base b
    ON ml.loja_id = b.loja_id

UNION ALL

-- Nuvemshop (site próprio)
SELECT
    'Nuvemshop'                             AS marketplace,
    CAST(ns.number AS STRING)               AS numero_pedido_marketplace,
    ns.contact_name                         AS nome_comprador,
    ns.contact_email                        AS email_comprador,
    ns.contact_identification               AS cpf_comprador,
    ns.payment_status                       AS status_marketplace,
    ns.financial_status                     AS detalhe_status,
    ns.payment_status                       AS status_pagamento,
    ns.financial_status                     AS status_financeiro,
    ns.fulfillment_status                   AS status_entrega,
    CAST(NULL AS DATE)                      AS data_pedido_marketplace,
    b.pedido_bling_id,
    b.data_pedido,
    b.valor_total,
    b.canal_venda
FROM `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos` ns
LEFT JOIN bling_base b
    ON ns.store_id = b.loja_id

UNION ALL

-- Shopee
SELECT
    'Shopee'                                AS marketplace,
    sp.number                               AS numero_pedido_marketplace,
    sp.contact_name                         AS nome_comprador,
    sp.contact_email                        AS email_comprador,
    sp.contact_identification               AS cpf_comprador,
    sp.status                               AS status_marketplace,
    sp.status_detail                        AS detalhe_status,
    sp.payment_status                       AS status_pagamento,
    sp.financial_status                     AS status_financeiro,
    sp.fulfillment_status                   AS status_entrega,
    CAST(NULL AS DATE)                      AS data_pedido_marketplace,
    b.pedido_bling_id,
    b.data_pedido,
    b.valor_total,
    b.canal_venda
FROM `iron-rex-461220-g4.database_aroom_health.shopee_pedidos` sp
LEFT JOIN bling_base b
    ON sp.loja_id = b.loja_id
