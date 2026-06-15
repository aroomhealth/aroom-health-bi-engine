# Estratégia de Atribuição de Marketing & Cálculo de ROAS Real

Este documento detalha o plano técnico para implementar o rastreamento de parâmetros UTM no ERP Bling e realizar a atribuição de receita ao nível de campanha no BigQuery para o cálculo do Retorno sobre Investimento em Anúncios (ROAS).

---

## 🎯 Objetivo de Negócio

Para otimizar os investimentos de marketing digital, a Aroom Health precisa saber exatamente **qual campanha gerou qual venda**. 

A correlação atual é feita de forma macro (faturamento diário vs. investimento diário). A nova abordagem permitirá a rastreabilidade direta do pedido até a campanha de origem, possibilitando:
1. Identificar campanhas de Google Ads e Meta Ads com ROAS real positivo/negativo.
2. Calcular o Custo de Aquisição de Cliente (CAC) por canal/campanha.
3. Alocar orçamento de marketing com base em dados de margem real.

---

## 🛠️ Arquitetura Técnica Proposta

### 1. Captura de UTM no E-commerce (Checkout)
Quando um cliente finaliza uma compra no site, o checkout deve capturar os parâmetros UTM da sessão ativa (`utm_source`, `utm_medium`, `utm_campaign`, `utm_content`, `utm_term`) persistidos nos cookies ou LocalStorage do navegador.

### 2. Injeção no Bling
Ao enviar o pedido via API do Bling (ou integração nativa do e-commerce), insira os dados de UTM formatados dentro do campo **Observações Internas** (`obs_internas` ou similar) do pedido.

* **Exemplo de string a ser injetada no pedido do Bling:**
  `[UTM: source=google | medium=cpc | campaign=conversao_oleos_capilares_jun26 | content=ad_imagem_01]`

### 3. Extração no BigQuery via Expressões Regulares
Na view `growth_engine_vendas_detalhado`, utilizaremos a função `REGEXP_EXTRACT` do BigQuery para extrair os parâmetros individualizados a partir do campo de observação do pedido.

* **Exemplo de SQL para extração:**
  ```sql
  SELECT
      p.identificador as pedido_id,
      -- Extrações de UTM
      REGEXP_EXTRACT(p.observacoes_internas, r'source=([^|\s\]]+)') as utm_source,
      REGEXP_EXTRACT(p.observacoes_internas, r'medium=([^|\s\]]+)') as utm_medium,
      REGEXP_EXTRACT(p.observacoes_internas, r'campaign=([^|\s\]]+)') as utm_campaign,
      REGEXP_EXTRACT(p.observacoes_internas, r'content=([^|\s\]]+)') as utm_content
  FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` p
  ```

### 4. Modelo de Cálculo de ROAS no BigQuery
Com as UTMs extraídas da view de vendas, podemos criar uma nova visão consolidada que cruza o faturamento por campanha com o custo de marketing importado das tabelas do Google Ads e Facebook Ads.

```sql
WITH receita_por_campanha AS (
    SELECT 
        utm_campaign,
        SUM(receita_total) as receita_atribuida
    FROM `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`
    WHERE utm_source = 'google' AND utm_medium = 'cpc'
    GROUP BY utm_campaign
),
custo_por_campanha AS (
    SELECT 
        campaign_name,
        SUM(cost) as custo_campanha
    FROM `iron-rex-461220-g4.google_ads.campaign_performance`
    GROUP BY campaign_name
)
SELECT 
    r.utm_campaign as campanha,
    r.receita_atribuida,
    c.custo_campanha,
    SAFE_DIVIDE(r.receita_atribuida, c.custo_campanha) as roas
FROM receita_por_campanha r
JOIN custo_por_campanha c ON r.utm_campaign = c.campaign_name
```
