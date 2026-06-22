# Arquitetura de Dados — Aroom Health BI Engine

**Versão:** v1.3.0  
**Data:** 22/06/2026  
**Projeto GCP:** `iron-rex-461220-g4`  
**Região:** `us-central1`

---

## 1. Visão Geral

```
┌─────────────────────────────────────────────────────────────────────┐
│                     FONTES DE DADOS (Ingestão)                      │
├────────────────┬────────────────┬────────────────┬──────────────────┤
│   Bling ERP    │  Google Ads    │   GA4 / UA     │   Marketplaces   │
│  (via API)     │  (via DTS)     │  (nativo + API)│ (ML/Shopee/etc)  │
└───────┬────────┴───────┬────────┴───────┬────────┴────────┬─────────┘
        │                │                │                 │
        ▼                ▼                ▼                 ▼
┌──────────────────────────────────────────────────────────────────────┐
│                    RAW LAYER — BigQuery Datasets                     │
│                                                                      │
│  database_aroom_health    google_ads          analytics_414017556    │
│  ─────────────────────    ──────────          ───────────────────    │
│  pedidos_vendas           p_ads_Campaign      events_*               │
│  pedidos_vendas_itens     p_ads_CampaignStats                        │
│  contato / contatos_v2                        analytics_recovery     │
│  produtos                                     ──────────────────     │
│  bling_estoque_saldos                         ga4_recovery_*         │
│  contas_pagar/receber                         (182 dias historico)   │
│  notas_fiscais_*                                                     │
│  mercadolivre/nuvemshop/shopee_pedidos                               │
│  meta_ads / facebook_ads_insights                                    │
│  shopee_ads / tiktok_ads / ml_ads_insights                           │
│  orders_tracking / *_order_tracking                                  │
└─────────────────────────────┬────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│                   CURATED / SEMANTIC LAYER                           │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ DATASET: marketing_attribution                               │   │
│  │ v_pedidos_com_origem       <- GA4 + Bling (join key:         │   │
│  │                               transactionId=numero_pedido)   │   │
│  │ v_roas_por_campanha        <- Google Ads + GA4 + de-para     │   │
│  │ v_resumo_canais_marketing  <- Share receita por canal        │   │
│  │ [TABLE] campaign_name_mapping <- De-Para: 54 mapeamentos     │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ DATASET: legado                                              │   │
│  │ v_legado_vendas      <- ML + Nuvemshop + Shopee (ops)        │   │
│  │ v_legado_clientes    <- contato + contatos_v2 unificados     │   │
│  │ v_legado_produtos    <- produtos + depara + sku_custos       │   │
│  │ v_legado_marketing   <- Meta/ML/Shopee/TikTok/Google Ads     │   │
│  │ v_legado_financeiro  <- contas_pagar + contas_receber        │   │
│  │ v_legado_expedicao   <- tracking unificado por pedido        │   │
│  │ v_legado_estoque     <- saldos + valor + status cobertura    │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │ VIEW: growth_engine_vendas_detalhado                         │   │
│  │ View principal de vendas. Auditada: R$ 9.540.041,07          │   │
│  └──────────────────────────────────────────────────────────────┘   │
└─────────────────────────────┬────────────────────────────────────────┘
                              │
                              ▼
┌──────────────────────────────────────────────────────────────────────┐
│                     REPORTING LAYER (Looker Studio)                  │
│  Visao Executiva | ROAS por Campanha | Mix de Canais | Estoque       │
└──────────────────────────────────────────────────────────────────────┘
```

---

## 2. Datasets — Detalhamento

### 2.1 `database_aroom_health` (Raw / Operacional)

Fonte de verdade do ERP Bling.

**Canais de venda consolidados no Bling via `loja_id`:**

| Canal | Pedidos | Faturamento |
|:---|---:|---:|
| Mercado Livre | 39.707 | R$ 2.632.792 |
| Shopee | 42.614 | R$ 2.221.505 |
| Amazon | 4.576 | R$ 289.080 |
| Magalu | 876 | R$ 60.315 |
| TikTok | 580 | R$ 42.739 |
| Shein | 788 | R$ 31.304 |
| B2W | 144 | R$ 10.581 |

> **IMPORTANTE:** ML/Shopee/Amazon ja estao consolidados no Bling via `loja_id`. As tabelas `mercadolivre_pedidos`, `nuvemshop_pedidos` e `shopee_pedidos` contem apenas dados operacionais adicionais — nao geram dupla contagem.

---

### 2.2 `google_ads` (via DTS)

| Tabela | Periodo | Registros |
|:---|:---|---:|
| `p_ads_CampaignStats_5644422842` | 01/01/2025 → hoje | 12.365+ |
| `p_ads_Campaign_5644422842` | historico | variado |

**Investimento total recuperado:** R$ 195.069,41 (531 dias)

---

### 2.3 `analytics_recovery` (GA4 Historico)

| Tabela | Periodo | Linhas |
|:---|:---|---:|
| `ga4_recovery_traffic_sources` | 11/12/2025 → 10/06/2026 | 6.942 |
| `ga4_recovery_ecommerce` | idem | 4.481 (4.955 transacoes) |

**Receita GA4 recuperada:** R$ 512.023,63 | **Taxa de captura:** 20,5%

---

### 2.4 `marketing_attribution`

**Join key oficial:** `transactionId` (GA4) = `numero_pedido` (Bling)

| Objeto | Tipo | Descricao |
|:---|:---|:---|
| `v_pedidos_com_origem` | VIEW | Pedidos Bling com canal de origem GA4 |
| `v_roas_por_campanha` | VIEW | ROAS diario por campanha via de-para |
| `v_resumo_canais_marketing` | VIEW | Receita por canal de marketing |
| `campaign_name_mapping` | TABLE | 54 mapeamentos Google Ads → utm_campaign |

---

### 2.5 `legado`

| View | Fontes | Proposito |
|:---|:---|:---|
| `v_legado_vendas` | ML + Nuvemshop + Shopee pedidos | Status entrega, fulfillment, CPF |
| `v_legado_clientes` | `contato`, `contatos_v2` | Customer 360 unificado |
| `v_legado_produtos` | `produtos`, `depara_produtos`, `sku_custos_reais` | Catalogo com margem bruta |
| `v_legado_marketing` | Meta/FB/ML/Shopee/TikTok/Google Ads legado | Ads consolidados multi-canal |
| `v_legado_financeiro` | `contas_pagar`, `contas_receber` | DRE operacional |
| `v_legado_expedicao` | `orders_tracking`, `*_order_tracking` | Tracking logistico unificado |
| `v_legado_estoque` | `bling_estoque_saldos` + produtos + custos | Estoque com valor e status |

---

## 3. Chaves de Join Oficiais

| Join | Chave | Observacao |
|:---|:---|:---|
| GA4 -> Bling | `transactionId` = `numero_pedido` | Chave principal de atribuicao |
| Google Ads -> GA4 | `campaign_name_mapping.utm_campaign` | Via tabela de-para (54 mapeamentos) |
| Bling -> Marketplace | `loja_id` = `bling_canais_venda.id_canal` | ML/Shopee/Amazon por loja |
| Produto -> Categoria | `produtos.codigo` = `depara_produtos.codigo` | Enriquecimento de catalogo |
| Produto -> Custo Real | `produtos.codigo` = `sku_custos_reais.sku` | Margem bruta por SKU |
| Estoque -> Produto | `bling_estoque_saldos.produto_identificador` = `produtos.identificador` | Saldo fisico |

---

## 4. Decisoes de Arquitetura

### Por que nao criar views de faturamento sobre ML/Shopee/Nuvemshop?
Auditoria de 22/06/2026 confirmou que os pedidos dessas plataformas **ja entram no Bling via `loja_id`**. Duplicar em views separadas criaria risco de dupla contagem. As views `v_legado_*` expoe apenas dados **nao financeiros**.

### Por que o ROAS esta baixo (~0.05x)?
Cobertura do GA4 e ~20,5% dos pedidos. O ROAS real estimado e ~5x maior considerando a cobertura parcial.

### Por que existe o de-para `campaign_name_mapping`?
Google Ads usa nomes com prefixos de meta ROAS ex: `[550%] [PMAX] [TINTURA MACA]`, enquanto GA4 registra o `utm_campaign` das URLs: `pmax_roas_maca-peruana`. Sem o de-para, o JOIN resulta em ROAS zerado.
