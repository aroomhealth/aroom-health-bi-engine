# Avaliação de Maturidade e Prontidão para IA (AI Readiness Assessment)
## Aroom Health BI Engine - Análise de Feature Engineering e Modelagem Preditiva

Este documento avalia a maturidade e a prontidão das tabelas do BigQuery da **Aroom Health** para suportar modelos de Inteligência Artificial e Aprendizado de Máquina (Machine Learning), identificando as lacunas de recursos (feature gaps) e propondo caminhos estratégicos de expansão de IA.

---

## 1. Avaliação de Prontidão por Modelos Preditivos Ativos

Atualmente, o ecossistema analítico possui três frentes ativas de modelagem estatística na camada `customer_intelligence`. Abaixo é apresentada a análise técnica de maturidade de cada frente:

### 1.1 Modelo 1: Previsão de Churn (Churn Prediction Model)
*   **Tabela de Origem:** `customer_intelligence.customer_predictions`
*   **Campos Chave:** `probabilidade_churn_30d`, `categoria_risco_churn`
*   **Maturidade dos Dados:** `🟢 ALTA`
*   **Análise de Prontidão:** A base de clientes possui identificadores técnicos consistentes (`customer_id`) atrelados a scores de risco de churn de 0.00 a 1.00. A categorização em faixas de risco (Baixo, Médio, Alto) está pronta para ser consumida como gatilho de automação em ferramentas de CRM (ActiveCampaign) para disparos automáticos de e-mails de reengajamento.

### 1.2 Modelo 2: Projeção de LTV Preditivo (Lifetime Value Prediction)
*   **Tabela de Origem:** `customer_intelligence.customer_predictions`
*   **Campos Chave:** `predicao_ltv_12meses`
*   **Maturidade dos Dados:** `🟡 MÉDIA`
*   **Análise de Prontidão:** O campo prediz a receita bruta esperada para os próximos 12 meses. No entanto, sua precisão e utilidade estratégica são severamente limitadas pela ausência de margens reais. Sem o preço de custo unitário (`preco_custo`) cadastrado, o modelo não consegue estimar o LTV líquido em termos de lucro, apenas em receita.

### 1.3 Modelo 3: Afinidade de Produtos (Market Basket Analysis)
*   **Tabela de Origem:** `customer_intelligence.product_affinity`
*   **Campos Chave:** `sku_a`, `sku_b`, scores de afinidade (Confiança, Suporte, Lift)
*   **Maturidade dos Dados:** `🟢 ALTA`
*   **Análise de Prontidão:** A tabela está estruturalmente completa, contendo chaves de associação consistentes entre produtos que são frequentemente comprados juntos (ex: Óleo de Alecrim e Rícino). Está perfeitamente apta a alimentar motores de recomendação em tempo real no carrinho do e-commerce ou sugerir a criação de pacotes (combos promocionais) para o time comercial.

---

## 2. Mapa de Recursos Disponíveis (Features) para Modelagem

Analisamos o catálogo de dados físicos e classificamos a qualidade e disponibilidade das variáveis de entrada (features) para uso imediato em algoritmos de Machine Learning:

| Categoria da Feature | Variáveis Disponíveis | Cobertura | Qualidade para Modelos | Recomendação de Engenharia |
| :--- | :--- | :---: | :---: | :--- |
| **Socioeconômicas (IBGE)** | `renda_media_setor`, `idh_municipio`, `escolaridade_media_setor` | ~99,9% | `🟢 EXCELENTE` | Dados censitários normatizados e ideais para clusterização regional e previsão de tíquete médio. |
| **Logísticas (CD)** | `distancia_cd_km`, `estado`, `volumes_servico` | ~99,9% | `🟢 EXCELENTE` | Coordenadas e distância linear calculadas com precisão. Excelente feature de entrada para regressão de prazos. |
| **Financeiras (Lucratividade)**| `preco_custo` (COGS), `comissao_valor` | ~8,9% | `🔴 CRÍTICA` | **Falta Crítica de Dados.** Quebra o cálculo de features de margem de lucro por pedido, inviabilizando modelos de otimização de lucro. |
| **Atribuição (Marketing)** | `session_source`, `session_medium`, `session_campaign_name` | < 10% | `🔴 CRÍTICA` | **Quebra de Ingestão e Registro.** UTMs ausentes em 93,4% das transações e Ads congelado inviabilizam modelos de ROI/Atribuição. |
| **Comportamentais (RFM)** | `recency_days`, `frequency_purchases`, `total_spend` | 100% | `🟢 EXCELENTE` | Chaves agregadas calculadas de recência e frequência em perfeita prontidão para alimentar modelos de árvore de decisão. |

---

## 3. Principais Gaps de Recursos de Dados (Feature Gaps)

Para avançar com segurança na implantação de inteligência preditiva avançada, os seguintes Gaps de Dados devem ser mitigados obrigatoriamente:

### 3.1 Gap 1: Custo de Produto Zerado (COGS Nulo)
*   **Problema:** Sem a feature `preco_custo` cadastrada, qualquer modelo preditivo de LTV ou Churn focará exclusivamente em maximizar a Receita Bruta, podendo sugerir campanhas de reativação para clientes de alto faturamento bruto, mas de margem negativa (ex: compradores de produtos com alto frete e margem de contribuição espremida).
*   **Impacto no AI:** Modelos de recomendação focados em combos podem sugerir pacotes de vendas que geram prejuízo contábil para a Aroom Health.

### 3.2 Gap 2: Desatualização das Fontes de Marketing (Google Ads DTS)
*   **Problema:** Dados de impressões e cliques do Google Ads congelados desde dezembro de 2025.
*   **Impacto no AI:** Inviabiliza a criação de modelos de Marketing Mix Modeling (MMM) ou regressões preditivas para otimização de orçamento de mídia, já que as séries temporais de investimento publicitário estão incompletas há meses.

---

## 4. Estratégia de Expansão de IA via BigQuery ML

Uma vez sanados os gaps de custo e marketing (Fases 1 e 2 de Roadmap), recomendamos o uso do **BigQuery ML (BQML)** para implementar algoritmos preditivos diretamente na base de dados por meio de comandos SQL, simplificando a arquitetura e reduzindo os custos de pipeline de dados.

### 4.1 Modelo de Propensão de Compra (Classificação Binária - Regressão Logística)
Permite prever a probabilidade de um cliente ativo realizar uma nova compra nos próximos 30 dias com base na sua recência e renda média local:

```sql
-- Exemplo de Criação de Modelo Preditivo no BigQuery ML
CREATE OR REPLACE MODEL `customer_intelligence.model_propensao_recompra`
OPTIONS(
  model_type='logistic_reg',
  input_label_cols=['realizou_recompra_30d']
) AS
SELECT 
    c.renda_media_setor,
    c.distancia_cd_km,
    rfm.recency_days,
    rfm.frequency_purchases,
    CASE WHEN rfm.recency_days <= 30 THEN 1 ELSE 0 END AS realizou_recompra_30d
FROM `customer_intelligence.customer_profile_enriched` c
JOIN `customer_intelligence.customer_rfm` rfm ON c.customer_id = rfm.customer_id;
```

### 4.2 Modelo de Segmentação de Clientes (Agrupamento - K-Means)
Permite criar automaticamente novos clusters comportamentais atualizados com base no valor gasto e localização geográfica para campanhas segmentadas de CRM:

```sql
-- Exemplo de Clusterização Automatizada via BigQuery ML
CREATE OR REPLACE MODEL `customer_intelligence.model_clusters_clientes`
OPTIONS(
  model_type='kmeans',
  num_clusters=4
) AS
SELECT 
    renda_media_setor,
    distancia_cd_km,
    receita_total_historica_ltv
FROM `customer_intelligence.customer_profile_enriched` c
JOIN `customer_intelligence.customer_rfm` rfm ON c.customer_id = rfm.customer_id;
```
