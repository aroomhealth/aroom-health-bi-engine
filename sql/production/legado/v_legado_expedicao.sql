-- ==============================================================================
-- VIEW: v_legado_expedicao
-- DATASET: legado
-- DESCRICAO: Tracking unificado de expedição/logística dos marketplaces.
--            Consolida os eventos de rastreamento do Mercado Livre, Shopee
--            e orders_tracking (tracking geral) para acompanhamento de SLA.
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.legado.v_legado_expedicao` AS

-- Orders Tracking (geral - todos marketplaces)
SELECT
    ot.marketplace                          AS marketplace,
    ot.order_id                             AS pedido_id,
    ot.loja_id,
    DATE(ot.event_date)                     AS data_evento,
    ot.status                               AS status_logistica,
    ot.description                          AS descricao_evento,
    DATE(ot.created_at)                     AS data_registro

FROM `iron-rex-461220-g4.database_aroom_health.orders_tracking` ot

UNION ALL

-- Mercado Livre Tracking
SELECT
    'Mercado Livre'                         AS marketplace,
    mlt.pedido_id                           AS pedido_id,
    mlt.loja_id,
    DATE(mlt.event_date)                    AS data_evento,
    mlt.status                              AS status_logistica,
    mlt.description                         AS descricao_evento,
    DATE(mlt.created_at)                    AS data_registro

FROM `iron-rex-461220-g4.database_aroom_health.mercadolivre_order_tracking` mlt

UNION ALL

-- Shopee Tracking
SELECT
    'Shopee'                                AS marketplace,
    sht.pedido_id                           AS pedido_id,
    sht.loja_id,
    DATE(sht.event_date)                    AS data_evento,
    sht.status                              AS status_logistica,
    sht.description                         AS descricao_evento,
    DATE(sht.created_at)                    AS data_registro

FROM `iron-rex-461220-g4.database_aroom_health.shopee_order_tracking` sht
