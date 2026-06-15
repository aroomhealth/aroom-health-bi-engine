-- ==============================================================================
-- PROFILE ALL TABLES - AROOM HEALTH BI ENGINE
-- DESCRICAO: Scripts consolidados para auditoria geral e testes de integridade.
-- ==============================================================================

-- 1. pedidos_vendas
SELECT 'pedidos_vendas' as tabela, COUNT(*) as total_rows, COUNT(DISTINCT identificador) as distinct_ids, MIN(data) as min_date, MAX(data) as max_date FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`;

-- 2. pedidos_vendas_itens
SELECT 'pedidos_vendas_itens' as tabela, COUNT(*) as total_rows, COUNT(DISTINCT identificador) as distinct_ids, COUNTIF(produto_id IS NULL) as null_products FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens`;

-- 3. produtos
SELECT 'produtos' as tabela, COUNT(*) as total_rows, COUNT(DISTINCT identificador) as distinct_ids, COUNTIF(preco_custo = 0) as zero_costs FROM `iron-rex-461220-g4.database_aroom_health.produtos`;

-- 4. pedidos_vendas_transporte
SELECT 'pedidos_vendas_transporte' as tabela, COUNT(*) as total_rows, COUNT(DISTINCT id) as distinct_ids, COUNTIF(frete IS NULL) as null_freight FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_transporte`;

-- 5. bling_canais_venda
SELECT 'bling_canais_venda' as tabela, COUNT(*) as total_rows, COUNT(DISTINCT id) as distinct_ids FROM `iron-rex-461220-g4.database_aroom_health.bling_canais_venda`;

-- 6. google_ads_campaign_performance
SELECT 'google_ads_campaign_performance' as tabela, COUNT(*) as total_rows, MIN(day) as min_date, MAX(day) as max_date, SUM(cost_spend) as total_spend FROM `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance`;

-- 7. google_analytics_utm_daily
SELECT 'google_analytics_utm_daily' as tabela, COUNT(*) as total_rows, SUM(sessions) as total_sessions FROM `iron-rex-461220-g4.database_aroom_health.google_analytics_utm_daily`;

-- 8. growth_engine_vendas_detalhado (Semantic View)
SELECT 'growth_engine_vendas_detalhado' as tabela, COUNT(*) as total_rows, SUM(receita_total) as total_revenue, COUNTIF(custo_total_produto = 0) as zero_cogs FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`;
