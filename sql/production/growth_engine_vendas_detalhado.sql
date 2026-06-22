-- ==============================================================================
-- VIEW: growth_engine_vendas_detalhado
-- DATASET: customer_intelligence
-- DESCRICAO: View consolidada de vendas no nivel de item. Corrige o fan-out
--            de joins 1-para-N, incorpora as dimensoes da SmartMetrics, e
--            adiciona calculos avançados de Unit Economics (DRE na linha).
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
-- DRE CTEs (Unit Economics)
forma_pagto AS (
    SELECT 
        pp.pedidos_vendas_identificador as pedido_id, 
        MAX(LOWER(COALESCE(fp.descricao, ''))) as forma_pagto 
    FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_parcelas` pp
    LEFT JOIN `iron-rex-461220-g4.database_aroom_health.formas_pagamento` fp ON pp.forma_pagamento_id = fp.id
    GROUP BY 1
),
ads_raw AS (
    SELECT DATE(segments_date) as data_referencia, CAST(SUM(metrics_cost_micros/1000000) AS FLOAT64) as investimento FROM `iron-rex-461220-g4.google_ads.ads_CampaignStats_5644422842` GROUP BY 1
    UNION ALL
    SELECT date as data_referencia, CAST(spend AS FLOAT64) as investimento FROM `iron-rex-461220-g4.database_aroom_health.facebook_ads_insights`
    UNION ALL
    SELECT date as data_referencia, CAST(spend AS FLOAT64) as investimento FROM `iron-rex-461220-g4.database_aroom_health.tiktok_ads_insights`
),
marketing_diario AS (
    SELECT 
        DATE(data_referencia) as data_mkt, 
        SUM(investimento) as custo_mkt_dia 
    FROM ads_raw 
    GROUP BY 1
),
receita_diaria AS (
    SELECT 
        DATE(p.data) as data_rec, 
        SUM(i.valor * i.quantidade) as receita_total_dia 
    FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p 
    JOIN `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens` i ON p.identificador = i.pedidos_vendas_identificador 
    WHERE p.situacao_id NOT IN (12, 105) 
    GROUP BY 1
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
        COALESCE(prod.nome, i.descricao) as produto,
        CASE 
            WHEN prod.situacao = 'A' THEN 'Sim'
            ELSE 'Não'
        END as is_produto_ativo,
        
        -- Regra de Inteligência Artificial para corrigir cadastros preguiçosos no Bling
        CASE
            WHEN (cat.categoria_produto IS NULL OR cat.categoria_produto = 'Outros' OR cat.categoria_produto = '') THEN
                CASE
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'vegeta|semente de uva|rícino|ricino|r.cino|jojoba|rosa mosqueta') THEN 'Óleos Vegetais'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'tintura|maca peruana|cardo mariano|espinheira|valeriana|algodoeiro|damiana') THEN 'Tintura Mãe'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'blend') THEN 'Blends Fórmulas Exclusivas'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'kit') THEN 'Kits De Óleos Vegetais'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'essencial|olíbano|olibano') THEN 'Óleos Essenciais'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'argila') THEN 'Argila'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'tônico|tonico|t.nico') THEN 'Tônicos Capilares'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'aloe vera') THEN 'Gel Aloe Vera'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'sérum|serum|rejuvenescedor|creme|ozonizado') THEN 'Estética e Beleza'
                    ELSE COALESCE(cat.categoria_produto, 'Sem Categoria')
                END
            ELSE cat.categoria_produto
        END as categoria_produto,
        
        CASE
            WHEN (cat.subcategoria_produto IS NULL OR cat.subcategoria_produto = 'Outros' OR cat.subcategoria_produto = '') THEN
                CASE
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'vegeta|semente de uva|rícino|ricino|r.cino|jojoba|rosa mosqueta') THEN 'Óleos Vegetais'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'tintura|maca peruana|cardo mariano|espinheira|valeriana|algodoeiro|damiana') THEN 'Tintura Mãe'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'blend') THEN 'Blends Fórmulas Exclusivas'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'kit') THEN 'Kits De Óleos Vegetais'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'essencial|olíbano|olibano') THEN 'Óleos Essenciais'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'argila') THEN 'Argila'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'tônico|tonico|t.nico') THEN 'Tônicos Capilares'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'aloe vera') THEN 'Gel Aloe Vera'
                    WHEN REGEXP_CONTAINS(LOWER(COALESCE(prod.nome, i.descricao)), r'sérum|serum|rejuvenescedor|creme|ozonizado') THEN 'Estética e Beleza'
                    ELSE COALESCE(cat.subcategoria_produto, 'Sem Categoria')
                END
            ELSE cat.subcategoria_produto
        END as subcategoria_produto,
        
        -- Metricas base (Níveis de Item a partir da base NOVA)
        i.quantidade as quantidade_comprada,
        (i.valor * i.quantidade) as receita_bruta,
        COALESCE(i.desconto, 0) as desconto_item,
        
        -- Flag de Auditoria de Custo
        CASE 
            WHEN COALESCE(prod.preco_custo, 0) > 0 THEN '1. Custo Original (ERP Bling)'
            WHEN plan.custo_total_real > 0 THEN '2. Custo Correto (Planilha Oficial)'
            ELSE '3. Custo Estimado (Regra de Segurança)'
        END as flag_origem_custo,

        -- Motor de Custos Triplo (Onda 1)
        CASE 
            WHEN COALESCE(prod.preco_custo, 0) > 0 THEN prod.preco_custo
            WHEN plan.custo_total_real > 0 THEN plan.custo_total_real
            ELSE 
                CASE
                    WHEN cat.categoria_produto = 'Óleos Vegetais' THEN i.valor * 0.40 
                    WHEN cat.categoria_produto = 'Óleos Essenciais' THEN i.valor * 0.35
                    WHEN cat.categoria_produto = 'Tintura Mãe' THEN i.valor * 0.30
                    WHEN cat.categoria_produto LIKE '%Kits%' THEN i.valor * 0.45
                    ELSE i.valor * 0.50 -- Margem padrão 50%
                END
        END as custo_unitario,
        
        -- Custo Total Produto
        (
            CASE 
                WHEN COALESCE(prod.preco_custo, 0) > 0 THEN prod.preco_custo
                WHEN plan.custo_total_real > 0 THEN plan.custo_total_real
                ELSE 
                    CASE
                        WHEN cat.categoria_produto = 'Óleos Vegetais' THEN i.valor * 0.40 
                        WHEN cat.categoria_produto = 'Óleos Essenciais' THEN i.valor * 0.35
                        WHEN cat.categoria_produto = 'Tintura Mãe' THEN i.valor * 0.30
                        WHEN cat.categoria_produto LIKE '%Kits%' THEN i.valor * 0.45
                        ELSE i.valor * 0.50 
                    END
            END * i.quantidade
        ) as custo_total_produto,
        
        -- Calculo do Frete Rateado
        CASE 
            WHEN vt.soma_valor_produtos > 0 THEN COALESCE(f.frete_total, 0) * ((i.valor * i.quantidade) / vt.soma_valor_produtos)
            ELSE 0 
        END as custo_frete,

        -- Receita Líquida (Abatendo desconto e frete)
        ((i.valor * i.quantidade) - COALESCE(i.desconto, 0) - (
            CASE 
                WHEN vt.soma_valor_produtos > 0 THEN COALESCE(f.frete_total, 0) * ((i.valor * i.quantidade) / vt.soma_valor_produtos)
                ELSE 0 
            END
        )) as receita_liquida,

        -- ---------------------------------------------------------
        -- NOVOS CÁLCULOS DO UNIT ECONOMICS (DRE NA LINHA)
        -- ---------------------------------------------------------

        -- Impostos Fixo (8.2%)
        ((i.valor * i.quantidade) * 0.082) as custo_impostos,

        -- Taxa de Gateway (Pix 1%, Cartão 3.5%, Boleto 3.00)
        CASE 
            WHEN LOWER(COALESCE(fp.forma_pagto, '')) LIKE '%boleto%' THEN 3.00 * ((i.valor * i.quantidade) / NULLIF(vt.soma_valor_produtos, 0))
            WHEN LOWER(COALESCE(fp.forma_pagto, '')) LIKE '%pix%' THEN (i.valor * i.quantidade) * 0.01
            ELSE (i.valor * i.quantidade) * 0.035 
        END as custo_taxa_gateway,

        -- Marketing Diário Rateado
        CASE 
            WHEN rec.receita_total_dia > 0 THEN (i.valor * i.quantidade) * (COALESCE(mkt.custo_mkt_dia, 0) / rec.receita_total_dia) 
            ELSE 0 
        END as custo_marketing_rateado,

        -- Custo Operacional (Contador R$ 150/mes = 5.00/dia)
        CASE 
            WHEN rec.receita_total_dia > 0 THEN (i.valor * i.quantidade) * (5.00 / rec.receita_total_dia) 
            ELSE 0 
        END as custo_operacional_rateado

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

    -- DRE Joins
    LEFT JOIN forma_pagto fp ON p.identificador = fp.pedido_id
    LEFT JOIN marketing_diario mkt ON DATE(p.data) = mkt.data_mkt
    LEFT JOIN receita_diaria rec ON DATE(p.data) = rec.data_rec

    WHERE p.situacao_id NOT IN (12, 105)
)

SELECT 
    *,
    -- LUCRO BRUTO ORIGINAL
    (receita_liquida - custo_total_produto) as lucro_bruto,
    
    -- MARGEM LIQUIDA FINAL (EBITDA UNITARIO)
    (receita_liquida - custo_total_produto - custo_impostos - custo_taxa_gateway - custo_marketing_rateado - custo_operacional_rateado) as margem_liquida_final,

    -- SMART METRICS ENGINE
    -- 1. Familia Produto
    CASE 
        WHEN REGEXP_CONTAINS(LOWER(subcategoria_produto), r'capilares|shampoo|condicionador|tônico|tonico') THEN '1. Tratamento Capilar'
        WHEN REGEXP_CONTAINS(LOWER(subcategoria_produto), r'vegeta|essencia|blend') THEN '2. Óleos Naturais'
        WHEN REGEXP_CONTAINS(LOWER(subcategoria_produto), r'cílio|cilio|sobrancelha|estética|estetica') THEN '3. Estética e Beleza'
        WHEN REGEXP_CONTAINS(LOWER(subcategoria_produto), r'seiva|tintura mãe|tintura mae|argila|hidrolato|aloe vera') THEN '4. Terapias Naturais'
        WHEN REGEXP_CONTAINS(LOWER(subcategoria_produto), r'tintura vegetal|coloração|coloracao') THEN '5. Coloração Natural'
        WHEN REGEXP_CONTAINS(LOWER(subcategoria_produto), r'kit') THEN '6. Kits'
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
    
    -- 5. Faixa de Valor (Usando Receita Bruta)
    CASE 
        WHEN (receita_bruta / NULLIF(quantidade_comprada, 0)) < 50 THEN '1. Entrada (< R$50)'
        WHEN (receita_bruta / NULLIF(quantidade_comprada, 0)) >= 50 AND (receita_bruta / NULLIF(quantidade_comprada, 0)) < 100 THEN '2. Médio (R$50-100)'
        WHEN (receita_bruta / NULLIF(quantidade_comprada, 0)) >= 100 AND (receita_bruta / NULLIF(quantidade_comprada, 0)) < 200 THEN '3. Premium (R$100-200)'
        WHEN (receita_bruta / NULLIF(quantidade_comprada, 0)) >= 200 THEN '4. High Ticket (> R$200)'
        ELSE 'Desconhecido'
    END as faixa_valor_produto,
    
    -- 6. Potencial de Recorrência
    CASE 
        WHEN subcategoria_produto IN ('Shampoos', 'Condicionadores', 'Tônicos Capilares', 'Tintura Mãe', 'Seivas Naturais', 'Gel Aloe Vera', 'Géis De Aloe Vera') THEN '1. Alto'
        WHEN subcategoria_produto IN ('Óleos Capilares', 'Óleos Para Terapia Capilar', 'Tinturas Vegetais', 'Blends Fórmulas Exclusivas', 'Argila', 'Argilas', 'Hidrolatos', 'Hidrolatos Florais', 'Cremes Base', 'Óleos De Massagem', 'Extratos Oleosos', 'Óleos Para Cílios E Sobrancelhas') THEN '2. Médio'
        WHEN subcategoria_produto IN ('Óleos Essenciais', 'Óleos Vegetais', 'Óleos Naturais', 'Kits', 'Kits De Óleos Vegetais', 'Kits De Óleos Capilares', 'Kits De Óleos', 'Cartão Presente', 'Toalhas') THEN '3. Baixo'
        ELSE 'Desconhecido'
    END as potencial_recorrencia

FROM base_limpa
