SELECT payment_status, SUM(subtotal) as valor
FROM `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos`
WHERE DATE(created_at) = '2026-06-16' AND payment_status NOT IN ('refunded', 'voided')
GROUP BY 1
