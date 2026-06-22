SELECT 
  p.data as data_pedido,
  i.descricao as produto_bling,
  i.codigo as sku_bling,
  i.valor as valor_unitario,
  i.quantidade
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens` i
JOIN `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p 
  ON p.identificador = i.pedidos_vendas_identificador
WHERE 
  LOWER(i.descricao) LIKE '%goiabeira%' AND LOWER(i.descricao) LIKE '%kit%'
  AND p.data >= '2026-06-01'
ORDER BY p.data DESC
LIMIT 10;
