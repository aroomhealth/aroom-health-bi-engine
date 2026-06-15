# Inventário de Datasets (Dataset Inventory)

Este documento apresenta a relação de todos os datasets do BigQuery integrados ao ecossistema analítico da **Aroom Health**, descrevendo sua finalidade de negócios, sistema de origem, frequência de atualização e dependências.

---

## 📂 Datasets do Ecossistema Analítico

### 1. `database_aroom_health`
*   **Finalidade de Negócios:** Contém as tabelas transacionais do ERP Bling importadas em estado bruto (Raw/Staging), além de tabelas integradas de campanhas de marketing (Google Ads e Google Analytics UTMs).
*   **Sistema de Origem:** Bling ERP, Google Ads API (via DTS), Google Analytics 4 API (via DTS).
*   **Frequência de Atualização:**
    *   Tabelas Bling: Diária (D-1).
    *   Tabelas Google Ads / GA UTMs: Habilitada historicamente; Google Ads está paralisada desde **12/12/2025** por quebra de pipeline.
*   **Responsável / Proprietário:** TI e Engenharia de Dados (Aroom Health).
*   **Dependências a Jusante (Downstream):** `customer_intelligence` (views semânticas e tabelas agregadas).
*   **Tabelas/Views Críticas Contidas:**
    *   `pedidos_vendas` (Tabela)
    *   `pedidos_vendas_itens` (Tabela)
    *   `produtos` (Tabela)
    *   `pedidos_vendas_transporte` (Tabela)
    *   `bling_canais_venda` (Tabela)
    *   `google_ads_campaign_performance` (Tabela)
    *   `google_analytics_utm_daily` (Tabela)

### 2. `customer_intelligence`
*   **Finalidade de Negócios:** Camada semântica e de modelagem de negócios (Marts). Centraliza dados enriquecidos de clientes, segmentações RFM, propensão de compra, previsões de churn e a view final unificada de vendas detalhadas.
*   **Sistema de Origem:** Processamentos internos de engenharia analítica sobre as tabelas brutas de `database_aroom_health` e cruzamentos com dados externos do IBGE.
*   **Frequência de Atualização:** Diária / Agendada por rotinas do BigQuery.
*   **Responsável / Proprietário:** Equipe de BI e Growth (Smartmetric Analytics).
*   **Dependências a Jusante (Downstream):** Looker Studio (Painéis Executivos, CRM, ActiveCampaign).
*   **Tabelas/Views Críticas Contidas:**
    *   `growth_engine_vendas_detalhado` (View Semântica)
    *   `customer_profile_enriched` (Tabela)
    *   `customer_rfm` (Tabela)
    *   `customer_predictions` (Tabela)
    *   `product_affinity` (Tabela)
    *   `ref_municipios_ibge` (Tabela)

### 3. `google_ads` (ou `google_ads` da conta `5644422842`)
*   **Finalidade de Negócios:** Conjunto de views detalhadas geradas nativamente pela integração do Google Ads Data Transfer Service. Contém estatísticas de anúncios, orçamentos, audiências e conversões.
*   **Sistema de Origem:** Google Ads API (BigQuery Data Transfer Service).
*   **Frequência de Atualização:** Habilitada; inativa / desatualizada desde **12/12/2025**.
*   **Responsável / Proprietário:** Equipe de Mídia Paga / CMO.
*   **Dependências a Jusante (Downstream):** Nenhuma ativa (devido à quebra do pipeline).
*   **Tabelas/Views Críticas Contidas:**
    *   `ads_CampaignBasicStats_5644422842` (View)
    *   `ads_AdStats_5644422842` (View)
    *   `ads_Budget_5644422842` (View)

### 4. `analytics_414017556`
*   **Finalidade de Negócios:** Exportação nativa e granular em nível de evento de comportamento de tráfego do Google Analytics 4 (GA4).
*   **Sistema de Origem:** Google Analytics 4 (Integração Direta do Firebase/GA4 no BigQuery).
*   **Frequência de Atualização:** Diária (Sharded tables por data, ex: `events_YYYYMMDD`).
*   **Responsável / Proprietário:** Marketing Digital.
*   **Dependências a Jusante (Downstream):** View semântica e rotinas de extração de tráfego.
*   **Tabelas/Views Críticas Contidas:**
    *   `events_20260611` a `events_20260614` (Tabelas Diárias)
