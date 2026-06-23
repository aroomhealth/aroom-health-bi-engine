# De-Para: growth_engine_vendas_detalhado vs. Problemas Phase 2

**Data:** 2026-06-22 | **Autor:** Principal Staff Data Engineer
**Tabela analisada:** `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado`

---

## O que o seu sócio construiu — Visão Geral

| Métrica | Valor |
|:---|:---:|
| Total de linhas | 187.879 itens |
| Pedidos distintos | 130.126 pedidos |
| Clientes distintos | 117.126 clientes |
| Período coberto | 2021-08-05 → 2026-06-23 |
| Receita total | R$ 9.777.468 |
| Lucro bruto total | R$ 5.364.362 |
| Margem líquida final | R$ 3.822.282 |

**34 colunas** cobrindo: datas, cliente, loja, produto, custo, receita, margem, categoria, jornada do produto.

---

## De-Para: 6 Problemas vs. growth_engine_vendas_detalhado

### P-01 — Schema Mismatch contato_id

| Item | Nossa solução (bi_layer) | Growth Engine do sócio |
|:---|:---|:---|
| Campo de cliente | `v_pedido_contato_bridge` → join via CPF/email | `id_cliente` INT64 — **já presente, 100% preenchido** |
| Cobertura | 35% via Nuvemshop (só site) | **117.126 clientes distintos (todos os canais)** |
| Bridge method | CPF + email | Direto via `pedidos_vendas.contato_id` |

> ✅ **COBERTO PELO SÓCIO — e melhor que a nossa solução.** O `id_cliente` na view tem 100% fill rate em todos os 187k itens. Ele resolveu o mismatch internamente na lógica da view usando o `contato_id` como identificador direto (sem precisar do join com a tabela `contato`). **Nossa view `v_pedido_contato_bridge` é redundante para análises de vendas.**

---

### P-02 — Attribution Gap (GA4 20.5%)

| Item | Nossa solução (bi_layer) | Growth Engine do sócio |
|:---|:---|:---|
| Campo de origem | `v_pedido_atribuicao` → join GA4 recovery | `origem_da_venda` STRING + `origem_agrupada` STRING |
| Cobertura | 1.7% em Maio/2026 via GA4 | **100% preenchido** — 187.879/187.879 |
| Granularidade | source/medium GA4 | Canal de venda Bling (loja_id → nome do canal) |

> ⚠️ **PARCIALMENTE COBERTO — com uma diferença importante.**
> O sócio resolveu a origem **por canal de venda Bling** (`Mercado Livre - Aroom Oficial`, `Site Aroom`, etc.), o que é ótimo para análise de canal. Mas **não tem UTM/campanha** (Google Ads, Meta específico). São duas granularidades diferentes:
> - Sócio: *"veio do Mercado Livre"* ✅
> - Nossa view: *"veio da campanha pmax_roas_formula-exclusiva no Google"* ← ainda faltando
> **O Server-Side Tagging ainda é necessário** para o nível de campanha.

---

### P-03 — checkout token 12.5% → 58.5% real

| Item | Nossa solução (bi_layer) | Growth Engine do sócio |
|:---|:---|:---|
| Funil de conversão | `v_checkout_pedido_bridge` — análise de checkout | Não presente — view começa nos pedidos confirmados |
| Status | TOKEN/EMAIL/CPF/ABANDONO | Não aplicável |

> ❌ **NÃO COBERTO.** A view do sócio começa em `pedidos_vendas` — ela não tem checkout. O funil pré-pedido (carrinhos abandonados) não está no escopo da `growth_engine_vendas_detalhado`. Nossa `v_checkout_pedido_bridge` é complementar e necessária para análise de funil.

---

### P-04 — 510 SKUs sem cadastro (R$ 95.170)

| Item | Nossa solução (bi_layer) | Growth Engine do sócio |
|:---|:---|:---|
| Rastreio de SKUs órfãos | `v_sku_orphans` — lista 510 SKUs classificados | `flag_origem_custo` — indica se SKU tem custo real ou estimado |
| SKUs sem custo | 510 identificados | **5.263 itens sem custo** + **103.075 com custo estimado** |
| Ação | CSV para saneamento no Bling | Usa regras de segurança (custo estimado por categoria) |

> ✅ **COBERTO PELO SÓCIO — com uma estratégia diferente e mais inteligente.**
> Em vez de bloquear a análise quando não há SKU cadastrado, ele **estimou o custo por categoria** (flag `3. Custo Estimado por Categoria`). Isso permite calcular margem mesmo com SKUs órfãos.
> **Detalhe crítico:** 103.075 linhas (55%) têm custo estimado — não real. A margem calculada é uma aproximação.
> Nossa `v_sku_orphans` ainda é útil para o **saneamento operacional** (cadastrar os SKUs reais no Bling).

---

### P-05 — fulfillment_status 0% → Proxy via NF

| Item | Nossa solução (bi_layer) | Growth Engine do sócio |
|:---|:---|:---|
| Status de entrega | `v_pedido_status_entrega` — proxy via NF | Não presente — sem campo de fulfillment |
| Cobertura | NF_AUTORIZADA 52.3% + NF_VINCULADA 47.7% | Não cobre |

> ❌ **NÃO COBERTO.** A view do sócio não tem status de entrega/fulfillment. Nossa view `v_pedido_status_entrega` é necessária e complementar para operações/logística.

---

### P-06 — Email quality / 35.3% sem email

| Item | Nossa solução (bi_layer) | Growth Engine do sócio |
|:---|:---|:---|
| Qualidade de email | `v_contato_email_quality` — segmentação por status | Não presente — sem campo de email |
| Clientes recuperáveis | 82 identificados via Nuvemshop | Não cobre |

> ❌ **NÃO COBERTO.** A view do sócio usa `id_cliente` como identificador mas não expõe email, CPF ou dados de contato. Nossa view é necessária para CRM e recuperação de clientes.

---

## Resumo do De-Para

| Problema | Coberto pelo Sócio? | Nossas Views (bi_layer) | Status |
|:---|:---:|:---|:---:|
| P-01 Identity | ✅ **SIM** (e melhor) | `v_pedido_contato_bridge` | Redundante para vendas |
| P-02 Attribution canal | ✅ **PARCIAL** (canal, não campanha) | `v_pedido_atribuicao` | Complementar (UTM level) |
| P-03 Checkout funnel | ❌ Não | `v_checkout_pedido_bridge` | Necessária |
| P-04 SKU custo | ✅ **PARCIAL** (estimado, não real) | `v_sku_orphans` | Necessária p/ saneamento |
| P-05 Entrega | ❌ Não | `v_pedido_status_entrega` | Necessária |
| P-06 Email CRM | ❌ Não | `v_contato_email_quality` | Necessária |

---

## Campos que o Sócio Tem e Nós Não Temos

| Campo | Tipo | O que resolve |
|:---|:---|:---|
| `flag_origem_custo` | STRING | Transparência sobre qualidade do custo (real vs. estimado) |
| `custo_frete` | NUMERIC | Custo de entrega por pedido |
| `custo_impostos` | NUMERIC | Impostos calculados por item |
| `custo_taxa_gateway` | NUMERIC | Taxa do meio de pagamento |
| `custo_marketing_rateado` | FLOAT64 | Marketing rateado por item |
| `custo_operacional_rateado` | FLOAT64 | Custo operacional rateado |
| `lucro_bruto` | FLOAT64 | Lucro bruto real por item |
| `margem_liquida_final` | FLOAT64 | Margem líquida completa |
| `familia_produto` | STRING | Segmentação de família de produto |
| `potencial_recorrencia` | STRING | Score de recorrência de compra |
| `etapa_jornada_produto` | STRING | Onde o produto está na jornada |

> 💡 **Recomendação:** A `growth_engine_vendas_detalhado` deve ser a **base principal de análise financeira e de produto**. As nossas views `bi_layer` são complementares para: funil de checkout, status de entrega, qualidade de email e atribuição por campanha (UTM).

---

## Recomendação de Arquitetura Integrada

```
growth_engine_vendas_detalhado  ← base financeira (sócio)
         +
bi_layer.v_checkout_pedido_bridge  ← funil pré-pedido (nosso)
bi_layer.v_pedido_status_entrega   ← operacional/logística (nosso)
bi_layer.v_contato_email_quality   ← CRM e recuperação (nosso)
bi_layer.v_pedido_atribuicao       ← atribuição UTM/campanha (nosso)
         ↓
     customer_360 completo
```

---

## Sobre o Script ga4_recovery.py (sócio)

O script atualizado pelo seu sócio ainda **não está no repositório** (git pull retornou "Already up to date"). Assim que ele fizer o push, executarei:

```bash
pip install google-analytics-data
gcloud auth application-default login \
  --scopes=https://www.googleapis.com/auth/analytics.readonly,\
           https://www.googleapis.com/auth/cloud-platform
python scripts/ga4_recovery.py
```

Isso vai criar `analytics_recovery.ga4_recovery_costs` com `advertiserAdCost`, `Clicks` e `Impressions` — dados que vão **alimentar o `custo_marketing_rateado`** da view do sócio com dados reais de custo de mídia.
