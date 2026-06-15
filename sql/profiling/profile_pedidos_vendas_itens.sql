-- ==============================================================================
-- PROFILING: database_aroom_health.pedidos_vendas_itens
-- DESCRICAO: Audita duplicatas de granularidade, SKUs órfãos e valores.
-- ==============================================================================

SELECT
    -- 1. Volume Geral
    COUNT(*) as total_registros,
    COUNT(DISTINCT identificador) as ids_unicos,
    COUNT(*) - COUNT(DISTINCT identificador) as registros_duplicados,
    
    -- 2. Integridade Referencial e Chaves
    COUNTIF(identificador IS NULL) as nulos_identificador,
    COUNTIF(pedidos_vendas_identificador IS NULL) as nulos_pedido_id,
    COUNTIF(produto_id IS NULL) as nulos_produto_id,
    COUNTIF(codigo IS NULL OR TRIM(codigo) = '') as skus_vazios_ou_nulos,
    COUNT(DISTINCT codigo) as skus_distintos,
    
    -- 3. Anomalias Financeiras e Operacionais
    COUNTIF(quantidade IS NULL) as nulos_quantidade,
    COUNTIF(quantidade <= 0) as quantidade_invalida, -- Qtd <= 0
    COUNTIF(valor IS NULL) as nulos_valor,
    COUNTIF(valor <= 0) as valor_unitario_invalido, -- Valor <= 0
    COUNTIF(desconto < 0) as desconto_negativo,
    COUNTIF(comissao_valor < 0) as comissao_negativa,
    
    -- 4. Métricas Financeiras Consolidadas
    SUM(quantidade) as total_unidades_vendidas,
    ROUND(SUM(desconto), 2) as volume_total_descontos,
    ROUND(SUM(comissao_valor), 2) as volume_total_comissoes

FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens`;
