# Plano de Rollback e Recuperação (Rollback Plan)

Este plano descreve o procedimento de contingência para reverter alterações malsucedidas na camada de BigQuery que impactem os dashboards do Looker Studio.

---

## 🚨 Gatilhos para Rollback

O processo de rollback deve ser executado imediatamente caso ocorra:
1. **Quebra do Dashboard:** Erros de carregamento de gráficos ou colunas não encontradas no Looker Studio após deploy.
2. **Divergência de Receita:** Divergência de faturamento no script `revenue_validation.sql` superior a **R$ 0,00** em relação ao valor homologado de R$ 9.540.041,07.
3. **Explosão de Registros:** Aumento repentino de contagem de linhas causado por loops/fan-outs em joins de views.

---

## 🛠️ Procedimento Passo a Passo para Reversão

### Passo 1: Interromper Cargas no Git
* Crie um branch de correção rápida (`hotfix/rollback-versao-anterior`).
* Faça o revert do commit causador do erro no GitHub.

### Passo 2: Executar o Código de Backup
* No console do BigQuery, execute o script contido em:
  [deployment/rollback.sql](file:///Users/renanstranodeoliveira/Downloads/aroom-health-bi-engine/deployment/rollback.sql)
* Este script recria a view `growth_engine_vendas_detalhado` exatamente na versão estável anterior.

### Passo 3: Executar a Suite de Testes
Rode as validações essenciais:
* `sql/tests/revenue_validation.sql`
* `sql/tests/duplicate_check.sql`

### Passo 4: Atualizar Logs e Notificar
* Registre o incidente na tabela de histórico em `governance/change_log.md`.
* Avise os stakeholders de negócio (Sócios e BI Lead) sobre a restauração.
