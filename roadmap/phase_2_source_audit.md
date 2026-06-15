# Fase 2: Auditoria de Fontes de Dados e Qualidade

## 🎯 Objetivo
Realizar a varredura completa nas tabelas de ingestão primária, mapeando a consistência dos dados do Bling, Google Ads e tráfego orgânico/pago (GA4).

---

## 📋 Entregáveis & Ações

### 1. Execução do Pacote de Validação SQL
* Rodar a suite de testes `/sql/tests/audit_*.sql` contra a base de dados do BigQuery.
* Consolidar os volumes de dados, chaves nulas e taxas de duplicidade física em relatório executivo.

### 2. Mapeamento de Risco e Linhagem
* Documentar a linhagem de dados no repositório (`docs/architecture.md`).
* Desenhar e manter a matriz de risco e plano de ação em `docs/source_audit_report.md`.
