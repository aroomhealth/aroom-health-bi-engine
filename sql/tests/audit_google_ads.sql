-- ==============================================================================
-- AUDITORIA: Google Ads
-- DESCRICAO: Validacoes da tabela de custo e performance de campanhas.
--            Confirma a data limite de ingestao e identifica discrepancias.
-- ==============================================================================

-- 1. Checagem Geral de Freshness e Volume
SELECT 
    COUNT(*) as total_registros,
    MIN(day) as data_inicial,
    MAX(day) as data_final,
    COUNT(DISTINCT campaign_name) as total_campanhas_unicas,
    SUM(cost_spend) as custo_total_acumulado,
    SUM(clicks) as cliques_totais
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`;


-- 2. Tendencia Diaria Recente (Auditoria do Congelamento em 12/12/2025)
SELECT 
    day,
    COUNT(*) as registros,
    SUM(cost_spend) as custo_dia,
    SUM(clicks) as cliques_dia
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`
WHERE day >= '2025-12-05' AND day <= '2025-12-20'
GROUP BY day
ORDER BY day ASC;


-- 3. Identificacao de Campanhas com Custo mas sem Conversao
SELECT 
    campaign_name,
    MIN(day) as inicio_campanha,
    MAX(day) as fim_campanha,
    SUM(cost_spend) as custo_total,
    SUM(conversions) as conversoes_totais
FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`
GROUP BY campaign_name
HAVING custo_total > 0 AND conversoes_totais = 0
ORDER BY custo_total DESC
LIMIT 10;
