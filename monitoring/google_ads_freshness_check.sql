-- ==============================================================================
-- MONITORAMENTO: Google Ads Freshness
-- DESCRICAO: Valida se a carga diaria de publicidade do Google Ads ocorreu
--            conforme planejado.
-- ==============================================================================

SELECT 
    MAX(day) as ultima_data_dados,
    CURRENT_DATE() as data_atual,
    DATE_DIFF(CURRENT_DATE(), MAX(day), DAY) as dias_atraso,
    CASE 
        WHEN DATE_DIFF(CURRENT_DATE(), MAX(day), DAY) <= 1 THEN '✅ HEALTHY'
        ELSE '🚨 CRITICAL - Pipeline do Google Ads está atrasado/pausado!'
    END as status
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`;
