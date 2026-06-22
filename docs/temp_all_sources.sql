SELECT
  table_id as Fonte_de_Dados,
  CAST(TIMESTAMP_MILLIS(last_modified_time) AS STRING) as Ultima_Data_Ingestao,
  row_count as Total_Historico_Registros
FROM
  `iron-rex-461220-g4.database_aroom_health.__TABLES__`
ORDER BY
  last_modified_time DESC
