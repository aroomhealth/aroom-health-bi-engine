-- ==============================================================================
-- AUDITORIA: BigQuery Camada Curada / Analitica (customer_intelligence)
-- DESCRICAO: Analise de metadados, visualizacoes ativas, dependencias de views
--            e tabelas de calculos no dataset de negocio.
-- ==============================================================================

-- 1. Inventario Geral de Objetos no Dataset Curated
SELECT 
    table_name,
    table_type,
    ddl
FROM `iron-rex-461220-g4.customer_intelligence.INFORMATION_SCHEMA.TABLES`
ORDER BY table_type, table_name;


-- 2. Analise de Freshness das Tabelas Curadas
SELECT 
    table_id as tabela_ou_view,
    row_count as total_linhas,
    ROUND(size_bytes / (1024*1024), 2) as tamanho_mb,
    TIMESTAMP_MILLIS(creation_time) as data_criacao,
    TIMESTAMP_MILLIS(last_modified_time) as ultima_atualizacao
FROM `iron-rex-461220-g4.customer_intelligence.__TABLES__`
ORDER BY total_linhas DESC;


-- 3. Identificacao de Dependencia Direta das Views Analiticas
SELECT 
    table_name as view_name,
    view_definition
FROM `iron-rex-461220-g4.customer_intelligence.INFORMATION_SCHEMA.VIEWS`
WHERE table_name LIKE 'growth_engine_%';
