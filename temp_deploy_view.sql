CREATE OR REPLACE VIEW iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado AS 

-- ==============================================================================
-- VIEW: growth_engine_vendas_detalhado
-- DATASET: customer_intelligence
-- DESCRICAO: View consolidada de vendas no nivel de item. Corrige o fan-out
--            de joins 1-para-N e incorpora as dimensoes da SmartMetrics.
-- FATURAMENTO AUDITADO: R$ 9.540.041,07
-- ==============================================================================

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
        p.contato_id as id_cliente,
        
        -- Localidade
        pe.estado as uf,
        
        -- Origem
        p.loja_id as id_da_loja_origem,
        COALESCE(c.canal_edit, c.canal, 'Loja FÃ­sica / Venda Direta') as origem_da_venda,
        
        CASE
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'mercado(\s)?livre|mercado(\s)?full') THEN 'Mercado Livre'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'amazon') THEN 'Amazon'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'magalu|integracommerce') THEN 'Magalu'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'shopee') THEN 'Shopee'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'shein') THEN 'Shein'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'olist') THEN 'Olist'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'tiktok') THEN 'Tiktok'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'drogaria|raia|pacheco|pague(\s)?menos|panvel') THEN 'Drogarias / FarmÃ¡cias'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'beleza(\s)?na(\s)?web|epoca') THEN 'Beleza na Web / Ã‰poca CosmÃ©ticos'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'netshoes|zattini') THEN 'Netshoes / Zattini'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'b2w|via(\s)?varejo|madeira') THEN 'Outros Marketplaces'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'azul|latam') THEN 'Programas de Pontos'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'giuliana|trecos|trivo|varie|facilzap|dropify|atacado|revenda') THEN 'Parceiros / B2B'
            WHEN REGEXP_CONTAINS(LOWER(COALESCE(c.canal_edit, c.canal, '')), r'site|magento|loja aroom') THEN 'Site PrÃ³prio (E-commerce)'
            WHEN COALESCE(c.canal_edit, c.canal) IS NULL OR COALESCE(c.canal_edit, c.canal) = '' THEN 'Loja FÃ­sica / Venda Direta'
            ELSE 'Outros'
        END as origem_agrupada,

        -- Produto e Categoria (Join apenas como dicionÃ¡rio/DePara)
        prod.nome as produto,
        CASE 
            WHEN prod.situacao = 'A' THEN 'Sim'
            ELSE 'NÃ£o'
        END as is_produto_ativo,
        
        -- Regra de InteligÃªncia Artificial para corrigir cadastros preguiÃ§osos no Bling
        CASE
            WHEN (cat.categoria_produto IS NULL OR cat.categoria_produto = 'Outros' OR cat.categoria_produto = '') THEN
                CASE
                    WHEN LOWER(prod.nome) LIKE '%Ã³leo vegetal%' OR LOWER(prod.nome) LIKE '%oleo vegetal%' OR LOWER(prod.nome) LIKE '%semente de uva%' OR LOWER(prod.nome) LIKE '%rÃ­cino%' OR LOWER(prod.nome) LIKE '%ricino%' OR LOWER(prod.nome) LIKE '%jojoba%' THEN 'Ã“leos Vegetais'
                    WHEN LOWER(prod.nome) LIKE '%tintura%' OR LOWER(prod.nome) LIKE '%maca peruana%' THEN 'Tintura MÃ£e'
                    WHEN LOWER(prod.nome) LIKE '%blend%' THEN 'Blends FÃ³rmulas Exclusivas'
                    WHEN LOWER(prod.nome) LIKE '%kit%' THEN 'Kits De Ã“leos Vegetais'
                    WHEN LOWER(prod.nome) LIKE '%Ã³leo essencial%' OR LOWER(prod.nome) LIKE '%oleo essencial%' THEN 'Ã“leos Essenciais'
                    WHEN LOWER(prod.nome) LIKE '%argila%' THEN 'Argila'
                    ELSE COALESCE(cat.categoria_produto, 'Sem Categoria')
                END
            ELSE cat.categoria_produto
        END as categoria_produto,
        
        CASE
            WHEN (cat.subcategoria_produto IS NULL OR cat.subcategoria_produto = 'Outros' OR cat.subcategoria_produto = '') THEN
                CASE
                    WHEN LOWER(prod.nome) LIKE '%Ã³leo vegetal%' OR LOWER(prod.nome) LIKE '%oleo vegetal%' OR LOWER(prod.nome) LIKE '%semente de uva%' OR LOWER(prod.nome) LIKE '%rÃ­cino%' OR LOWER(prod.nome) LIKE '%ricino%' OR LOWER(prod.nome) LIKE '%jojoba%' THEN 'Ã“leos Vegetais'
                    WHEN LOWER(prod.nome) LIKE '%tintura%' OR LOWER(prod.nome) LIKE '%maca peruana%' THEN 'Tintura MÃ£e'
                    WHEN LOWER(prod.nome) LIKE '%blend%' THEN 'Blends FÃ³rmulas Exclusivas'
                    WHEN LOWER(prod.nome) LIKE '%kit%' THEN 'Kits De Ã“leos Vegetais'
                    WHEN LOWER(prod.nome) LIKE '%Ã³leo essencial%' OR LOWER(prod.nome) LIKE '%oleo essencial%' THEN 'Ã“leos Essenciais'
                    WHEN LOWER(prod.nome) LIKE '%argila%' THEN 'Argila'
                    ELSE COALESCE(cat.subcategoria_produto, 'Sem Categoria')
                END
            ELSE cat.subcategoria_produto
        END as subcategoria_produto,
        
        -- Metricas (NÃ­veis de Item a partir da base NOVA)
        i.quantidade as quantidade_comprada,
        (i.valor * i.quantidade) as receita_bruta,
        COALESCE(i.desconto, 0) as desconto_item,
        
        -- Flag de Auditoria de Custo (Para Estudos e Ajustes)
        CASE 
            WHEN COALESCE(prod.preco_custo, 0) > 0 THEN '1. Custo Original (ERP Bling)'
            WHEN plan.custo_total_real > 0 THEN '2. Custo Correto (Planilha Oficial)'
            ELSE '3. Custo Estimado (Regra de SeguranÃ§a)'
        END as flag_origem_custo,

        -- Motor de Custos Triplo (Onda 1)
        CASE 
            WHEN COALESCE(prod.preco_custo, 0) > 0 THEN prod.preco_custo
            WHEN plan.custo_total_real > 0 THEN plan.custo_total_real
            ELSE 
                CASE
                    WHEN cat.categoria_produto = 'Ã“leos Vegetais' THEN i.valor * 0.40 
                    WHEN cat.categoria_produto = 'Ã“leos Essenciais' THEN i.valor * 0.35
                    WHEN cat.categoria_produto = 'Tintura MÃ£e' THEN i.valor * 0.30
                    WHEN cat.categoria_produto LIKE '%Kits%' THEN i.valor * 0.45
                    ELSE i.valor * 0.50 -- Margem padrÃ£o 50%
                END
        END as custo_unitario,
        
        -- Custo Total e Lucro Bruto atualizados
        (
            CASE 
                WHEN COALESCE(prod.preco_custo, 0) > 0 THEN prod.preco_custo
                WHEN plan.custo_total_real > 0 THEN plan.custo_total_real
                ELSE 
                    CASE
                        WHEN cat.categoria_produto = 'Ã“leos Vegetais' THEN i.valor * 0.40 
                        WHEN cat.categoria_produto = 'Ã“leos Essenciais' THEN i.valor * 0.35
                        WHEN cat.categoria_produto = 'Tintura MÃ£e' THEN i.valor * 0.30
                        WHEN cat.categoria_produto LIKE '%Kits%' THEN i.valor * 0.45
                        ELSE i.valor * 0.50 
                    END
            END * i.quantidade
        ) as custo_total_produto,
        
        ((i.valor * i.quantidade) - COALESCE(i.desconto, 0) - (
            CASE 
                WHEN vt.soma_valor_produtos > 0 THEN COALESCE(f.frete_total, 0) * ((i.valor * i.quantidade) / vt.soma_valor_produtos)
                ELSE 0 
            END
        ) - (
            CASE 
                WHEN COALESCE(prod.preco_custo, 0) > 0 THEN prod.preco_custo
                WHEN plan.custo_total_real > 0 THEN plan.custo_total_real
                ELSE 
                    CASE
                        WHEN cat.categoria_produto = 'Ã“leos Vegetais' THEN i.valor * 0.40 
                        WHEN cat.categoria_produto = 'Ã“leos Essenciais' THEN i.valor * 0.35
                        WHEN cat.categoria_produto = 'Tintura MÃ£e' THEN i.valor * 0.30
                        WHEN cat.categoria_produto LIKE '%Kits%' THEN i.valor * 0.45
                        ELSE i.valor * 0.50 
                    END
            END * i.quantidade
        )) as lucro_bruto,
        
        -- Calculo do Frete Rateado (100% Nativo na nossa base nova)
        CASE 
            WHEN vt.soma_valor_produtos > 0 THEN COALESCE(f.frete_total, 0) * ((i.valor * i.quantidade) / vt.soma_valor_produtos)
            ELSE 0 
        END as custo_frete,

        -- Receita LÃ­quida Final (Abatendo desconto e frete)
        ((i.valor * i.quantidade) - COALESCE(i.desconto, 0) - (
            CASE 
                WHEN vt.soma_valor_produtos > 0 THEN COALESCE(f.frete_total, 0) * ((i.valor * i.quantidade) / vt.soma_valor_produtos)
                ELSE 0 
            END
        )) as receita_liquida

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
        
    -- Planilha Oficial de Custos
    LEFT JOIN `iron-rex-461220-g4.database_aroom_health.sku_custos_reais` plan
        ON CAST(prod.codigo AS STRING) = CAST(plan.sku AS STRING)

    WHERE p.situacao_id NOT IN (12, 105)
)

SELECT 
    *,
    -- SMART METRICS ENGINE
    -- 1. Familia Produto
    CASE 
        WHEN subcategoria_produto IN ('Ã“leos Capilares', 'Ã“leos Para Terapia Capilar', 'TÃ´nicos Capilares', 'Shampoos', 'Condicionadores', 'TÃ´nicos', 'Shampoo') THEN '1. Tratamento Capilar'
        WHEN subcategoria_produto IN ('Ã“leos Vegetais', 'Ã“leos Essenciais', 'Blends FÃ³rmulas Exclusivas') THEN '2. Ã“leos Naturais'
        WHEN subcategoria_produto IN ('Ã“leos Para CÃ­lios E Sobrancelhas', 'CÃ­lios', 'Sobrancelha', 'EstÃ©tica') THEN '3. EstÃ©tica e Beleza'
        WHEN subcategoria_produto IN ('Seivas Naturais', 'Tintura MÃ£e', 'Argila', 'Argilas', 'Hidrolatos', 'Hidrolatos Florais', 'Gel Aloe Vera', 'GÃ©is De Aloe Vera') THEN '4. Terapias Naturais'
        WHEN subcategoria_produto IN ('Tinturas Vegetais', 'ColoraÃ§Ã£o') THEN '5. ColoraÃ§Ã£o Natural'
        WHEN subcategoria_produto IN ('Kits De Ã“leos Vegetais', 'Kits De Ã“leos Capilares', 'Kits De Ã“leos', 'Kits') THEN '6. Kits'
        ELSE '7. Outros'
    END as familia_produto,

    -- 2. Objetivo Produto
    CASE 
        WHEN subcategoria_produto IN ('Ã“leos Capilares', 'TÃ´nicos Capilares', 'Ã“leos Para Terapia Capilar') THEN 'Crescimento e Tratamento'
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'Sabonetes') THEN 'Limpeza'
        WHEN subcategoria_produto IN ('Ã“leos Essenciais', 'Hidrolatos', 'Hidrolatos Florais', 'Blends FÃ³rmulas Exclusivas') THEN 'Bem-estar e Aromaterapia'
        WHEN subcategoria_produto IN ('Ã“leos Vegetais', 'Seivas Naturais', 'Gel Aloe Vera', 'GÃ©is De Aloe Vera') THEN 'NutriÃ§Ã£o'
        WHEN subcategoria_produto IN ('Tinturas Vegetais', 'Tintura MÃ£e', 'Argila', 'Argilas') THEN 'ColoraÃ§Ã£o e Terapia Profunda'
        WHEN subcategoria_produto IN ('Ã“leos Para CÃ­lios E Sobrancelhas') THEN 'EstÃ©tica'
        ELSE 'Uso Geral'
    END as objetivo_produto,
    
    -- 3. Jornada do Cliente
    CASE 
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'Argila', 'Argilas', 'Gel Aloe Vera') THEN '1. Entrada'
        WHEN subcategoria_produto IN ('Ã“leos Capilares', 'Ã“leos Vegetais', 'Hidrolatos', 'Hidrolatos Florais') THEN '2. Tratamento'
        WHEN subcategoria_produto IN ('TÃ´nicos Capilares', 'Ã“leos Essenciais', 'Tintura MÃ£e', 'Seivas Naturais') THEN '3. IntensificaÃ§Ã£o'
        WHEN subcategoria_produto LIKE '%Kit%' OR subcategoria_produto IN ('Kits De Ã“leos Vegetais', 'Kits De Ã“leos Capilares', 'Kits De Ã“leos', 'Kits') THEN '4. ManutenÃ§Ã£o'
        ELSE 'NÃ£o Mapeado'
    END as etapa_jornada_produto,
    
    -- 4. NÃ­vel de EspecializaÃ§Ã£o
    CASE 
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'Kits', 'Kits De Ã“leos Vegetais', 'Kits De Ã“leos Capilares', 'Kits De Ã“leos', 'Gel Aloe Vera') THEN '1. BÃ¡sico'
        WHEN subcategoria_produto IN ('Ã“leos Vegetais', 'Ã“leos Capilares', 'Argila', 'Argilas', 'Hidrolatos') THEN '2. IntermediÃ¡rio'
        WHEN subcategoria_produto IN ('Ã“leos Essenciais', 'Blends FÃ³rmulas Exclusivas') THEN '3. AvanÃ§ado'
        WHEN subcategoria_produto IN ('Tintura MÃ£e', 'TÃ´nicos Capilares', 'Seivas Naturais', 'Tinturas Vegetais') THEN '4. Especialista'
        ELSE 'Outros'
    END as nivel_especializacao,
    
    -- 5. Faixa de Valor (Usando Receita Bruta)
    CASE 
        WHEN (receita_bruta / NULLIF(quantidade_comprada, 0)) < 50 THEN '1. Entrada (< R$50)'
        WHEN (receita_bruta / NULLIF(quantidade_comprada, 0)) >= 50 AND (receita_bruta / NULLIF(quantidade_comprada, 0)) < 100 THEN '2. MÃ©dio (R$50-100)'
        WHEN (receita_bruta / NULLIF(quantidade_comprada, 0)) >= 100 AND (receita_bruta / NULLIF(quantidade_comprada, 0)) < 200 THEN '3. Premium (R$100-200)'
        WHEN (receita_bruta / NULLIF(quantidade_comprada, 0)) >= 200 THEN '4. High Ticket (> R$200)'
        ELSE 'Desconhecido'
    END as faixa_valor_produto,
    
    -- 6. Potencial de RecorrÃªncia
    CASE 
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'TÃ´nicos Capilares', 'Tintura MÃ£e', 'Seivas Naturais', 'Gel Aloe Vera', 'GÃ©is De Aloe Vera') THEN '1. Alto'
        WHEN subcategoria_produto IN ('Ã“leos Capilares', 'Ã“leos Para Terapia Capilar', 'Tinturas Vegetais', 'Blends FÃ³rmulas Exclusivas', 'Argila', 'Argilas', 'Hidrolatos', 'Hidrolatos Florais', 'Cremes Base', 'Ã“leos De Massagem', 'Extratos Oleosos', 'Ã“leos Para CÃ­lios E Sobrancelhas') THEN '2. MÃ©dio'
        WHEN subcategoria_produto IN ('Ã“leos Essenciais', 'Ã“leos Vegetais', 'Ã“leos Naturais', 'Kits', 'Kits De Ã“leos Vegetais', 'Kits De Ã“leos Capilares', 'Kits De Ã“leos', 'CartÃ£o Presente', 'Toalhas') THEN '3. Baixo'
        ELSE 'Desconhecido'
    END as potencial_recorrencia

FROM base_limpa
