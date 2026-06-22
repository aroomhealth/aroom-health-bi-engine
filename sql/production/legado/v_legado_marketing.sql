-- ==============================================================================
-- VIEW: v_legado_marketing
-- DATASET: legado
-- DESCRICAO: Consolida o investimento em ads de TODOS os canais pagos:
--            Meta/Facebook, Mercado Livre Ads, Shopee Ads, TikTok Ads e
--            Google Ads (legado). Permite análise de share of spend por canal.
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.legado.v_legado_marketing` AS

-- Meta Ads
SELECT
    'Meta Ads'                              AS canal,
    CAST(NULL AS DATE)                      AS data,
    ma.campaign_id,
    ma.campaign_name                        AS campanha,
    ma.adset_name                           AS conjunto_anuncio,
    ROUND(ma.spend, 2)                      AS investimento,
    ma.impressions,
    ma.clicks,
    ROUND(SAFE_DIVIDE(ma.clicks, NULLIF(ma.impressions, 0)) * 100, 2) AS ctr_pct,
    ROUND(SAFE_DIVIDE(ma.spend, NULLIF(ma.clicks, 0)), 4)             AS cpc_calculado,
    CAST(ma.website_purchase_roas AS FLOAT64)  AS conversoes_valor,   -- ROAS de compra no site (sem 'purchase' direto)
    CAST(ma.purchase_roas AS FLOAT64)          AS roas
FROM `iron-rex-461220-g4.database_aroom_health.meta_ads` ma
WHERE ma.spend > 0

UNION ALL

-- Facebook Ads Insights (legado)
SELECT
    'Facebook Ads (Legado)'                 AS canal,
    fa.date                                 AS data,
    CAST(fa.campaign_id AS STRING),
    fa.campaign_name,
    CAST(NULL AS STRING)                    AS conjunto_anuncio,
    ROUND(fa.spend, 2),
    fa.impressions,
    fa.clicks,
    ROUND(fa.ctr * 100, 2),
    ROUND(fa.cpc, 4),
    fa.purchase,
    ROUND(SAFE_DIVIDE(fa.purchase, NULLIF(fa.spend, 0)), 2)
FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights` fa
WHERE fa.spend > 0

UNION ALL

-- Mercado Livre Ads
SELECT
    'Mercado Livre Ads',
    ml.date,
    CAST(ml.campaign_id AS STRING),
    ml.campaign_name,
    CAST(NULL AS STRING),
    ROUND(CAST(ml.spend AS FLOAT64), 2),
    ml.impressions,
    ml.clicks,
    ROUND(CAST(ml.ctr AS FLOAT64) * 100, 2),
    ROUND(CAST(ml.cpc AS FLOAT64), 4),
    CAST(ml.purchase AS FLOAT64),
    ROUND(SAFE_DIVIDE(CAST(ml.purchase AS FLOAT64), NULLIF(CAST(ml.spend AS FLOAT64), 0)), 2)
FROM `iron-rex-461220-g4.database_aroom_health.mercadolivre_ads_insights` ml
WHERE ml.spend > 0

UNION ALL

-- Shopee Ads
SELECT
    'Shopee Ads',
    sh.date,
    CAST(sh.campaign_id AS STRING),
    sh.campaign_name,
    CAST(NULL AS STRING),
    ROUND(CAST(sh.spend AS FLOAT64), 2),
    sh.impressions,
    sh.clicks,
    ROUND(CAST(sh.ctr AS FLOAT64) * 100, 2),
    ROUND(CAST(sh.cpc AS FLOAT64), 4),
    CAST(sh.purchase AS FLOAT64),
    ROUND(SAFE_DIVIDE(CAST(sh.purchase AS FLOAT64), NULLIF(CAST(sh.spend AS FLOAT64), 0)), 2)
FROM `iron-rex-461220-g4.database_aroom_health.shopee_ads_insights` sh
WHERE sh.spend > 0

UNION ALL

-- TikTok Ads (usa coluna `date`, não `stat_time_day`)
SELECT
    'TikTok Ads',
    tk.date,
    CAST(tk.campaign_id AS STRING),
    tk.campaign_name,
    CAST(NULL AS STRING),
    CAST(tk.spend AS FLOAT64),
    tk.impressions,
    tk.clicks,
    CAST(tk.ctr AS FLOAT64),
    CAST(tk.cpc AS FLOAT64),
    CAST(tk.purchase AS FLOAT64),
    ROUND(SAFE_DIVIDE(CAST(tk.purchase AS FLOAT64), NULLIF(CAST(tk.spend AS FLOAT64), 0)), 2)
FROM `iron-rex-461220-g4.database_aroom_health.tiktok_ads_insights` tk
WHERE tk.spend > 0

UNION ALL

-- Google Ads Legado (pré-DTS)
SELECT
    'Google Ads (Legado)',
    ga.day,
    CAST(NULL AS STRING),
    ga.campaign_name,
    CAST(NULL AS STRING),
    ROUND(ga.cost_spend, 2),
    ga.impressions,
    ga.clicks,
    ROUND(ga.ctr * 100, 2),
    ROUND(ga.avg_cpc, 4),
    ga.total_conv_value,
    ROUND(ga.value_conv, 2)
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance` ga
WHERE ga.cost_spend > 0
