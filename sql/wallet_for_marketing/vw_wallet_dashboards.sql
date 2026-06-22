-- ==============================================================================
-- VIEW: vw_wallet_dashboards
-- DATASET: wallet_for_marketing
-- DESCRICAO: Agrega o snapshot mensal em visões prontas para Dashboards, 
--            trazendo métricas de evolução de base, financeira, e LTV.
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.wallet_for_marketing.vw_wallet_dashboards` AS

WITH base_metrics AS (
    SELECT 
        mes_referencia,
        -- Status do Cliente no Mês
        CASE 
            WHEN DATE_TRUNC(data_primeira_compra, MONTH) = mes_referencia THEN '1. Novo Cliente'
            WHEN receita_mes > 0 THEN '2. Cliente Recorrente'
            WHEN dias_sem_comprar <= 90 THEN '3. Ativo (Sem compra no mês)'
            WHEN dias_sem_comprar > 90 AND dias_sem_comprar <= 180 THEN '4. Em Risco'
            ELSE '5. Perdido (Churn > 180 dias)'
        END as status_cliente,
        
        -- Dimensões
        canal_preferido,
        produto_preferido,
        
        -- Financeiro do Mês
        receita_mes,
        lucro_mes,
        qtd_pedidos_mes,
        
        -- Acumulado (Para LTV)
        receita_acumulada,
        lucro_acumulado,
        
        -- Chave
        id_cliente
        
    FROM `iron-rex-461220-g4.wallet_for_marketing.customer_wallet_snapshot`
)

SELECT 
    mes_referencia,
    
    -- Evolução da Base
    COUNT(DISTINCT id_cliente) as total_clientes_carteira,
    COUNT(DISTINCT CASE WHEN status_cliente = '1. Novo Cliente' THEN id_cliente END) as novos_clientes,
    COUNT(DISTINCT CASE WHEN status_cliente = '2. Cliente Recorrente' THEN id_cliente END) as clientes_recorrentes,
    COUNT(DISTINCT CASE WHEN status_cliente = '3. Ativo (Sem compra no mês)' THEN id_cliente END) as clientes_ativos_base,
    COUNT(DISTINCT CASE WHEN status_cliente = '4. Em Risco' THEN id_cliente END) as clientes_em_risco,
    COUNT(DISTINCT CASE WHEN status_cliente = '5. Perdido (Churn > 180 dias)' THEN id_cliente END) as clientes_perdidos,
    
    -- Evolução Financeira (Desempenho no mês corrente)
    SUM(receita_mes) as receita_mensal,
    SUM(lucro_mes) as lucro_mensal,
    SAFE_DIVIDE(SUM(receita_mes), SUM(qtd_pedidos_mes)) as ticket_medio_mensal,
    
    -- Saúde da Carteira (LTV Médio Histórico dos clientes vivos naquele mês)
    SAFE_DIVIDE(SUM(receita_acumulada), COUNT(DISTINCT id_cliente)) as ltv_receita_medio,
    SAFE_DIVIDE(SUM(lucro_acumulado), COUNT(DISTINCT id_cliente)) as ltv_lucro_medio

FROM base_metrics
GROUP BY 1
ORDER BY mes_referencia DESC;
