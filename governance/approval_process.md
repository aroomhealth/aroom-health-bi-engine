# Processo de Aprovação & Fluxo Git

Para manter a governança da camada de BI e evitar alterações acidentais na produção, estabelecemos a seguinte política de ramificações (branching policy) e revisão de código.

---

## 🌿 Estrutura de Branches

1. **`main` (Produção):**
   * Contém o código SQL idêntico ao que está rodando em produção no BigQuery.
   * **Bloqueio:** Commit direto é proibido. Toda alteração deve vir de um Pull Request homologado.
2. **`dev` (Desenvolvimento/Staging):**
   * Contém recursos em fase de teste e homologação.
   * **Bloqueio:** Commit direto desencorajado; use Pull Requests de features.
3. **`feature/*` (Novas Regras/Melhorias):**
   * Branches de trabalho criadas para desenvolver novas dimensões, correções ou refatorações (ex: `feature/ajuste-categoria-oleos`).

---

## 🔄 Fluxo de Desenvolvimento e Implantação

```mermaid
sequenceDiagram
    participant Dev as Desenvolvedor
    participant Git as GitHub (Staging Branch)
    participant BQ_Stage as BigQuery Staging View
    participant Reviewer as Revisor (Sócio/Eng. Dados)
    participant BQ_Prod as BigQuery Prod View

    Dev->>Git: Cria branch feature/minha-alteracao
    Dev->>BQ_Stage: Aplica SQL e valida com testes locais
    Dev->>Git: Abre Pull Request (PR) para 'dev'
    Git->>Reviewer: Solicita Code Review e Validação de Receita
    Reviewer->>BQ_Stage: Executa testes de receita e duplicidade
    Reviewer->>Git: Aprova PR
    Git->>Git: Merge para branch 'main'
    Dev->>BQ_Prod: Executa deployment/deploy_view.sql em Produção
```

---

## 🔍 Checklist de Revisão de Código (Pull Request)

O revisor deve validar os seguintes pontos no PR antes de aprovar o merge para `main`:
1. **Regras SmartMetrics preservadas:** A query alterada contém as 6 dimensões SmartMetrics descritas na documentação de regras de negócio?
2. **Faturamento correto:** Os scripts de teste em staging comprovaram que o faturamento de R$ 9.540.041,07 foi mantido intacto (a menos que a alteração seja explicitamente para corrigir vendas retroativas homologadas)?
3. **Prevenção de Fan-out:** O código introduziu algum JOIN de tabela 1-para-N sem agrupamento que possa duplicar linhas no Looker Studio?
4. **Semântica de Campo:** Algum campo existente no Looker Studio foi excluído ou renomeado?
