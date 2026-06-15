-- ==============================================================================
-- SCRIPT DE ROLLBACK (REVERSAO)
-- DESCRICAO: Restaura a view de producao para a versao homologada original
--            extraida em 15/06/2026 caso uma atualizacao quebre o dashboard.
-- ==============================================================================

CREATE OR REPLACE VIEW `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado` AS

WITH frete_pedido AS (
    SELECT 
        pedidos_vendas_identificador as pedido_id,
        MAX(frete) as frete_total
    FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_transporte`
    GROUP BY pedidos_vendas_identificador
),
valor_total_pedido AS (
    SELECT 
        pedidos_vendas_identificador as pedido_id,
        SUM(valor * quantidade) as soma_valor_produtos
    FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens`
    GROUP BY pedidos_vendas_identificador
),
categorias_antigas AS (
    SELECT 
        codigo_produto, 
        ANY_VALUE(INITCAP(LOWER(Categoria_Produto_Agrupada))) as categoria_produto,
        ANY_VALUE(INITCAP(LOWER(Categoria_Produto))) as subcategoria_produto
    FROM `iron-rex-461220-g4.database_aroom_health.view_vendas`
    WHERE codigo_produto IS NOT NULL
    GROUP BY codigo_produto
),
customer_profile_unique AS (
    SELECT 
        customer_id, 
        ANY_VALUE(estado) as estado
    FROM `iron-rex-461220-g4.customer_intelligence.customer_profile_enriched`
    GROUP BY customer_id
),
canais_unique AS (
    SELECT 
        CAST(id_canal AS STRING) as id_canal, 
        ANY_VALUE(canal_edit) as canal_edit, 
        ANY_VALUE(canal) as canal
    FROM `iron-rex-461220-g4.database_aroom_health.bling_canais_venda`
    GROUP BY id_canal
),
base_limpa AS (
    SELECT 
        -- Chaves
        p.data as data,
        p.data as data_venda,
        p.data as data_compra,
        p.identificador as pedido_id,
        i.identificador as item_id,
        
        -- Localidade
        pe.estado as uf,
        
        -- Origem
        p.loja_id as id_da_loja_origem,
        COALESCE(c.canal_edit, c.canal, 'Loja Física / Venda Direta') as origem_da_venda,
        
        CASE
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'mercado(\s)?livre|mercado(\s)?full') THEN 'Mercado Livre'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'amazon') THEN 'Amazon'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'magalu|integracommerce') THEN 'Magalu'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'shopee') THEN 'Shopee'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'shein') THEN 'Shein'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'olist') THEN 'Olist'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'tiktok') THEN 'Tiktok'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'drogaria|raia|pacheco|pague(\s)?menos|panvel') THEN 'Drogarias / Farmácias'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'beleza(\s)?na(\s)?web|epoca') THEN 'Beleza na Web / Época Cosméticos'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'netshoes|zattini') THEN 'Netshoes / Zattini'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'b2w|via(\s)?varejo|madeira') THEN 'Outros Marketplaces'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'azul|latam') THEN 'Programas de Pontos'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'giuliana|trecos|trivo|varie|facilzap|dropify|atacado|revenda') THEN 'Parceiros / B2B'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'site|magento|loja aroom') THEN 'Site Próprio (E-commerce)'
            WHEN COALESCE(c.canal_edit, c.canal) IS NULL OR COALESCE(c.canal_edit, c.canal) = '' THEN 'Loja Física / Venda Direta'
            ELSE 'Outros'
        END as origem_agrupada,

        -- Produto e Categoria (Join apenas como dicionário/DePara)
        prod.nome as produto,
        -- Regra de Inteligência Artificial para corrigir cadastros preguiçosos no Bling
        CASE
            WHEN (cat.categoria_produto IS NULL OR cat.categoria_produto = 'Outros' OR cat.categoria_produto = '') THEN
                CASE
                    WHEN LOWER(prod.nome) LIKE '%óleo vegetal%' OR LOWER(prod.nome) LIKE '%oleo vegetal%' OR LOWER(prod.nome) LIKE '%semente de uva%' OR LOWER(prod.nome) LIKE '%rícino%' OR LOWER(prod.nome) LIKE '%ricino%' OR LOWER(prod.nome) LIKE '%jojoba%' THEN 'Óleos Vegetais'
                    WHEN LOWER(prod.nome) LIKE '%tintura%' OR LOWER(prod.nome) LIKE '%maca peruana%' THEN 'Tintura Mãe'
                    WHEN LOWER(prod.nome) LIKE '%blend%' THEN 'Blends Fórmulas Exclusivas'
                    WHEN LOWER(prod.nome) LIKE '%kit%' THEN 'Kits De Óleos Vegetais'
                    WHEN LOWER(prod.nome) LIKE '%óleo essencial%' OR LOWER(prod.nome) LIKE '%oleo essencial%' THEN 'Óleos Essenciais'
                    WHEN LOWER(prod.nome) LIKE '%argila%' THEN 'Argila'
                    ELSE COALESCE(cat.categoria_produto, 'Sem Categoria')
                END
            ELSE cat.categoria_produto
        END as categoria_produto,
        
        CASE
            WHEN (cat.subcategoria_produto IS NULL OR cat.subcategoria_produto = 'Outros' OR cat.subcategoria_produto = '') THEN
                CASE
                    WHEN LOWER(prod.nome) LIKE '%óleo vegetal%' OR LOWER(prod.nome) LIKE '%oleo vegetal%' OR LOWER(prod.nome) LIKE '%semente de uva%' OR LOWER(prod.nome) LIKE '%rícino%' OR LOWER(prod.nome) LIKE '%ricino%' OR LOWER(prod.nome) LIKE '%jojoba%' THEN 'Óleos Vegetais'
                    WHEN LOWER(prod.nome) LIKE '%tintura%' OR LOWER(prod.nome) LIKE '%maca peruana%' THEN 'Tintura Mãe'
                    WHEN LOWER(prod.nome) LIKE '%blend%' THEN 'Blends Fórmulas Exclusivas'
                    WHEN LOWER(prod.nome) LIKE '%kit%' THEN 'Kits De Óleos Vegetais'
                    WHEN LOWER(prod.nome) LIKE '%óleo essencial%' OR LOWER(prod.nome) LIKE '%oleo essencial%' THEN 'Óleos Essenciais'
                    WHEN LOWER(prod.nome) LIKE '%argila%' THEN 'Argila'
                    ELSE COALESCE(cat.subcategoria_produto, 'Sem Categoria')
                END
            ELSE cat.subcategoria_produto
        END as subcategoria_produto,
        
        -- Metricas (Níveis de Item a partir da base NOVA)
        i.quantidade as quantidade_comprada,
        (i.valor * i.quantidade) as receita_total,
        
        -- Custos e Lucro Bruto
        COALESCE(prod.preco_custo, 0) as custo_unitario,
        (COALESCE(prod.preco_custo, 0) * i.quantidade) as custo_total_produto,
        ((i.valor * i.quantidade) - (COALESCE(prod.preco_custo, 0) * i.quantidade)) as lucro_bruto,
        
        -- Calculo do Frete Rateado (100% Nativo na nossa base nova)
        CASE 
            WHEN vt.soma_valor_produtos > 0 THEN COALESCE(f.frete_total, 0) * ((i.valor * i.quantidade) / vt.soma_valor_produtos)
            ELSE 0 
        END as custo_frete

    FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p
    JOIN `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens` i 
        ON p.identificador = i.pedidos_vendas_identificador
    LEFT JOIN `iron-rex-461220-g4.database_aroom_health.produtos` prod 
        ON i.produto_id = prod.identificador

    -- Joins Nativos
    LEFT JOIN frete_pedido f ON p.identificador = f.pedido_id
    LEFT JOIN valor_total_pedido vt ON p.identificador = vt.pedido_id
    LEFT JOIN customer_profile_unique pe 
        ON CAST(p.contato_id AS STRING) = pe.customer_id
    LEFT JOIN canais_unique c
        ON CAST(p.loja_id AS STRING) = c.id_canal

    -- Lookup da tabela antiga apenas para pegar a Categoria (dicionario)
    LEFT JOIN categorias_antigas cat 
        ON prod.codigo = cat.codigo_produto

    WHERE p.situacao_id NOT IN (12, 105)
)

SELECT 
    *,
    -- SMART METRICS ENGINE
    -- 1. Familia Produto
    CASE 
        WHEN subcategoria_produto IN ('Óleos Capilares', 'Óleos Para Terapia Capilar', 'Tônicos Capilares', 'Shampoos', 'Condicionadores', 'Tônicos', 'Shampoo') THEN '1. Tratamento Capilar'
        WHEN subcategoria_produto IN ('Óleos Vegetais', 'Óleos Essenciais', 'Blends Fórmulas Exclusivas') THEN '2. Óleos Naturais'
        WHEN subcategoria_produto IN ('Óleos Para Cílios E Sobrancelhas', 'Cílios', 'Sobrancelha', 'Estética') THEN '3. Estética e Beleza'
        WHEN subcategoria_produto IN ('Seivas Naturais', 'Tintura Mãe', 'Argila', 'Argilas', 'Hidrolatos', 'Hidrolatos Florais', 'Gel Aloe Vera', 'Géis De Aloe Vera') THEN '4. Terapias Naturais'
        WHEN subcategoria_produto IN ('Tinturas Vegetais', 'Coloração') THEN '5. Coloração Natural'
        WHEN subcategoria_produto IN ('Kits De Óleos Vegetais', 'Kits De Óleos Capilares', 'Kits De Óleos', 'Kits') THEN '6. Kits'
        ELSE '7. Outros'
    END as familia_produto,

    -- 2. Objetivo Produto
    CASE 
        WHEN subcategoria_produto IN ('Óleos Capilares', 'Tônicos Capilares', 'Óleos Para Terapia Capilar') THEN 'Crescimento e Tratamento'
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'Sabonetes') THEN 'Limpeza'
        WHEN subcategoria_produto IN ('Óleos Essenciais', 'Hidrolatos', 'Hidrolatos Florais', 'Blends Fórmulas Exclusivas') THEN 'Bem-estar e Aromaterapia'
        WHEN subcategoria_produto IN ('Óleos Vegetais', 'Seivas Naturais', 'Gel Aloe Vera', 'Géis De Aloe Vera') THEN 'Nutrição'
        WHEN subcategoria_produto IN ('Tinturas Vegetais', 'Tintura Mãe', 'Argila', 'Argilas') THEN 'Coloração e Terapia Profunda'
        WHEN subcategoria_produto IN ('Óleos Para Cílios E Sobrancelhas') THEN 'Estética'
        ELSE 'Uso Geral'
    END as objetivo_produto,
    
    -- 3. Jornada do Cliente
    CASE 
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'Argila', 'Argilas', 'Gel Aloe Vera') THEN '1. Entrada'
        WHEN subcategoria_produto IN ('Óleos Capilares', 'Óleos Vegetais', 'Hidrolatos', 'Hidrolatos Florais') THEN '2. Tratamento'
        WHEN subcategoria_produto IN ('Tônicos Capilares', 'Óleos Essenciais', 'Tintura Mãe', 'Seivas Naturais') THEN '3. Intensificação'
        WHEN subcategoria_produto LIKE '%Kit%' OR subcategoria_produto IN ('Kits De Óleos Vegetais', 'Kits De Óleos Capilares', 'Kits De Óleos', 'Kits') THEN '4. Manutenção'
        ELSE 'Não Mapeado'
    END as etapa_jornada_produto,
    
    -- 4. Nível de Especialização
    CASE 
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'Kits', 'Kits De Óleos Vegetais', 'Kits De Óleos Capilares', 'Kits De Óleos', 'Gel Aloe Vera') THEN '1. Básico'
        WHEN subcategoria_produto IN ('Óleos Vegetais', 'Óleos Capilares', 'Argila', 'Argilas', 'Hidrolatos') THEN '2. Intermediário'
        WHEN subcategoria_produto IN ('Óleos Essenciais', 'Blends Fórmulas Exclusivas') THEN '3. Avançado'
        WHEN subcategoria_produto IN ('Tintura Mãe', 'Tônicos Capilares', 'Seivas Naturais', 'Tinturas Vegetais') THEN '4. Especialista'
        ELSE 'Outros'
    END as nivel_especializacao,
    
    -- 5. Faixa de Valor
    CASE 
        WHEN (receita_total / NULLIF(quantidade_comprada, 0)) < 50 THEN '1. Entrada (< R$50)'
        WHEN (receita_total / NULLIF(quantidade_comprada, 0)) >= 50 AND (receita_total / NULLIF(quantidade_comprada, 0)) < 100 THEN '2. Médio (R$50-100)'
        WHEN (receita_total / NULLIF(quantidade_comprada, 0)) >= 100 AND (receita_total / NULLIF(quantidade_comprada, 0)) < 200 THEN '3. Premium (R$100-200)'
        WHEN (receita_total / NULLIF(quantidade_comprada, 0)) >= 200 THEN '4. High Ticket (> R$200)'
        ELSE 'Desconhecido'
    END as faixa_valor_produto,
    
    -- 6. Potencial de Recorrência
    CASE 
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'Tônicos Capilares', 'Tintura Mãe', 'Seivas Naturais', 'Gel Aloe Vera', 'Géis De Aloe Vera') THEN '1. Alto'
        WHEN subcategoria_produto IN ('Óleos Capilares', 'Óleos Para Terapia Capilar', 'Tinturas Vegetais', 'Blends Fórmulas Exclusivas', 'Argila', 'Argilas', 'Hidrolatos', 'Hidrolatos Florais', 'Cremes Base', 'Óleos De Massagem', 'Extratos Oleosos', 'Óleos Para Cílios E Sobrancelhas') THEN '2. Médio'
        WHEN subcategoria_produto IN ('Óleos Essenciais', 'Óleos Vegetais', 'Óleos Naturais', 'Kits', 'Kits De Óleos Vegetais', 'Kits De Óleos Capilares', 'Kits De Óleos', 'Cartão Presente', 'Toalhas') THEN '3. Baixo'
        ELSE 'Desconhecido'
    END as potencial_recorrencia

FROM base_limpa;
