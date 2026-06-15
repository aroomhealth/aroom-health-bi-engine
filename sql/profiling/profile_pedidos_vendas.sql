-- ==============================================================================
-- PROFILING: database_aroom_health.pedidos_vendas
-- DESCRICAO: Audita integridade, duplicatas, nulos e anomalias financeiras.
-- ==============================================================================

SELECT
    -- 1. Métricas de Volume Geral
    COUNT(*) as total_registros,
    COUNT(DISTINCT identificador) as ids_unicos,
    COUNT(*) - COUNT(DISTINCT identificador) as registros_duplicados,
    
    -- 2. Integridade de Chaves e Datas
    COUNTIF(identificador IS NULL) as nulos_identificador,
    COUNTIF(contato_id IS NULL) as nulos_contato_id,
    COUNTIF(loja_id IS NULL) as nulos_loja_id,
    COUNTIF(data IS NULL) as nulos_data,
    MIN(data) as data_minima,
    MAX(data) as data_maxima,
    
    -- 3. Anomalias Financeiras
    COUNTIF(total IS NULL) as nulos_total,
    COUNTIF(total < 0) as total_negativo,
    COUNTIF(total = 0) as total_zero,
    MIN(total) as valor_minimo_total,
    MAX(total) as valor_maximo_total,
    SUM(CASE WHEN total < 0 THEN total ELSE 0 END) as volume_receita_negativa,
    
    -- 4. Rastreamento e Marketing (UTM)
    COUNTIF(observacoes_internas IS NULL OR TRIM(observacoes_internas) = '') as observacoes_vazias_ou_nulas,
    COUNTIF(REGEXP_CONTAINS(observacoes_internas, r'utm_source|utm_medium|utm_campaign')) as registros_com_utm_detectado

FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`;
