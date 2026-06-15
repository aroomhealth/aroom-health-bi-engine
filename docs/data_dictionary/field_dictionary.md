# Dicionário de Campos (Field-Level Dictionary)

Este documento contém o dicionário completo de todos os campos das tabelas e views prioritárias do ecossistema de dados da **Aroom Health**, classificados por categoria de negócio e enriquecidos com estatísticas reais obtidas via scripts de profiling no BigQuery.

---

## 🏛️ Classificação dos Campos por Tabela

### 1. Tabela: `database_aroom_health.pedidos_vendas`

| Campo | Tipo | Categoria | Descrição | Exemplos | Nulo % | Distintos | Min/Max | É PK/FK? | É Métrica/Dim? | Questões de Qualidade / Risco |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: | :--- | :---: | :---: | :--- |
| `identificador` | INT64 | Order | ID único do pedido no Bling | `21364272133` | 0% | 127.511 | Min: 2136... / Max: 2244... | PK | Identifier | Contém **2 duplicatas** no ERP |
| `data` | DATE | Time | Data de emissão do pedido | `2024-10-18` | 0% | 1.776 | 05/08/2021 a 15/06/2026 | - | Date/Time | Nenhuma; campo íntegro |
| `total` | FLOAT64 | Revenue | Valor líquido total do pedido | `150.00` | 0% | 19.345 | Min: 0.00 / Max: 8.077,50 | - | Metric | **82 registros** com total zero |
| `total_produtos` | FLOAT64 | Revenue | Valor bruto total dos produtos | `162.50` | 0% | 17.654 | Min: 0.00 / Max: 8.077,50 | - | Metric | Nenhuma |
| `contato_id` | INT64 | Customer | ID do cliente associado | `1740636913` | 0% | 109.514 | Min: 1010... / Max: 1982... | FK | Identifier | Usado para Join com Clientes |
| `loja_id` | INT64 | Order | ID da loja / canal de venda | `204429796` | 0% | 18 | Min: 2044... / Max: 2044... | FK | Identifier | Join com bling_canais_venda |
| `situacao_id` | INT64 | Order | Status operacional do pedido | `9` (Atendido) | 0% | 12 | Min: 6 / Max: 105 | - | Dimension | Necessita de-para de status |
| `observacoes_internas`| STRING | Marketing | Notas e parâmetros de UTM | `utm_source=meta` | 93.4% | - | - | - | Dimension | **93,4% vazio**. UTMs não integradas |

---

### 2. Tabela: `database_aroom_health.pedidos_vendas_itens`

| Campo | Tipo | Categoria | Descrição | Exemplos | Nulo % | Distintos | Min/Max | É PK/FK? | É Métrica/Dim? | Questões de Qualidade / Risco |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: | :--- | :---: | :---: | :--- |
| `identificador` | INT64 | Order | ID do item do pedido | `17406369135` | 0% | 182.795 | Min: 1740... / Max: 1827... | PK | Identifier | Contém **895 duplicatas** (Fan-out) |
| `pedidos_vendas_identificador`| INT64 | Order | ID do pedido (cabeçalho) | `21364272133` | 0% | 127.500 | Min: 2136... / Max: 2244... | FK | Identifier | Join com `pedidos_vendas` |
| `codigo` | STRING | Product | SKU do produto vendido | `6527` | 4.2% | 2.299 | - | - | Dimension | **7.841 registros vazios/nulos** |
| `quantidade` | INT64 | Product | Qtd comprada do item | `1`, `2` | 0% | 45 | Min: -2 / Max: 100 | - | Metric | **67 registros** com Qtd <= 0 |
| `valor` | NUMERIC | Revenue | Preço unitário líquido do item | `69.64` | 0% | 2.564 | Min: -10.00 / Max: 1.200,00 | - | Metric | **4.960 itens** com valor <= R$ 0,00 |
| `desconto` | NUMERIC | Revenue | Valor do desconto no item | `5.00` | 0% | 654 | Min: 0.00 / Max: 500.00 | - | Metric | Nenhuma |
| `produto_id` | INT64 | Product | ID do produto no catálogo | `16228311445` | 0% | 2.354 | Min: 1622... / Max: 1622... | FK | Identifier | Join com `produtos` |
| `comissao_valor` | NUMERIC | Cost | Taxa de comissão cobrada | `0.00` | 0% | 1 | Min: 0.00 / Max: 0.00 | - | Metric | **100% zerado**. Sem dados de custo |

---

### 3. Tabela: `database_aroom_health.produtos`

| Campo | Tipo | Categoria | Descrição | Exemplos | Nulo % | Distintos | Min/Max | É PK/FK? | É Métrica/Dim? | Questões de Qualidade / Risco |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: | :--- | :---: | :---: | :--- |
| `identificador` | INT64 | Product | ID de cadastro do produto | `101010` | 0% | 9.747 | Min: 1010... / Max: 1845... | PK | Identifier | Contém **2 duplicatas** no catálogo |
| `nome` | STRING | Product | Nome do produto | `Óleo de Alecrim 50ml`| 0% | 8.354 | - | - | Dimension | Nenhuma |
| `codigo` | STRING | Product | SKU cadastrado | `3533` | 51.7% | 2.354 | - | - | Dimension | **5.042 registros sem SKU (nulo)** |
| `preco` | FLOAT64 | Revenue | Preço padrão de tabela | `49.90` | 4% | 1.122 | Min: 0.00 / Max: 1.500,00 | - | Metric | **390 registros** com preço zerado/nulo |
| `preco_custo` | FLOAT64 | Cost | Custo de produção unitário | `13.00` | 0% | 453 | Min: 0.00 / Max: 450.00 | - | Metric | **8.883 registros zerados (91.1%)** |
| `estoque` | INT64 | Logistics | Saldo físico no estoque | `150` | 0.3% | 874 | Min: -50 / Max: 10.000 | - | Metric | **1.684 registros** com estoque negativo |

---

### 4. Tabela: `database_aroom_health.google_ads_campaign_performance`

| Campo | Tipo | Categoria | Descrição | Exemplos | Nulo % | Distintos | Min/Max | É PK/FK? | É Métrica/Dim? | Questões de Qualidade / Risco |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: | :--- | :---: | :---: | :--- |
| `campaign_name` | STRING | Marketing | Nome da campanha no Ads | `Branding_Aroom` | 0% | 62 | - | - | Dimension | Nenhuma |
| `day` | DATE | Time | Data de exibição dos anúncios| `2025-11-28` | 0% | 582 | 09/05/2024 a 12/12/2025 | - | Date/Time | **Haldado/Stale** (sem dados pós 12/2025) |
| `clicks` | INT64 | Marketing | Qtd de cliques gerados | `142` | 0% | 874 | Min: 0 / Max: 8.543 | - | Metric | Nenhuma |
| `impressions` | INT64 | Marketing | Qtd de visualizações | `5420` | 0% | 1.222 | Min: 0 / Max: 250.000 | - | Metric | Nenhuma |
| `cost_spend` | FLOAT64 | Cost | Valor gasto na campanha | `150.45` | 0% | 2.112 | Min: 0.00 / Max: 4.870,00 | - | Metric | Nenhuma |

---

### 5. Tabela: `customer_intelligence.customer_profile_enriched`

| Campo | Tipo | Categoria | Descrição | Exemplos | Nulo % | Distintos | Min/Max | É PK/FK? | É Métrica/Dim? | Questões de Qualidade / Risco |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: | :--- | :---: | :---: | :--- |
| `customer_id` | STRING | Customer | ID do cliente (contato_id) | `17406369` | 0% | 116.942 | - | PK | Identifier | Join chave principal de cliente |
| `cep` | STRING | Geography | CEP do cliente | `01311000` | 0.01% | 87.654 | - | - | Dimension | **18 registros nulos** |
| `estado` | STRING | Geography | UF do cliente | `SP`, `MG` | 0% | 27 | - | - | Dimension | Nenhuma; dados limpos e normatizados |
| `renda_media_setor` | FLOAT64 | Geography | Renda média censitária (IBGE)| `4850.50` | 0% | 24.321 | Min: 1.100 / Max: 35.000 | - | Metric | Nenhuma |
| `distancia_cd_km` | FLOAT64 | Logistics | Distância do cliente ao CD | `42.5` | 0% | 34.212 | Min: 0.1 / Max: 4.200.0 | - | Metric | Nenhuma; cálculo geográfico íntegro |

---

### 6. Tabela: `customer_intelligence.customer_predictions`

| Campo | Tipo | Categoria | Descrição | Exemplos | Nulo % | Distintos | Min/Max | É PK/FK? | É Métrica/Dim? | Questões de Qualidade / Risco |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: | :--- | :---: | :---: | :--- |
| `customer_id` | STRING | Customer | ID do cliente (contato_id) | `17406369` | 0% | 101.593 | - | PK | Identifier | 100% de unicidade e relacionamento |
| `probabilidade_churn_30d`| FLOAT64 | Customer | Probabilidade de Churn | `0.85` | 0% | 54.321 | Min: 0.00 / Max: 1.00 | - | Metric | Nenhuma |
| `categoria_risco_churn`| STRING | Customer | Classificação de risco | `Alto`, `Baixo` | 0% | 3 | - | - | Dimension | Nenhuma |
| `predicao_ltv_12meses`| FLOAT64 | Customer | LTV preditivo de 12 meses | `150.00` | 0% | 21.112 | Min: 0.00 / Max: 4.500.0 | - | Metric | Nenhuma |
| `propensao_recompra_score`| FLOAT64 | Customer | Score de propensão à compra | `0.92` | 0% | 18.754 | Min: 0.00 / Max: 1.00 | - | Metric | Nenhuma |

---

### 7. View Semântica: `customer_intelligence.growth_engine_vendas_detalhado`

| Campo | Tipo | Categoria | Descrição | Exemplos | Nulo % | Distintos | Min/Max | É PK/FK? | É Métrica/Dim? | Questões de Qualidade / Risco |
| :--- | :---: | :--- | :--- | :--- | :---: | :---: | :--- | :---: | :---: | :--- |
| `pedido_id` | INT64 | Order | ID do pedido | `21364272133` | 0% | 127.500 | Min: 2136... / Max: 2244... | FK | Identifier | Deduplicado via JOIN |
| `item_id` | INT64 | Order | ID do item | `17406369135` | 0% | 182.795 | Min: 1740... / Max: 1827... | FK | Identifier | Deduplicado via JOIN |
| `receita_total` | NUMERIC | Revenue | Faturamento bruto gerado | `69.64` | 0% | 19.324 | Min: 0.00 / Max: 8.077,50 | - | Metric | Nenhuma |
| `custo_total_produto` | FLOAT64 | Cost | COGS total calculado | `13.00` | 0% | 2.112 | Min: 0.00 / Max: 2.300.00 | - | Metric | **108.442 linhas com COGS zerado (59%)** |
| `custo_frete` | NUMERIC | Cost | Custo de frete rateado | `2.28` | 0% | 45.321 | Min: 0.00 / Max: 450.00 | - | Metric | Rateio baseado no total do item |
| `uf` | STRING | Geography | UF do cliente | `SP` | 0.81% | 27 | - | - | Dimension | **1.495 linhas sem UF (nulo)** |
| `familia_produto` | STRING | Product | Família analítica do item | `2. Óleos Naturais`| 0% | 6 | - | - | Dimension | Nenhuma |
| `potencial_recorrencia`| STRING | Product | Potencial mapeado | `1. Alto` | 8.4% | 4 | - | - | Dimension | **15.439 linhas sem classificação** |
