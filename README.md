# Aroom Health BI Engine & Analytics Governance

Este repositório contém a definição oficial, versionada e auditada da camada analítica do GCP / BigQuery para a **Aroom Health**.

O objetivo é garantir a integridade dos dados de vendas, manter rastreabilidade de marketing (ROAS), consolidar dados de todos os canais e gerenciar mudanças de forma segura com versionamento completo.

---

## 📂 Estrutura do Repositório

```text
aroom-health-bi-engine/
├── README.md
├── docs/
│   ├── business_rules.md                  # Regras de negócio e métricas SmartMetrics
│   ├── architecture.md                    # Arquitetura completa dos datasets e fluxo de dados
│   ├── data_dictionary.md                 # Dicionário de dados da view de vendas
│   ├── google_ads_pipeline_issue.md       # Diagnóstico e recuperação do Google Ads (DTS)
│   ├── ga4_recovery_report.md             # Relatório de recuperação histórica do GA4 (182 dias)
│   └── roas_tracking_strategy.md          # Estratégia de rastreamento UTM com Bling
├── sql/
│   ├── production/
│   │   ├── growth_engine_vendas_detalhado.sql         # View principal de vendas (auditada)
│   │   ├── marketing_attribution/
│   │   │   ├── v_pedidos_com_origem.sql               # Pedidos Bling com canal de origem GA4
│   │   │   ├── v_roas_por_campanha.sql                # ROAS diário por campanha Google Ads
│   │   │   ├── v_resumo_canais_marketing.sql          # Share de receita por canal
│   │   │   └── campaign_name_mapping.sql              # Tabela de-para Google Ads ↔ GA4 UTM
│   │   └── legado/
│   │       ├── v_legado_vendas.sql                    # Pedidos brutos ML/Nuvemshop/Shopee
│   │       ├── v_legado_clientes.sql                  # Base unificada de clientes (Customer 360)
│   │       ├── v_legado_produtos.sql                  # Catálogo com margem bruta por produto
│   │       ├── v_legado_marketing.sql                 # Ads consolidados: Meta/ML/Shopee/TikTok/Google
│   │       ├── v_legado_financeiro.sql                # DRE: contas pagar + receber
│   │       ├── v_legado_expedicao.sql                 # Tracking logístico unificado
│   │       └── v_legado_estoque.sql                   # Posição de estoque com valor e status
│   ├── staging/
│   │   └── growth_engine_vendas_detalhado_staging.sql
│   └── tests/
│       ├── revenue_validation.sql
│       ├── duplicate_check.sql
│       ├── null_category_check.sql
│       └── item_granularity_check.sql
├── deployment/
│   ├── deploy_view.sql
│   ├── rollback.sql
│   └── validation_checklist.md
├── governance/
│   ├── change_log.md                      # ← Registro de todas as versões e alterações
│   ├── approval_process.md
│   └── ownership_matrix.md
└── roadmap/
    ├── phase_1_version_control.md
    ├── phase_2_google_ads_recovery.md
    ├── phase_3_roas_model.md
    └── phase_4_smartmetrics_feature_layer.md
```

---

## 🗄️ Datasets no BigQuery

| Dataset | Região | Propósito |
| :--- | :--- | :--- |
| `database_aroom_health` | us-central1 | Fonte de verdade — ERP Bling, Nuvemshop, Marketplaces |
| `analytics_414017556` | us-central1 | GA4 nativo (dados recentes) |
| `analytics_recovery` | us-central1 | GA4 histórico recuperado via API (182 dias) |
| `google_ads` | us-central1 | Google Ads via Data Transfer Service (DTS) — 531 dias |
| `marketing_attribution` | us-central1 | Modelo de ROAS e atribuição de marketing |
| `legado` | us-central1 | Views consolidadas das fontes secundárias de dados |

---

## 🛠️ Tecnologias Utilizadas

* **Google BigQuery:** Data Warehouse serverless — todos os datasets e views.
* **BigQuery Data Transfer Service (DTS):** Ingestão automática do Google Ads.
* **GA4 / Google Analytics 4:** Rastreamento de origem de tráfego e ecommerce.
* **Bling ERP:** Sistema de pedidos, produtos, estoque e financeiro.
* **Nuvemshop / Mercado Livre / Shopee / Amazon:** Canais de venda integrados ao Bling via `loja_id`.
* **Meta Ads / TikTok Ads:** Canais de mídia paga adicionais (dados em `legado.v_legado_marketing`).
* **Looker Studio:** Camada de visualização conectada às views do BigQuery.
* **Git & GitHub:** Versionamento, revisão e governança de código.

---

## 🔄 Fluxo de Trabalho e Implantação

1. **Alterações:** Nunca altere regras de negócio diretamente no BigQuery sem registrar aqui.
2. **Desenvolvimento:** Crie uma branch a partir de `dev` (ex: `feature/nova-dimensao`).
3. **Validação:** Implante na view de staging e execute todos os scripts em `/sql/tests/`.
4. **Pull Request:** Abra PR apontando para `dev` → `main`. Siga o [Processo de Aprovação](governance/approval_process.md).
5. **Produção:** Após aprovação, atualize a view com o script `deployment/deploy_view.sql`.

---

## 📊 Estado Atual — Versão v1.3.0 (22/06/2026)

### Faturamento Auditado
> **R$ 9.540.041,07** — Validado e intacto. ML/Shopee/Amazon já consolidados no Bling.

### Cobertura de Atribuição GA4
> **~20,5%** dos pedidos rastreados com `utm_campaign`. Limitação: bloqueadores de cookie/AdBlock no checkout.

### Modelo de ROAS (Google Ads)
> Funcional. 54 mapeamentos de campanha no de-para. Limitado pela cobertura GA4.

### Próximos Passos
- Conectar views `marketing_attribution` e `legado` ao Looker Studio.
- Aumentar cobertura do evento `purchase` no GA4 (server-side tagging ou Conversions API).
- Validar `v_legado_financeiro` com o DRE real da empresa.

---

Consulte [`governance/change_log.md`](governance/change_log.md) para o histórico completo de versões.
