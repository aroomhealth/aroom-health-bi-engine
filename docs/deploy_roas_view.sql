CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_marketing_roas` AS
WITH ga4_daily AS (
    SELECT 
        metric_date as data_referencia,
        SUM(sessions) as sessoes_totais
    FROM `iron-rex-461220-g4.database_aroom_health.google_analytics_utm_daily`
    GROUP BY 1
),
ads_raw AS (
    -- Google Ads
    SELECT 
        DATE(segments_date) as data_referencia,
        CAST(SUM(metrics_cost_micros/1000000) AS FLOAT64) as investimento,
        SUM(metrics_clicks) as cliques,
        SUM(metrics_impressions) as impressoes
    FROM `iron-rex-461220-g4.google_ads.ads_CampaignStats_5644422842`
    GROUP BY 1
    
    UNION ALL
    
    -- Meta Ads (Facebook/Instagram)
    SELECT 
        date as data_referencia,
        CAST(spend AS FLOAT64) as investimento,
        clicks as cliques,
        impressions as impressoes
    FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights`
    
    UNION ALL
    
    -- TikTok Ads
    SELECT 
        date as data_referencia,
        CAST(spend AS FLOAT64) as investimento,
        clicks as cliques,
        impressions as impressoes
    FROM `iron-rex-461220-g4.database_aroom_health.tiktok_ads_insights`
),
ads_daily AS (
    SELECT 
        data_referencia,
        SUM(investimento) as investimento_total,
        SUM(cliques) as cliques_totais,
        SUM(impressoes) as impressoes_totais
    FROM ads_raw
    GROUP BY 1
),
vendas_daily AS (
    SELECT 
        data_venda as data_referencia,
        SUM(receita_total) as receita_ecommerce,
        SUM(lucro_bruto) as lucro_bruto_ecommerce,
        COUNT(DISTINCT pedido_id) as pedidos_ecommerce
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
    -- Filtramos para cruzar Ads apenas com o Site Próprio, ignorando Marketplaces
    WHERE origem_agrupada = 'Site Próprio (E-commerce)'
    GROUP BY 1
)

SELECT 
    COALESCE(v.data_referencia, g.data_referencia, a.data_referencia) as data_referencia,
    
    -- Funil de Tráfego e Custos
    COALESCE(g.sessoes_totais, 0) as sessoes_ga4,
    COALESCE(a.investimento_total, 0) as investimento_ads,
    COALESCE(a.cliques_totais, 0) as cliques_ads,
    
    -- Funil de Vendas Reais (Bling)
    COALESCE(v.pedidos_ecommerce, 0) as qtd_pedidos_site,
    COALESCE(v.receita_ecommerce, 0) as receita_bruta_site,
    COALESCE(v.lucro_bruto_ecommerce, 0) as lucro_bruto_site,
    
    -- Indicadores Mágicos (Onda 2)
    -- 1. Blended ROAS (Receita Bruta do Site / Investimento em Ads)
    CASE 
        WHEN COALESCE(a.investimento_total, 0) > 0 
        THEN COALESCE(v.receita_ecommerce, 0) / a.investimento_total 
        ELSE 0 
    END as roas_blended,
    
    -- 2. ROI Real (Lucro Bruto do Site após Custos da Onda 1 / Investimento em Ads)
    CASE 
        WHEN COALESCE(a.investimento_total, 0) > 0 
        THEN COALESCE(v.lucro_bruto_ecommerce, 0) / a.investimento_total 
        ELSE 0 
    END as roi_real,
    
    -- 3. CPA Blended (Custo de Aquisição por Pedido Real)
    CASE 
        WHEN COALESCE(v.pedidos_ecommerce, 0) > 0 
        THEN COALESCE(a.investimento_total, 0) / v.pedidos_ecommerce 
        ELSE 0 
    END as cpa_blended,
    
    -- 4. Taxa de Conversão do Site (Pedidos / Sessões)
    CASE 
        WHEN COALESCE(g.sessoes_totais, 0) > 0 
        THEN COALESCE(v.pedidos_ecommerce, 0) / g.sessoes_totais 
        ELSE 0 
    END as taxa_conversao_site

FROM vendas_daily v
FULL OUTER JOIN ga4_daily g 
    ON v.data_referencia = g.data_referencia
FULL OUTER JOIN ads_daily a 
    ON COALESCE(v.data_referencia, g.data_referencia) = a.data_referencia

ORDER BY data_referencia DESC;
