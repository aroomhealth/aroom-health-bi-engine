CREATE OR REPLACE TABLE `iron-rex-461220-g4.wallet_for_marketing.customer_wallet_snapshot` AS

WITH customer_base AS (
    SELECT 
        id_cliente,
        DATE_TRUNC(MIN(data_venda), MONTH) as first_month
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
    WHERE id_cliente IS NOT NULL
    GROUP BY 1
),

months_spine AS (
    SELECT month as mes_referencia
    FROM UNNEST(GENERATE_DATE_ARRAY(
        (SELECT MIN(first_month) FROM customer_base),
        DATE_TRUNC(CURRENT_DATE('America/Sao_Paulo'), MONTH),
        INTERVAL 1 MONTH
    )) as month
),

customer_months AS (
    SELECT 
        c.id_cliente, 
        m.mes_referencia
    FROM customer_base c
    CROSS JOIN months_spine m
    WHERE m.mes_referencia >= c.first_month
),

monthly_sales AS (
    SELECT 
        id_cliente,
        DATE_TRUNC(data_venda, MONTH) as mes_referencia,
        COUNT(DISTINCT pedido_id) as qtd_pedidos_no_mes,
        SUM(receita_total) as receita_no_mes,
        SUM(lucro_bruto) as lucro_no_mes,
        MAX(data_venda) as ultima_compra_no_mes,
        MIN(data_venda) as primeira_compra_no_mes
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
    WHERE id_cliente IS NOT NULL
    GROUP BY 1, 2
),

-- Calculation of preferred product and channel to avoid Data Leakage
product_sales_monthly AS (
    SELECT 
        id_cliente,
        DATE_TRUNC(data_venda, MONTH) as mes_venda,
        produto,
        origem_agrupada as canal,
        SUM(receita_total) as receita_produto_mes
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
    WHERE id_cliente IS NOT NULL
    GROUP BY 1, 2, 3, 4
),

product_cumulative AS (
    SELECT 
        cm.id_cliente,
        cm.mes_referencia,
        ps.produto,
        ps.canal,
        SUM(ps.receita_produto_mes) as receita_acumulada_produto
    FROM customer_months cm
    JOIN product_sales_monthly ps 
      ON ps.id_cliente = cm.id_cliente 
      AND ps.mes_venda <= cm.mes_referencia
    GROUP BY 1, 2, 3, 4
),

preferred_attributes_per_month AS (
    SELECT 
        id_cliente, 
        mes_referencia, 
        produto as produto_preferido,
        canal as canal_preferido
    FROM (
        SELECT 
            id_cliente, 
            mes_referencia, 
            produto, 
            canal,
            ROW_NUMBER() OVER(PARTITION BY id_cliente, mes_referencia ORDER BY receita_acumulada_produto DESC) as rn
        FROM product_cumulative
    )
    WHERE rn = 1
)

SELECT 
    cm.mes_referencia,
    cm.id_cliente,
    
    -- Lifetime Dates
    MIN(ms.primeira_compra_no_mes) OVER(PARTITION BY cm.id_cliente ORDER BY cm.mes_referencia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as data_primeira_compra,
    MAX(ms.ultima_compra_no_mes) OVER(PARTITION BY cm.id_cliente ORDER BY cm.mes_referencia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as data_ultima_compra,
    
    -- Inactivity
    DATE_DIFF(
        LAST_DAY(cm.mes_referencia), 
        MAX(ms.ultima_compra_no_mes) OVER(PARTITION BY cm.id_cliente ORDER BY cm.mes_referencia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
        DAY
    ) as dias_sem_comprar,
    
    -- Monthly Metrics
    IFNULL(ms.qtd_pedidos_no_mes, 0) as qtd_pedidos_mes,
    IFNULL(ms.receita_no_mes, 0) as receita_mes,
    IFNULL(ms.lucro_no_mes, 0) as lucro_mes,
    
    -- Cumulative Metrics (LTV)
    SUM(IFNULL(ms.qtd_pedidos_no_mes, 0)) OVER(PARTITION BY cm.id_cliente ORDER BY cm.mes_referencia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as total_pedidos_acumulado,
    SUM(IFNULL(ms.receita_no_mes, 0)) OVER(PARTITION BY cm.id_cliente ORDER BY cm.mes_referencia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as receita_acumulada,
    SUM(IFNULL(ms.lucro_no_mes, 0)) OVER(PARTITION BY cm.id_cliente ORDER BY cm.mes_referencia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) as lucro_acumulado,
    
    -- Ticket Medio
    SAFE_DIVIDE(
        SUM(IFNULL(ms.receita_no_mes, 0)) OVER(PARTITION BY cm.id_cliente ORDER BY cm.mes_referencia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
        SUM(IFNULL(ms.qtd_pedidos_no_mes, 0)) OVER(PARTITION BY cm.id_cliente ORDER BY cm.mes_referencia ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
    ) as ticket_medio_acumulado,
    
    -- Preferences (Point in Time)
    pref.produto_preferido,
    pref.canal_preferido
    
FROM customer_months cm
LEFT JOIN monthly_sales ms 
  ON cm.id_cliente = ms.id_cliente 
 AND cm.mes_referencia = ms.mes_referencia
LEFT JOIN preferred_attributes_per_month pref
  ON cm.id_cliente = pref.id_cliente
 AND cm.mes_referencia = pref.mes_referencia
ORDER BY cm.id_cliente, cm.mes_referencia;
