# Inventário de Tabelas (Table Inventory)

Este documento detalha o inventário de tabelas e views prioritárias no ecossistema da **Aroom Health**, definindo sua tipologia, volumetria (row counts), limites temporais, granularidade de grão (grain) e os riscos identificados no nível de objeto.

---

## 📊 Inventário Detalhado de Tabelas e Views

### 1. `database_aroom_health.pedidos_vendas`
*   **Tipo de Objeto:** Tabela física.
*   **Sistema de Origem:** Bling ERP (via webhook/carga).
*   **Propósito de Negócios:** Registro consolidado de cabeçalhos de pedidos de vendas (tíquetes, descontos globais, datas e vínculos de clientes).
*   **Granularidade (Grain):** Pedido de venda (`identificador`).
*   **Chave Primária Recomendada:** `identificador` (com validação de unicidade).
*   **Chaves Estrangeiras (FK):** `contato_id` (para perfil do cliente), `loja_id` (para canais).
*   **Particionamento / Agrupamento:** Nenhum.
*   **Contagem de Linhas (Rows):** 127.513
*   **Intervalo de Datas:** 05/08/2021 a 15/06/2026.
*   **Riscos Conhecidos:** 
    *   Presença de **2 registros duplicados** no nível de pedido (`identificador`).
    *   Ausência total de rastreamento UTM estruturado nas observações (campo `observacoes_internas` zerado em 93,4% das linhas).

### 2. `database_aroom_health.pedidos_vendas_itens`
*   **Tipo de Objeto:** Tabela física.
*   **Sistema de Origem:** Bling ERP.
*   **Propósito de Negócios:** Registro de itens individuais que compõem cada pedido de venda (quantidade, preços unitários e comissão).
*   **Granularidade (Grain):** Item por pedido (`identificador`).
*   **Chave Primária Recomendada:** `identificador` (sujeito a deduplicação).
*   **Chaves Estrangeiras (FK):** `pedidos_vendas_identificador` (join com pedidos), `produto_id` (join com produtos).
*   **Particionamento / Agrupamento:** Nenhum.
*   **Contagem de Linhas (Rows):** 183.690
*   **Riscos Conhecidos:**
    *   Presença de **895 registros duplicados** no nível de item de pedido (`identificador`).
    *   **7.841 itens** com SKU (`codigo`) nulo ou vazio na tabela transacional.
    *   **4.960 registros** com valor unitário (`valor`) igual ou menor que R$ 0,00.
    *   **67 registros** com quantidade vendida menor ou igual a 0.
    *   Campo de comissões (`comissao_valor`) 100% zerado/vazio (inutilizável para DRE real sem regras externas).

### 3. `database_aroom_health.produtos`
*   **Tipo de Objeto:** Tabela física.
*   **Sistema de Origem:** Bling ERP.
*   **Propósito de Negócios:** Cadastro e catálogo oficial de produtos, preços de tabela, custos de produção e estoque físico.
*   **Granularidade (Grain):** Variação de Produto (`identificador`).
*   **Chave Primária Recomendada:** `identificador`.
*   **Chaves Estrangeiras (FK):** `categoria_id` (join com categorias de produtos).
*   **Contagem de Linhas (Rows):** 9.749
*   **Riscos Conhecidos:**
    *   **8.883 produtos** cadastrados com custo unitário (`preco_custo`) igual a **R$ 0,00** (91,1% do catálogo sem custo). Isso quebra o cálculo de COGS de mais da metade dos itens vendidos.
    *   **5.042 produtos** sem SKU (`codigo`) cadastrado no ERP.
    *   **1.684 produtos** com saldo de estoque (`estoque`) negativo no cadastro.

### 4. `database_aroom_health.pedidos_vendas_transporte`
*   **Tipo de Objeto:** Tabela física.
*   **Sistema de Origem:** Bling ERP.
*   **Propósito de Negócios:** Custos logísticos e dados de frete/rastreamento associados aos pedidos.
*   **Granularidade (Grain):** Registro de frete por pedido (`pedidos_vendas_identificador`).
*   **Chave Primária Recomendada:** `id`.
*   **Chaves Estrangeiras (FK):** `pedidos_vendas_identificador` (pedido de origem), `contato_id` (cliente/transportadora).
*   **Contagem de Linhas (Rows):** 127.513
*   **Riscos Conhecidos:** Dados de frete são declarados globalmente no nível de pedido; requer rateio proporcional no nível do item para evitar duplicação (fan-out).

### 5. `database_aroom_health.bling_canais_venda`
*   **Tipo de Objeto:** Tabela física.
*   **Sistema de Origem:** Bling ERP.
*   **Propósito de Negócios:** Tabela auxiliar contendo de-para de canais e lojas onde as vendas foram realizadas (Shopee, Amazon, Site).
*   **Granularidade (Grain):** Canal de venda (`id_canal`).
*   **Chave Primária Recomendada:** `id`.
*   **Riscos Conhecidos:** Baixo risco; tabela de mapeamento estático e limpo.

### 6. `customer_intelligence.growth_engine_vendas_detalhado`
*   **Tipo de Objeto:** View lógica.
*   **Sistema de Origem:** Modelo de transformação SmartMetrics BI Engine.
*   **Propósito de Negócios:** Consolidação semântica e deduplicada para relatórios contábeis e de marketing. Conecta vendas, custos, frete rateado e dimensões comportamentais do cliente.
*   **Granularidade (Grain):** Item por pedido.
*   **Chave Primária Recomendada:** `pedido_id` + `item_id`.
*   **Contagem de Linhas (Rows):** 183.692
*   **Intervalo de Datas:** 05/08/2021 a 15/06/2026.
*   **Riscos Conhecidos:**
    *   **108.442 registros de vendas (59%)** com custo total do produto (`custo_total_produto`) zerado por conta da falta de custo no catálogo de produtos (`produtos`).
    *   **1.495 registros** sem estado do cliente (`uf`) preenchido na base.

### 7. `database_aroom_health.google_ads_campaign_performance`
*   **Tipo de Objeto:** Tabela física.
*   **Sistema de Origem:** Google Ads API (BigQuery Data Transfer Service).
*   **Propósito de Negócios:** Consolidação diária de impressões, cliques, custos (spend) e conversões das campanhas do Google Ads.
*   **Granularidade (Grain):** Campanha por dia (`campaign_name` + `day`).
*   **Contagem de Linhas (Rows):** 3.418
*   **Intervalo de Datas:** 09/05/2024 a 12/12/2025.
*   **Riscos Conhecidos:** 
    *   **Paralisação Total:** Não possui novos registros após **12/12/2025**. O pipeline está quebrado e dados recentes não são ingeridos.

### 8. `database_aroom_health.google_analytics_utm_daily`
*   **Tipo de Objeto:** Tabela física.
*   **Sistema de Origem:** Google Analytics 4 API (DTS).
*   **Propósito de Negócios:** Consolidação diária de sessões agregadas por UTM de tráfego.
*   **Granularidade (Grain):** Combinação de UTMs (`metric_date` + `session_source` + `session_medium` + `session_campaign_name`).
*   **Contagem de Linhas (Rows):** 20.969
*   **Intervalo de Datas:** 01/01/2025 a 15/06/2026.
*   **Riscos Conhecidos:** Tráfego direto e orgânico alto; sem conexão transacional direta com pedidos de vendas (Bling) sem uso de chaves como sessões ou UTMs injetadas.
