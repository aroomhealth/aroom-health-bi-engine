# Histórico de Alterações - BigQuery Analytics Layer

Todas as alterações na estrutura ou nas regras de negócio da view `growth_engine_vendas_detalhado` devem ser registradas aqui.

---

| Data | Versão | Autor | Alteração | Validação de Receita |
| :--- | :--- | :--- | :--- | :--- |
| **15/06/2026** | `v1.0.0` | Antigravity (AI Staff Engineer) | Extração inicial da view de produção e estabelecimento do repositório versionado no GitHub. | **R$ 9.540.041,07** (✅ PASS) |
| **22/06/2026** | `v1.1.0` | Renan / Antigravity | **[Google Ads DTS Recovery]** Reconexão do pipeline de Google Ads via BigQuery Data Transfer Service (conta `5644422842`). Backfill completo de **531 dias** (01/01/2025 → 21/06/2026) com **12.365 registros** e **R$ 195.069,41** em investimento recuperado. Dataset destino: `google_ads`. Risk R-01 ✅ FECHADO. | — |
| **22/06/2026** | `v1.1.0` | Renan / Antigravity | **[GA4 Historical Recovery]** Recuperação histórica do GA4 via API para o período de gap (11/12/2025 → 10/06/2026). **182 dias** sem gaps. 6 tabelas inseridas no dataset `analytics_recovery`: traffic_sources (6.942 rows), pages (36.671), geo (50.884), devices (1.442), events (3.559), ecommerce (4.481 rows — 4.955 transações / R$ 512.023,63). Taxa de captura GA4 vs. Bling: 20,5%. 0 duplicatas. | — |
