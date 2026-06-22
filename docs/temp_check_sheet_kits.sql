SELECT * FROM `iron-rex-461220-g4.database_aroom_health.sku_custos_reais`
WHERE CAST(sku AS STRING) IN ('8672', '6470', '7156', '8658', '6463') OR LOWER(descricao_do_produto) LIKE '%goiabeira%';
