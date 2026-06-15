-- ==============================================================================
-- PROFILING: database_aroom_health.google_ads_campaign_performance
-- DESCRICAO: Audita o histórico de campanhas de Ads, nulos, spend e data limite.
-- ==============================================================================

SELECT
    -- 1. Volume Geral
    COUNT(*) as total_registros,
    COUNT(DISTINCT campaign_name) as campanhas_distintas,
    
    -- 2. Integridade Temporal (Validação de Parada do DTS)
    MIN(day) as data_minima,
    MAX(day) as data_maxima, -- Confirma se o último registro é de 12/12/2025
    COUNTIF(day IS NULL) as dias_nulos,
    
    -- 3. Métricas de Desempenho e Custos
    SUM(clicks) as total_clicks,
    SUM(impressions) as total_impressoes,
    ROUND(SUM(cost_spend), 2) as investimento_total,
    ROUND(SUM(conversions), 2) as total_conversoes,
    
    -- 4. Anomalias e Nulos
    COUNTIF(campaign_name IS NULL OR TRIM(campaign_name) = '') as campanhas_sem_nome,
    COUNTIF(cost_spend IS NULL) as spend_nulo,
    COUNTIF(cost_spend < 0) as spend_negativo,
    COUNTIF(clicks IS NULL) as clicks_nulo,
    COUNTIF(impressions IS NULL) as impressoes_nulo

FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`;
