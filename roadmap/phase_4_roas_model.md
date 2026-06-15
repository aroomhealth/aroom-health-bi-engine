# Fase 3: Modelo de Atribuição e ROAS por Campanha

## 🎯 Objetivo
Habilitar a correlação direta entre pedidos de vendas do Bling e campanhas de origem de marketing pago, permitindo calcular o ROAS real por campanha.

---

## 📋 Entregáveis & Ações

### 1. Injeção de Parâmetros UTM nos Pedidos (Bling)
* Parametrizar a integração do checkout do e-commerce (ex: Shopify, WooCommerce, Magento) para gravar a string de UTM no campo de observação do pedido no Bling.
* Testar a integridade dos dados trafegados na API.

### 2. Criação do Parser de UTM no BigQuery
* Desenvolver expressões regulares (`REGEXP_EXTRACT`) integradas na view `growth_engine_vendas_detalhado` para quebrar a observação do pedido nas colunas:
  * `utm_source`
  * `utm_medium`
  * `utm_campaign`
  * `utm_content`

### 3. Modelo Consolidado de ROAS
* Desenvolver a view `marketing_performance_roas_detalhado` cruzando os dados da Google Ads com as vendas por campanha extraídas via UTM.
* Disponibilizar esses novos relatórios no painel principal do Looker Studio.
