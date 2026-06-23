CREATE OR REPLACE VIEW `iron-rex-461220-g4.marketing_attribution.v_gasto_diario` AS
SELECT 
    date AS data,
    'Facebook Ads' AS plataforma,
    campaign_name AS campanha,
    CAST(spend AS FLOAT64) AS gasto
FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights`

UNION ALL

SELECT 
    date AS data,
    'Google Ads' AS plataforma,
    sessionCampaignName AS campanha,
    CAST(advertiserAdCost AS FLOAT64) AS gasto
FROM `iron-rex-461220-g4.analytics_recovery.ga4_recovery_costs`
WHERE advertiserAdCost > 0

UNION ALL

SELECT 
    date AS data,
    'TikTok Ads' AS plataforma,
    campaign_name AS campanha,
    CAST(spend AS FLOAT64) AS gasto
FROM `iron-rex-461220-g4.database_aroom_health.tiktok_ads_insights`

UNION ALL

SELECT 
    date AS data,
    'Shopee Ads' AS plataforma,
    campaign_name AS campanha,
    CAST(spend AS FLOAT64) AS gasto
FROM `iron-rex-461220-g4.database_aroom_health.shopee_ads_insights`

UNION ALL

SELECT 
    date AS data,
    'Mercado Livre Ads' AS plataforma,
    campaign_name AS campanha,
    CAST(spend AS FLOAT64) AS gasto
FROM `iron-rex-461220-g4.database_aroom_health.mercadolivre_ads_insights`;
