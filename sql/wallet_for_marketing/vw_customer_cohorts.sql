-- ==============================================================================
-- VIEW: vw_customer_cohorts
-- DATASET: wallet_for_marketing
-- DESCRICAO: Visão de Safras (Vintages). Agrupa os clientes pelo mês de 
--            aquisição e acompanha o LTV nos meses subsequentes (M0, M1, M2...)
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.wallet_for_marketing.vw_customer_cohorts` AS

WITH cohort_base AS (
    SELECT 
        id_cliente,
        DATE_TRUNC(data_primeira_compra, MONTH) as mes_safra,
        mes_referencia,
        -- Calcula quantos meses se passaram desde a primeira compra
        DATE_DIFF(mes_referencia, DATE_TRUNC(data_primeira_compra, MONTH), MONTH) as meses_desde_aquisicao,
        receita_acumulada,
        lucro_acumulado,
        qtd_pedidos_mes
    FROM `iron-rex-461220-g4.wallet_for_marketing.customer_wallet_snapshot`
)

SELECT 
    mes_safra,
    meses_desde_aquisicao as month_index,
    CONCAT('M', meses_desde_aquisicao) as safra_mes,
    
    COUNT(DISTINCT id_cliente) as clientes_na_safra,
    SUM(receita_acumulada) as ltv_receita_total,
    SUM(lucro_acumulado) as ltv_lucro_total,
    
    -- LTV Médio da Safra
    SAFE_DIVIDE(SUM(receita_acumulada), COUNT(DISTINCT id_cliente)) as ltv_receita_medio,
    SAFE_DIVIDE(SUM(lucro_acumulado), COUNT(DISTINCT id_cliente)) as ltv_lucro_medio,
    
    -- Engajamento (Quantos clientes DAQUELA safra voltaram a comprar NESTE mês)
    COUNT(DISTINCT CASE WHEN qtd_pedidos_mes > 0 THEN id_cliente END) as clientes_compraram_no_mes

FROM cohort_base
GROUP BY 1, 2, 3
ORDER BY mes_safra DESC, month_index ASC;
