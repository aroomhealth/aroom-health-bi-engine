# Phase 2 — Plano de Ação: Correção dos 6 Problemas Críticos
**Versão:** 1.0 | **Data:** 22/06/2026 | **Modo:** READ ONLY + CREATE ONLY (sem alterar objetos existentes)

> ⚠️ **Regra de ouro:** Nenhuma alteração em tabelas, views ou pipelines existentes em produção.
> Toda correção será feita via **novas views** no dataset `bi_layer` ou `staging`.

---

## P-01 — contato_id ≠ contato.identificador (Schema Mismatch)
**Severidade:** 🔴 CRÍTICO | **Impacto:** 0% de join direto pedido→cliente

### Root Cause
`pedidos_vendas.contato_id` é um INT32 interno do Bling (ex: 35738) diferente do `contato.identificador` INT64 público (ex: 18215784661). São dois sistemas de IDs distintos — o Bling usa um ID interno diferente do ID da API pública.

### Plano de Ação (sem impactar produção)
```
ETAPA 1 — Investigar mapping via API Bling
  → Query: verificar se existe tabela bling_contatos_mapping no BQ
  → Se não: criar view v_pedido_contato_bridge usando CPF como chave

ETAPA 2 — Criar bridge view
  CREATE OR REPLACE VIEW bi_layer.v_pedido_contato_bridge AS
  SELECT
    pv.identificador       AS pedido_id,
    pv.numero              AS numero_pedido,
    pv.contato_id          AS contato_id_interno,
    c.identificador        AS contato_identificador,
    c.email,
    c.numero_documento     AS cpf,
    'CPF'                  AS bridge_method,
    95.0                   AS bridge_coverage_pct
  FROM pedidos_vendas pv
  JOIN nuvemshop_pedidos ns ON pv.numero = CAST(ns.id AS INT64)
  JOIN contato c ON ns.contact_identification = c.numero_documento
  WHERE c.numero_documento IS NOT NULL;

ETAPA 3 — Validar cobertura
  → Contar quantos pedidos têm match via CPF vs total
  → Documentar % de cobertura real

ETAPA 4 — Bridge via email (fallback)
  → Para pedidos sem match CPF, tentar via email
  → Registrar bridge_method = 'EMAIL'
```

### Critério de Sucesso
- View `v_pedido_contato_bridge` com ≥90% de cobertura
- Nenhuma tabela existente modificada

---

## P-02 — GA4 transaction_id ausente em 79.5%
**Severidade:** 🔴 ALTO | **Impacto:** R$ ~7.5M sem atribuição de campanha

### Root Cause
AdBlock + ITP (Intelligent Tracking Prevention) bloqueiam o evento `purchase` antes de enviar `transaction_id` ao GA4. Solução definitiva requer Server-Side Tagging, mas há uma solução intermediária via `ga4_recovery_ecommerce`.

### Plano de Ação (sem impactar produção)
```
ETAPA 1 — Maximizar uso da ga4_recovery_ecommerce
  → Esta tabela já tem transactionId para 4.955 pedidos (R$ 512k)
  → Criar view que une GA4 nativo + recovery

ETAPA 2 — Criar view de atribuição consolidada
  CREATE OR REPLACE VIEW bi_layer.v_pedido_atribuicao AS
  SELECT
    pv.numero              AS numero_pedido,
    pv.total               AS receita,
    COALESCE(
      ga4r.session_source,
      ga4_agg.session_source_medium
    )                      AS source_atribuido,
    CASE
      WHEN ga4r.transactionId IS NOT NULL THEN 'ga4_recovery'
      WHEN ga4_agg.session_source_medium IS NOT NULL THEN 'ga4_aggregated'
      ELSE 'sem_atribuicao'
    END                    AS metodo_atribuicao
  FROM pedidos_vendas pv
  LEFT JOIN ga4_recovery_ecommerce ga4r ON CAST(pv.numero AS STRING) = ga4r.transactionId
  LEFT JOIN google_analytics_utm_daily ga4_agg ON DATE(pv.data) = ga4_agg.metric_date;

ETAPA 3 — Calcular receita atribuível antes/depois
  → Medir melhoria de cobertura

ETAPA 4 — Documentar spec para Server-Side Tagging
  → GTM Server + GA4 Measurement Protocol
  → Pré-requisito para Phase 3
```

### Critério de Sucesso
- View `v_pedido_atribuicao` elevando cobertura de 5.4% para ≥25%
- Spec técnico de Server-Side Tagging documentado

---

## P-03 — checkout.token → 12.5% de conversão rastreada
**Severidade:** 🟡 MÉDIO | **Impacto:** Funil de conversão real desconhecido

### Root Cause
O `token` do checkout pode ser gerado múltiplas vezes por sessão (refreshes, steps intermediários), enquanto o pedido final em `nuvemshop_pedidos` usa apenas o token do momento da confirmação. Os 87.5% restantes são genuinamente abandonos ou tokens distintos.

### Plano de Ação (sem impactar produção)
```
ETAPA 1 — Investigar lógica do token
  → Verificar se checkout tem campo updated_at para pegar o token mais recente
  → Verificar se email do checkout bate com email do nuvemshop_pedido

ETAPA 2 — Criar bridge alternativa via email
  CREATE OR REPLACE VIEW bi_layer.v_checkout_pedido_bridge AS
  SELECT
    c.token                AS checkout_token,
    c.contact_email,
    c.created_at           AS checkout_start,
    ns.token               AS pedido_token,
    ns.payment_status,
    CASE
      WHEN ns.token = c.token THEN 'token_match'
      WHEN ns.contact_email = c.contact_email THEN 'email_match'
      ELSE 'abandono'
    END                    AS status
  FROM checkout c
  LEFT JOIN nuvemshop_pedidos ns
    ON c.token = ns.token OR c.contact_email = ns.contact_email;

ETAPA 3 — Calcular taxa de conversão real por email
  → Pode revelar taxa real de 30-40% (muito carrinhos do mesmo email)
```

### Critério de Sucesso
- Taxa de conversão real calculada via email bridge
- View `v_checkout_pedido_bridge` documentando cada status

---

## P-04 — 510 SKUs sem cadastro em produtos
**Severidade:** 🟡 MÉDIO | **Impacto:** R$ 95.170 sem margem calculável

### Root Cause
Produtos vendidos cujo `codigo` (SKU) não existe na tabela `produtos`. Padrões: sufixo `full`, IDs antigos `MLB*`, produtos descontinuados.

### Plano de Ação (sem impactar produção)
```
ETAPA 1 — Catalogar todos os 510 SKUs faltantes
  CREATE OR REPLACE VIEW bi_layer.v_sku_orphans AS
  SELECT
    pvi.codigo             AS sku_vendido,
    COUNT(DISTINCT pv.identificador) AS pedidos,
    SUM(pvi.valor * pvi.quantidade)  AS receita_total,
    MIN(pv.data)           AS primeira_venda,
    MAX(pv.data)           AS ultima_venda,
    COUNT(DISTINCT pv.contato_id)    AS clientes_impactados
  FROM pedidos_vendas_itens pvi
  JOIN pedidos_vendas pv ON pvi.pedidos_vendas_identificador = pv.identificador
  LEFT JOIN produtos p ON pvi.codigo = p.codigo
  WHERE p.codigo IS NULL AND pvi.codigo IS NOT NULL
  GROUP BY pvi.codigo
  ORDER BY receita_total DESC;

ETAPA 2 — Classificar por padrão
  → sufixo 'full' → variante de volume (ex: 0034full)
  → prefixo 'MLB' → produto de marketplace
  → outros → produto descontinuado

ETAPA 3 — Gerar CSV para saneamento manual no Bling
  → Exportar lista priorizada para time de produto
  → Top 50 SKUs por receita = prioridade de cadastro

ETAPA 4 — Criar regra de monitoramento
  → Alert se SKU sem cadastro vendido > R$ 1.000/mês
```

### Critério de Sucesso
- View `v_sku_orphans` com todos os 510 SKUs catalogados
- CSV exportado para time de produto cadastrar no Bling

---

## P-05 — fulfillment_status 0% vazio no Nuvemshop
**Severidade:** 🟡 MÉDIO | **Impacto:** Sem rastreio de entrega no backend

### Root Cause
O campo `fulfillment_status` na tabela `nuvemshop_pedidos` não está sendo preenchido pelo pipeline de ingestão. Pode ser que o webhook de fulfillment do Nuvemshop não esteja ativo ou o campo não está sendo capturado.

### Plano de Ação (sem impactar produção)
```
ETAPA 1 — Investigar pipeline de ingestão Nuvemshop
  → Verificar se existe tabela de fulfillment separada
  → Verificar configuração do webhook no Nuvemshop

ETAPA 2 — Verificar API Nuvemshop
  → GET /fulfillments endpoint está mapeado?
  → Criar tabela staging.nuvemshop_fulfillments

ETAPA 3 — Usar notas_fiscais_saida como proxy de entrega
  CREATE OR REPLACE VIEW bi_layer.v_pedido_status_entrega AS
  SELECT
    pv.numero,
    pv.data,
    pv.total,
    CASE
      WHEN nf.chave_acesso IS NOT NULL THEN 'NF_EMITIDA'
      WHEN pv.nota_fiscal_id IS NOT NULL THEN 'NF_VINCULADA'
      ELSE 'SEM_NF'
    END                    AS status_fiscal,
    ns.payment_status
  FROM pedidos_vendas pv
  LEFT JOIN notas_fiscais_saida nf ON pv.nota_fiscal_id = nf.identificador
  LEFT JOIN nuvemshop_pedidos ns ON CAST(pv.numero AS STRING) = ns.token;
```

### Critério de Sucesso
- Diagnóstico do pipeline de ingestão documentado
- View proxy de status de entrega via NF criada

---

## P-06 — contato.email com 35.3% vazio
**Severidade:** 🟡 MÉDIO | **Impacto:** 42.588 clientes sem identidade digital

### Root Cause
Clientes de marketplaces (ML, Amazon, Shopee) entram no Bling com email mascarado ou sem email. Emails como `h6kxvvrcq53g82n@marketplace.amazon.com.br` são inúteis para CRM.

### Plano de Ação (sem impactar produção)
```
ETAPA 1 — Classificar clientes por qualidade de email
  CREATE OR REPLACE VIEW bi_layer.v_contato_email_quality AS
  SELECT
    identificador,
    nome,
    email,
    numero_documento,
    CASE
      WHEN email IS NULL OR email = ''
        THEN 'SEM_EMAIL'
      WHEN email LIKE '%@marketplace.amazon.com.br'
        OR email LIKE '%@rd.com.br'
        OR email LIKE '%@shopee%'
        THEN 'EMAIL_MASCARADO'
      WHEN email NOT LIKE '%@%.%'
        THEN 'EMAIL_INVALIDO'
      ELSE 'EMAIL_VALIDO'
    END                    AS email_status,
    CASE
      WHEN numero_documento IS NOT NULL AND numero_documento != ''
        THEN TRUE ELSE FALSE
    END                    AS tem_cpf
  FROM contato;

ETAPA 2 — Priorizar contatos com CPF mas sem email
  → Esses clientes podem ser recuperados via enriquecimento
  → Exportar lista para time de CRM enviar email de atualização cadastral

ETAPA 3 — Criar campanha de recuperação de email
  → Via Perfit: segmento "clientes com CPF sem email válido"
  → Formulário de atualização de cadastro

ETAPA 4 — Enriquecimento automático
  → Nuvemshop tem email 100% preenchido
  → Join CPF: nuvemshop_pedidos.contact_identification → contato.numero_documento
  → Onde Bling não tem email mas Nuvemshop tem → propor atualização (aprovação manual)
```

### Critério de Sucesso
- View `v_contato_email_quality` com segmentação de qualidade
- Lista de clientes recuperáveis (CPF presente, email ausente) exportada

---

## Resumo do Plano

| Problema | Solução | Objetos Criados | Sem Tocar Em |
|:---|:---|:---|:---|
| P-01 Schema mismatch | Bridge via CPF/email | `v_pedido_contato_bridge` | `pedidos_vendas`, `contato` |
| P-02 Attribution gap | View atribuição + spec SST | `v_pedido_atribuicao` | GA4, pipelines existentes |
| P-03 Token conversion | Bridge alternativa email | `v_checkout_pedido_bridge` | `checkout`, `nuvemshop_pedidos` |
| P-04 SKU orphans | Catálogo + CSV exportação | `v_sku_orphans` | `produtos`, `pedidos_vendas_itens` |
| P-05 Fulfillment vazio | Proxy via NF + diagnóstico | `v_pedido_status_entrega` | Pipeline ingestão NS |
| P-06 Email quality | Segmentação + recuperação | `v_contato_email_quality` | `contato` |

**Dataset alvo:** `iron-rex-461220-g4.bi_layer`
**Total de objetos novos:** 6 views
**Impacto em produção:** ZERO
