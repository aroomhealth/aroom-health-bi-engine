-- ==============================================================================
-- VIEW: v_pedidos_com_origem
-- DATASET: marketing_attribution
-- DESCRICAO: Enriquece cada pedido do Bling com a origem de marketing
--            identificada pelo GA4 (via transactionId = numero do pedido).
--            É a base de toda a cadeia de atribuição de ROAS.
-- ATUALIZAÇÃO: Diária (dependente do export do GA4 analytics_recovery + BQ nativo)
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.marketing_attribution.v_pedidos_com_origem` AS

WITH 

-- GA4 Recovery (período histórico: 11/12/2025 → 10/06/2026)
ga4_historico AS (
    SELECT
        SAFE_CAST(transactionId AS INT64)   AS numero_pedido,
        sessionSource                        AS utm_source,
        sessionMedium                        AS utm_medium,
        CAST(NULL AS STRING)                 AS utm_campaign, -- não disponível na tabela de ecommerce
        purchaseRevenue                      AS receita_ga4,
        date                                 AS data_sessao,
        'recovery_api'                       AS origem_dado
    FROM `iron-rex-461220-g4.analytics_recovery.ga4_recovery_ecommerce`
    WHERE purchaseRevenue > 0
      AND SAFE_CAST(transactionId AS INT64) IS NOT NULL
),

-- GA4 Nativo BigQuery (export diário corrente)  
ga4_nativo AS (
    SELECT
        SAFE_CAST(ecommerce.transaction_id AS INT64) AS numero_pedido,
        traffic_source.source                         AS utm_source,
        traffic_source.medium                         AS utm_medium,
        traffic_source.name                           AS utm_campaign,
        ecommerce.purchase_revenue                    AS receita_ga4,
        DATE(TIMESTAMP_MICROS(CAST(event_timestamp AS INT64)), 'America/Sao_Paulo') AS data_sessao,
        'bq_native_export'                            AS origem_dado
    FROM `iron-rex-461220-g4.analytics_414017556.events_*`
    WHERE event_name = 'purchase'
      AND ecommerce.transaction_id IS NOT NULL
      AND SAFE_CAST(ecommerce.transaction_id AS INT64) IS NOT NULL
),

-- Unificação das duas fontes GA4 (histórico + nativo), sem duplicar pedidos
ga4_unificado AS (
    -- Prioriza o dado nativo; para pedidos sem cobertura nativa, usa o recovery
    SELECT * FROM ga4_nativo
    UNION ALL
    SELECT h.*
    FROM ga4_historico h
    WHERE NOT EXISTS (
        SELECT 1 FROM ga4_nativo n WHERE n.numero_pedido = h.numero_pedido
    )
)

-- Resultado final: cada pedido + sua origem
SELECT
    p.identificador                                          AS pedido_id,
    p.numero                                                 AS numero_pedido,
    p.data                                                   AS data_pedido,
    p.total                                                  AS receita_bling,
    p.contato_id                                             AS cliente_id,
    p.loja_id                                                AS loja_id,

    -- Atribuição GA4
    COALESCE(g.utm_source,   '(sem rastreamento)')           AS utm_source,
    COALESCE(g.utm_medium,   '(sem rastreamento)')           AS utm_medium,
    COALESCE(g.utm_campaign, '(sem rastreamento)')           AS utm_campaign,
    g.receita_ga4,
    g.origem_dado                                            AS origem_atribuicao,

    -- Canal macro agrupado
    CASE
        WHEN LOWER(COALESCE(g.utm_source, '')) IN ('google') 
         AND LOWER(COALESCE(g.utm_medium, '')) IN ('cpc', 'ppc') THEN 'Google Ads (Pago)'
        WHEN LOWER(COALESCE(g.utm_source, '')) IN ('ig', 'instagram', 'fb', 'facebook', 'meta')
         AND LOWER(COALESCE(g.utm_medium, '')) NOT IN ('organic', 'referral') THEN 'Meta Ads (Pago)'
        WHEN LOWER(COALESCE(g.utm_medium, '')) = 'organic' THEN 'Orgânico (SEO)'
        WHEN LOWER(COALESCE(g.utm_source, '')) = '(direct)' THEN 'Direto'
        WHEN LOWER(COALESCE(g.utm_medium, '')) = 'referral' THEN 'Referral'
        WHEN g.utm_source IS NULL THEN 'Não Rastreado'
        ELSE 'Outros'
    END AS canal_marketing,

    -- Flag: pedido tem atribuição?
    CASE WHEN g.numero_pedido IS NOT NULL THEN TRUE ELSE FALSE END AS tem_atribuicao_ga4

FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p
LEFT JOIN ga4_unificado g
    ON p.numero = g.numero_pedido
WHERE p.situacao_id NOT IN (12, 105)  -- exclui cancelados e devolvidos
