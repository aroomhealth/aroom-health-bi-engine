# Customer Identity Map — Aroom Health
**Versão:** 1.0 | **Data:** 22/06/2026 | **Modo:** READ ONLY

---

## 1. Onde a Identidade Nasce

```
PONTO DE ENTRADA          IDENTIDADE GERADA              TABELA
─────────────────────────────────────────────────────────────────────
Google/Meta Ads clica     user_pseudo_id (cookie GA4)    analytics_414017556.events_*
                          traffic_source.{source,medium,campaign}

Usuário preenche checkout contact_email                  checkout.contact_email
                          contact_identification (CPF)   checkout.contact_identification
                          token (ID carrinho)            checkout.token
                          shipping_zipcode               checkout.shipping_zipcode

Pedido confirmado NS      customer_id (ID Nuvemshop)    nuvemshop_pedidos.customer_id
                          token (persiste do checkout)   nuvemshop_pedidos.token
                          CPF confirmado                 nuvemshop_pedidos.contact_identification

Pedido entra no Bling     identificador (PK longo)       contato.identificador
                          contato_id (INT pequeno)       pedidos_vendas.contato_id
                          numero (numero do pedido)      pedidos_vendas.numero

NF emitida                chave_acesso (44 dígitos)      notas_fiscais_saida.chave_acesso
                          numero NF                      notas_fiscais_saida.numero
```

---

## 2. Mapa de Identidades por Etapa

| Etapa | Identificador Disponível | Tipo | Persistência | Confiança |
|:---|:---|:---|:---|:---|
| 1. Clique no Ads | `user_pseudo_id` | Cookie anônimo | Sessão/dispositivo | BAIXA — perde cross-device |
| 2. Landing Page | `user_pseudo_id` + UTMs | Cookie + URL param | Sessão | MÉDIA |
| 3. Checkout aberto | `token` + `contact_email` + CPF | Gerado no momento | Por carrinho | ALTA — 100% fill |
| 4. Pedido Nuvemshop | `customer_id` + `token` + `contact_email` | Nuvemshop ID | Por cliente | ALTA |
| 5. Pedido Bling | `contato_id` (INT) + `numero` | Bling ID | Por pedido | ALTA — mas `contato_id` incompatível |
| 6. Contato Bling | `identificador` (INT64 longo) | Bling PK | Por cliente | ALTA — mas sem email em 35.3% |
| 7. Email CRM (Perfit) | `contact_email` | Email | Por campanha | ALTA — 75% match com Bling |
| 8. Dispatch automação | `contact_id` (INT) | FK direta | Por envio | ALTA — 100% fill |

---

## 3. Onde a Identidade Muda ou é Perdida

### ⚠️ PROBLEMA CRÍTICO #1 — contato_id vs identificador (schema mismatch)

```
pedidos_vendas.contato_id = 35738           (INT32 pequeno)
contato.identificador    = 18215784661      (INT64 longo)

JOIN NÃO FUNCIONA → 0% de match direto.

Causa: contato_id em pedidos_vendas aponta para uma tabela interna
       do Bling que não é a tabela contato sincronizada no BigQuery.
       Pode ser um ID interno do Bling diferente do identificador público.

Impacto: IMPOSSÍVEL fazer join direto pedido → cliente via ID.
Workaround: usar contact_email como bridge intermediária.
```

### ⚠️ PROBLEMA CRÍTICO #2 — user_pseudo_id não persiste

```
GA4.user_pseudo_id = cookie anônimo por dispositivo.

Não existe campo que ligue user_pseudo_id ao email do cliente.
Não existe campo que ligue user_pseudo_id ao contato_id do Bling.

Consequência: um usuário que visita, adiciona ao carrinho e compra
em dispositivos diferentes gera múltiplos user_pseudo_id sem conexão.

Impacto: impossível reconhecer o mesmo usuário em múltiplas visitas
         sem login, afetando análise de touchpoints pré-conversão.
```

### ⚠️ PROBLEMA CRÍTICO #3 — transaction_id ausente em 79.5% dos purchases

```
GA4.event_params[transaction_id] preenchido: ~20.5% dos pedidos
Ausente: ~79.5%

Causa: AdBlock / Intelligent Tracking Prevention / cookies bloqueados
       impedem que o GA4 registre o evento purchase com transaction_id.

Consequência: não é possível atribuir origem de marketing para
              79.5% da receita do site próprio.
```

### ⚠️ PROBLEMA #4 — checkout token converte apenas 12.5%

```
checkout (carrinhos abertos):        2.568 tokens únicos
nuvemshop_pedidos (tokens matching):   320 tokens

Taxa de conversão rastreada: 12.5%

Interpretação:
- 320 carrinhos (12.5%) confirmadamente viraram pedido (token match)
- 2.248 carrinhos (87.5%) não têm correspondência no nuvemshop_pedidos

Possíveis causas:
  a) Checkout captura sessões de navegação antes do pedido ser criado
  b) Token muda entre checkout e pedido final
  c) Pedidos criados em outros canais (app mobile, WhatsApp) sem checkout web
  d) Carrinhos genuinamente abandonados (mais provável)
```

### ⚠️ PROBLEMA #5 — 35.3% dos contatos sem email

```
contato sem email: 42.588 de 120.479 (35.3%)
contato sem CPF:    6.068 de 120.479  (5.0%)
contato sem tel:   79.810 de 120.479 (66.2%)

Causa: clientes de marketplaces (ML, Shopee, Amazon) entram no Bling
       com email mascarado (ex: h6kxvvrcq53g82n@marketplace.amazon.com.br)
       ou sem email algum, impossibilitando o enriquecimento digital.

Impacto: ~42k clientes não podem receber campanhas Perfit ou ser
         identificados no GA4 via email.
```

### ⚠️ PROBLEMA #6 — produtos.codigo com 51.7% vazio

```
produtos com codigo preenchido: 4.710 de 9.751 (48.3%)
produtos sem codigo:            5.041 de 9.751 (51.7%)

Causa: produtos criados no Bling sem código SKU obrigatório.
       Esses produtos não têm join possível com pedidos_vendas_itens.codigo.

Impacto: mais de metade do catálogo não pode ser cruzado
         com vendas por SKU para análise de margem e giro.
```

---

## 4. Mapa de Resolução de Identidade — Campo a Campo

```
IDENTIDADE DIGITAL (GA4)          →  IDENTIDADE TRANSACIONAL (Bling)
──────────────────────────────────────────────────────────────────────

user_pseudo_id                     ✗ SEM BRIDGE (cookie anônimo)
  │
  ├─ transaction_id (20.5%)        → pedidos_vendas.numero  ✓ [MÉDIA]
  │
  └─ traffic_source.source/medium  → (atribuição agregada apenas)

checkout.contact_email (100%)      → contato.email          ✓ [ALTA, mas 35.3% sem email]
checkout.contact_identification    → contato.numero_documento ✓ [ALTA]
checkout.token (100%)              → nuvemshop_pedidos.token ✓ [ALTA, 12.5% conversão]

nuvemshop_pedidos.customer_id      ✗ SEM BRIDGE (ID não existe no Bling)
nuvemshop_pedidos.store_id         → pedidos_vendas.loja_id ✓ [ALTA - nível canal, não pedido]
nuvemshop_pedidos.contact_email    → contato.email          ✓ [ALTA]
nuvemshop_pedidos.contact_identification → contato.numero_documento ✓ [ALTA]

pedidos_vendas.contato_id          ✗ SEM BRIDGE (schema incompatível com contato.identificador)
pedidos_vendas.numero              → ga4_recovery_ecommerce.transactionId ✓ [MÉDIA, 20.5%]

perfit.contact_email               → contato.email          ✓ [ALTA, 75%]
dispatch_log.contact_id            → contato.identificador  ✗ SEM BRIDGE (mesmo problema schema)
```

---

## 5. Workarounds Possíveis para Identity Resolution

### Workaround 1 — Email como backbone de identidade
```sql
-- Bridge: nuvemshop_pedidos → contato via email
SELECT ns.*, c.identificador AS bling_contato_id
FROM nuvemshop_pedidos ns
JOIN contato c ON LOWER(ns.contact_email) = LOWER(c.email)
-- Cobertura: ~64.7% dos contatos têm email
```

### Workaround 2 — CPF como backbone de identidade
```sql
-- Bridge: nuvemshop_pedidos → contato via CPF (mais robusto)
SELECT ns.*, c.identificador AS bling_contato_id
FROM nuvemshop_pedidos ns
JOIN contato c ON ns.contact_identification = c.numero_documento
-- Cobertura: 95% dos contatos têm CPF
```

### Workaround 3 — contato_id via tabela intermediária
```
pedidos_vendas.contato_id (INT pequeno)
→ JOIN com tabela interna Bling (contato_id mapping)
→ Needs validation: verificar se existe tabela de_para de IDs
```

---

## 6. Diagrama de Identidade

```
MUNDO DIGITAL                     MUNDO TRANSACIONAL
─────────────────────────────────────────────────────

[GA4 Cookie]                      [Bling Contato]
user_pseudo_id                    identificador (INT64)
    │                                    ▲
    │ SEM BRIDGE DIRETA                  │ via email/CPF
    │                                    │
[Checkout Web]                    [Nuvemshop Pedidos]
contact_email ──────────────────→ contact_email
contact_identification (CPF) ───→ contact_identification
token ──────────────────────────→ token (12.5% converte)
    │                                    │ store_id = loja_id
    │                                    ▼
[GA4 Purchase Event]              [Bling Pedidos]
transaction_id (20.5%) ─────────→ numero
    │                             contato_id ✗ (schema mismatch)
    │                                    │
    │                                    ▼
[Email CRM - Perfit]              [Bling Contato]
contact_email ──────────────────→ email (75% match)
    │
[Dispatch Automações]
contact_id → ? (schema mismatch com identificador)
```
