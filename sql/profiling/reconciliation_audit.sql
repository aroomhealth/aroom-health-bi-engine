-- ==============================================================================
-- AUDITORIA E RECONCILIAÇÃO: GA4 Recovery
-- DESCRICAO: Consultas para verificar a completude, qualidade e reconciliação
--            dos dados históricos recuperados no dataset analytics_recovery.
-- ==============================================================================

-- 1. Verificação de Cobertura Temporal e Dias Preenchidos
SELECT 
  'ga4_recovery_traffic_sources' as tabela,
  MIN(date) as data_minima,
  MAX(date) as data_maxima,
  COUNT(DISTINCT date) as dias_com_dados,
  SUM(sessions) as total_sessoes_recuperadas,
  SUM(activeUsers) as total_usuarios_ativos_recuperados,
  SUM(conversions) as total_conversoes_recuperadas
FROM `iron-rex-461220-g4.analytics_recovery.ga4_recovery_traffic_sources`;


-- 2. Teste de Duplicidade de Chaves Primárias
SELECT 
  date,
  sessionSource,
  sessionMedium,
  sessionCampaignName,
  COUNT(*) as duplicados
FROM `iron-rex-461220-g4.analytics_recovery.ga4_recovery_traffic_sources`
GROUP BY 1, 2, 3, 4
HAVING duplicados > 1;


-- 3. Comparação das Médias Diárias: Recuperado vs Produção Nativa (Adjacentes)
-- Este teste verifica se a volumetria dos dados recuperados está coerente
-- com o comportamento dos dados nativos imediatamente antes e depois do gap.
WITH nativo_antes AS (
  SELECT 
    'Nativo (Antes)' as origem,
    AVG(sessoes_diarias) as media_sessoes_dia,
    AVG(usuarios_diarios) as media_usuarios_dia
  FROM (
    SELECT 
      _TABLE_SUFFIX as data,
      COUNT(DISTINCT CONCAT(user_pseudo_id, (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id'))) as sessoes_diarias,
      COUNT(DISTINCT user_pseudo_id) as usuarios_diarios
    FROM `iron-rex-461220-g4.analytics_414017556.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20251128' AND '20251204'
    GROUP BY 1
  )
),
recuperado AS (
  SELECT 
    'Recuperado (Gap)' as origem,
    AVG(sessoes_diarias) as media_sessoes_dia,
    AVG(usuarios_diarios) as media_usuarios_dia
  FROM (
    SELECT 
      date,
      SUM(sessions) as sessoes_diarias,
      SUM(activeUsers) as usuarios_diarios
    FROM `iron-rex-461220-g4.analytics_recovery.ga4_recovery_traffic_sources`
    GROUP BY 1
  )
),
nativo_depois AS (
  SELECT 
    'Nativo (Depois)' as origem,
    AVG(sessoes_diarias) as media_sessoes_dia,
    AVG(usuarios_diarios) as media_usuarios_dia
  FROM (
    SELECT 
      _TABLE_SUFFIX as data,
      COUNT(DISTINCT CONCAT(user_pseudo_id, (SELECT value.int_value FROM UNNEST(event_params) WHERE key = 'ga_session_id'))) as sessoes_diarias,
      COUNT(DISTINCT user_pseudo_id) as usuarios_diarios
    FROM `iron-rex-461220-g4.analytics_414017556.events_*`
    WHERE _TABLE_SUFFIX BETWEEN '20260611' AND '20260615'
    GROUP BY 1
  )
)
SELECT * FROM nativo_antes
UNION ALL
SELECT * FROM recuperado
UNION ALL
SELECT * FROM nativo_depois;


-- 4. Reconciliação Contábil de E-commerce: GA4 Recovery vs ERP Bling (view_vendas)
-- Compara as transações e receita recuperadas via API do GA4 com o faturamento real do ERP.
WITH ga4_sales AS (
  SELECT 
    date,
    SUM(purchaseRevenue) as receita_ga4,
    COUNT(DISTINCT transactionId) as transacoes_ga4
  FROM `iron-rex-461220-g4.analytics_recovery.ga4_recovery_ecommerce`
  GROUP BY 1
),
bling_sales AS (
  SELECT 
    data_compra as date,
    SUM(valor * quantidade) as receita_erp,
    COUNT(DISTINCT identificador) as transacoes_erp
  FROM `iron-rex-461220-g4.database_aroom_health.view_vendas`
  WHERE data_compra BETWEEN '2025-12-11' AND '2026-06-10'
  GROUP BY 1
)
SELECT 
  g.date,
  g.transacoes_ga4,
  b.transacoes_erp,
  ROUND(100 * g.transacoes_ga4 / NULLIF(b.transacoes_erp, 0), 2) as taxa_captura_pedidos,
  g.receita_ga4,
  b.receita_erp,
  ROUND(100 * g.receita_ga4 / NULLIF(b.receita_erp, 0), 2) as taxa_captura_receita
FROM ga4_sales g
JOIN bling_sales b ON g.date = b.date
ORDER BY date ASC;
