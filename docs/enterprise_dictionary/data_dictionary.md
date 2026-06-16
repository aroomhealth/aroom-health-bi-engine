# Enterprise Data Dictionary - Aroom Health BI Engine
## Camada de Metadados e Catálogo Físico de Colunas

Este documento estabelece o **Dicionário de Dados Corporativo** para o ambiente analítico Google BigQuery da **Aroom Health**, abrangendo os conjuntos de dados de ingestão transacional (`database_aroom_health`), modelagem analítica (`customer_intelligence`) e tráfego web (`analytics_414017556`).

---

## 1. Catálogo de Conjuntos de Dados (Datasets)

O ecossistema BigQuery está estruturado em três conjuntos de dados lógicos com finalidades, regras de segurança e frequências de atualização específicas:

### 1.1 `database_aroom_health`
*   **Propósito de Negócio:** Camada de Ingestão e Staging (Raw/Staging). Armazena as tabelas espelhadas diretamente do ERP Bling via webhook, além de integrações logísticas, e-commerce (Nuvemshop), marketplaces (Mercado Livre) e dados históricos de mídia paga (Google Ads, Facebook Ads).
*   **Proprietário (Owner):** Engenharia de Dados & TI.
*   **Domínio de Negócio:** Vendas, Estoque, Financeiro, Logística e Ingestão de Marketing.
*   **Frequência de Atualização:** Carga transacional diária (D-1) e webhook em tempo real (pedidos/estoque). Integrações de mídia (D-1, atualmente paralisada para Google Ads desde 12/12/2025).

### 1.2 `customer_intelligence`
*   **Propósito de Negócio:** Camada Semântica e Analítica (Marts). Centraliza dados de clientes enriquecidos com coordenadas geográficas e estimativas socioeconômicas (IBGE), segmentações RFM, propensão de compra e previsões estatísticas de churn/LTV. Contém as views finais consolidadas consumidas pelo Looker Studio.
*   **Proprietário (Owner):** Inteligência de Growth & BI (Smartmetric Analytics).
*   **Domínio de Negócio:** Clientes, Inteligência Competitiva, Vendas Consolidadas e IA.
*   **Frequência de Atualização:** Diária / Agendada por rotinas de transformação SQL no BigQuery.

### 1.3 `analytics_414017556`
*   **Propósito de Negócio:** Camada de Tráfego e Comportamento Web. Armazena os logs granulares brutos de eventos capturados em nível de usuário pelo Google Analytics 4 (GA4).
*   **Proprietário (Owner):** Equipe de Marketing Digital.
*   **Domínio de Negócio:** Tráfego Digital, Comportamento de Usuário e Funil de E-commerce.
*   **Frequência de Atualização:** Contínua (Intraday) e Consolidação diária (sharded tables: `events_YYYYMMDD`).

---

## 2. Inventário Geral de Tabelas (Table-Level Inventory)

Abaixo estão listadas as tabelas e views presentes nos datasets analíticos, especificando o volume de registros, tamanho físico em bytes, data de última modificação/frescor, propósito de negócio e chaves candidatas de associação.

### 2.1 Tabelas de `database_aroom_health`

| Nome da Tabela / View | Tipo | Linhas | Tamanho (MB) | Propósito de Negócio | Chave Primária (PK) | Chave Estrangeira (FK) |
| :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `pedidos_vendas_parcelas` | Tabela | 1.188.790 | 176,22 | Histórico de parcelamentos e vencimentos de recebíveis no ERP. | `identificador` (ERP) | `pedidos_vendas_identificador` |
| `view_financeiro` | Tabela | 353.420 | 68,40 | Visão consolidada de movimentações de fluxo de caixa no ERP. | `identificador` (ERP) | `contato_id`, `pedido_id` |
| `pedidos_vendas_itens` | Tabela | 183.719 | 46,20 | Itens individuais contidos em cada pedido de venda. | `identificador` (Bling) | `pedidos_vendas_identificador`, `produto_id`, `codigo` (SKU) |
| `view_vendas` | Tabela | 164.409 | 120,66 | Visão consolidada de cabeçalho e itens de faturamento bruto. | `item_id` | `pedido_id`, `contato_id`, `loja_id`, `produto_id` |
| `pedidos_vendas_v2` | Tabela | 138.734 | 12,08 | Cópia incremental otimizada de cabeçalhos de pedidos de vendas. | `identificador` | `contato_id`, `loja_id`, `transporte_id` |
| `contatos_v2` | Tabela | 131.242 | 14,29 | Cadastro de contatos de clientes com dados de qualificação. | `identificador` | `contato_id` |
| `pedidos_vendas_transporte` | Tabela | 128.142 | 21,40 | Custos de frete, prazos e transportadoras vinculadas às vendas. | `id` (Incremental) | `pedidos_vendas_identificador`, `contato_id` |
| `pedidos_vendas_desconto` | Tabela | 128.140 | 12,22 | Detalhamento de descontos e cupons aplicados no nível do pedido. | `id` | `pedidos_vendas_identificador` |
| `pedidos_vendas_intermediador` | Tabela | 128.140 | 12,79 | Detalhes do intermediador financeiro de pagamentos (Ex: Pagar.me).| `id` | `pedidos_vendas_identificador` |
| `pedidos_vendas_taxas` | Tabela | 128.140 | 14,42 | Taxas acessórias e adquirentes cobradas no checkout. | `id` | `pedidos_vendas_identificador` |
| `pedidos_vendas_tributacao` | Tabela | 128.140 | 13,44 | Detalhamento fiscal e impostos de vendas (IPI, ICMS). | `id` | `pedidos_vendas_identificador` |
| `pedidos_vendas_transporte_etiqueta`| Tabela | 128.139 | 22,90 | IDs de etiquetas geradas para postagem física (Melhor Envio). | `id` | `pedidos_vendas_identificador` |
| `pedidos_vendas_situacao` | Tabela | 127.718 | 11,45 | Tabela auxiliar de mapeamento de status operacional de pedidos.| `id` | `pedidos_vendas_identificador` |
| `pedidos_vendas` | Tabela | 127.528 | 39,18 | Cabeçalho dos pedidos transacionais contendo totais e clientes. | `identificador` | `contato_id`, `loja_id`, `nota_fiscal_id`, `tributacao_id` |
| `contato_endereco` | Tabela | 122.308 | 19,22 | Endereços cadastrados de clientes (rua, número, CEP). | `identificador` | `contato_id` |
| `contato` | Tabela | 119.036 | 24,76 | Base oficial de clientes cadastrados (Nome, CPF/CNPJ, Email, Tel). | `identificador` | - |
| `Contatos_Tratados` | Tabela | 109.631 | 71,16 | Tabela de contatos deduplicada na granularidade de CPF único. | `customer_id` | `contato_id` |
| `view_contatos_tratados` | View | 109.631 | 71,16 | View espelho contendo a deduplicação de contatos por CPF. | `customer_id` | `contato_id` |
| `nomes_genero` | Tabela | 103.306 | 1,18 | Tabela auxiliar contendo de-para de primeiro nome e gênero. | `nome` | - |
| `dicionario_nome_genero` | Tabela | 100.788 | 5,01 | Base expandida de probabilidade de classificação de gênero. | `nome` | - |
| `contas_receber` | Tabela | 91.985 | 13,30 | Lançamentos financeiros de contas a receber ativos do ERP. | `identificador` | `pedido_id`, `contato_id` |
| `contas_receber_origem` | Tabela | 82.590 | 16,19 | Registro detalhado da origem de faturamento das contas a receber. | `id` | `contas_receber_identificador` |
| `notas_fiscais_saida` | Tabela | 72.858 | 12,71 | Registros de notas fiscais de venda faturadas. | `identificador` | `pedido_id`, `contato_id` |
| `meta_ads_actions` | Tabela | 67.591 | 17,32 | Registro de ações de campanhas no Facebook Ads (Stale). | `action_id` | `campaign_id` |
| `bling_webhook_log` | Tabela | 59.712 | 8,71 | Log de auditoria operacional de webhooks recebidos do Bling ERP.| `id` | - |
| `nuvemshop_pedido_produto` | Tabela | 48.213 | 25,77 | Itens individuais de pedidos integrados via Nuvemshop. | `id` | `pedido_id`, `produto_id` |
| `view_vendas_nuvem` | Tabela | 48.207 | 32,88 | Visão consolidada de vendas da plataforma Nuvemshop. | `item_id` | `pedido_id`, `produto_id` |
| `bling_estoque_saldos` | Tabela | 44.117 | 12,45 | Saldo de estoque físico reportado pelo ERP por SKU. | `sku` (codigo) | `produto_id` |
| `orders_tracking` | Tabela | 38.546 | 4,17 | Status de rastreamento logístico de despachos da Aroom. | `id` | `pedido_id` |
| `Produtos_Giro` | Tabela | 32.531 | 3,20 | Histórico de giro e turnover de estoque dos SKUs. | `produto_id` | `codigo` (SKU) |
| `produto_imagens` | Tabela | 28.033 | 6,64 | Cadastro de URLs de imagens do catálogo de produtos. | `id` | `produto_id` |
| `mercadolivre_pedidos` | Tabela | 23.293 | 35,14 | Cabeçalhos de vendas realizadas via canal Mercado Livre. | `identificador` | `contato_id`, `loja_id` |
| `mercadolivre_pedido_produto`| Tabela | 23.273 | 5,57 | Itens individuais vendidos via Mercado Livre. | `id` | `pedidos_vendas_identificador`, `produto_id` |
| `google_analytics_utm_daily` | Tabela | 21.013 | 3,11 | Tráfego diário agregado por UTM extraído do GA4. | `metric_date` + UTMs | - |
| `dispatch_send_log` | Tabela | 20.794 | 1,90 | Histórico de disparos de automações de e-mail/CRM. | `id` | `contato_id` |
| `nuvemshop_pedidos` | Tabela | 19.795 | 12,42 | Cabeçalhos de pedidos gerados via Nuvemshop. | `identificador` | `contato_id` |
| `nuvemshop_contato` | Tabela | 16.793 | 3,35 | Clientes integrados via e-commerce Nuvemshop. | `identificador` | `contato_id` |
| `whatsapp_order` | Tabela | 14.588 | 2,82 | Vendas realizadas através do canal de atendimento WhatsApp. | `identificador` | `contato_id` |
| `nuvemshop_cupom` | Tabela | 12.676 | 2,71 | Cadastro de cupons de descontos criados na Nuvemshop. | `id` | - |
| `produtos` | Tabela | 9.749 | 18,79 | Cadastro e catálogo de produtos (Contém COGS). | `identificador` | `categoria_id` |
| `view_tracking_order` | Tabela | 9.266 | 2,43 | View de monitoramento de status de postagem. | `id` | `pedido_id` |
| `google_analytics_event_daily` | Tabela | 8.343 | 0,95 | Estatísticas de conversão e eventos do GA4. | `metric_date` + `event_name`| - |
| `checkout_products` | Tabela | 6.898 | 3,58 | Produtos visualizados/adicionados no checkout do e-commerce. | `id` | `checkout_id`, `produto_id` |
| `mercadolivre_order_tracking`| Tabela | 6.846 | 0,77 | Rastreamento logístico específico das postagens do ML. | `id` | `pedido_id` |
| `notas_fiscais_entrada_itens`| Tabela | 6.373 | 2,15 | Itens de compras e notas fiscais de entrada (Fornecedores). | `id` | `nota_fiscal_entrada_id`, `produto_id` |
| `notas_fiscais_entrada` | Tabela | 5.466 | 1,02 | Cabeçalhos de notas fiscais de compras e despesas. | `identificador` | `contato_id` (Fornecedor) |
| `depara_produtos` | Tabela | 3.927 | 0,70 | Mapeamento de SKUs de diferentes plataformas de venda. | `sku_origem` | `produto_id` |
| `produtos_processados` | Tabela | 3.927 | 1,63 | Tabela consolidada de produtos com categorias padronizadas. | `identificador` | `categoria_id` |
| `view_produtos_processados` | View | 3.927 | 1,63 | View analítica sobre a consolidação de produtos processados. | `identificador` | `categoria_id` |
| `depara_produtos_calculos` | Tabela | 3.784 | 0,63 | Tabela auxiliar de cálculo para unificação de SKUs. | `id` | `produto_id` |
| `google_ads_campaign_performance`| Tabela | 3.418 | 0,78 | Performance diária de campanhas do Google Ads (Stale). | `campaign_name` + `day` | - |
| `contas_pagar` | Tabela | 3.345 | 0,57 | Registro de obrigações e despesas financeiras (Fluxo de Saída). | `identificador` | `contato_id` |
| `view_contas_pagar_processado` | View | 3.345 | 0,97 | View de processamento financeiro de obrigações de caixa. | `identificador` | `contato_id` |
| `google_analytics_revenue_channel_daily`| Tabela | 3.260 | 0,41 | Faturamento de conversões de e-commerce atribuído a canais GA4. | `metric_date` + `channel` | - |
| `checkout` | Tabela | 2.496 | 2,10 | Sessões iniciadas no checkout do e-commerce (Carrinhos). | `identificador` | `contato_id` |
| `checkout_customer_visit` | Tabela | 2.496 | 0,80 | Sessões de checkout atreladas a visitas e UTMs de tráfego. | `id` | `checkout_id` |
| `checkout_free_shipping_config`| Tabela | 2.496 | 0,27 | Parâmetros de frete grátis aplicados nas sessões de checkout. | `id` | `checkout_id` |
| `checkout_payment_details` | Tabela | 2.496 | 0,22 | Detalhes de pagamento (Cartão, Pix) inseridos no checkout. | `id` | `checkout_id` |
| `checkout_promotional_discount`| Tabela | 2.496 | 0,73 | Regras de descontos promocionais ativadas no checkout. | `id` | `checkout_id` |
| `checkout_message_context` | Tabela | 2.153 | 0,32 | Logs de envio de mensagens para carrinhos abandonados. | `id` | `checkout_id` |
| `facebook_ads_insights` | Tabela | 1.831 | 0,37 | Métricas consolidadas diárias de Facebook Ads. | `campaign_id` + `day` | - |
| `meta_ads` | Tabela | 1.798 | 0,74 | Histórico legado de campanhas do Facebook Ads (Stale). | `campaign_id` + `day` | - |
| `chatbot_message` | Tabela | 1.572 | 0,56 | Logs de mensagens do chatbot operacional de suporte. | `id` | `contato_id` |
| `google_ads_ad_performance` | Tabela | 1.409 | 0,35 | Performance de anúncios individuais (Ads - Stale). | `ad_id` + `day` | - |
| `visao_diaria_de_vendas` | Tabela | 968 | 0,29 | Histórico legado diário de faturamento total de vendas. | `data` | - |
| `checkout_coupon` | Tabela | 954 | 0,17 | Visitas de checkout contendo aplicação de cupons ativos. | `id` | `checkout_id` |
| `whatsapp_template_metrics_daily`| Tabela | 663 | 0,14 | Métricas de envio e leitura de templates oficiais de WhatsApp. | `metric_date` | - |
| `produtos_ajuste_estatico` | Tabela | 618 | 0,12 | Tabela manual contendo de-para estáticos de custos e SKUs. | `id` | `produto_id` |

### 2.2 Tabelas de `customer_intelligence`

| Nome da Tabela / View | Tipo | Linhas | Tamanho (MB) | Propósito de Negócio | Chave Primária (PK) | Chave Estrangeira (FK) |
| :--- | :---: | :---: | :---: | :--- | :--- | :--- |
| `customer_profile_enriched` | Tabela | 119.873 | 12,32 | Perfil socioeconômico e localização de clientes via IBGE. | `customer_id` | `customer_id` (contato_id)|
| `customer_360` | Tabela | 118.514 | 12,89 | Visão unificada de comportamento, valor e recência do cliente. | `customer_id` | `customer_id` |
| `customer_clusters` | Tabela | 103.340 | 6,08 | Classificação de grupos homogêneos comportamentais (K-Means).| `customer_id` | `customer_id` |
| `customer_predictions` | Tabela | 101.593 | 5,44 | Probabilidade de churn de 30 dias e LTV preditivo de 12 meses. | `customer_id` | `customer_id` |
| `customer_rfm` | Tabela | 101.593 | 5,65 | Segmentação e pontuação RFM (Champions, Loyalists, etc.). | `customer_id` | `customer_id` |
| `customer_activation` | Tabela | 81.297 | 14,55 | Status e recomendações de ações de reativação de CRM. | `customer_id` | `customer_id` |
| `product_affinity` | Tabela | 51.873 | 10,41 | Afinidade de compras de SKUs (Modelo de Cesta de Compras). | `sku_a` + `sku_b` | - |
| `market_opportunities` | Tabela | 5.581 | 0,59 | Oportunidades regionais de conversão de novos clientes. | `cidade` + `estado` | - |
| `ref_municipios_ibge` | Tabela | 5.571 | 0,51 | Tabela referencial estática do IBGE de municípios brasileiros. | `codigo_ibge` | - |
| `marketing_performance` | Tabela | 270 | 0,03 | Tabela de performance de canais de aquisição de clientes. | `data` + `channel` | - |
| `growth_engine_aquisicao` | View | Logical | - | View analítica de funil de conversão de leads e novos CPFs. | `customer_id` | `customer_id` |
| `growth_engine_churn_risco` | View | Logical | - | View de monitoramento de propensão e volumetria de Churn. | `customer_id` | `customer_id` |
| `growth_engine_crm_rfm` | View | Logical | - | View semântica servindo segmentação de CRM do Looker Studio. | `customer_id` | `customer_id` |
| `growth_engine_geografia` | View | Logical | - | View de inteligência geográfica e distribuição logística. | `customer_id` | `customer_id` |
| `growth_engine_produtos_afinidade`| View | Logical | - | View contendo scores de afinidade para recomendações de combos. | `sku_a` + `sku_b` | - |
| `growth_engine_retencao` | View | Logical | - | View de ações de CRM recomendadas para clientes inativos. | `customer_id` | `customer_id` |
| `growth_engine_vendas_detalhado` | View | Logical | - | View unificada contábil e de vendas deduplicada (BI Engine).| `pedido_id` + `item_id`| `pedido_id`, `item_id`, `produto_id`, `customer_id` |

---

## 3. Catálogo de Colunas por Tabela Crítica (Column-Level Dictionary)

Para garantir máxima integridade analítica nos cálculos de DRE, Atribuição de Marketing (ROAS) e CRM, esta seção estabelece o mapeamento detalhado das colunas das tabelas centrais do ecossistema, incluindo metadados físicos, significados comerciais e classificação de criticidade.

### 3.1 Tabela: `database_aroom_health.pedidos_vendas` (Cabeçalho de Pedidos)
*   **Finalidade:** Armazena o registro agregado de cada transação de venda emitida pelo ERP Bling.
*   **Grão (Grain):** Pedido de Venda (`identificador`).

| Nome do Campo | Tipo | Null % | Distintos | Exemplos | Significado Comercial | Criticidade | Risco / Observação |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: | :--- |
| `identificador` | INT64 | 0% | 127.511 | `21364272133` | ID único interno gerado no ERP Bling para a venda. | **Crítica** | Contém **2 duplicatas** operacionais. |
| `numero` | INT64 | 0% | 127.513 | `45233` | Número sequencial legível do pedido impresso na nota. | Importante | Nulo % igual a 0. |
| `numero_loja` | STRING | 15% | 102.342 | `AR-98542` | Código do pedido gerado no e-commerce (Nuvemshop). | Importante | Usado para conciliar e-commerce e ERP. |
| `data` | DATE | 0% | 1.776 | `2024-10-18` | Data de emissão/criação do pedido. | **Crítica** | Campo íntegro. Base temporal de DRE. |
| `total` | FLOAT64 | 0% | 19.345 | `150.00` | Valor financeiro total líquido final faturado (inclui frete). | **Crítica** | **82 registros** com total igual a R$ 0,00. |
| `total_produtos` | FLOAT64 | 0% | 17.654 | `162.50` | Valor bruto apenas da soma dos produtos (sem taxas/fretes). | Importante | Usado para ratear custos de frete. |
| `contato_id` | INT64 | 0% | 109.514 | `1740636913` | ID do cliente associado no cadastro oficial de contatos. | **Crítica** | Chave estrangeira primária para Clientes. |
| `loja_id` | INT64 | 0% | 18 | `204429796` | ID do canal de venda parceiro onde a compra ocorreu. | **Crítica** | Chave de ligação para Canais de Venda. |
| `situacao_id` | INT64 | 0% | 12 | `9` (Atendido) | Status operacional do pedido (Ex: 9=Atendido, 12=Cancelado). | Importante | Deve-se filtrar situações de cancelados (12, 105). |
| `observacoes_internas`| STRING | 93.4% | - | `[utm_source=meta]`| Campo de notas internas utilizado para registrar parâmetros UTM.| Importante | **93,4% vazio**. UTMs não integradas. |
| `outras_despesas` | FLOAT64 | 82% | 452 | `15.00` | Despesas e taxas adicionais incidentes no cabeçalho. | Auxiliar | Geralmente zerado. |
| `nota_fiscal_id` | INT64 | 42% | 72.858 | `1845421` | ID referencial da Nota Fiscal gerada. | Importante | Vincula com o faturamento contábil oficial. |
| `transporte_id` | INT64 | 1% | 126.112 | `5854212` | ID vinculando o registro de dados logísticos e frete. | Importante | Chave estrangeira para tabela de transporte. |

---

### 3.2 Tabela: `database_aroom_health.pedidos_vendas_itens` (Itens de Pedidos)
*   **Finalidade:** Registra individualmente cada variação de produto (SKU) vendida no pedido.
*   **Grão (Grain):** Item por Pedido (`identificador`).

| Nome do Campo | Tipo | Null % | Distintos | Exemplos | Significado Comercial | Criticidade | Risco / Observação |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: | :--- |
| `identificador` | INT64 | 0% | 182.795 | `17406369135` | ID físico único gerado para a linha do item. | **Crítica** | Contém **895 duplicatas** (Causa Fan-out). |
| `pedidos_vendas_identificador`| INT64 | 0% | 127.500 | `21364272133` | ID de associação com a tabela `pedidos_vendas`. | **Crítica** | Chave estrangeira de ligação. |
| `codigo` | STRING | 4.2% | 2.299 | `6527` | SKU (código do produto) cadastrado no item. | **Crítica** | **7.841 registros vazios/nulos**. |
| `quantidade` | INT64 | 0% | 45 | `2` | Quantidade física vendida de unidades do SKU. | **Crítica** | **67 registros** com quantidade <= 0. |
| `valor` | NUMERIC | 0% | 2.564 | `69.64` | Preço unitário líquido faturado cobrado por SKU. | **Crítica** | **4.960 registros** com valor <= R$ 0,00. |
| `desconto` | NUMERIC | 0% | 654 | `5.00` | Valor do desconto total deduzido do item. | Importante | Deduzido no cálculo da receita líquida do item. |
| `produto_id` | INT64 | 0% | 2.354 | `16228311445` | ID físico referencial do produto no catálogo oficial. | **Crítica** | Chave estrangeira para Join com `produtos`. |
| `comissao_valor` | NUMERIC | 0% | 1 | `0.00` | Valor de comissão operacional retido pela venda do item. | Importante | **100% zerado/vazio**. |

---

### 3.3 Tabela: `database_aroom_health.produtos` (Catálogo de Produtos)
*   **Finalidade:** Centraliza o cadastro oficial de mercadorias, preços padrão e custos operacionais.
*   **Grão (Grain):** Cadastro do Produto (`identificador`).

| Nome do Campo | Tipo | Null % | Distintos | Exemplos | Significado Comercial | Criticidade | Risco / Observação |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: | :--- |
| `identificador` | INT64 | 0% | 9.747 | `101010` | ID físico único gerado para o produto. | **Crítica** | Contém **2 duplicatas** físicas. |
| `nome` | STRING | 0% | 8.354 | `Óleo de Alecrim 50ml`| Nome cadastrado oficial de exibição do SKU. | Importante | Usado em relatórios descritivos de vendas. |
| `codigo` | STRING | 51.7% | 2.354 | `3533` | SKU padrão utilizado nos faturamentos e estoques. | **Crítica** | **5.042 registros nulos/sem SKU**. |
| `preco` | FLOAT64 | 4% | 1.122 | `49.90` | Preço de venda padrão sugerido de tabela. | Auxiliar | **390 registros** com preço zerado/nulo. |
| `preco_custo` | FLOAT64 | 0% | 453 | `13.00` | Custo de aquisição unitário de fábrica (COGS). | **Crítica** | **8.883 registros zerados (91,1%)**. |
| `estoque` | INT64 | 0.3% | 874 | `150` | Saldo físico atual do produto disponível no CD. | Importante | **1.684 registros** com estoque negativo. |
| `situacao` | STRING | 0% | 2 | `A` | Status do produto (A=Ativo, I=Inativo). | Importante | Filtro padrão de catálogo ativo. |

---

### 3.4 Tabela: `customer_intelligence.customer_profile_enriched` (Perfil Enriquecido do Cliente)
*   **Finalidade:** Armazena o enriquecimento geográfico e socioeconômico mapeado via CEP.
*   **Grão (Grain):** Cliente Único (`customer_id`).

| Nome do Campo | Tipo | Null % | Distintos | Exemplos | Significado Comercial | Criticidade | Risco / Observação |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: | :--- |
| `customer_id` | STRING | 0% | 116.942 | `17406369` | ID técnico referencial do cliente (contato_id). | **Crítica** | Chave estrangeira primária para ligações com vendas.|
| `cep` | STRING | 0.01% | 87.654 | `01311000` | Código de Endereçamento Postal do consumidor. | Importante | Usado para cruzamentos geográficos e rotas. |
| `estado` | STRING | 0% | 27 | `SP` | Sigla da Unidade Federativa (UF) de residência. | Importante | Campo limpo, normatizado e sem nulos. |
| `renda_media_setor` | FLOAT64 | 0% | 24.321 | `4850.50` | Estimativa de renda familiar média censitária (IBGE). | Importante | Usado em segmentações de poder de compra. |
| `idh_municipio` | FLOAT64 | 0% | 452 | `0.805` | Índice de Desenvolvimento Humano do município. | Auxiliar | Utilizado em análises macroeconômicas. |
| `distancia_cd_km` | FLOAT64 | 0% | 34.212 | `42.5` | Distância linear em Km calculada até o CD (São Paulo). | Importante | Base de precificação de fretes e prazos de entrega. |

---

### 3.5 Tabela: `customer_intelligence.customer_predictions` (Previsões Analíticas de Clientes)
*   **Finalidade:** Armazena scores estatísticos e preditivos gerados para a base ativa de CPFs.
*   **Grão (Grain):** Cliente Único (`customer_id`).

| Nome do Campo | Tipo | Null % | Distintos | Exemplos | Significado Comercial | Criticidade | Risco / Observação |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: | :--- |
| `customer_id` | STRING | 0% | 101.593 | `17406369` | ID único de identificação de cliente. | **Crítica** | Chave primária de relacionamento de IA. |
| `probabilidade_churn_30d`| FLOAT64 | 0% | 54.321 | `0.85` | Probabilidade preditiva do cliente abandonar a marca. | Importante | Valor varia de 0.00 a 1.00. |
| `categoria_risco_churn`| STRING | 0% | 3 | `Alto` | Classificação do risco de churn (Baixo, Médio, Alto). | Importante | Utilizado em segmentações de CRM e e-mail marketing. |
| `predicao_ltv_12meses`| FLOAT64 | 0% | 21.112 | `350.00` | Projeção de receita líquida estimada do cliente em 12 meses. | Importante | Ajuda no cálculo de viabilidade de CAC. |
| `propensao_recompra_score`| FLOAT64 | 0% | 18.754 | `0.92` | Score estatístico de probabilidade de realizar nova compra. | Importante | Útil para disparos de cupons e descontos. |

---

### 3.6 View Semântica: `customer_intelligence.growth_engine_vendas_detalhado` (Visão Consolidada de Vendas)
*   **Finalidade:** View analítica unificada servindo as vendas consolidadas e higienizadas para os painéis Looker Studio.
*   **Grão (Grain):** Item por Pedido (`pedido_id` + `item_id`).

| Nome do Campo | Tipo | Null % | Distintos | Exemplos | Significado Comercial | Criticidade | Risco / Observação |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: | :--- |
| `pedido_id` | INT64 | 0% | 127.500 | `21364272133` | ID identificador do cabeçalho do pedido de vendas. | **Crítica** | Chave primária composta de relacionamento. |
| `item_id` | INT64 | 0% | 182.795 | `17406369135` | ID do item físico individual vendido no pedido. | **Crítica** | Chave primária composta de relacionamento. |
| `receita_total` | NUMERIC | 0% | 19.324 | `69.64` | Faturamento bruto líquido gerado (`quantidade * valor`). | **Crítica** | Livre de duplicidades contábeis. |
| `custo_total_produto` | FLOAT64 | 0% | 2.112 | `13.00` | COGS total do produto (`preco_custo * quantidade`). | **Crítica** | **108.442 linhas com custo zerado (59%)**. |
| `custo_frete` | NUMERIC | 0% | 45.321 | `2.28` | Custo de frete rateado e atribuído proporcionalmente ao item. | Importante | Rateado com base na receita líquida do item no total. |
| `uf` | STRING | 0.81% | 27 | `SP` | Sigla da Unidade Federativa do endereço do comprador. | Importante | **1.495 linhas sem UF (nulo)**. |
| `origem_da_venda` | STRING | 0% | 18 | `Shopee` | Canal de venda mapeado no ERP. | Importante | Contém mapeamento e-commerce/marketplaces. |
| `produto` | STRING | 0% | 8.354 | `Óleo de Alecrim 50ml`| Nome do SKU cadastrado. | Importante | Descrição legível do item de produto. |
| `familia_produto` | STRING | 0% | 6 | `2. Óleos Naturais`| Classificação analítica padronizada da Smartmetric. | Importante | Utilizado para estruturar hierarquias de relatórios. |
| `potencial_recorrencia`| STRING | 8.4% | 4 | `1. Alto` | Grau estimado de recorrência do produto. | Auxiliar | **15.439 linhas sem classificação**. |

---

### 3.7 Tabela: `analytics_414017556.events_YYYYMMDD` (Eventos Diários do GA4)
*   **Finalidade:** Armazena logs brutos de comportamento de tráfego capturados na propriedade GA4.
*   **Grão (Grain):** Evento por Usuário (`event_timestamp` + `user_pseudo_id`).

| Nome do Campo | Tipo | Null % | Distintos | Exemplos | Significado Comercial | Criticidade | Risco / Observação |
| :--- | :--- | :---: | :---: | :--- | :--- | :---: | :--- |
| `event_date` | STRING | 0% | 1 | `20260615` | Data do evento em formato de string. | Importante | Utilizado para particionar consultas temporais. |
| `event_timestamp` | INT64 | 0% | ~12.000 | `1781547407242` | Carimbo de data/hora em microssegundos da ocorrência. | **Crítica** | Grão do log de evento. |
| `event_name` | STRING | 0% | 22 | `page_view`, `click` | Nome do evento disparado no front-end do e-commerce. | **Crítica** | Permite reconstruir o funil de tráfego. |
| `user_pseudo_id` | STRING | 0% | ~8.500 | `984521232.12` | Cookie identificador único anônimo gerado pelo browser. | **Crítica** | Usado para rastrear jornadas únicas. |
| `event_params` | RECORD | 0% | REPEAT | `[key="page_location"]`| Parâmetros e propriedades associadas ao evento. | Importante | Estrutura aninhada (Array de Structs). |
| `traffic_source` | RECORD | 10% | - | `[source="google"]` | Origem da primeira visita que adquiriu o usuário. | Importante | Estrutura contendo dados de aquisição histórica. |
| `geo` | RECORD | 1% | - | `[country="Brazil"]` | Localidade e país estimada a partir do IP do usuário. | Auxiliar | Estrutura aninhada. |

---

## 4. Classificação Geral de Criticidade

Para orientar políticas de segurança de dados, acessos (LGPD) e alertas de monitoramento, todos os ativos foram classificados em cinco níveis de relevância:

1.  **Critical (Crítica):** Chaves primárias de relacionamento, IDs transacionais, datas de faturamento, totais financeiros, preços de custo e dados brutos de faturamento. Se estes dados forem alterados, corrompidos ou excluídos, todo o BI é paralisado.
2.  **Important (Importante):** Chaves estrangeiras, SKUs, nomes de produtos, localizações de clientes (UF), e-mail/celular (PII a ser protegida), parâmetros de UTM e prazos de transporte. Afetam a integridade e precisão das análises secundárias.
3.  **Auxiliary (Auxiliar):** Imagens de produtos, dados censitários secundários (IDH), descrições complementares, de-para analíticos não essenciais e logs de webhooks operacionais.
4.  **Deprecated (Obsoleto):** Tabelas físicas redundantes criadas para processamento temporário ou migrações históricas que não são ativamente utilizadas nas views finais (Ex: `Contatos_Tratados` físico).
5.  **Unknown / Needs Validation (A Validar):** Tabelas e colunas com nomenclatura ambígua ou ausência de dados recentes que exigem validação cadastral contábil do cliente para definição de regra (Ex: comissões de venda zeradas, tabelas auxiliares órfãs de 2025).
