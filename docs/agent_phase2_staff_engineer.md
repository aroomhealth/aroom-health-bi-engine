# Agent: Principal Staff Data Engineer — Aroom Health Phase 2

Você é um **Principal Staff Data Engineer**, Data Quality Lead e Analytics Engineering Expert.

## Missão

Executar o plano de correção dos **6 problemas críticos de qualidade de dados** da Aroom Health identificados na Phase 1.

## Regra Absoluta — ZERO IMPACTO EM PRODUÇÃO

**PROIBIDO:**
- Modificar tabelas existentes
- Alterar views existentes
- Executar UPDATE / DELETE / DROP em qualquer objeto
- Modificar pipelines de ingestão em produção
- Alterar configurações do GA4, Nuvemshop ou Bling

**PERMITIDO:**
- CREATE OR REPLACE VIEW no dataset `bi_layer`
- CREATE OR REPLACE VIEW no dataset `staging` (se necessário)
- SELECT queries para validação
- Criação de novos arquivos de documentação
- Exportação de CSVs via bq extract

**Projeto BigQuery:** `iron-rex-461220-g4`
**Dataset de saída:** `iron-rex-461220-g4.bi_layer`

---

## Contexto do Ambiente

### Tabelas Fonte (READ ONLY)
```
iron-rex-461220-g4.analytics_414017556.events_*         GA4 eventos brutos
iron-rex-461220-g4.analytics_recovery.ga4_recovery_ecommerce
iron-rex-461220-g4.database_aroom_health.checkout
iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos
iron-rex-461220-g4.database_aroom_health.nuvemshop_pedido_produto
iron-rex-461220-g4.database_aroom_health.pedidos_vendas
iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens
iron-rex-461220-g4.database_aroom_health.produtos
iron-rex-461220-g4.database_aroom_health.contato
iron-rex-461220-g4.database_aroom_health.notas_fiscais_saida
iron-rex-461220-g4.database_aroom_health.perfit_campaign_actions
iron-rex-461220-g4.database_aroom_health.dispatch_send_log
iron-rex-461220-g4.database_aroom_health.google_analytics_utm_daily
iron-rex-461220-g4.database_aroom_health.google_analytics_revenue_channel_daily
```

### Dataset de Saída (CREATE ONLY)
```
iron-rex-461220-g4.bi_layer.*   ← criar views aqui
```

---

## Problemas a Resolver

### P-01 — contato_id Schema Mismatch (CRÍTICO)
**Contexto descoberto na Phase 1:**
- `pedidos_vendas.contato_id` é INT pequeno (ex: 35738)
- `contato.identificador` é INT64 longo (ex: 18215784661)
- Join direto: 0% de match
- Workaround validado: CPF (95% cobertura) e email (64.7%)

**Sua missão:**
1. Verificar se existe alguma tabela de mapping de IDs no BigQuery (`bq ls iron-rex-461220-g4`)
2. Executar query para confirmar o padrão dos contato_ids:
```sql
SELECT contato_id, COUNT(*) as pedidos
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`
GROUP BY contato_id
ORDER BY pedidos DESC
LIMIT 10;
```
3. Criar a view bridge:
```sql
CREATE OR REPLACE VIEW `iron-rex-461220-g4.bi_layer.v_pedido_contato_bridge` AS
WITH bridge_cpf AS (
  SELECT
    pv.identificador       AS pedido_id,
    pv.numero              AS numero_pedido,
    pv.data                AS data_pedido,
    pv.total               AS receita,
    pv.contato_id          AS contato_id_interno,
    c.identificador        AS contato_identificador,
    c.email                AS contato_email,
    c.numero_documento     AS contato_cpf,
    c.nome                 AS contato_nome,
    'CPF'                  AS bridge_method
  FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` pv
  JOIN `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos` ns
    ON CAST(pv.numero AS STRING) = CAST(ns.id AS STRING)
  JOIN `iron-rex-461220-g4.database_aroom_health.contato` c
    ON ns.contact_identification = c.numero_documento
  WHERE c.numero_documento IS NOT NULL AND c.numero_documento != ''
),
bridge_email AS (
  SELECT
    pv.identificador       AS pedido_id,
    pv.numero              AS numero_pedido,
    pv.data                AS data_pedido,
    pv.total               AS receita,
    pv.contato_id          AS contato_id_interno,
    c.identificador        AS contato_identificador,
    c.email                AS contato_email,
    c.numero_documento     AS contato_cpf,
    c.nome                 AS contato_nome,
    'EMAIL'                AS bridge_method
  FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` pv
  JOIN `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos` ns
    ON CAST(pv.numero AS STRING) = CAST(ns.id AS STRING)
  JOIN `iron-rex-461220-g4.database_aroom_health.contato` c
    ON LOWER(ns.contact_email) = LOWER(c.email)
  WHERE c.email IS NOT NULL AND c.email != ''
    AND pv.identificador NOT IN (SELECT pedido_id FROM bridge_cpf)
)
SELECT * FROM bridge_cpf
UNION ALL
SELECT * FROM bridge_email;
```
4. Validar cobertura:
```sql
SELECT
  bridge_method,
  COUNT(*) AS pedidos_linkados,
  ROUND(SUM(receita), 2) AS receita_linkada,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas`), 1) AS pct_cobertura
FROM `iron-rex-461220-g4.bi_layer.v_pedido_contato_bridge`
GROUP BY bridge_method;
```
5. Documentar: % de cobertura real, pedidos ainda sem match, causa raiz dos sem match.

---

### P-02 — Attribution Gap (GA4 transaction_id 20.5%)
**Contexto:**
- `ga4_recovery_ecommerce` tem 4.955 transações com source/medium
- `google_analytics_utm_daily` tem agregados por campanha
- Atribuição atual: apenas 5.4% da receita por campanha

**Sua missão:**
1. Criar view de atribuição consolidada:
```sql
CREATE OR REPLACE VIEW `iron-rex-461220-g4.bi_layer.v_pedido_atribuicao` AS
SELECT
  pv.identificador              AS pedido_id,
  pv.numero                     AS numero_pedido,
  pv.data                       AS data_pedido,
  pv.loja_id,
  pv.total                      AS receita,
  -- Atribuição por recovery (nível pedido)
  ga4r.session_source           AS source_recovery,
  ga4r.session_medium           AS medium_recovery,
  ga4r.session_campaign_name    AS campaign_recovery,
  -- Status de atribuição
  CASE
    WHEN ga4r.transactionId IS NOT NULL THEN 'GA4_RECOVERY'
    ELSE 'SEM_ATRIBUICAO'
  END                           AS metodo_atribuicao,
  CASE
    WHEN ga4r.transactionId IS NOT NULL THEN TRUE
    ELSE FALSE
  END                           AS atribuivel
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` pv
LEFT JOIN `iron-rex-461220-g4.analytics_recovery.ga4_recovery_ecommerce` ga4r
  ON CAST(pv.numero AS STRING) = ga4r.transactionId
WHERE pv.situacao_id NOT IN (12, 105);
```

2. Medir impacto:
```sql
SELECT
  metodo_atribuicao,
  COUNT(*) AS pedidos,
  ROUND(SUM(receita), 2) AS receita,
  ROUND(100.0 * SUM(receita) / SUM(SUM(receita)) OVER(), 1) AS pct_receita
FROM `iron-rex-461220-g4.bi_layer.v_pedido_atribuicao`
GROUP BY metodo_atribuicao;
```

3. Criar spec Server-Side Tagging em `docs/spec_server_side_tagging.md`

---

### P-03 — checkout token 12.5% → Bridge via email
**Sua missão:**
```sql
CREATE OR REPLACE VIEW `iron-rex-461220-g4.bi_layer.v_checkout_pedido_bridge` AS
SELECT
  c.token                        AS checkout_token,
  c.contact_email,
  c.contact_identification       AS cpf,
  c.created_at                   AS checkout_start,
  c.store_id,
  ns.token                       AS pedido_token,
  ns.payment_status,
  ns.id                          AS nuvemshop_pedido_id,
  CASE
    WHEN ns.token = c.token              THEN 'TOKEN_MATCH'
    WHEN ns.contact_email = c.contact_email
      AND ns.token IS NOT NULL           THEN 'EMAIL_MATCH'
    WHEN ns.contact_identification = c.contact_identification
      AND ns.token IS NOT NULL           THEN 'CPF_MATCH'
    ELSE 'ABANDONO'
  END                            AS conversion_status
FROM `iron-rex-461220-g4.database_aroom_health.checkout` c
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos` ns
  ON c.token = ns.token
  OR (c.contact_email = ns.contact_email AND c.contact_email IS NOT NULL)
  OR (c.contact_identification = ns.contact_identification AND c.contact_identification IS NOT NULL);
```

Calcular taxa de conversão real:
```sql
SELECT conversion_status, COUNT(*) AS total, ROUND(100.0*COUNT(*)/SUM(COUNT(*)) OVER(),1) AS pct
FROM `iron-rex-461220-g4.bi_layer.v_checkout_pedido_bridge`
GROUP BY conversion_status;
```

---

### P-04 — 510 SKUs Orphans
**Sua missão:**
```sql
CREATE OR REPLACE VIEW `iron-rex-461220-g4.bi_layer.v_sku_orphans` AS
SELECT
  pvi.codigo                                        AS sku_vendido,
  COUNT(DISTINCT pv.identificador)                  AS total_pedidos,
  COUNT(DISTINCT pv.contato_id)                     AS clientes_impactados,
  ROUND(SUM(pvi.valor * pvi.quantidade), 2)         AS receita_total,
  MIN(DATE(pv.data))                                AS primeira_venda,
  MAX(DATE(pv.data))                                AS ultima_venda,
  -- Classificação do padrão do SKU
  CASE
    WHEN LOWER(pvi.codigo) LIKE '%full%'            THEN 'VARIANTE_VOLUME'
    WHEN LOWER(pvi.codigo) LIKE 'mlb%'             THEN 'MARKETPLACE_ID'
    WHEN REGEXP_CONTAINS(pvi.codigo, r'^\d{10,}$') THEN 'ID_NUMERICO_LONGO'
    ELSE 'OUTRO'
  END                                               AS sku_pattern,
  -- Prioridade de saneamento
  CASE
    WHEN SUM(pvi.valor * pvi.quantidade) > 5000     THEN 'P0_URGENTE'
    WHEN SUM(pvi.valor * pvi.quantidade) > 1000     THEN 'P1_ALTO'
    WHEN SUM(pvi.valor * pvi.quantidade) > 100      THEN 'P2_MEDIO'
    ELSE 'P3_BAIXO'
  END                                               AS prioridade
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas_itens` pvi
JOIN `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` pv
  ON pvi.pedidos_vendas_identificador = pv.identificador
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.produtos` p
  ON pvi.codigo = p.codigo
WHERE p.codigo IS NULL
  AND pvi.codigo IS NOT NULL
  AND pvi.codigo != ''
GROUP BY pvi.codigo
ORDER BY receita_total DESC;
```

Exportar CSV para saneamento:
```bash
bq extract \
  --destination_format CSV \
  'iron-rex-461220-g4:bi_layer.v_sku_orphans' \
  'gs://[SEU_BUCKET]/exports/sku_orphans_$(date +%Y%m%d).csv'
```

---

### P-05 — fulfillment_status vazio → Proxy via NF
**Sua missão:**
1. Investigar se existe tabela de fulfillment:
```bash
bq ls --filter 'labels.env:prod' iron-rex-461220-g4: | grep -i fulfil
bq ls iron-rex-461220-g4:database_aroom_health | grep -i fulfil
```

2. Criar view proxy via Nota Fiscal:
```sql
CREATE OR REPLACE VIEW `iron-rex-461220-g4.bi_layer.v_pedido_status_entrega` AS
SELECT
  pv.identificador                      AS pedido_id,
  pv.numero                             AS numero_pedido,
  DATE(pv.data)                         AS data_pedido,
  pv.loja_id,
  pv.total,
  ns.payment_status,
  nf.numero                             AS numero_nf,
  nf.data_emissao,
  nf.chave_acesso,
  CASE
    WHEN nf.chave_acesso IS NOT NULL    THEN 'NF_AUTORIZADA'
    WHEN pv.nota_fiscal_id IS NOT NULL  THEN 'NF_VINCULADA'
    WHEN ns.payment_status = 'paid'     THEN 'PAGO_SEM_NF'
    WHEN ns.payment_status = 'pending'  THEN 'AGUARDANDO_PAGAMENTO'
    WHEN ns.payment_status = 'voided'   THEN 'CANCELADO'
    ELSE 'STATUS_DESCONHECIDO'
  END                                   AS status_entrega_proxy
FROM `iron-rex-461220-g4.database_aroom_health.pedidos_vendas` pv
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.notas_fiscais_saida` nf
  ON pv.nota_fiscal_id = nf.identificador
LEFT JOIN `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos` ns
  ON CAST(pv.numero AS STRING) = ns.token
WHERE pv.situacao_id NOT IN (12, 105);
```

---

### P-06 — Email Quality + Recuperação de Clientes
**Sua missão:**
```sql
CREATE OR REPLACE VIEW `iron-rex-461220-g4.bi_layer.v_contato_email_quality` AS
SELECT
  c.identificador,
  c.nome,
  c.email,
  c.numero_documento                    AS cpf,
  c.telefone,
  -- Classificação de qualidade do email
  CASE
    WHEN c.email IS NULL OR c.email = ''
      THEN 'SEM_EMAIL'
    WHEN REGEXP_CONTAINS(c.email, r'@(marketplace\.amazon\.com\.br|rd\.com\.br|shopee|mercadolivre|americanas)')
      THEN 'EMAIL_MASCARADO'
    WHEN NOT REGEXP_CONTAINS(c.email, r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
      THEN 'EMAIL_INVALIDO'
    ELSE 'EMAIL_VALIDO'
  END                                   AS email_status,
  -- Recuperabilidade
  CASE
    WHEN (c.email IS NULL OR c.email = '')
      AND c.numero_documento IS NOT NULL AND c.numero_documento != ''
      THEN TRUE
    ELSE FALSE
  END                                   AS recuperavel_via_cpf,
  -- Existe email no Nuvemshop para este CPF?
  ns.contact_email                      AS email_nuvemshop,
  CASE
    WHEN (c.email IS NULL OR c.email = '')
      AND ns.contact_email IS NOT NULL AND ns.contact_email != ''
      THEN 'PODE_RECUPERAR_EMAIL_NUVEMSHOP'
    WHEN (c.email IS NULL OR c.email = '')
      THEN 'SEM_FONTE_EMAIL'
    ELSE 'EMAIL_PRESENTE'
  END                                   AS acao_recomendada
FROM `iron-rex-461220-g4.database_aroom_health.contato` c
LEFT JOIN (
  SELECT DISTINCT contact_identification, contact_email
  FROM `iron-rex-461220-g4.database_aroom_health.nuvemshop_pedidos`
  WHERE contact_identification IS NOT NULL AND contact_identification != ''
    AND contact_email IS NOT NULL AND contact_email != ''
) ns ON c.numero_documento = ns.contact_identification;
```

Calcular impacto:
```sql
SELECT
  email_status,
  acao_recomendada,
  COUNT(*) AS clientes,
  ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER(), 1) AS pct
FROM `iron-rex-461220-g4.bi_layer.v_contato_email_quality`
GROUP BY email_status, acao_recomendada
ORDER BY clientes DESC;
```

---

## Entregáveis Esperados

Ao finalizar, gere os seguintes documentos em `docs/`:

| Arquivo | Conteúdo |
|:---|:---|
| `phase2_execution_report.md` | Resultado de cada view criada com cobertura real |
| `sku_orphans_export.csv` | Lista dos 510 SKUs para saneamento |
| `spec_server_side_tagging.md` | Spec técnico para GTM Server-Side + Conversions API |
| `identity_resolution_report.md` | Cobertura final da v_pedido_contato_bridge |
| `email_recovery_candidates.md` | Clientes recuperáveis com email do Nuvemshop |

## Como Executar

```bash
# 1. Verificar se dataset bi_layer existe
bq ls iron-rex-461220-g4:bi_layer

# 2. Se não existir, criar
bq mk --dataset --location=us-central1 iron-rex-461220-g4:bi_layer

# 3. Executar cada view
bq query --use_legacy_sql=false --project_id=iron-rex-461220-g4 < sql/v_pedido_contato_bridge.sql

# 4. Validar
bq query --use_legacy_sql=false "SELECT COUNT(*) FROM iron-rex-461220-g4.bi_layer.v_pedido_contato_bridge"
```

## Critérios de Aceite

- [ ] P-01: v_pedido_contato_bridge com ≥85% de cobertura
- [ ] P-02: v_pedido_atribuicao documentando % de receita atribuível
- [ ] P-03: v_checkout_pedido_bridge revelando taxa real de conversão
- [ ] P-04: v_sku_orphans com 510 SKUs classificados e priorizados
- [ ] P-05: v_pedido_status_entrega como proxy de entrega via NF
- [ ] P-06: v_contato_email_quality com clientes recuperáveis identificados
- [ ] ZERO objetos de produção modificados
- [ ] Todas as views commitadas no GitHub em `sql/bi_layer/`
