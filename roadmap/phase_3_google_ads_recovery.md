# Fase 2: Recuperação do Pipeline do Google Ads

## 🎯 Objetivo
Restabelecer o fluxo diário de custos e performance de campanhas do Google Ads no BigQuery de forma automática, segura e resiliente.

---

## 📋 Entregáveis & Ações

### 1. Migração para BigQuery Data Transfer Service (DTS)
* Seguir o guia em `docs/google_ads_pipeline_issue.md`.
* Habilitar a transferência nativa para a conta do Google Ads correspondente.

### 2. Backfill Histórico Completo
* Agendar o preenchimento de dados históricos retroativo desde **12/12/2025** até a data atual.
* Homologar se o total gasto no console do Google Ads bate com os dados consolidados carregados no BigQuery.

### 3. Monitoramento de Atualização (Freshness Check)
* Criar query de teste diário para verificar se a data máxima de carga é igual a D-1.
* Configurar alertas de erro de sincronização para envio por e-mail ou integração via webhook.
