-- ==============================================================================
-- VIEW: v_roas_por_campanha
-- DATASET: marketing_attribution
-- DESCRICAO: Modelo principal de ROAS. Cruza receita atribuída via GA4 com
--            custo de campanha do Google Ads via tabela de-para campaign_name_mapping.
--            Granularidade: campanha × dia.
-- FÓRMULA: ROAS = Receita Atribuída (Bling) / Custo da Campanha (Google Ads)
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.marketing_attribution.v_roas_por_campanha` AS

WITH

-- Receita do Bling atribuída ao Google Ads por utm_campaign e dia (via GA4)
receita_google_por_campanha_dia AS (
    SELECT
        po.data_pedido                          AS data,
        po.utm_campaign                         AS campanha_utm,
        COUNT(DISTINCT po.pedido_id)            AS pedidos_atribuidos,
        ROUND(SUM(po.receita_bling), 2)         AS receita_bling_atribuida,
        ROUND(SUM(po.receita_ga4),   2)         AS receita_ga4_atribuida
    FROM `iron-rex-461220-g4.marketing_attribution.v_pedidos_com_origem` po
    WHERE po.canal_marketing = 'Google Ads (Pago)'
      AND po.utm_campaign IS NOT NULL
      AND po.utm_campaign NOT IN ('(sem rastreamento)', '(not set)', '(direct)')
    GROUP BY data, campanha_utm
),

-- Custo real do Google Ads por campanha e dia
-- com traducao do nome via de-para -> utm_campaign
custo_google_por_campanha_dia AS (
    SELECT
        DATE(cs._PARTITIONTIME)                      AS data,
        cam.campaign_name                            AS campanha_ads,
        cs.campaign_id,
        COALESCE(dp.utm_campaign, cam.campaign_name) AS campanha_utm_normalizada,
        COALESCE(dp.campaign_grupo, 'Sem Grupo')     AS campaign_grupo,
        COALESCE(dp.ativa, FALSE)                    AS campanha_ativa,
        ROUND(SUM(cs.metrics_cost_micros) / 1000000, 2) AS custo_dia,
        SUM(cs.metrics_clicks)                       AS cliques,
        SUM(cs.metrics_impressions)                  AS impressoes,
        ROUND(SUM(cs.metrics_conversions), 0)        AS conversoes_ads
    FROM `iron-rex-461220-g4.google_ads.p_ads_CampaignStats_5644422842` cs
    LEFT JOIN (
        SELECT DISTINCT campaign_id, ANY_VALUE(campaign_name) AS campaign_name
        FROM `iron-rex-461220-g4.google_ads.p_ads_Campaign_5644422842`
        GROUP BY campaign_id
    ) cam ON cs.campaign_id = cam.campaign_id
    LEFT JOIN `iron-rex-461220-g4.marketing_attribution.campaign_name_mapping` dp
        ON cam.campaign_name = dp.nome_google_ads
    WHERE cs._PARTITIONTIME IS NOT NULL
      AND cs.metrics_cost_micros > 0
    GROUP BY data, cam.campaign_name, cs.campaign_id, campanha_utm_normalizada, campaign_grupo, campanha_ativa
)

SELECT
    COALESCE(r.data, cu.data)                        AS data,
    DATE_TRUNC(COALESCE(r.data, cu.data), MONTH)     AS mes,

    cu.campanha_ads                                  AS nome_campanha_google_ads,
    COALESCE(r.campanha_utm, cu.campanha_utm_normalizada) AS campanha_utm,
    cu.campaign_grupo,
    cu.campaign_id,
    cu.campanha_ativa,

    COALESCE(cu.custo_dia,       0)                  AS custo_google_ads,
    COALESCE(cu.cliques,         0)                  AS cliques,
    COALESCE(cu.impressoes,      0)                  AS impressoes,
    COALESCE(cu.conversoes_ads,  0)                  AS conversoes_google_ads,

    COALESCE(r.pedidos_atribuidos,      0)           AS pedidos_atribuidos,
    COALESCE(r.receita_bling_atribuida, 0)           AS receita_bling_atribuida,
    COALESCE(r.receita_ga4_atribuida,   0)           AS receita_ga4_atribuida,

    ROUND(SAFE_DIVIDE(
        COALESCE(r.receita_bling_atribuida, 0),
        NULLIF(COALESCE(cu.custo_dia, 0), 0)
    ), 2)                                            AS roas,

    ROUND(SAFE_DIVIDE(
        COALESCE(cu.custo_dia, 0),
        NULLIF(COALESCE(r.pedidos_atribuidos, 0), 0)
    ), 2)                                            AS cac_por_pedido,

    ROUND(SAFE_DIVIDE(
        COALESCE(cu.custo_dia, 0),
        NULLIF(COALESCE(cu.cliques, 0), 0)
    ), 4)                                            AS cpc,

    ROUND(SAFE_DIVIDE(
        COALESCE(cu.cliques, 0),
        NULLIF(COALESCE(cu.impressoes, 0), 0)
    ) * 100, 2)                                      AS ctr,

    ROUND(SAFE_DIVIDE(
        COALESCE(r.pedidos_atribuidos, 0),
        NULLIF(COALESCE(cu.cliques, 0), 0)
    ) * 100, 2)                                      AS taxa_conversao_pct,

    CASE
        WHEN SAFE_DIVIDE(COALESCE(r.receita_bling_atribuida, 0), NULLIF(COALESCE(cu.custo_dia, 0), 0)) >= 4 THEN 'ROAS Excelente (>=4x)'
        WHEN SAFE_DIVIDE(COALESCE(r.receita_bling_atribuida, 0), NULLIF(COALESCE(cu.custo_dia, 0), 0)) >= 2 THEN 'ROAS Aceitavel (2x-4x)'
        WHEN SAFE_DIVIDE(COALESCE(r.receita_bling_atribuida, 0), NULLIF(COALESCE(cu.custo_dia, 0), 0)) >= 1 THEN 'ROAS Baixo (1x-2x)'
        WHEN COALESCE(cu.custo_dia, 0) > 0 AND COALESCE(r.receita_bling_atribuida, 0) = 0 THEN 'Sem Conversao'
        ELSE 'Sem Dados de Custo'
    END AS status_roas

FROM receita_google_por_campanha_dia r
FULL OUTER JOIN custo_google_por_campanha_dia cu
    ON r.data          = cu.data
    AND r.campanha_utm = cu.campanha_utm_normalizada

ORDER BY data DESC, custo_google_ads DESC
