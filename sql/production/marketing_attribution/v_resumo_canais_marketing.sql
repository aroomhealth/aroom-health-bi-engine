-- ==============================================================================
-- VIEW: v_resumo_canais_marketing
-- DATASET: marketing_attribution
-- DESCRICAO: Visão consolidada por canal de marketing (Google Ads, Meta, Orgânico,
--            Direto, Referral) agrupando receita e pedidos mensalmente.
--            Ideal para o painel executivo de performance geral no Looker Studio.
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.marketing_attribution.v_resumo_canais_marketing` AS

SELECT
    DATE_TRUNC(data_pedido, MONTH)              AS mes,
    canal_marketing,
    utm_source,
    utm_medium,

    -- Volume
    COUNT(DISTINCT pedido_id)                   AS total_pedidos,
    COUNT(DISTINCT cliente_id)                  AS total_clientes_unicos,

    -- Receita
    ROUND(SUM(receita_bling), 2)                AS receita_total_bling,
    ROUND(AVG(receita_bling), 2)                AS ticket_medio,

    -- Atribuição GA4
    ROUND(SUM(COALESCE(receita_ga4, 0)), 2)     AS receita_total_ga4,
    COUNTIF(tem_atribuicao_ga4 = TRUE)          AS pedidos_com_atribuicao,
    ROUND(COUNTIF(tem_atribuicao_ga4 = TRUE) * 100.0 / COUNT(DISTINCT pedido_id), 1) AS pct_atribuicao

FROM `iron-rex-461220-g4.marketing_attribution.v_pedidos_com_origem`
GROUP BY mes, canal_marketing, utm_source, utm_medium
ORDER BY mes DESC, receita_total_bling DESC
