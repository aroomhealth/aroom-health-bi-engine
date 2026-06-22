# Architecture Assessment — Aroom Health BI Engine
**Versão:** 1.0 | **Data:** 22/06/2026 | **Autor:** Principal Staff Data Architect

---

## Score Geral de Arquitetura: 58/100

| Dimensão | Score | Peso | Nota |
|:---|:---:|:---:|:---|
| Completude de Dados (volume/cobertura) | 72/100 | 25% | Bling completo; GA4 parcial |
| Qualidade de Identidade | 41/100 | 25% | Schema mismatch crítico; email fill baixo |
| Atribuição de Marketing | 32/100 | 20% | GA4 apenas 20.5% cobertura |
| Rastreabilidade de SKU | 61/100 | 15% | 510 SKUs faltantes / 51.7% sem código |
| Governança e Documentação | 78/100 | 15% | Bem documentado; gaps conhecidos |

---

## Riscos Críticos (P0)

### RISCO-01 — Schema Mismatch contato_id (BLOQUEANTE)
**Severidade:** CRÍTICO  
**Impacto:** 100% dos pedidos Bling sem link direto ao cliente Bling por ID  
**Causa:** `pedidos_vendas.contato_id` (INT32 pequeno, ex: 35738) é incompatível com `contato.identificador` (INT64 longo, ex: 18215784661). São dois schemas de IDs diferentes — o `contato_id` possivelmente aponta para uma tabela interna do Bling não sincronizada no BigQuery.  
**Workaround atual:** JOIN via email ou CPF (64.7% e 95.0% cobertura respectivamente)  
**Solução:** Investigar API Bling para mapear contato_id → identificador público, ou criar tabela de-para manualmente.

### RISCO-02 — GA4 Attribution Gap (ALTO)
**Severidade:** ALTO  
**Impacto:** 79.5% da receita do site sem atribuição de campanha  
**Causa:** AdBlock + ITP (Intelligent Tracking Prevention) bloqueiam o evento `purchase` do GA4 antes de enviar `transaction_id`  
**Solução:** Implementar GA4 via Google Tag Manager Server-Side + Conversions API (Meta/Google)

### RISCO-03 — 35.3% Clientes Sem Email (ALTO)
**Severidade:** ALTO  
**Impacto:** 42.588 clientes Bling não alcançáveis por email marketing  
**Causa:** Clientes de marketplaces (ML, Amazon, Shopee) entram com email mascarado ou sem email  
**Solução:** Coleta de email no pós-venda + enriquecimento via CRM

---

## Riscos Moderados (P1)

| Risco | Impacto | Causa | Solução |
|:---|:---|:---|:---|
| fulfillment_status 0% | Sem rastreio de entrega no backend | Campo não preenchido pelo Nuvemshop | Ativar webhook de fulfillment |
| produtos.codigo 51.7% vazio | Análise de SKU limitada | Cadastro opcional no Bling | Tornar campo obrigatório |
| checkout→nuvemshop 12.5% | Funil de conversão opaco | Lógica de token pode mudar | Investigar geração do token |
| perfit cobre só Mar/2026+ | Histórico email ausente | Pipeline de ingestão recente | Re-ingerir histórico da API Perfit |

---

## O que Funciona Bem

| Aspecto | Status | Evidência |
|:---|:---|:---|
| Faturamento consolidado Bling | ✅ Confiável | R$ 9.538.019 / 130.135 pedidos |
| Bridge Nuvemshop → Bling | ✅ Confiável | store_id = loja_id / R$ 2.85M confirmado |
| NF vinculada ao pedido | ✅ Quase perfeito | 99.99% cobertura |
| CPF como identidade | ✅ Robusto | 95% dos contatos com CPF |
| Email CRM (Perfit) | ✅ Funcional | 75% match com base Bling |
| Customer Intelligence pipeline | ✅ Operacional | Datasets customer_intelligence / ml ativos |
| Documentação de arquitetura | ✅ Evoluindo | Phase 1 concluída com 5 entregáveis |

---

## Roadmap de Correção (Phase 2)

### Sprint 1 — Identity (prioridade máxima)
- [ ] Investigar mapping `contato_id` → `identificador` via API Bling
- [ ] Criar view `v_pedido_contato` usando CPF como bridge principal
- [ ] Documentar workaround email/CPF no dbt ou SQL Views

### Sprint 2 — Attribution
- [ ] Implementar GA4 Server-Side Tagging via GTM Server
- [ ] Configurar Google Conversions API
- [ ] Configurar Meta Conversions API (CAPI)
- [ ] Meta: adicionar `order_id` no pixel de Purchase

### Sprint 3 — SKU + Catálogo
- [ ] Auditar 510 SKUs faltantes e criar plano de cadastro
- [ ] Criar regra de validação: `pedidos_vendas_itens.codigo` deve existir em `produtos`
- [ ] Forçar preenchimento de `produtos.codigo` no processo de cadastro

### Sprint 4 — Backend Completeness
- [ ] Ativar fulfillment webhook Nuvemshop → BigQuery
- [ ] Investigar token checkout → nuvemshop (gap de 87.5%)
- [ ] Re-ingerir histórico Perfit (pré-Março/2026)

---

## Arquitetura Alvo (Phase 2)

```
[Google/Meta Ads] ──UTM──→ [GTM Server-Side] ──→ [GA4 Nativo]
                                    │
                              Server-Side
                              event_purchase
                              com transaction_id
                              GARANTIDO (100%)
                                    │
                                    ▼
[Checkout Nuvemshop] ──→ [Bling ERP] ──→ [BigQuery Raw Layer]
                                                    │
                              ┌─────────────────────┤
                              ▼                     ▼
                    [dbt Transform Layer]    [Customer Intelligence]
                    v_cliente_360            customer_360
                    v_pedido_atribuido       rfm_segments
                    v_sku_margem             churn_risk
                              │
                              ▼
                    [Looker Studio Dashboards]
                    Marketing ROAS
                    Customer Lifetime Value
                    DRE Gerencial
                    Funil de Conversão
```
