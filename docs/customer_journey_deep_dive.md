# Customer Journey Deep Dive — Aroom Health
**Versão:** 1.0 | **Data:** 22/06/2026 | **Classificação:** Confidencial

---

## Fase 1 — Inventário de Campos (síntese)

### analytics_414017556.events_* (GA4 Nativo)

| Campo | Tipo | Fill% | Distinct | Observação |
|:---|:---|---:|---:|:---|
| `event_date` | STRING | 100% | 18 (dias) | Partição da tabela |
| `event_name` | STRING | 100% | ~30 | `purchase`, `add_to_cart`, `page_view`… |
| `user_pseudo_id` | STRING | 100% | 8.231 | Cookie anônimo — não persiste cross-device |
| `traffic_source.source` | STRING | 99.7% | 33 | `google`, `ig`, `(direct)`, `facebook.com` |
| `traffic_source.medium` | STRING | 99.7% | 16 | `cpc`, `paid`, `organic`, `referral` |
| `traffic_source.name` | STRING | varia | varia | Nome da campanha (last non-direct click) |
| `event_params[transaction_id]` | STRING | **100% quando purchase** | 242 (21 dias) | **Chave de atribuição → Bling. Ausente em 79.5% das compras totais** |
| `device.category` | STRING | 100% | 3 | `mobile`, `desktop`, `tablet` |
| `geo.country/region/city` | STRING | 100% | varia | Geolocalização IP |

### checkout

| Campo | Tipo | Fill% | Distinct | Observação |
|:---|:---|---:|---:|:---|
| `token` | STRING | 100% | 2.568 | PK único por carrinho — bridge com NS |
| `contact_email` | STRING | 100% | 2.294 | Melhor chave de identidade digital |
| `contact_identification` | STRING | 100% | 2.278 | CPF/CNPJ |
| `store_id` | INT64 | 100% | 1 (2537710) | Sempre a mesma loja — site próprio |
| `shipping_zipcode` | STRING | 100% | 2.250 | CEP de entrega |

### nuvemshop_pedidos

| Campo | Tipo | Fill% | Distinct | Observação |
|:---|:---|---:|---:|:---|
| `token` | STRING | 100% | 19.917 | Bridge com checkout (12.5% match) |
| `customer_id` | INT64 | 100% | 16.882 | ID Nuvemshop — sem correspondência no Bling |
| `contact_email` | STRING | 100% | 16.905 | Bridge com contato.email |
| `contact_identification` | STRING | 100% | 16.774 | Bridge com contato.numero_documento |
| `store_id` | INT64 | 100% | 1 | Bridge com pedidos_vendas.loja_id |
| `payment_status` | STRING | 100% | 5 | `paid` 93.6% · `pending` 4.7% · `voided` 1.1% |
| `fulfillment_status` | STRING | **0%** | 0 | **CAMPO VAZIO — sem rastreio de entrega** |

### pedidos_vendas

| Campo | Tipo | Fill% | Distinct | Observação |
|:---|:---|---:|---:|:---|
| `identificador` | INT64 | 100% | 130.133 | PK real |
| `numero` | INT64 | 100% | 112.688 | Número do pedido → bridge GA4 |
| `loja_id` | INT64 | 100% | 48 | 48 canais de venda |
| `contato_id` | INT64 | 100% | 117.131 | **INCOMPATÍVEL com contato.identificador** |
| `nota_fiscal_id` | INT64 | 99.99% | 92.501 | Apenas 11 pedidos sem NF ID |
| `numero_pedido_compra` | STRING | **0.2%** | 288 | Quase vazio — ID marketplace não propagado |
| `total` | NUMERIC | 100% | — | Fonte de verdade financeira |

### contato

| Campo | Tipo | Fill% | Distinct | Observação |
|:---|:---|---:|---:|:---|
| `identificador` | INT64 | 100% | 120.479 | PK — INT64 longo (incompatível com contato_id) |
| `email` | STRING | **64.7%** | 75.126 | **35.3% sem email (42.588 clientes)** |
| `numero_documento` | STRING | 95.0% | 111.055 | CPF — mais confiável que email |
| `telefone` | STRING | **33.8%** | 37.276 | **66.2% sem telefone** |

### pedidos_vendas_itens

| Campo | Tipo | Fill% | Distinct | Observação |
|:---|:---|---:|---:|:---|
| `pedidos_vendas_identificador` | INT64 | 100% | 130.137 | FK para pedidos_vendas |
| `codigo` | STRING | ~91% | varia | SKU — 510 SKUs sem match em produtos |
| `produto_id` | INT64 | 100% | varia | FK mais confiável que codigo |
| `valor` | NUMERIC | 100% | — | Valor unitário do item |

### produtos

| Campo | Tipo | Fill% | Distinct | Observação |
|:---|:---|---:|---:|:---|
| `identificador` | INT64 | 100% | 9.749 | PK |
| `codigo` | STRING | **48.3%** | 2.356 | **51.7% sem código SKU** |
| `situacao` | STRING | 100% | 3 | `A`=Ativo(1.730) · `I`=Inativo · `E`=Excluído |

---

## Fase 2 — Data Lineage Campo a Campo

| Campo Origem | Tabela Origem | → Campo Destino | Tabela Destino | Tipo Rel | Cobertura | Confiança | Risco | Impacto |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| `event_params[transaction_id]` | GA4 events | `numero` | pedidos_vendas | 1:1 | 20.5% | MÉDIA | Bloqueado por AdBlock/cookie | Perda de atribuição em 79.5% da receita site |
| `traffic_source.source/medium` | GA4 events | `sessionSource/Medium` | ga4_recovery | N:1 | 99.7% | ALTA | Agrupamento — sem pedido a pedido | ROAS por canal confiável em agregado |
| `session_campaign_name` | ga4_utm_daily | `utm_campaign` | campaign_name_mapping | N:1 | ~80% | ALTA | 54 campanhas mapeadas / não cobre todas | Custo por campanha calculável |
| `token` | checkout | `token` | nuvemshop_pedidos | 1:1 | 12.5% | MÉDIA | 87.5% são abandonos ou tokens diferentes | Taxa de conversão real não mensurável |
| `contact_email` | checkout | `contact_email` | nuvemshop_pedidos | 1:N | ~100% | ALTA | Case sensitivity | Bridge de identidade mais robusta |
| `store_id` | nuvemshop_pedidos | `loja_id` | pedidos_vendas | N:1 | ~100% | ALTA | Nível canal, não pedido individual | R$ 2.85M confirmado Site Aroom |
| `contact_email` | nuvemshop_pedidos | `email` | contato | 1:1 | 64.7% | ALTA | 35.3% contatos sem email no Bling | Customer 360 parcial |
| `contact_identification` | nuvemshop_pedidos | `numero_documento` | contato | 1:1 | 95.0% | ALTA | CPF mais robusto que email | Melhor chave de identity resolution |
| `contato_id` | pedidos_vendas | `identificador` | contato | 1:1 | **0%** | **CRÍTICO** | Schema mismatch (INT32 vs INT64 longo) | Impossível ligar pedido→cliente via ID |
| `codigo` | pedidos_vendas_itens | `codigo` | produtos | N:1 | ~99.1% | ALTA | 510 SKUs sem cadastro | R$ 95.170 sem margem calculável |
| `contact_email` | perfit_campaign_actions | `email` | contato | 1:1 | 75% | ALTA | Case sensitivity / 25% não encontrado | 4.994 clientes com comportamento de email |
| `contact_id` | dispatch_send_log | `identificador` | contato | 1:1 | 100% fill | ALTA* | *Mesmo problema de schema do contato_id | Automações rastreáveis por cliente |
| `nota_fiscal_id` | pedidos_vendas | `identificador` | notas_fiscais_saida | 1:1 | 99.99% | ALTA | Apenas 11 pedidos sem NF | Rastreio fiscal praticamente completo |

---

## Fase 3 — Jornada do Cliente (Cenários)

### Cenário A — Usuário vem do Google Ads e compra no site

```
ETAPA 1 — AQUISIÇÃO
Google Ads serve anúncio com UTM:
  utm_source=google
  utm_medium=cpc
  utm_campaign=pmax_roas_formula-exclusiva
  → custo registrado em google_ads.p_ads_CampaignStats

ETAPA 2 — LANDING PAGE
Usuário clica → acessa landing page
GA4 registra:
  event_name = session_start
  user_pseudo_id = "abc123" (cookie gerado)
  traffic_source.source = "google"
  traffic_source.medium = "cpc"
  traffic_source.name = "pmax_roas_formula-exclusiva"

ETAPA 3 — NAVEGAÇÃO
GA4 registra sequência:
  page_view (URL da landing)
  view_item_list
  view_item (produto específico)
  select_item
  add_to_cart ← funil critico
  view_cart

ETAPA 4 — CHECKOUT ABERTO
Usuário acessa checkout Nuvemshop
  → checkout.token = "xyz789abc" gerado
  → checkout.contact_email = "cliente@email.com" (preenchido)
  → checkout.contact_identification = "123.456.789-00" (CPF)
  → checkout.store_id = 2537710
GA4 registra:
  begin_checkout
  add_shipping_info
  add_payment_info

ETAPA 5 — PEDIDO CONFIRMADO
Usuário finaliza compra
  → nuvemshop_pedidos criado:
    token = "xyz789abc" (mesmo do checkout)
    customer_id = 99999 (ID Nuvemshop)
    contact_email = "cliente@email.com"
    contact_identification = "123.456.789-00"
    store_id = 2537710
    payment_status = "paid"
  → nuvemshop_pedido_produto: itens do pedido com SKU
GA4 registra:
  event_name = purchase
  event_params[transaction_id] = "24500" ← numero do pedido Bling
  event_params[value] = 189.90
  [SE COOKIED NÃO BLOQUEADO]

ETAPA 6 — INTEGRAÇÃO BLING
Pedido Nuvemshop → Bling via integração automática
  → pedidos_vendas criado:
    numero = 24500
    loja_id = 205519093 ("Site Aroom")
    contato_id = 35738 [ID interno Bling - não bate com contato.identificador]
    total = 189.90
  → pedidos_vendas_itens:
    codigo = "0034" (SKU do produto)
    quantidade = 1
    valor = 189.90

ETAPA 7 — NOTA FISCAL EMITIDA
  → notas_fiscais_saida:
    numero = "001234"
    chave_acesso = "35 dígitos..."
    data_emissao = data do pedido
  → pedidos_vendas.nota_fiscal_id atualizado

ETAPA 8 — CLIENTE NO BLING
  → contato criado/atualizado:
    identificador = 18215784661 (INT64 longo)
    email = "cliente@email.com"
    numero_documento = "12345678900"
  PROBLEMA: pedidos_vendas.contato_id = 35738 ≠ 18215784661
  → Join direto não funciona. Usar email/CPF como bridge.

ETAPA 9 — CUSTOMER INTELLIGENCE
  → customer_intelligence.customer_360:
    enriquecido via email/CPF
    RFM calculado
    segmento atribuído
  → growth_engine_vendas_detalhado:
    pedido visível com margem

ETAPA 10 — EMAIL CRM PÓS-COMPRA
  → perfit recebe lista de clientes
  → Campanha de recompra ou cross-sell disparada
  → perfit_campaign_actions registra:
    action_type = SENT (email enviado)
    action_type = OPEN (abriu)
    action_type = CLICK (clicou)
  → dispatch_send_log registra automações:
    rule_tag = "produto_acabando_cliente" (após X dias)
    rule_tag = "sinto_sua_falta" (após inatividade)
```

### Cenário B — Usuário vem do Meta/Instagram e compra no marketplace (Shopee)

```
ETAPA 1 — AQUISIÇÃO
Meta Ad serve anúncio
  utm_campaign = "120209681087360703" (ID numérico da campanha)
  → spend registrado em facebook_ads_insights e meta_ads

ETAPA 2 — MARKETPLACE
Usuário vai direto para Shopee (não pelo site)
  GA4 NÃO registra (fora do domínio)
  checkout NÃO existe (processo Shopee)

ETAPA 3 — PEDIDO SHOPEE
  → shopee_pedidos criado (dados operacionais)
  → shopee_pedido_produto: itens

ETAPA 4 — INTEGRAÇÃO BLING
  → pedidos_vendas:
    loja_id = [ID da loja Shopee]
    canal = "Shopee (1)" ou "Shopee (2)"
    total registrado

RESULTADO:
  ✗ SEM atribuição de campanha Meta para este pedido
  ✗ SEM identidade digital (GA4 não capturou)
  ✓ Faturamento contabilizado no Bling
  ✓ Cliente cadastrado no contato (via dados Shopee)
```

---

## Fase 4 — Customer Identity Resolution

Ver `customer_identity_map.md` para detalhes completos.

**Resumo executivo da identidade:**

| Identificador | Nasce em | Morre em | Recuperável? |
|:---|:---|:---|:---|
| `user_pseudo_id` | GA4 (primeiro clique) | Ao trocar dispositivo | Não — é anônimo |
| `token` | checkout (carrinho aberto) | Após 30 dias | Via email/CPF |
| `contact_email` | checkout (preenchimento) | Nunca (persiste) | Sim — backbone de identidade |
| `customer_id` | nuvemshop_pedidos | No Bling (não existe) | Não — ID isolado |
| `contato_id` | pedidos_vendas | Ao tentar join com contato | Não — schema mismatch |
| `identificador` | contato (Bling) | Nunca | Sim via email/CPF |

---

## Fase 5 — Matriz de Confiabilidade

| Conexão | Chave | Cobertura | Confiança | Tipo | Risco Principal |
|:---|:---|:---|:---|:---|:---|
| GA4 purchase → Bling pedido | `transaction_id = numero` | 20.5% | 🟡 MÉDIA | 1:1 | AdBlock bloqueia 79.5% |
| checkout → nuvemshop | `token = token` | 12.5% convertidos | 🟡 MÉDIA | 1:1 | 87.5% são abandonos |
| nuvemshop → Bling canal | `store_id = loja_id` | ~100% | 🟢 ALTA | N:1 | Nível canal, não pedido |
| nuvemshop cliente → Bling | `contact_email = email` | 64.7% | 🟢 ALTA | 1:1 | 35.3% contatos sem email |
| nuvemshop cliente → Bling | `contact_identification = numero_documento` | 95.0% | 🟢 ALTA | 1:1 | Melhor chave disponível |
| pedido → cliente (ID) | `contato_id = identificador` | **0%** | 🔴 CRÍTICO | — | Schema mismatch |
| pedido → NF | `nota_fiscal_id = identificador` | 99.99% | 🟢 ALTA | 1:1 | Quase perfeito |
| itens → produtos | `codigo = codigo` | ~99.1% | 🟢 ALTA | N:1 | 510 SKUs faltantes |
| email CRM → cliente | `contact_email = email` | 75% | 🟢 ALTA | 1:1 | 25% sem match |
| automação → cliente | `contact_id = identificador` | 100% fill | 🟢 ALTA* | 1:1 | *Mesmo schema issue |
| GA4 UTM → Google Ads | `session_campaign_name → utm_campaign` | ~80% | 🟢 ALTA | N:1 | 54 mapeamentos de-para |

---

## Fase 6 — Pontos de Perda

| # | Onde | O que se perde | Impacto Financeiro | Solução |
|:---|:---|:---|:---|:---|
| P-01 | GA4 purchase sem transaction_id | Atribuição de 79.5% da receita do site | ~R$ 1.8M não atribuível | Conversions API / server-side tagging |
| P-02 | pedidos_vendas.contato_id incompatível | Impossível ligar pedido→cliente por ID | 100% dos pedidos sem identity via ID | Investigar mapping ID ou usar email/CPF |
| P-03 | contato sem email (35.3%) | Clientes de marketplace sem identidade digital | 42.588 clientes não alcançáveis via email | Solicitar email no pós-venda / Bling |
| P-04 | checkout token só 12.5% match | Taxa de conversão real desconhecida | Funil de conversão incalculável | Investigar lógica de geração de token |
| P-05 | 510 SKUs sem cadastro | Margem e giro impossíveis para R$ 95.170 | R$ 95.170 sem análise de margem | Cadastrar SKUs faltantes + de-para |
| P-06 | produtos.codigo 51.7% vazio | Metade do catálogo sem SKU | 5.041 produtos sem rastreio de venda | Preenchimento obrigatório no Bling |
| P-07 | Meta Ads → marketplace (sem GA4) | Zero atribuição para vendas Shopee/ML vindas de Meta | R$ 2.2M+ Shopee não atribuível | Pixel marketplace / UTM landing |
| P-08 | fulfillment_status vazio | Status de entrega desconhecido no backend | Logística inrastreável pelo site | Ativar webhook de fulfillment Nuvemshop |
| P-09 | perfit cobre apenas Mar/2026+ | Histórico de email marketing ausente | Dados de CRM de 2025 perdidos | Verificar pipeline de ingestão Perfit |
| P-10 | customer_id Nuvemshop sem bridge | Histórico de compras Nuvemshop isolado | Análise de recorrência incompleta | Criar de-para customer_id → contato via email |

---

## Fase 8 — Executive Summary

### 1. Como um lead vira receita?

```
Ads → Landing Page → GA4 captura comportamento
→ Checkout aberto (token gerado)
→ Pedido confirmado Nuvemshop (payment_status = paid)
→ Integração automática → Bling (pedidos_vendas)
→ NF emitida → Receita contabilizada
→ Cliente entra no Customer Intelligence
```

### 2. Qual o caminho dos dados?

`Ads → GA4 → Checkout → Nuvemshop → Bling → Customer Intelligence → Email CRM → loop`

### 3. Quais conexões são confiáveis?

| Conexão | Status |
|:---|:---|
| Nuvemshop → Bling (store_id) | ✅ Confiável — R$ 2.85M validado |
| Email → Contato | ✅ Confiável — 75–95% cobertura |
| CPF → Contato | ✅ Melhor chave — 95% cobertura |
| Pedido → NF | ✅ 99.99% cobertura |
| Email CRM → Bling | ✅ 75% via email |

### 4. Quais conexões estão frágeis?

| Conexão | Status |
|:---|:---|
| GA4 → Bling via transaction_id | ⚠️ Frágil — 20.5% apenas |
| Checkout token → Nuvemshop | ⚠️ Frágil — 12.5% conversão |
| pedido_id → cliente_id | 🔴 Quebrado — 0% por schema mismatch |

### 5. Onde existe perda de rastreabilidade?

- 79.5% dos purchases GA4 sem `transaction_id`
- 35.3% dos clientes Bling sem email
- 87.5% dos carrinhos com destino desconhecido
- 510 SKUs vendidos sem cadastro

### 6. Qual % da receita é atribuível hoje?

| Receita | Valor | % |
|:---|---:|:---|
| Total Bling (fonte de verdade) | R$ 9.538.019 | 100% |
| Atribuível via GA4 (transactionId) | R$ 512.023 | **5.4%** |
| Atribuível por canal (site Aroom) | R$ 2.850.297 | **29.9%** |
| Atribuível por canal (todos) | R$ 9.538.019 | **100%** (nível canal, não campanha) |
| Atribuível a campanha específica | ~R$ 512.023 | **5.4%** |

### 7. O que impede visão 360° do cliente?

1. **Schema mismatch** `contato_id` vs `identificador` — join direto pedido→cliente impossível
2. **GA4 cobertura 20.5%** — atribuição de campanha limitada
3. **35.3% de clientes sem email** — campanhas digitais não alcançam ~43k clientes
4. **customer_id Nuvemshop isolado** — histórico do site não conecta ao Bling por ID
5. **510 SKUs sem cadastro** — análise de margem e giro incompleta
