# Aroom Health BI Engine & Analytics Governance

Este repositório contém a definição oficial, versionada e auditada da camada analítica do GCP / BigQuery para a **Aroom Health**. 

O objetivo principal deste ambiente é garantir a integridade dos dados de vendas, prevenir duplicações de linhas (fan-out) no Looker Studio, manter as dimensões da **SmartMetrics** intactas e gerenciar mudanças de forma segura entre os engenheiros de dados e parceiros de negócio.

---

## 📂 Estrutura do Repositório

```text
aroom-health-bi-engine/
├── README.md
├── docs/
│   ├── business_rules.md              # Detalhamento de métricas e dimensões SmartMetrics
│   ├── architecture.md                # Desenho do fluxo de dados e integrações
│   ├── data_dictionary.md             # Dicionário de dados da view de vendas
│   ├── google_ads_pipeline_issue.md   # Diagnóstico e plano de recuperação do Google Ads
│   └── roas_tracking_strategy.md      # Estratégia de rastreamento de UTM com Bling
├── sql/
│   ├── production/
│   │   └── growth_engine_vendas_detalhado.sql         # SQL ativo em Produção
│   ├── staging/
│   │   └── growth_engine_vendas_detalhado_staging.sql # SQL de Staging para validação
│   └── tests/
│       ├── revenue_validation.sql     # Teste de faturamento (R$ 9.540.041,07)
│       ├── duplicate_check.sql        # Teste de granularidade e duplicados
│       ├── null_category_check.sql    # Teste de falha na categorização inteligente
│       └── item_granularity_check.sql # Validação matemática de quantidade x valores
├── deployment/
│   ├── deploy_view.sql                # Script de deploy
│   ├── rollback.sql                   # Script de rollback
│   └── validation_checklist.md        # Checklist manual de validação pré-merge
├── governance/
│   ├── change_log.md                  # Registro de alterações históricas
│   ├── approval_process.md            # Regras do fluxo de aprovação no Git
│   └── ownership_matrix.md            # Matriz de donos das regras de negócio
└── roadmap/
    ├── phase_1_version_control.md
    ├── phase_2_google_ads_recovery.md
    ├── phase_3_roas_model.md
    └── phase_4_smartmetrics_feature_layer.md
```

---

## 🛠️ Tecnologias Utilizadas

* **Google Cloud Platform (GCP):** Provedor de infraestrutura em nuvem.
* **BigQuery:** Data Warehouse serverless onde residem os dados e views.
* **SmartMetrics BI Engine:** Motor de dimensões personalizadas de produto aplicadas na camada de vendas.
* **Looker Studio:** Camada de visualização de dados consumindo diretamente a view auditada.
* **Git & GitHub:** Versionamento e governança de código.

---

## 🔄 Fluxo de Trabalho e Implantação

1. **Alterações:** Nunca altere as regras de negócio diretamente no BigQuery.
2. **Desenvolvimento:** Crie uma branch a partir de `dev` (ex: `feature/nova-dimensao`).
3. **Validação:** Implante na view de staging (`growth_engine_vendas_detalhado_staging`) e execute todos os scripts da pasta `/sql/tests/`.
4. **Pull Request:** Abra um PR apontando para a branch `dev` e, em seguida, para a `main`. Siga o [Processo de Aprovação](governance/approval_process.md).
5. **Produção:** Somente após passar em todas as validações, a view de produção é atualizada com o script `deployment/deploy_view.sql`.

Consulte a pasta `docs/` para mais detalhes de arquitetura e regras de negócio.
