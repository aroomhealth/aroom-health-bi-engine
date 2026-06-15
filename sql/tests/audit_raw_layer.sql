-- ==============================================================================
-- AUDITORIA: BigQuery Camada Raw (database_aroom_health)
-- DESCRICAO: Analise de metadados, partições, tamanhos de tabelas e datas de
--            ultima modificacao na camada de ingestao primaria.
-- ==============================================================================

-- 1. Inventario Geral de Tabelas no Dataset Raw
SELECT 
    table_name,
    table_type,
    is_insertable_into,
    ddl
FROM `iron-rex-461220-g4.database_aroom_health.INFORMATION_SCHEMA.TABLES`
WHERE table_type = 'BASE TABLE'
ORDER BY table_name;


-- 2. Analise de Tamanho e Volume Fisico das Tabelas
SELECT 
    table_id as tabela,
    row_count as total_linhas,
    ROUND(size_bytes / (1024*1024), 2) as tamanho_mb,
    TIMESTAMP_MILLIS(creation_time) as data_criacao,
    TIMESTAMP_MILLIS(last_modified_time) as ultima_atualizacao
FROM `iron-rex-461220-g4.database_aroom_health.__TABLES__`
ORDER BY total_linhas DESC;


-- 3. Verificacao de Particionamento (Tabelas com data de corte/particao)
SELECT 
    table_name,
    partition_id,
    total_rows,
    last_modified_time
FROM `iron-rex-461220-g4.database_aroom_health.INFORMATION_SCHEMA.PARTITIONS`
WHERE table_name IN ('pedidos_vendas_partitioned', 'contas_receber_partitioned')
ORDER BY partition_id DESC
LIMIT 10;
