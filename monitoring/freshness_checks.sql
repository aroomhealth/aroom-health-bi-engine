-- ==============================================================================
-- MONITORAMENTO: Freshness Checks (Bling ERP)
-- DESCRICAO: Valida se a ingestao transacional de pedidos do Bling ocorreu
--            nas ultimas 24 horas (D-1).
-- ==============================================================================

SELECT 
    MAX(data) as ultima_data_pedido,
    CURRENT_DATE() as data_atual,
    DATE_DIFF(CURRENT_DATE(), MAX(data), DAY) as dias_atraso,
    CASE 
        WHEN DATE_DIFF(CURRENT_DATE(), MAX(data), DAY) <= 1 THEN '✅ HEALTHY'
        ELSE '🚨 CRITICAL - Ingestão do Bling está atrasada!'
    END as status
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`;
