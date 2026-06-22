SELECT situacao, COUNT(*) as qtd
FROM `iron-rex-461220-g4.database_aroom_health.produtos`
GROUP BY situacao;
