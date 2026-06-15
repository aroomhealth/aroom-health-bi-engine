# Dicionário de Dados das Fontes - Aroom Health BI Engine

Este documento apresenta o dicionário de dados detalhado (em nível de microesquema) de todas as fontes de dados brutas consumidas no Google BigQuery pela **Aroom Health**.

---

## 1. Fonte: Bling ERP (transacional)

### 1.1 Tabela: `pedidos_vendas`
Armazena as informações de cabeçalho dos pedidos de vendas faturados e ativos.

| Nome do Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | INT64 | Chave incremental física da linha no BigQuery. |
| `identificador` | INT64 | ID único transacional do pedido gerado pelo Bling ERP. |
| `numero` | INT64 | Número legível do pedido. |
| `numero_loja` | STRING | Número do pedido gerado na plataforma de e-commerce parceira. |
| `data` | DATE | Data de emissão/criação do pedido. |
| `data_saida` | DATE | Data de saída física/faturamento do estoque. |
| `data_prevista` | DATE | Data prevista para a entrega ao cliente. |
| `total_produtos` | FLOAT64 | Valor bruto total apenas dos produtos do pedido (sem frete/taxas). |
| `total` | FLOAT64 | Valor total líquido final do pedido (incluindo descontos e fretes). |
| `contato_id` | INT64 | Chave estrangeira referenciando o ID do cliente no cadastro. |
| `loja_id` | INT64 | Chave estrangeira referenciando o ID do canal de venda parceiro. |
| `situacao_id` | INT64 | ID de status do pedido (ex: 12 e 105 representam cancelados). |
| `created_at` | TIMESTAMP | Carimbo de data/hora de criação do registro no banco analítico. |
| `updated_at` | TIMESTAMP | Carimbo de data/hora de atualização do registro no banco analítico. |
| `numero_pedido_compra` | STRING | Número da ordem de compra inserida pelo cliente. |
| `outras_despesas` | FLOAT64 | Custos acessórios diversos somados ao pedido. |
| `observacoes` | STRING | Observações públicas gravadas no pedido (ex: notas do cliente). |
| `observacoes_internas` | STRING | Notas internas inseridas no ERP (usado para injeção de UTMs futuras). |
| `categoria_id` | INT64 | ID da categoria interna de classificação do pedido. |
| `nota_fiscal_id` | INT64 | ID referencial da Nota Fiscal gerada para o pedido. |
| `vendedor_id` | INT64 | ID do vendedor associado à venda (se houver). |
| `desconto_id` | INT64 | ID referencial de promoções aplicadas ao pedido. |
| `tributacao_id` | INT64 | ID de regras tributárias do faturamento do pedido. |
| `intermediador_id` | INT64 | ID do intermediador de pagamento utilizado (ex: Pagar.me, Mercado Pago). |
| `taxas_id` | INT64 | ID de taxas acessórias cobradas. |
| `transporte_id` | INT64 | ID do frete/transportadora selecionada. |
| `itens_id` | JSON | Objeto JSON bruto contendo os itens associados de forma aninhada. |
| `parcelas_id` | JSON | Objeto JSON bruto contendo o parcelamento e vencimentos de pagamento. |
| `bling_id` | INT64 | ID nativo gerado pelo ERP. |

---

### 1.2 Tabela: `pedidos_vendas_itens`
Armazena a granularidade de itens individuais contidos dentro de cada pedido.

| Nome do Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | INT64 | ID incremental de linha de registro analítico. |
| `identificador` | INT64 | ID único gerado no ERP para a linha do item. *(Contém duplicações por webhook)*. |
| `pedidos_vendas_identificador` | INT64 | Chave estrangeira referenciando o `identificador` da tabela `pedidos_vendas`. |
| `codigo` | STRING | SKU do produto associado. |
| `unidade` | STRING | Unidade de medida do produto (ex: UN, ML). |
| `quantidade` | INT64 | Quantidade de unidades compradas no item. |
| `desconto` | NUMERIC(10,2) | Valor unitário de desconto deduzido do item. |
| `valor` | NUMERIC(10,2) | Preço unitário líquido cobrado por item. |
| `aliquota_ipi` | NUMERIC(10,2) | Alíquota do Imposto sobre Produtos Industrializados (IPI) incidente. |
| `descricao` | STRING | Nome descritivo do produto na nota de venda. |
| `descricao_detalhada` | STRING | Descritivo estendido do item. |
| `produto_id` | INT64 | Chave estrangeira referenciando o ID único da tabela `produtos`. |
| `comissao_base` | FLOAT64 | Base de cálculo da comissão de venda (se houver). |
| `comissao_aliquota` | NUMERIC(10,2) | Alíquota de comissão. |
| `comissao_valor` | NUMERIC(10,2) | Valor da comissão do item. |
| `sem_produto` | INT64 | Flag para produtos fictícios ou não catalogados. |

---

### 1.3 Tabela: `pedidos_vendas_transporte`
Armazena informações relativas à logística e taxas de frete dos pedidos.

| Nome do Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | INT64 | ID físico do registro. |
| `pedidos_vendas_identificador` | INT64 | Chave estrangeira referenciando o pedido de origem. |
| `frete_por_conta` | INT64 | Tipo de frete contratado (ex: CIF ou FOB). |
| `frete` | NUMERIC(10,2) | Valor total do frete cobrado para o pedido. |
| `quantidade_volumes` | INT64 | Quantidade de caixas/volumes físicos transportados. |
| `peso_bruto` | NUMERIC(10,2) | Peso bruto final aferido para o pedido em kg. |
| `prazo_entrega` | INT64 | Prazo estimado de entrega em dias úteis. |
| `contato_id` | INT64 | ID do cliente. |
| `volumes_id` | INT64 | ID identificador dos volumes gerados. |
| `volumes_servico` | STRING | Serviço de frete selecionado (ex: PAC, Sedex, Jadlog). |
| `codigo_rastreamento` | STRING | Código de rastreio logístico gerado pela transportadora. |
| `etiqueta_id` | INT64 | ID referencial da etiqueta de envio de correios/melhor envio. |

---

### 1.4 Tabela: `produtos`
Dicionário de cadastro e dados de catálogo de todos os produtos comercializados.

| Nome do Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id` | INT64 | ID físico incremental. |
| `identificador` | INT64 | ID único de produto gerado no ERP Bling. |
| `id_produto_pai` | INT64 | ID do produto pai no caso de SKUs com variações (tamanho/cor). |
| `nome` | STRING | Nome cadastrado do produto comercializado. |
| `codigo` | STRING | SKU oficial do produto. |
| `preco` | FLOAT64 | Preço padrão de venda do produto. |
| `preco_custo` | FLOAT64 | Custo unitário médio de produção/aquisição do produto. |
| `estoque` | INT64 | Quantidade atual física disponível no armazém. |
| `tipo` | STRING | Tipo do produto (ex: P para físico, S para serviço). |
| `situacao` | STRING | Status do produto no catálogo (A = Ativo, I = Inativo). |
| `formato` | STRING | Formato do produto (ex: S para simples, V para variação). |
| `descricao_curta` | STRING | Breve descrição comercial do produto. |
| `imagem_url` | STRING | Link para imagem pública do produto. |
| `categoria_id` | INT64 | ID da categoria cadastrada no ERP. |
| `descricao_complementar`| STRING | Detalhes adicionais do produto. |
| `gtin` | STRING | Código EAN/GTIN padrão de barras internacional. |
| `gtin_embalagem` | STRING | Código GTIN da caixa de despacho coletivo. |

---

### 1.5 Tabela: `bling_canais_venda`
Tabela de mapeamento (De/Para) dos canais e integrações de venda.

| Nome do Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `id_canal` | INT64 | ID numérico gerado no Bling para o canal integrado. |
| `canal` | STRING | Nome descritivo padrão do canal (ex: Shopee, Shopify). |
| `canal_edit` | STRING | Nome personalizado ou agrupado definido pelo analista para o BI. |

---

## 2. Fonte: Google Ads (Mkt Pago)

### 2.1 Tabela: `google_ads_campaign_performance`
Armazena a performance diária agregada no nível de campanha publicitária.

| Nome do Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `day` | DATE | Data em que as métricas foram aferidas. |
| `account_name` | STRING | Nome da conta do Google Ads. |
| `customer_id` | STRING | ID da conta do cliente Google Ads (MCC/Individual). |
| `campaign_name` | STRING | Nome da campanha cadastrada. |
| `campaign_state` | STRING | Status da campanha (ex: ENABLED, PAUSED). |
| `advertising_channel`| STRING | Canal de veiculação (ex: SEARCH, DISPLAY, PERFORMANCE_MAX). |
| `clicks` | INT64 | Quantidade de cliques recebidos nos anúncios da campanha. |
| `impressions` | INT64 | Quantidade de exibições (impressões) dos anúncios. |
| `ctr` | FLOAT64 | Taxa de clique sobre impressão (Click-Through Rate). |
| `avg_cpc` | FLOAT64 | Custo Médio por Clique (Average Cost-per-Click). |
| `cost_spend` | FLOAT64 | Custo total consumido pela campanha na data (Investimento de Mkt). |
| `conversions` | FLOAT64 | Quantidade de conversões registradas no painel do Ads. |
| `view_through_conv` | FLOAT64 | Conversões por visualização (sem clique). |
| `cost_conv` | FLOAT64 | Custo médio por conversão gerada. |
| `conv_rate` | FLOAT64 | Taxa de conversão. |
| `conv_value_current_mode`| FLOAT64 | Valor financeiro associado às conversões correntes. |
| `total_conv_value` | FLOAT64 | Valor total gerado de faturamento pelas conversões (rastreado por tag). |
| `value_conv` | FLOAT64 | Valor médio por conversão gerada. |
| `safe_uuid` | STRING | ID único gerado no pipeline analítico para desduplicação de ingestão. |
| `datetime_stamp` | TIMESTAMP | Data e hora em que a linha foi carregada na tabela. |

---

## 3. Fonte: GA4 (Tráfego Orgânico & Pago)

### 3.1 Tabela: `google_analytics_utm_daily`
Armazena o tráfego de sessões e usuários agregados diariamente por dimensões de UTM de origem.

| Nome do Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `metric_date` | DATE | Data das sessões monitoradas. |
| `ga_property_id` | STRING | Identificador da propriedade GA4 da Aroom Health. |
| `session_source` | STRING | Origem da sessão de tráfego (`utm_source` ex: google, facebook). |
| `session_medium` | STRING | Meio da sessão de tráfego (`utm_medium` ex: cpc, organic, email). |
| `session_campaign_name`| STRING | Nome da campanha de marketing acessada (`utm_campaign`). |
| `session_campaign_id` | STRING | ID da campanha registrado. |
| `sessions` | INT64 | Volume total de sessões contabilizadas com este padrão de UTM no dia. |

---

## 4. Fonte: Customer Intelligence (Enriquecimento)

### 4.1 Tabela: `customer_profile_enriched`
Enriquece a base de clientes com coordenadas geográficas e estimativas socioeconômicas do IBGE.

| Nome do Campo | Tipo | Descrição |
| :--- | :--- | :--- |
| `customer_id` | STRING | ID único do cliente (conecta ao `contato_id` da base de vendas). |
| `cep` | STRING | CEP residencial cadastrado do cliente. |
| `cidade` | STRING | Nome do município de residência. |
| `estado` | STRING | Sigla do Estado (UF) de moradia do cliente. |
| `regiao` | STRING | Região brasileira do cliente (ex: Sudeste, Nordeste). |
| `eh_capital` | BOOL | Flag indicando se o município é capital de estado. |
| `renda_media_setor` | FLOAT64 | Estimativa de renda familiar média no setor censitário do cliente (IBGE). |
| `idh_municipio` | FLOAT64 | Índice de Desenvolvimento Humano (IDH) do município. |
| `escolaridade_media_setor` | FLOAT64 | Média de anos de estudo do setor residencial. |
| `densidade_demografica_setor` | FLOAT64 | Densidade populacional da região do cliente. |
| `latitude` | FLOAT64 | Coordenada geográfica (latitude) estimada a partir do CEP. |
| `longitude` | FLOAT64 | Coordenada geográfica (longitude) estimada a partir do CEP. |
| `distancia_cd_km` | FLOAT64 | Distância linear em km calculada do CEP do cliente ao Centro de Distribuição. |
| `data_atualizacao` | TIMESTAMP | Data de atualização dos dados na tabela enriquecida. |
