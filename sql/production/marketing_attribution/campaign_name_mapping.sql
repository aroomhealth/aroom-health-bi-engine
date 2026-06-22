-- ==============================================================================
-- TABLE: campaign_name_mapping
-- DATASET: marketing_attribution
-- DESCRICAO: Tabela de-para que mapeia os nomes de campanhas do Google Ads
--            (formato interno da plataforma) para os nomes de UTM registrados
--            no GA4 (formato das URLs de rastreamento).
--
-- COMO ATUALIZAR:
--   Ao criar uma nova campanha, adicione uma linha aqui com o nome exato
--   como aparece no Google Ads e o utm_campaign correspondente usado na URL.
--
-- COLUNA campaign_grupo: agrupamento semântico para relatórios executivos.
-- ==============================================================================

CREATE OR REPLACE TABLE `iron-rex-461220-g4.marketing_attribution.campaign_name_mapping` (
    nome_google_ads     STRING  OPTIONS(description='Nome exato da campanha como aparece no painel do Google Ads'),
    utm_campaign        STRING  OPTIONS(description='Valor do parâmetro utm_campaign usado nas URLs/links dos anúncios'),
    campaign_grupo      STRING  OPTIONS(description='Agrupamento semântico para relatórios executivos'),
    ativa               BOOL    OPTIONS(description='Se a campanha ainda está ativa'),
    observacoes         STRING  OPTIONS(description='Notas sobre a campanha, ex: data de encerramento, contexto')
)
OPTIONS (
    description = 'Tabela de-para entre nomes de campanhas do Google Ads e UTMs do GA4',
    labels = [('dataset', 'marketing_attribution'), ('tipo', 'lookup')]
);

-- ==============================================================================
-- CARGA INICIAL DO DE-PARA
-- Mapeamento construído cruzando os dados reais do Google Ads vs GA4
-- ==============================================================================

INSERT INTO `iron-rex-461220-g4.marketing_attribution.campaign_name_mapping`
  (nome_google_ads, utm_campaign, campaign_grupo, ativa, observacoes)
VALUES

-- ── PERFORMANCE MAX ───────────────────────────────────────────────────────────
('pmax_roas_formula-exclusiva',
 'pmax_roas_formula-exclusiva',
 'PMax - Fórmula Exclusiva', TRUE,
 'Campanha principal PMax. Maior investimento do portfólio.'),

('pmax_roas_todos-sp-abc',
 'pmax_roas_todos-sp-abc',
 'PMax - Todos Produtos (SP/ABC)', TRUE,
 'PMax segmentado para região SP e Grande ABC.'),

('pmax_roas_todos-sudeste',
 'pmax_roas_todos-sudeste',
 'PMax - Todos Produtos (Sudeste)', TRUE,
 'PMax para toda a região Sudeste.'),

('pmax_roas_maca-peruana',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', TRUE,
 'PMax focado no produto Maçã Peruana e linha Tintura.'),

-- ── PERFORMANCE MAX (NOMES LEGADOS COM PREFIXO ROAS%) ─────────────────────────
('[REDUZIDO DE 300] Google Performance Max - Site - SP/ABC',
 'pmax_roas_todos-sp-abc',
 'PMax - Todos Produtos (SP/ABC)', FALSE,
 'Versão anterior da campanha pmax_roas_todos-sp-abc com orçamento reduzido de R$300.'),

('[ROAS 800%] Google Performance Max - Site - Estados',
 'pmax_roas_todos-sudeste',
 'PMax - Todos Produtos (Sudeste)', FALSE,
 'Versão anterior com meta ROAS 800% - estados.'),

('[ROAS 952%] Google Performance Max - Site - SP/ABC',
 'pmax_roas_todos-sp-abc',
 'PMax - Todos Produtos (SP/ABC)', FALSE,
 'Versão anterior com meta ROAS 952%.'),

('[ROAS 762%] Google Performance Max - Site - SP/ABC',
 'pmax_roas_todos-sp-abc',
 'PMax - Todos Produtos (SP/ABC)', FALSE,
 'Versão anterior com meta ROAS 762%.'),

('[ORÇAMENTO 50] PMAX FÓRMULA EXCLUSIVA',
 'pmax_roas_formula-exclusiva',
 'PMax - Fórmula Exclusiva', FALSE,
 'Versão anterior com orçamento limitado R$50.'),

('[ROAS 550%] PMAX FÓRMULA EXCLUSIVA',
 'pmax_roas_formula-exclusiva',
 'PMax - Fórmula Exclusiva', FALSE,
 'Versão anterior com meta ROAS 550%.'),

('[ROAS 867%] PMAX FÓRMULA EXCLUSIVA',
 'pmax_roas_formula-exclusiva',
 'PMax - Fórmula Exclusiva', FALSE,
 'Versão anterior com meta ROAS 867%.'),

('[ROAS 788%] PMAX FÓRMULA EXCLUSIVA',
 'pmax_roas_formula-exclusiva',
 'PMax - Fórmula Exclusiva', FALSE,
 'Versão anterior com meta ROAS 788%.'),

('PMAX FÓRMULA EXCLUSIVA [MELHOR HORARIO]',
 'pmax_roas_formula-exclusiva',
 'PMax - Fórmula Exclusiva', FALSE,
 'Versão com segmentação de horário.'),

('Google Performance Max - Site - Estados',
 'pmax_roas_todos-sudeste',
 'PMax - Todos Produtos (Sudeste)', FALSE,
 'Versão original sem prefixo ROAS.'),

('Google Shopping Aroom',
 'shop_roas_todos',
 'Shopping', FALSE,
 'Campanha Shopping original - substituída por shop_roas_todos.'),

('[CA02][TPROD][JUN][SHOPPING]',
 'shop_roas_todos',
 'Shopping', FALSE,
 'Campanha Shopping legada (formato interno antigo).'),

('shop_roas_todos',
 'shop_roas_todos',
 'Shopping', TRUE,
 'Campanha Shopping ativa - todos produtos.'),

-- ── TINTURA MAÇÃ PERUANA (todas as versões) ────────────────────────────────────
('[PMAX] [TINTURA MACA]',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', FALSE,
 'Versão legada da campanha de Tintura/Maçã Peruana.'),

('[550%] [PMAX] [TINTURA MACA]',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', FALSE,
 'Versão com meta ROAS 550%.'),

('[644%] [PMAX] [TINTURA MACA]',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', FALSE,
 'Versão com meta ROAS 644%.'),

('[680%] [PMAX] [TINTURA MACA]',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', FALSE,
 'Versão com meta ROAS 680%.'),

('[700%] [PMAX] [TINTURA MACA]',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', FALSE,
 'Versão com meta ROAS 700%.'),

('[544%] [PMAX] [TINTURA MACA]',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', FALSE,
 'Versão com meta ROAS 544%.'),

('[850%] [PMAX] [TINTURA MACA]',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', FALSE,
 'Versão com meta ROAS 850%.'),

('[859%] [PMAX] [TINTURA MACA]',
 'pmax_roas_maca-peruana',
 'PMax - Maçã Peruana / Tintura', FALSE,
 'Versão com meta ROAS 859%.'),

-- ── PESQUISA / SEARCH ─────────────────────────────────────────────────────────
('search_roas_institucional',
 'search_roas_institucional',
 'Search - Institucional', TRUE,
 'Campanha de pesquisa institucional ativa.'),

('[PESQUISA] [INSTITUCIONAL]',
 'search_roas_institucional',
 'Search - Institucional', FALSE,
 'Versão legada da campanha institucional de pesquisa.'),

('[700%] [PESQUISA] [INSTITUCIONAL]',
 'search_roas_institucional',
 'Search - Institucional', FALSE,
 'Versão com meta ROAS 700%.'),

('[1000%] [PESQUISA] [INSTITUCIONAL]',
 'search_roas_institucional',
 'Search - Institucional', FALSE,
 'Versão com meta ROAS 1000%.'),

('REDE PESQUISA 31-03',
 'search_roas_institucional',
 'Search - Institucional', FALSE,
 'Versão da rede de pesquisa criada em 31/03.'),

('[PESQUISA MACA]',
 'pmax_roas_maca-peruana',
 'Search - Maçã Peruana', FALSE,
 'Campanha de pesquisa para Maçã Peruana.'),

('[pesquisa] [maca]',
 'pmax_roas_maca-peruana',
 'Search - Maçã Peruana', FALSE,
 'Versão em minúsculas da campanha pesquisa maca.'),

('[PESQUISA] [MACA GOTA]',
 'pmax_roas_maca-peruana',
 'Search - Maçã Peruana', FALSE,
 'Variante com produto Maçã Gota.'),

-- ── CONCORRENTE / CAPTAÇÃO ────────────────────────────────────────────────────
('[ROAS 944%] [LANCE ELEVADO] [PESQUISA] [CONCORRENTE]',
 'search_roas_institucional',
 'Search - Concorrente', FALSE,
 'Campanha de concorrentes com lance elevado.'),

('[VENDA APENAS CLIENTES NOVOS] [PESQUISA] [CONCORRENTE]',
 'search_roas_institucional',
 'Search - Concorrente', FALSE,
 'Focada em novos clientes via termos de concorrentes.'),

('[ROAS 620% 29/08] [VENDA APENAS CLIENTES NOVOS] [PESQUISA] [CONCORRENTE]',
 'search_roas_institucional',
 'Search - Concorrente', FALSE,
 'Versão com meta ROAS 620% - novos clientes - concorrentes.'),

('[VENDA] [PESQUISA] [CONCORRENTE]',
 'search_roas_institucional',
 'Search - Concorrente', FALSE,
 'Versão simplificada - pesquisa concorrente.'),

('[VERIFICAR] [VENDA] [PESQUISA] [MOD CATIVA NATUREZA]',
 'search_roas_institucional',
 'Search - Concorrente', FALSE,
 'Campanha com modificador cativa natureza - para verificar.'),

('[VENDA] [PESQUISA] [MOD CATIVA NATUREZA]',
 'search_roas_institucional',
 'Search - Concorrente', FALSE,
 'Versão sem flag verificar - mod cativa natureza.'),

-- ── REGIÃO / SEGMENTAÇÃO GEOGRÁFICA ───────────────────────────────────────────
('[REDUZIDO DE 50] [PMAX] [REGIÃO NORDESTE] [ROAS]',
 'pmax_roas_todos-sudeste',
 'PMax - Regional (Nordeste)', FALSE,
 'PMax segmentado para Nordeste com orçamento reduzido.'),

('[SEARCH] [REGIÃO NORTE] [CPA 11]',
 'search_roas_institucional',
 'Search - Regional', FALSE,
 'Search segmentado para Região Norte com meta CPA R$11.'),

('[SEARCH] [REGIÃO SUDESTE] [CPA 7]',
 'search_roas_institucional',
 'Search - Regional', FALSE,
 'Search segmentado para Região Sudeste com meta CPA R$7.'),

('[SEARCH] [REGIÃO SUL] [CPA 15]',
 'search_roas_institucional',
 'Search - Regional', FALSE,
 'Search segmentado para Região Sul com meta CPA R$15.'),

('[SEARCH] [REGIÃO CENTRO-OESTE] [CPA 15]',
 'search_roas_institucional',
 'Search - Regional', FALSE,
 'Search segmentado para Região Centro-Oeste com meta CPA R$15.'),

('[SEARCH] [REGIÃO NORDESTE] [CPA 13]',
 'search_roas_institucional',
 'Search - Regional', FALSE,
 'Search segmentado para Região Nordeste com meta CPA R$13.'),

-- ── REMARKETING / DISPLAY ─────────────────────────────────────────────────────
('[REDUZIDO DE 30] PMax: [DISPLAY][REMARKETING][VISITANTES][14D]',
 'pmax_roas_formula-exclusiva',
 'Remarketing', FALSE,
 'Remarketing para visitantes dos últimos 14 dias.'),

('[REDE DISPLAY] [CONCORRENTE]',
 'search_roas_institucional',
 'Display', FALSE,
 'Rede Display com público de concorrentes.'),

-- ── VÍDEO / GERAÇÃO DE DEMANDA ────────────────────────────────────────────────
('[GERAÇÃO DE DEMANDA] [VIDEOS] [IA]',
 'pmax_roas_formula-exclusiva',
 'Vídeo / Demanda', FALSE,
 'Campanha de vídeo com IA para geração de demanda.'),

('[GERAÇÃO DE DEMANDA] [09/10]',
 'pmax_roas_formula-exclusiva',
 'Vídeo / Demanda', FALSE,
 'Campanha de demanda criada em 09/10.'),

('[CAMPANHA] [VIDEOS]',
 'pmax_roas_formula-exclusiva',
 'Vídeo / Demanda', FALSE,
 'Campanha de vídeos genérica.'),

('[TESTE ATÉ 25/07] [GERAÇÃO DE DEMANDA] [VIDEOS] [OLEOS VEGETAIS]',
 'pmax_roas_formula-exclusiva',
 'Vídeo / Demanda', FALSE,
 'Teste de vídeo para Óleos Vegetais - encerrado em 25/07.'),

-- ── SAZONAIS ──────────────────────────────────────────────────────────────────
('[PMAX] [DIA DOS NAMORADOS]',
 'pmax_roas_formula-exclusiva',
 'Sazonais', FALSE,
 'Campanha sazonal Dia dos Namorados.'),

('CAMPANHA SEMANA DO CONSUMIDOR',
 'pmax_roas_formula-exclusiva',
 'Sazonais', FALSE,
 'Campanha sazonal Semana do Consumidor.'),

('[CAMPANHA ALCANCE]',
 'pmax_roas_formula-exclusiva',
 'Alcance / Branding', FALSE,
 'Campanha de alcance - branding. Investimento mínimo.')
;
