# Mapeamento de Modelos de Negócio (Business Field Mapping)

Este documento identifica de forma explícita quais tabelas e campos do BigQuery devem ser consumidos para alimentar os principais painéis analíticos e modelos preditivos da **Aroom Health**.

---

## 💵 1. Modelo de Rentabilidade (Profitability Model)

Para calcular a margem de lucro por SKU, canal e campanha, devem ser utilizados:

| Conceito Contábil | Tabela de Origem | Campo Recomendado | Observações / Regra de Negócio |
| :--- | :--- | :--- | :--- |
| **Gross Revenue** | `pedidos_vendas_itens` | `quantidade * valor` | Faturamento bruto gerado pelo item. |
| **Desconto** | `pedidos_vendas_itens` | `desconto` | Descontos concedidos diretamente no produto. |
| **Net Revenue** | `pedidos_vendas_itens` | `(quantidade * valor) - desconto` | Faturamento líquido real. |
| **Product Cost (COGS)**| `produtos` | `preco_custo` | Preço de fabricação. Requer preenchimento urgente. |
| **Freight Cost** | `pedidos_vendas_transporte` | `frete` | Ratear proporcionalmente ao Net Revenue do item no total do pedido. |
| **Commission** | `pedidos_vendas_itens` | `comissao_valor` | Taxas de canais. Requer inserção de regra complementar de-para. |

---

## 📢 2. Modelo de Atribuição de Marketing (ROAS Model)

Para cruzar custos de campanhas, cliques e tráfego com faturamento gerado:

| Conceito de Mídia | Tabela de Origem | Campo Recomendado | Observações / Regra de Negócio |
| :--- | :--- | :--- | :--- |
| **Mídia Gasta (Spend)** | `google_ads_campaign_performance` | `cost_spend` | Investimento diário por campanha (Ads). |
| **Visualizações** | `google_ads_campaign_performance` | `impressions` | Quantidade de visualizações dos anúncios. |
| **Cliques** | `google_ads_campaign_performance` | `clicks` | Quantidade de cliques recebidos. |
| **Origem (Source)** | `google_analytics_utm_daily` | `session_source` | Canal de origem do tráfego (ex: google, meta). |
| **Mídia (Medium)** | `google_analytics_utm_daily` | `session_medium` | Meio do tráfego (ex: cpc, organic, cpm). |
| **Campanha** | `google_analytics_utm_daily` | `session_campaign_name` | Nome da campanha ativa que atraiu o tráfego. |
| **Sessões** | `google_analytics_utm_daily` | `sessions` | Quantidade de sessões de navegação geradas. |

---

## 👤 3. Modelo de Inteligência do Cliente (Customer Intelligence)

Para segmentação comportamental e previsão de comportamento:

| Conceito Analítico | Tabela de Origem | Campo Recomendado | Observações / Regra de Negócio |
| :--- | :--- | :--- | :--- |
| **Identificador** | `customer_profile_enriched` | `customer_id` | Chave primária de vínculo do cliente. |
| **Segmento RFM** | `customer_rfm` | `rfm_segment` | Classificação de fidelidade (Champions, Potential Loyalists, etc.). |
| **LTV Histórico** | `customer_rfm` | `receita_total_historica_ltv` | Receita total líquida acumulada. |
| **LTV Preditivo** | `customer_predictions` | `predicao_ltv_12meses` | Projeção estatística de compras futuras em 12 meses. |
| **Churn Risco** | `customer_predictions` | `probabilidade_churn_30d` | Score preditivo de abandono (0.00 a 1.00). |
| **Repropensão** | `customer_predictions` | `propensao_recompra_score` | Probabilidade de realizar nova compra. |
| **Renda Média** | `customer_profile_enriched` | `renda_media_setor` | Renda da localidade residencial baseada no IBGE. |
| **IDH Regional** | `customer_profile_enriched` | `idh_municipio` | Índice de Desenvolvimento Humano local. |

---

## 🚚 4. Modelo Logístico (Logistics Model)

Para eficiência de frete e prazos de entrega:

| Conceito Logístico | Tabela de Origem | Campo Recomendado | Observações / Regra de Negócio |
| :--- | :--- | :--- | :--- |
| **Frete** | `pedidos_vendas_transporte` | `frete` | Custo do frete cobrado do cliente. |
| **Serviço de Envio**| `pedidos_vendas_transporte` | `volumes_servico` | Nome da transportadora/serviço (Correios, Sedex, etc.). |
| **Rastreamento** | `pedidos_vendas_transporte` | `codigo_rastreamento` | Código de tracking logístico da transportadora. |
| **Prazo** | `pedidos_vendas_transporte` | `prazo_entrega` | Prazo prometido ao cliente em dias úteis. |
| **Distância** | `customer_profile_enriched` | `distancia_cd_km` | Distância física linear calculada em Km até o CD em SP. |
