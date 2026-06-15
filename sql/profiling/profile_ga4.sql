-- ==============================================================================
-- PROFILING: GA4 & google_analytics_utm_daily
-- DESCRICAO: Audita sessões, integridade de UTMs de tráfego e datas de navegação.
-- ==============================================================================

-- 1. Auditoria da Tabela Consolidada de UTMs (google_analytics_utm_daily)
SELECT
    'google_analytics_utm_daily' as tabela,
    COUNT(*) as total_registros,
    SUM(sessions) as total_sessoes,
    MIN(metric_date) as data_minima,
    MAX(metric_date) as data_maxima,
    
    -- Qualidade de UTMs
    COUNTIF(session_source IS NULL OR session_source = '') as source_nulo_ou_vazio,
    COUNTIF(session_medium IS NULL OR session_medium = '') as medium_nulo_ou_vazio,
    COUNTIF(session_campaign_name IS NULL OR session_campaign_name = '') as campaign_nulo_ou_vazio,
    
    -- Fontes de tráfego conhecidas vs desconhecidas
    COUNTIF(LOWER(session_source) = '(direct)') as direct_traffic,
    COUNTIF(LOWER(session_source) LIKE '%google%') as google_traffic,
    COUNTIF(LOWER(session_source) LIKE '%facebook%' OR LOWER(session_source) LIKE '%instagram%') as meta_traffic

FROM `iron-rex-461220-g4.database_aroom_health.google_analytics_utm_daily`;


-- 2. Exemplo de Perfil de Eventos Brutos GA4 (analytics_414017556.events_*)
-- Este bloco pode ser executado para uma data específica (ex: 2026-06-14)
/*
SELECT
    event_date,
    event_name,
    COUNT(*) as total_eventos,
    COUNT(DISTINCT user_pseudo_id) as usuarios_unicos,
    COUNTIF(traffic_source.name IS NULL) as traffic_name_nulos
FROM `iron-rex-461220-g4.analytics_414017556.events_20260614`
GROUP BY event_date, event_name
ORDER BY total_eventos DESC;
*/
