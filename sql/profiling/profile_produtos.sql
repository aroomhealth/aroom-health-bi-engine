-- ==============================================================================
-- PROFILING: database_aroom_health.produtos
-- DESCRICAO: Audita o cadastro de produtos, custos nulos/zerados e estoque.
-- ==============================================================================

SELECT
    -- 1. Volume Geral
    COUNT(*) as total_registros,
    COUNT(DISTINCT identificador) as ids_unicos,
    COUNT(*) - COUNT(DISTINCT identificador) as registros_duplicados,
    COUNT(DISTINCT codigo) as skus_unicos,
    
    -- 2. Integridade de Nomes e Códigos
    COUNTIF(identificador IS NULL) as nulos_identificador,
    COUNTIF(nome IS NULL OR TRIM(nome) = '') as nomes_nulos_ou_vazios,
    COUNTIF(codigo IS NULL OR TRIM(codigo) = '') as skus_nulos_ou_vazios,
    
    -- 3. Auditoria de Preços e Custos (Foco em COGS)
    COUNTIF(preco IS NULL OR preco = 0) as precos_nulos_ou_zero,
    COUNTIF(preco < 0) as precos_negativos,
    COUNTIF(preco_custo IS NULL) as custos_nulos,
    COUNTIF(preco_custo = 0) as custos_zerados, -- Ponto crítico: Tintura Mãe/Sem Categoria
    COUNTIF(preco_custo < 0) as custos_negativos,
    COUNTIF(preco_custo > preco) as custo_maior_que_preco, -- Margem negativa teórica
    
    -- 4. Auditoria de Estoque e Cadastro
    COUNTIF(estoque IS NULL) as estoque_nulo,
    COUNTIF(estoque < 0) as estoque_negativo,
    COUNT(DISTINCT tipo) as tipos_distintos,
    COUNT(DISTINCT situacao) as situacoes_distintas

FROM `iron-rex-461220-g4.database_aroom_health.produtos`;
