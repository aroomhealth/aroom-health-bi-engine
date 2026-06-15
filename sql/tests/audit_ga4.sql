-- ==============================================================================
-- AUDITORIA: Google Analytics 4 (GA4)
-- DESCRICAO: Analise de completude de UTMs, sessoes e canais de aquisicao
--            de trafego armazenados no BigQuery.
-- ==============================================================================

-- 1. Resumo Geral de Trafego e Datas
SELECT 
    COUNT(*) as total_linhas,
    MIN(metric_date) as data_inicial,
    MAX(metric_date) as data_final,
    COUNT(DISTINCT session_source) as fontes_unicas,
    COUNT(DISTINCT session_campaign_name) as campanhas_unicas,
    SUM(sessions) as sessoes_totais
FROM `iron-rex-461220-g4.database_aroom_health.google_analytics_utm_daily`;


-- 2. Analise de Presenca de UTMs (Completude)
SELECT 
    COUNT(*) as total_sessoes,
    COUNTIF(session_source IS NULL OR session_source = '') as sem_source,
    COUNTIF(session_medium IS NULL OR session_medium = '') as sem_medium,
    COUNTIF(session_campaign_name IS NULL OR session_campaign_name = '' OR session_campaign_name = '(referral)' OR session_campaign_name = '(direct)') as sem_campanha,
    ROUND(100 * COUNTIF(session_campaign_name IS NULL OR session_campaign_name = '' OR session_campaign_name = '(referral)' OR session_campaign_name = '(direct)') / COUNT(*), 2) as pct_sem_campanha_marketing
FROM `iron-rex-461220-g4.database_aroom_health.google_analytics_utm_daily`;


-- 3. Top Fontes de Trafego e Sessoes
SELECT 
    session_source,
    session_medium,
    SUM(sessions) as sessoes,
    ROUND(100 * SUM(sessions) / SUM(SUM(sessions)) OVER(), 2) as pct_sessoes
FROM `iron-rex-461220-g4.database_aroom_health.google_analytics_utm_daily`
GROUP BY session_source, session_medium
ORDER BY sessoes DESC
LIMIT 10;
