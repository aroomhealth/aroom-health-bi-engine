# Relatório de Descoberta Enterprise do BigQuery & Roadmap de Governança
## Aroom Health - Arquitetura de Dados, Governança e Inteligência de Negócio

---

## 1. Catálogo e Inventário de Ativos do BigQuery (Asset Inventory)

Abaixo é apresentado o inventário físico completo do ambiente de BigQuery no projeto Google Cloud Platform (`iron-rex-461220-g4`) para a **Aroom Health**, consolidando o volume de registros, tamanho físico em bytes, data de última modificação e domínio de negócio mapeado.

O ecossistema é composto por 3 conjuntos de dados principais (datasets):
1.  **`database_aroom_health`**: Camada bruta (Raw/Staging) que armazena os dados transacionais do ERP Bling, canais adicionais (Mercado Livre, Nuvemshop) e métricas de campanhas (Google Ads, Facebook Ads e Google Analytics UTMs).
2.  **`customer_intelligence`**: Camada semântica e analítica refinada (Marts), que unifica as visões de perfil de cliente 360, pontuações RFM, propensão de compra e a view de vendas unificada.
3.  **`analytics_414017556`**: Exportação nativa baseada em eventos diários do Google Analytics 4 (GA4).

### 📊 Catálogo Geral de Tabelas e Views

| Dataset | Nome da Tabela / View | Tipo | Linhas | Tamanho (MB) | Última Atualização | Domínio de Negócio |
| :--- | :--- | :---: | :---: | :---: | :---: | :--- |
| **database_aroom_health** | `pedidos_vendas_parcelas` | Tabela | 1.188.790 | 176,22 MB | 2026-06-16 | Vendas / Financeiro |
| **database_aroom_health** | `view_financeiro` | Tabela | 353.420 | 68,40 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `pedidos_vendas_itens` | Tabela | 183.719 | 46,20 MB | 2026-06-16 | Vendas |
| **database_aroom_health** | `view_vendas` | Tabela | 164.409 | 120,66 MB | 2026-06-16 | Vendas |
| **database_aroom_health** | `pedidos_vendas_v2` | Tabela | 138.734 | 12,08 MB | 2026-06-16 | Vendas |
| **database_aroom_health** | `contatos_v2` | Tabela | 131.242 | 14,29 MB | 2026-06-16 | Clientes |
| **database_aroom_health** | `pedidos_vendas_transporte` | Tabela | 128.142 | 21,40 MB | 2026-06-16 | Logística |
| **database_aroom_health** | `pedidos_vendas_desconto` | Tabela | 128.140 | 12,22 MB | 2026-06-16 | Vendas |
| **database_aroom_health** | `pedidos_vendas_intermediador` | Tabela | 128.140 | 12,79 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `pedidos_vendas_taxas` | Tabela | 128.140 | 14,42 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `pedidos_vendas_tributacao` | Tabela | 128.140 | 13,44 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `pedidos_vendas_transporte_etiqueta` | Tabela | 128.139 | 22,90 MB | 2026-06-16 | Logística |
| **database_aroom_health** | `pedidos_vendas_situacao` | Tabela | 127.718 | 11,45 MB | 2026-06-16 | Metadados |
| **database_aroom_health** | `pedidos_vendas` | Tabela | 127.528 | 39,18 MB | 2026-06-16 | Vendas |
| **database_aroom_health** | `pedidos_vendas_partitioned` | Tabela | 127.483 | 39,16 MB | 2026-06-11 | Vendas |
| **database_aroom_health** | `contato_endereco` | Tabela | 122.308 | 19,22 MB | 2026-06-16 | Clientes |
| **database_aroom_health** | `contato` | Tabela | 119.036 | 23,62 MB | 2026-06-16 | Clientes |
| **database_aroom_health** | `cpf_exclusivos` | Tabela | 109.636 | 2,20 MB | 2026-06-16 | Clientes |
| **database_aroom_health** | `Contatos_Tratados` | Tabela | 109.631 | 71,16 MB | 2026-06-16 | Clientes (Duplicado) |
| **database_aroom_health** | `view_contatos_tratados` | View | 109.631 | 71,16 MB | 2026-06-16 | Clientes |
| **database_aroom_health** | `nomes_genero` | Tabela | 103.306 | 1,18 MB | 2025-06-01 | Metadados / CRM |
| **database_aroom_health** | `dicionario_nome_genero` | Tabela | 100.788 | 5,01 MB | 2025-06-01 | Metadados / CRM |
| **database_aroom_health** | `contas_receber` | Tabela | 91.985 | 13,30 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `contas_receber_partitioned` | Tabela | 91.597 | 13,24 MB | 2026-06-11 | Financeiro |
| **database_aroom_health** | `contas_receber_origem` | Tabela | 82.590 | 16,19 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `notas_fiscais_saida` | Tabela | 72.858 | 12,71 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `meta_ads_actions` | Tabela | 67.591 | 17,32 MB | 2025-07-29 | Marketing (Stale) |
| **database_aroom_health** | `bling_webhook_log` | Tabela | 59.712 | 8,71 MB | 2026-06-16 | Governança |
| **database_aroom_health** | `nuvemshop_pedido_produto` | Tabela | 48.213 | 25,77 MB | 2026-06-16 | Vendas (E-commerce) |
| **database_aroom_health** | `view_vendas_nuvem` | Tabela | 48.207 | 32,88 MB | 2026-06-16 | Vendas (E-commerce) |
| **database_aroom_health** | `bling_estoque_saldos` | Tabela | 44.117 | 12,45 MB | 2026-06-12 | Produtos / Estoque |
| **database_aroom_health** | `orders_tracking` | Tabela | 38.546 | 4,17 MB | 2026-06-16 | Logística |
| **database_aroom_health** | `Produtos_Giro` | Tabela | 32.531 | 3,20 MB | 2026-06-16 | Vendas / Estoque |
| **database_aroom_health** | `produto_imagens` | Tabela | 28.033 | 6,64 MB | 2026-06-16 | Catálogo de Produtos |
| **database_aroom_health** | `mercadolivre_pedidos` | Tabela | 23.293 | 35,14 MB | 2026-06-16 | Vendas (Mktplace) |
| **database_aroom_health** | `mercadolivre_pedido_produto` | Tabela | 23.273 | 5,57 MB | 2026-06-16 | Vendas (Mktplace) |
| **database_aroom_health** | `google_analytics_utm_daily` | Tabela | 21.013 | 3,11 MB | 2026-06-16 | Marketing |
| **database_aroom_health** | `dispatch_send_log` | Tabela | 20.794 | 1,90 MB | 2026-06-16 | CRM / CRM Logs |
| **database_aroom_health** | `nuvemshop_pedidos` | Tabela | 19.795 | 12,42 MB | 2026-06-16 | Vendas (E-commerce) |
| **database_aroom_health** | `nuvemshop_contato` | Tabela | 16.793 | 3,35 MB | 2026-06-16 | Clientes |
| **database_aroom_health** | `whatsapp_order` | Tabela | 14.588 | 2,82 MB | 2026-06-16 | Vendas (CRM) |
| **database_aroom_health** | `nuvemshop_cupom` | Tabela | 12.676 | 2,71 MB | 2026-06-16 | Vendas (Promoções) |
| **database_aroom_health** | `produtos` | Tabela | 9.749 | 18,79 MB | 2026-06-16 | Catálogo de Produtos |
| **database_aroom_health** | `view_tracking_order` | Tabela | 9.266 | 2,43 MB | 2026-06-16 | Logística |
| **database_aroom_health** | `google_analytics_event_daily` | Tabela | 8.343 | 0,95 MB | 2026-06-16 | Marketing |
| **database_aroom_health** | `checkout_products` | Tabela | 6.898 | 3,58 MB | 2026-06-16 | Vendas (Checkout) |
| **database_aroom_health** | `mercadolivre_order_tracking` | Tabela | 6.846 | 0,77 MB | 2026-06-16 | Logística |
| **database_aroom_health** | `notas_fiscais_entrada_itens` | Tabela | 6.373 | 2,15 MB | 2026-06-15 | Financeiro / Custos |
| **database_aroom_health** | `notas_fiscais_entrada` | Tabela | 5.466 | 1,02 MB | 2026-06-15 | Financeiro / Custos |
| **database_aroom_health** | `depara_produtos` | Tabela | 3.927 | 0,70 MB | 2026-06-15 | Catálogo de Produtos |
| **database_aroom_health** | `produtos_processados` | Tabela | 3.927 | 1,63 MB | 2026-06-16 | Catálogo de Produtos |
| **database_aroom_health** | `view_produtos_processados` | View | 3.927 | 1,63 MB | 2026-06-16 | Catálogo de Produtos |
| **database_aroom_health** | `depara_produtos_calculos` | Tabela | 3.784 | 0,63 MB | 2025-07-12 | Catálogo (Auxiliar) |
| **database_aroom_health** | `google_ads_campaign_performance` | Tabela | 3.418 | 0,78 MB | 2025-12-12 | Marketing (Stale) |
| **database_aroom_health** | `contas_pagar` | Tabela | 3.345 | 0,57 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `view_contas_pagar_processado` | View | 3.345 | 0,97 MB | 2026-06-16 | Financeiro |
| **database_aroom_health** | `google_analytics_revenue_channel_daily` | Tabela | 3.260 | 0,39 MB | 2026-06-16 | Marketing |
| **database_aroom_health** | `checkout` | Tabela | 2.496 | 2,10 MB | 2026-06-16 | Vendas (Checkout) |
| **database_aroom_health** | `checkout_customer_visit` | Tabela | 2.496 | 0,80 MB | 2026-06-16 | Marketing (Checkout) |
| **database_aroom_health** | `checkout_free_shipping_config` | Tabela | 2.496 | 0,25 MB | 2026-06-16 | Vendas (Checkout) |
| **database_aroom_health** | `checkout_payment_details` | Tabela | 2.496 | 0,22 MB | 2026-06-16 | Vendas (Checkout) |
| **database_aroom_health** | `checkout_promotional_discount` | Tabela | 2.496 | 0,73 MB | 2026-06-16 | Vendas (Checkout) |
| **database_aroom_health** | `checkout_message_context` | Tabela | 2.153 | 0,31 MB | 2026-06-16 | CRM / Checkout |
| **database_aroom_health** | `facebook_ads_insights` | Tabela | 1,831 | 0,35 MB | 2026-06-16 | Marketing |
| **database_aroom_health** | `meta_ads` | Tabela | 1.798 | 0,74 MB | 2025-07-29 | Marketing (Stale) |
| **database_aroom_health** | `chatbot_message` | Tabela | 1.572 | 0,53 MB | 2026-06-16 | CRM / Atendimento |
| **database_aroom_health** | `google_ads_ad_performance` | Tabela | 1.409 | 0,34 MB | 2025-12-12 | Marketing (Stale) |
| **database_aroom_health** | `visao_diaria_de_vendas` | Tabela | 968 | 0,28 MB | 2026-06-16 | Vendas (Histórico) |
| **database_aroom_health** | `checkout_coupon` | Tabela | 954 | 0,16 MB | 2026-06-16 | Vendas (Checkout) |
| **database_aroom_health** | `whatsapp_template_metrics_daily` | Tabela | 663 | 0,13 MB | 2026-06-16 | CRM / Metadados |
| **database_aroom_health** | `produtos_ajuste_estatico` | Tabela | 618 | 0,11 MB | 2025-07-20 | Catálogo (Ajustes) |
| **customer_intelligence** | `customer_profile_enriched` | Tabela | 119.873 | 12,32 MB | 2026-06-12 | Inteligência / Clientes |
| **customer_intelligence** | `customer_360` | Tabela | 118.514 | 12,30 MB | 2026-06-12 | Inteligência / Clientes |
| **customer_intelligence** | `customer_clusters` | Tabela | 103.340 | 6,08 MB | 2026-06-12 | Inteligência / Clientes |
| **customer_intelligence** | `customer_predictions` | Tabela | 101.593 | 5,44 MB | 2026-06-12 | Inteligência / Clientes |
| **customer_intelligence** | `customer_rfm` | Tabela | 101.593 | 5,65 MB | 2026-06-12 | Inteligência / Clientes |
| **customer_intelligence** | `customer_activation` | Tabela | 81.297 | 14,55 MB | 2026-06-12 | Inteligência / Clientes |
| **customer_intelligence** | `product_affinity` | Tabela | 51.873 | 10,41 MB | 2026-06-12 | Inteligência / Produtos |
| **customer_intelligence** | `market_opportunities` | Tabela | 5.581 | 0,56 MB | 2026-06-12 | Inteligência / Oportun. |
| **customer_intelligence** | `ref_municipios_ibge` | Tabela | 5.571 | 0,49 MB | 2026-06-12 | Governança / Geografia |
| **customer_intelligence** | `marketing_performance` | Tabela | 270 | 0,03 MB | 2026-06-12 | Inteligência / Mkt |
| **customer_intelligence** | `growth_engine_aquisicao` | View | 0 | 0,00 MB | 2026-06-12 | Camada Semântica |
| **customer_intelligence** | `growth_engine_churn_risco` | View | 0 | 0,00 MB | 2026-06-12 | Camada Semântica |
| **customer_intelligence** | `growth_engine_crm_rfm` | View | 0 | 0,00 MB | 2026-06-12 | Camada Semântica |
| **customer_intelligence** | `growth_engine_geografia` | View | 0 | 0,00 MB | 2026-06-12 | Camada Semântica |
| **customer_intelligence** | `growth_engine_produtos_afinidade` | View | 0 | 0,00 MB | 2026-06-12 | Camada Semântica |
| **customer_intelligence** | `growth_engine_retencao` | View | 0 | 0,00 MB | 2026-06-12 | Camada Semântica |
| **customer_intelligence** | `growth_engine_vendas_detalhado` | View | 0 | 0,00 MB | 2026-06-15 | Camada Semântica |
| **analytics_414017556** | `events_YYYYMMDD` (Sharded) | Tabela | ~10.000/dia | ~20 MB/dia | Diário | Tráfego Digital / GA4 |

*(Nota: As views do BigQuery possuem contagem física de 0 linhas e 0 bytes na consulta de metadados padrão por serem construções lógicas que processam dados dinamicamente sob demanda no momento da execução).*

---

## 2. Mapa de Linhagem de Dados (Data Lineage Map)

O fluxo abaixo representa o ciclo de vida dos dados na arquitetura atual da **Aroom Health**, partindo das fontes de ingestão primárias, passando pelas camadas de limpeza e refinamento no BigQuery, até a disponibilização para os canais de entrega final.

```mermaid
graph TD
    %% Ingestion Sources
    subgraph Fontes_de_Origem ["Fontes de Origem (Sistemas Transacionais & APIs)"]
        ERP[Bling ERP]
        GAdsAPI[Google Ads API]
        FBAdsAPI[Meta/Facebook Ads API]
        GA4Web[GA4 Web/App Events]
        Nshop[Nuvemshop API]
        ML[Mercado Livre API]
    end

    %% Raw / Staging Datasets
    subgraph Raw_Staging ["Camada Raw & Staging (database_aroom_health)"]
        PV[pedidos_vendas]
        PVI[pedidos_vendas_itens]
        PVP[pedidos_vendas_parcelas]
        PVT[pedidos_vendas_transporte]
        Prod[produtos]
        GAdsTable[google_ads_campaign_performance]
        FBAdsTable[facebook_ads_insights]
        GAutm[google_analytics_utm_daily]
        LogWebhook[bling_webhook_log]
        
        %% Relationships
        PV -->|Join pedido_id| PVI
        PV -->|Join pedido_id| PVT
        PV -->|Join pedido_id| PVP
        PVI -->|Join produto_id| Prod
    end

    %% Transformation & Enriched Layer
    subgraph Refinement_Marts ["Camada Marts & Enriquecimento (customer_intelligence & Staging)"]
        ContTrat[Contatos_Tratados]
        CustEnr[customer_profile_enriched]
        CustRFM[customer_rfm]
        CustPred[customer_predictions]
        ProdAffin[product_affinity]
        Ibge[ref_municipios_ibge]
        
        PV -->|Deduplicação de Contatos| ContTrat
        ContTrat -->|Enriquecimento Cep/IBGE| CustEnr
        Ibge -->|De-para Cidades/UF| CustEnr
        CustEnr -->|Análise RFM| CustRFM
        CustRFM -->|Modelagem de Churn| CustPred
        PVI -->|Cálculo de Afinidade| ProdAffin
    end

    %% Unified Semantic layer
    subgraph Semantic_Layer ["Camada Semântica Unificada (customer_intelligence)"]
        GE_Sales[growth_engine_vendas_detalhado]
        GE_Marketing[marketing_performance]
        GE_CRM[growth_engine_crm_rfm]
        GE_Geo[growth_engine_geografia]
        GE_Prod[growth_engine_produtos_afinidade]
        
        %% Construction of Views
        PV & PVI & PVT & Prod --> GE_Sales
        CustRFM --> GE_CRM
        CustEnr --> GE_Geo
        ProdAffin --> GE_Prod
        GAdsTable & GAutm --> GE_Marketing
    end

    %% Presentation Layer
    subgraph Camada_Apresentacao ["Camada de Apresentação & Ação"]
        LookerFaturamento["Looker Studio: Faturamento e DRE"]
        LookerMarketing["Looker Studio: Performance de ROAS"]
        ActiveCampaign["Sincronização CRM: ActiveCampaign (Outbound)"]
    end

    %% Lineage Flows
    ERP -->|Webhook / API| PV
    ERP -->|Ingestão diária| Prod
    GAdsAPI -->|BigQuery DTS (Stale)| GAdsTable
    FBAdsAPI -->|Ingestão de Mídia| FBAdsTable
    GA4Web -->|Conector Nativo GA4| analytics_414017556
    analytics_414017556 -->|DTS UTMs| GAutm
    Nshop -->|Integração e-commerce| nuvemshop_pedidos
    ML -->|Integração Marketplace| mercadolivre_pedidos
    
    GE_Sales --> LookerFaturamento
    GE_Marketing --> LookerMarketing
    GE_CRM --> ActiveCampaign
    GE_Geo --> LookerFaturamento
    GE_Prod --> LookerFaturamento
```

---

## 3. Registro de Débitos Técnicos e Riscos (Technical Debt Register)

A auditoria física do BigQuery mapeou riscos arquiteturais críticos que afetam a integridade financeira e de atribuição de marketing. A tabela abaixo classifica as vulnerabilidades por criticidade e detalha seu impacto comercial imediato.

| Criticidade | Vulnerabilidade | Arquivo / Tabela Afetada | Impacto no Negócio | Solução Proposta |
| :---: | :--- | :--- | :--- | :--- |
| **CRÍTICA** | **Custo Zero de Produtos (COGS Nulo)** | `produtos.preco_custo` (91,1% das linhas com R$ 0,00) | **108.442 itens vendidos (59%)** aparecem com custo zerado, inflando falsamente o Lucro Bruto e a Margem de Contribuição de categorias inteiras. | Realizar carga corretiva retroativa de custos no ERP Bling e criar tabela de margem fallback baseada em categoria. |
| **CRÍTICA** | **Paralisação do Sync de Marketing (Ads Stale)** | `google_ads_campaign_performance` (Paralisado desde 12/12/2025) | Os painéis de marketing e o cálculo de ROAS Real estão desatualizados há meses, impedindo a alocação de verbas pelo CMO. | Reautenticar a credencial do BigQuery Data Transfer Service para restaurar a ingestão diária automática. |
| **ALTA** | **Duplicidades de Webhook na Ingestão (Fan-out)** | `pedidos_vendas_itens` (895 itens duplicados); `pedidos_vendas` (2 duplicados) | Juntar itens diretamente às vendas sem deduplicação infla artificialmente o faturamento contábil e a quantidade física vendida. | Implementar deduplicação sistemática por `ROW_NUMBER() / datastream_metadata.source_timestamp` no staging. |
| **ALTA** | **Ausência de Parâmetros UTM Transacionais** | `pedidos_vendas.observacoes_internas` (93,4% das linhas nulas/vazias) | Impossibilita correlacionar diretamente a receita de pedidos com campanhas publicitárias de origem no ERP, cegando o ROAS. | Configurar o checkout do e-commerce para injetar parâmetros UTM ativos diretamente nas notas internas do pedido enviadas ao Bling. |
| **ALTA** | **Duplicação de Base de Dados Física** | `Contatos_Tratados` vs `view_contatos_tratados` (Mesmo tamanho físico: 71,16 MB) | Desperdício de recursos de armazenamento físico com replicação desnecessária de dados em vez do uso exclusivo de view virtual. | Eliminar a tabela física redundante `Contatos_Tratados` e padronizar o consumo através da view analítica unificada. |
| **MÉDIA** | **Ausência de Código de SKU no Catálogo** | `produtos.codigo` (51,7% nulos); `pedidos_vendas_itens` (7.841 SKU nulos) | Quebra de joins de produtos e relatórios de performance de itens vendidos em canais parceiros. | Tornar o SKU campo obrigatório no cadastro do ERP e implementar fallback baseado na chave de ID do produto. |
| **MÉDIA** | **Estoque Físico Negativo** | `produtos.estoque` (1.684 itens com saldo < 0) | Indica quebras de estoque operacional e falhas de inventário físico no Centro de Distribuição. | Implementar alertas semanais de divergência de estoque e inventário rotativo no Centro de Distribuição. |
| **MÉDIA** | **Comissão de Vendas Zerada** | `pedidos_vendas_itens.comissao_valor` (100% zerado em 183k registros) | Impossibilita o desconto automático da taxa cobrada por marketplaces no cálculo de rentabilidade real. | Mapear alíquotas fixas em tabela estática no BigQuery baseada no canal de venda (`loja_id` / de-para). |
| **BAIXA** | **Histórico de Meta Ads Congelado** | `meta_ads` (Stale desde 29/07/2025) | Dados históricos de anúncios de Facebook Ads incompletos dificultam a consolidação de custos antigos. | Isolar dados legados em pasta histórica e configurar pipeline automático de ingestão do Facebook Ads. |

---

## 4. Domínio de Negócios e Matriz de Priorização (Domain Map & Matrix)

Para organizar de forma coerente as 94 tabelas e views do BigQuery, elas foram mapeadas em 8 domínios de negócio lógicos. A partir desse mapeamento, foi desenhada a Matriz de Priorização, estruturando as iniciativas técnicas de acordo com o Valor de Negócio gerado e o Esforço de Engenharia requerido.

### 🗺️ Mapeamento de Domínios de Negócio (Business Domain Map)

```
BigQuery BI Ecosystem (iron-rex-461220-g4)
 ├── 🛒 Domínio de Vendas (Sales Domain)
 │    ├── pedidos_vendas (Tabela Principal)
 │    ├── pedidos_vendas_itens
 │    ├── pedidos_vendas_desconto
 │    ├── nuvemshop_pedidos
 │    ├── mercadolivre_pedidos
 │    └── checkout_products
 ├── 👥 Domínio de Clientes (Customer Domain)
 │    ├── customer_profile_enriched
 │    ├── customer_360
 │    ├── customer_rfm
 │    ├── customer_predictions
 │    ├── customer_clusters
 │    ├── contatos_v2
 │    └── contato_endereco
 ├── 📦 Domínio de Produtos (Product Domain)
 │    ├── produtos
 │    ├── produtos_processados
 │    ├── Produtos_Giro
 │    ├── product_affinity
 │    └── depara_produtos
 ├── 📢 Domínio de Marketing (Marketing Domain)
 │    ├── google_ads_campaign_performance
 │    ├── google_analytics_utm_daily
 │    ├── facebook_ads_insights
 │    └── google_analytics_revenue_channel_daily
 ├── 💳 Domínio Financeiro (Financial Domain)
 │    ├── view_financeiro
 │    ├── contas_receber
 │    ├── contas_pagar
 │    ├── view_contas_pagar_processado
 │    └── notas_fiscais_saida
 ├── 🚚 Domínio de Logística (Logistics Domain)
 │    ├── pedidos_vendas_transporte
 │    ├── orders_tracking
 │    └── mercadolivre_order_tracking
 ├── 🤖 Domínio de Machine Learning & IA (ML Domain)
 │    ├── customer_predictions (Churn/Valor)
 │    └── customer_clusters (Algoritmos de Agrupamento)
 └── 🛡️ Domínio de Governança & Metadados (Governance Domain)
      ├── bling_webhook_log (Monitoramento)
      ├── ref_municipios_ibge (Referencial)
      └── nomes_genero (Auxiliar)
```

---

### 📊 Matriz de Priorização (Valor vs Esforço)

```
      Alto  │ ─────────────────────────────────────────────────────────────
            │  [Quick Wins - Prioridade Alta]       [Strategic - Prioridade Crítica]
            │  1. Reautenticação do Google Ads      1. Ingestão de Preços de Custo (COGS)
            │  2. Deduplicação de Webhooks          2. Injeção de UTMs no Checkout
            │  3. Tabela de Comissão Proporcional  3. Criação da Camada Semântica de BI
            │
  VALOR DE  │
  NEGÓCIO   │
            │
            │  [Hygiene - Prioridade Média]        [Complex - Prioridade Baixa]
            │  1. Eliminar Contatos_Tratados físico 1. Alertas de Estoque Negativo CD
            │  2. Tratamento de SKUs Nulos          2. Ingestão Automatizada de Meta Ads
            │
       Baixo│ ─────────────────────────────────────────────────────────────
            └─────────────────────────────────────────────────────────────
                                 Baixo                            Alto
                                          ESFORÇO DE ENGENHARIA
```

*   **Quick Wins (Ganho Rápido / Alto Valor e Baixo Esforço):**
    *   *Reativar Google Ads DTS:* Esforço de configuração apenas; resolve a desatualização de dados desde dezembro de 2025.
    *   *Deduplicação de Webhooks:* Query de deduplicação na camada de staging remove imediatamente a inflação de vendas.
    *   *Tabela Estática de Comissões:* Mapeia as taxas dos marketplaces por de-para no BigQuery, sem precisar configurar o ERP individualmente.
*   **Strategic (Iniciativas Estratégicas / Alto Valor e Alto Esforço):**
    *   *Preços de Custo (COGS):* Exige esforço cadastral do cliente no ERP, mas é a única forma de obter lucros brutos de vendas corretos.
    *   *UTMs no Checkout:* Exige alteração no front-end do e-commerce, mas gera atribuição precisa.
    *   *Camada Semântica:* Construção das visões unificadas finais para alimentar o Looker Studio de forma blindada.

---

## 5. Estrutura Proposta para o Quadro Trello (Trello Board Structure)

Para guiar e monitorar a implementação técnica das soluções dos débitos de dados e o desenvolvimento da camada de inteligência, recomendamos a criação de um quadro no Trello estruturado da seguinte forma:

### 🗂️ Colunas do Quadro (Board Lists)
1.  **`[Backlog de Dados]`**: Histórias de usuários e problemas identificados no BigQuery pendentes de triagem técnica.
2.  **`[A Fazer (Sprint To Do)]`**: Atividades selecionadas para execução imediata no ciclo de desenvolvimento ativo.
3.  **`[Em Desenvolvimento]`**: Tarefas ativas com engenheiros de dados/analistas designados.
4.  **`[Qualidade & Homologação (QA/Review)]`**: Validação de integridade física, testes de chaves primárias e checagem de dados com o Looker Studio.
5.  **`[Concluído (Done)]`**: Mudanças aplicadas em produção, validadas, auditadas e documentadas.

### 🏷️ Sistema de Etiquetas (Labels)
*   🔴 **`Prioridade: Crítica`** - Bloqueia cálculos financeiros do negócio.
*   🟠 **`Prioridade: Alta`** - Afeta a integridade analítica e atribuição.
*   🟡 **`Prioridade: Média`** - Quebras de consistência operacional ou cadastro.
*   🔵 **`Prioridade: Baixa`** - Melhorias estéticas ou de otimização de custos.
*   ⚡ **`Data Quality`** - Limpeza de duplicidades, nulos ou dados incorretos.
*   🔗 **`Integração / Pipeline`** - Conexão de APIs ou reativação de conectores.
*   🏛️ **`Camada Semântica`** - Criação de views de negócios no BigQuery.

---

### 📝 Estrutura de Cards Recomendados (Card Templates)

Abaixo estão detalhados os cards prioritários para o quadro Trello:

#### Card 1: Reativação do Data Transfer Service do Google Ads
*   **Coluna:** `A Fazer`
*   **Etiquetas:** 🔴 `Prioridade: Crítica`, 🔗 `Integração / Pipeline`
*   **Descrição:** O pipeline de dados de performance de campanhas do Google Ads está congelado desde 12/12/2025. É necessário reautenticar a conta proprietária do Google Ads no GCP e disparar uma rotina de Backfill.
*   **Critérios de Aceitação (Checklist):**
    *   `[ ]` Reautenticar a credencial vinculada ao DTS na interface do BigQuery.
    *   `[ ]` Agendar execução de Backfill de dados no período de 13/12/2025 até a data atual.
    *   `[ ]` Validar se a tabela `google_ads_campaign_performance` possui registros recentes saudáveis.
    *   `[ ]` Conferir no Looker Studio se as métricas de investimento voltaram a atualizar de forma dinâmica.

#### Card 2: Saneamento e Importação de Preço de Custo (COGS)
*   **Coluna:** `A Fazer`
*   **Etiquetas:** 🔴 `Prioridade: Crítica`, ⚡ `Data Quality`
*   **Descrição:** 91.1% dos produtos no cadastro oficial do ERP Bling estão com preço de custo igual a R$ 0,00, gerando uma visão distorcida de margem (COGS zerado em 59% dos itens vendidos).
*   **Critérios de Aceitação (Checklist):**
    *   `[ ]` Consolidar planilha de custos industriais e de fabricação de SKUs com o time financeiro.
    *   `[ ]` Realizar upload em lote dos custos no ERP Bling.
    *   `[ ]` Criar regra na query de staging do BigQuery para aplicar fallback (`COALESCE`) com base na margem média histórica da categoria do produto caso o custo continue zerado.
    *   `[ ]` Validar que a quantidade de vendas com COGS igual a R$ 0,00 foi reduzida para menos de 5%.

#### Card 3: Deduplicação de Webhook na Camada de Staging
*   **Coluna:** `A Fazer`
*   **Etiquetas:** 🟠 `Prioridade: Alta`, ⚡ `Data Quality`
*   **Descrição:** Presença de 895 registros duplicados em `pedidos_vendas_itens` e 2 em `pedidos_vendas` inflam artificialmente o faturamento bruto auditado em aproximadamente R$ 45.902,50.
*   **Critérios de Aceitação (Checklist):**
    *   `[ ]` Escrever a query analítica utilizando funções de janela (`ROW_NUMBER()`) particionadas pela chave de negócio (`pedido_id` e `item_id`) priorizando o timestamp mais recente do webhook.
    *   `[ ]` Substituir o consumo direto da tabela física bruta `pedidos_vendas_itens` por uma view deduplicada na camada de staging.
    *   `[ ]` Validar que o faturamento de vendas deduplicado na view corresponde exatamente ao faturamento real homologado do financeiro.

#### Card 4: Captura de Parâmetros UTM no Checkout e Injeção no ERP
*   **Coluna:** `Backlog de Dados`
*   **Etiquetas:** 🟠 `Prioridade: Alta`, 🔗 `Integração / Pipeline`
*   **Descrição:** 93,4% das observações de vendas estão vazias, impedindo a atribuição direta de campanhas de marketing ao faturamento do Bling.
*   **Critérios de Aceitação (Checklist):**
    *   `[ ]` Ajustar o código do checkout no e-commerce para salvar os parâmetros UTM ativos da sessão (`utm_source`, `utm_medium`, `utm_campaign`) no armazenamento local.
    *   `[ ]` Configurar a API de envio de pedidos para incluir essas UTMs no formato estruturado (ex: `[utm_source=google&utm_medium=cpc]`) nas observações internas do pedido enviadas ao Bling.
    *   `[ ]` Atualizar a regex de extração de UTMs no BigQuery para ler o novo formato do campo `observacoes_internas`.

---

## 6. Smartmetric Roadmap Estratégico de Implantação

Para guiar a transformação de dados da **Aroom Health**, definimos um roadmap estratégico de 3 fases, com estimativas de tempo e metas de impacto financeiro (ROI) estimadas com base na recuperação de dados de custos de marketing e saneamento de margens.

### 📅 Cronograma de Fases

```
Fase 1: Recuperação & Qualidade de Dados (Mês 1)
 ├── Reautenticação do Google Ads e Backfill
 ├── Deduplicação de Webhooks no Staging
 └── Saneamento de Custos de Produtos (COGS)

Fase 2: Rastreabilidade & Integração (Mês 2)
 ├── Injeção de UTMs no Checkout
 ├── Mapeamento de Comissões por de-para
 └── Resolução de SKUs nulos e consistência de estoque

Fase 3: Inteligência Avançada & BI (Mês 3)
 ├── Criação da Camada Semântica Unificada
 ├── Integração Socioeconômica e Logística
 └── Painel de ROAS Real e Margem no Looker Studio
```

---

### 📝 Descrição Detalhada das Fases

#### Fase 1: Recuperação de Ingestão e Saneamento de Dados
*   **Duração Estimada:** 3 a 4 semanas.
*   **Foco Técnico:** Intervenção nos conectores quebrados, mitigação de duplicações físicas e saneamento emergencial de custos (COGS) no BigQuery.
*   **Principais Entregas:**
    1.  Pipeline do Google Ads ativo e dados atualizados diariamente.
    2.  Modelos de staging deduplicados via código SQL de transformação.
    3.  Preço de custo cadastrado no catálogo e cálculo correto da Margem de Contribuição por item.
*   **Estimativa de Impacto Comercial:**
    *   *Eficiência de Mídia:* Identificação imediata de campanhas ineficientes que gastavam orçamento sem conversão após dezembro de 2025.
    *   *Acurácia Contábil:* Correção do desvio de R$ 45,9k de faturamento inflado por duplicidades de webhook.

#### Fase 2: Rastreabilidade, Atribuição e Integração Transacional
*   **Duração Estimada:** 4 semanas.
*   **Foco Técnico:** Integração das origens de tráfego com transações de vendas no e-commerce e saneamento cadastral de SKUs e comissões.
*   **Principais Entregas:**
    1.  Atribuição de marketing (UTMs) capturada no checkout e integrada ao ERP Bling.
    2.  Consolidação das taxas de marketplaces por canal no BigQuery.
    3.  Ajuste automático de SKUs nulos e conciliação de estoque físico negativo.
*   **Estimativa de Impacto Comercial:**
    *   *Atribuição de ROAS:* Capacidade de rastrear vendas de alta margem associadas diretamente à campanha geradora.
    *   *Governança de Marketplace:* Desconto automático das comissões reais, permitindo calcular o lucro líquido real dos canais externos (Mercado Livre/Shopee).

#### Fase 3: Camada Semântica Unificada e Inteligência Avançada
*   **Duração Estimada:** 4 semanas.
*   **Foco Técnico:** Construção da camada de modelagem analítica final (Marts) e conexões de BI com Looker Studio.
*   **Principais Entregas:**
    1.  Visualização de dados analíticos unificada em uma única view de produção (`customer_intelligence.growth_engine_marketing_vendas_consolidado`).
    2.  Enriquecimento socioeconômico (renda média, IDH municipal) e análise logística cruzados diretamente com a rentabilidade por pedido.
    3.  Dashboard executivo contábil (DRE) e painel de eficiência de mídia (ROAS) homologados no Looker Studio.
*   **Estimativa de Impacto Comercial:**
    *   *Segmentação Avançada:* Direcionamento de campanhas de CRM baseadas na pontuação RFM e clusters de afinidade de produtos.
    *   *Margem Logística:* Economia de custos com frete preditivo baseada na distância real do Centro de Distribuição até as zonas de entrega de alta renda.
