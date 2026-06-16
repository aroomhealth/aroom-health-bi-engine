# Glossário de Negócios e Métricas Corporativas (Business Glossary)
## Aroom Health BI Engine - Definições Conceituais e Regras de Cálculo

Este documento unifica e padroniza a terminologia conceitual de negócios, fórmulas matemáticas e regras de cálculo para os principais indicadores-chave de desempenho (KPIs) e classificações semânticas utilizadas pela **Aroom Health**.

---

## 1. Domínio Financeiro (Financial Metrics)

### 1.1 Receita Bruta (Gross Revenue)
*   **Definição:** O faturamento total gerado pelas vendas de produtos antes de qualquer dedução de descontos, devoluções, fretes ou taxas de intermediação.
*   **Fórmula de Cálculo:**
    $$\text{Receita Bruta} = \sum (\text{quantidade} \times \text{valor unitário})$$
*   **Campo no BigQuery:** `pedidos_vendas_itens.valor * pedidos_vendas_itens.quantidade`
*   **Dono de Negócio:** CFO / Controladoria.

### 1.2 Receita Líquida (Net Revenue)
*   **Definição:** Faturamento líquido real gerado pela comercialização de produtos, deduzindo-se diretamente os descontos aplicados nos itens. É a base oficial para apuração da Margem de Contribuição e de DRE.
*   **Fórmula de Cálculo:**
    $$\text{Receita Líquida} = \sum ((\text{quantidade} \times \text{valor unitário}) - \text{desconto})$$
*   **Campo no BigQuery:** `(pedidos_vendas_itens.valor * pedidos_vendas_itens.quantidade) - pedidos_vendas_itens.desconto`
*   **Dono de Negócio:** CFO / CMO.

### 1.3 Custo das Mercadorias Vendidas (COGS)
*   **Definição:** Custo total acumulado de fabricação ou aquisição física dos produtos que foram vendidos no período.
*   **Fórmula de Cálculo:**
    $$\text{COGS} = \sum (\text{quantidade vendida} \times \text{preco\_custo cadastrado})$$
*   **Campo no BigQuery:** `pedidos_vendas_itens.quantidade * produtos.preco_custo`
*   **Risco Conhecido:** **91,1% do catálogo** de produtos está com custo cadastrado como R$ 0,00 no ERP.
*   **Dono de Negócio:** Diretor de Operações (COO) / Controladoria.

### 1.4 Margem de Contribuição (Contribution Margin)
*   **Definição:** O lucro gerado pelas vendas que sobra para cobrir os custos fixos da empresa (como folha e aluguel) após deduzir todos os custos variáveis diretos (COGS, comissões de canais e custo de frete de despacho).
*   **Fórmula de Cálculo:**
    $$\text{Margem de Contribuição} = \text{Receita Líquida} - \text{COGS} - \text{Comissão} - \text{Frete Rateado}$$
*   **Campo no BigQuery:** Calculado dinamicamente na view `customer_intelligence.growth_engine_vendas_detalhado`.
*   **Dono de Negócio:** CFO / Diretoria Executiva.

### 1.5 Custo de Frete Rateado
*   **Definição:** Distribuição proporcional do frete total cobrado na nota para cada item contido no pedido, com base na representatividade financeira líquida de cada produto no total faturado. Evita a inflação de despesas logísticas (fan-out).
*   **Fórmula de Cálculo:**
    $$\text{Frete Rateado} = \text{frete total do pedido} \times \left( \frac{\text{Receita Líquida do Item}}{\text{Soma da Receita Líquida de todos os Itens do Pedido}} \right)$$
*   **Campo no BigQuery:** `customer_intelligence.growth_engine_vendas_detalhado.custo_frete`
*   **Dono de Negócio:** Diretor de Logística.

---

## 2. Domínio de Marketing e Vendas (Marketing Metrics)

### 2.1 Investimento em Mídia (Spend)
*   **Definição:** O custo financeiro diário consumido pelas campanhas publicitárias pagas para aquisição de tráfego.
*   **Campo no BigQuery:** `google_ads_campaign_performance.cost_spend` (Google Ads) e `facebook_ads_insights.cost_spend` (Facebook/Meta Ads).
*   **Dono de Negócio:** CMO / Gerente de Mídia Paga.

### 2.2 Retorno sobre Investimento Publicitário Real (ROAS Real)
*   **Definição:** Relação entre a receita líquida gerada por pedidos atribuídos a campanhas e o valor financeiro gasto para veicular os anúncios destas campanhas.
*   **Fórmula de Cálculo:**
    $$\text{ROAS Real} = \frac{\text{Receita Líquida de Vendas Atribuída à Campanha (via UTM)}}{\text{Investimento Total na Campanha (Spend)}}$$
*   **Chave de Atribuição:** Cruzamento viaRegex de `utm_campaign` gravada em `observacoes_internas` do Bling com o `campaign_name` nas tabelas de Ads.
*   **Dono de Negócio:** CMO / Inteligência de Growth.

### 2.3 Taxa de Cliques (CTR)
*   **Definição:** Porcentagem de impressões de anúncios que resultaram em um clique de redirecionamento para o e-commerce.
*   **Fórmula de Cálculo:**
    $$\text{CTR} = \frac{\text{Cliques}}{\text{Impressões}} \times 100$$
*   **Dono de Negócio:** CMO.

---

## 3. Domínio de Clientes e CRM (Customer Intelligence)

### 3.1 Valor de Tempo de Vida do Cliente Histórico (LTV Histórico)
*   **Definição:** A soma de todo o faturamento líquido gerado por compras concluídas por um mesmo consumidor (CPF único) ao longo de todo o seu histórico de relacionamento com a marca.
*   **Fórmula de Cálculo:**
    $$\text{LTV Histórico} = \sum (\text{Receita Líquida de todos os pedidos válidos do cliente})$$
*   **Campo no BigQuery:** `customer_rfm.receita_total_historica_ltv`
*   **Dono de Negócio:** Head de CRM / Customer Experience.

### 3.2 LTV Preditivo de 12 Meses
*   **Definição:** Estimativa estatística/preditiva baseada em aprendizado de máquina que projeta a receita futura provável que o cliente gerará nos próximos 12 meses.
*   **Campo no BigQuery:** `customer_predictions.predicao_ltv_12meses`
*   **Dono de Negócio:** Cientista de Dados / Head de CRM.

### 3.3 Probabilidade de Churn de 30 Dias (Churn Risk)
*   **Definição:** A probabilidade estimada (de 0.00 a 1.00) de um cliente ativo se tornar inativo (não realizar compras) nos próximos 30 dias com base em seu comportamento histórico de recência, frequência e engajamento.
*   **Campo no BigQuery:** `customer_predictions.probabilidade_churn_30d`
*   **Dono de Negócio:** Head de CRM / Growth Engine.

### 3.4 Segmento RFM
*   **Definição:** Agrupamento de clientes baseado em pontuações de **Recência** (tempo desde a última compra), **Frequência** (quantidade de compras realizadas) e **Valor Monetário** (gasto total).
*   **Classificações Padrão:**
    *   *Champions:* Compraram recentemente, compram muito e gastam alto.
    *   *Potential Loyalists:* Clientes com compras recentes e frequência média.
    *   *About to Sleep:* Clientes com recência média alta que necessitam de reativação imediata.
    *   *Hibernating / Lost:* Longo período sem comprar e baixa frequência.
*   **Campo no BigQuery:** `customer_rfm.rfm_segment`
*   **Dono de Negócio:** Head de CRM.

---

## 4. Classificações Específicas da SmartMetrics (SmartMetrics Layer)

Para apoiar decisões táticas de portfólio de produtos e campanhas, foram consolidadas 6 dimensões analíticas proprietárias de taxonomia de produtos na visualização final de BI:

### 4.1 Família do Produto (SmartMetrics 1)
*   **Definição:** Agrupamento estratégico de SKUs em grandes verticais comerciais baseadas em formulação física.
*   **Valores Válidos:**
    *   `1. Óleos Essenciais` (Concentrados puros de aromaterapia).
    *   `2. Óleos Vegetais` (Carreadores puros).
    *   `3. Blends` (Misturas prontas para aplicação).
    *   `4. Fórmulas` (Soluções especializadas de saúde/bem-estar).
    *   `5. Cosméticos` (Cuidados de beleza natural).
    *   `6. Outros` (Acessórios, difusores e itens de apoio).

### 4.2 Objetivo do Produto (SmartMetrics 2)
*   **Definição:** Objetivo principal de uso terapêutico ou comercial do SKU.
*   **Valores Válidos:**
    *   `Terapêutico` (Tratamentos de saúde e sintomas específicos).
    *   `Estético / Cosmético` (Cuidados capilares, de pele ou corporal).
    *   `Bem-estar` (Relaxamento, sono, foco).
    *   `Acessório` (Consumo instrumental).

### 4.3 Etapa da Jornada do Consumidor (SmartMetrics 3)
*   **Definição:** Classificação do papel do produto na atração de novos clientes versus expansão da carteira ativa.
*   **Valores Válidos:**
    *   `Aquisição` (SKUs com baixo valor de barreira, ideais para primeira compra).
    *   `Retenção` (SKUs de alta recompra e consumo frequente).
    *   `Expansão` (SKUs complementares de cross-sell/up-sell).

### 4.4 Nível de Especialização (SmartMetrics 4)
*   **Definição:** Complexidade exigida do cliente para uso ou aplicação segura do produto.
*   **Valores Válidos:**
    *   `Simples` (Pronto para uso por qualquer consumidor, ex: Blends aplicáveis).
    *   `Intermediário` (Exige diluição simples ou regras de uso).
    *   `Avançado` (Exige conhecimento aprofundado ou recomendação terapêutica).

### 4.5 Faixa de Valor do Produto (SmartMetrics 5)
*   **Definição:** Classificação de faixa de preço de venda de tabela de forma categorizada.
*   **Valores Válidos:**
    *   `Low Ticket` (SKUs abaixo de R$ 30,00).
    *   `Medium Ticket` (SKUs de R$ 30,00 a R$ 80,00).
    *   `High Ticket` (SKUs acima de R$ 80,00).

### 4.6 Potencial de Recorrência (SmartMetrics 6)
*   **Definição:** Ciclo médio estimado de esgotamento e necessidade de recompra do produto.
*   **Valores Válidos:**
    *   `Alto` (Ciclo de uso diário e esgotamento rápido de 30 a 45 dias, ex: Óleos carreadores de uso massivo).
    *   `Médio` (Ciclo de 45 a 90 dias).
    *   `Baixo` (Ciclo de longa duração, acima de 90 dias, ou acessórios de uso permanente).
*   **Campo no BigQuery:** `customer_intelligence.growth_engine_vendas_detalhado.potencial_recorrencia`
