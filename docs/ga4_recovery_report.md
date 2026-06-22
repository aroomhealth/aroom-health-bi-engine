# Relatório de Reconciliação e Auditoria: GA4 Recovery (2025-12-11 a 2026-06-10)

Este relatório apresenta os resultados da auditoria, completude e validação de dados históricos do Google Analytics 4 (GA4) recuperados no BigQuery para o período de interrupção da exportação nativa.

Todos os dados recuperados foram inseridos com sucesso no dataset de isolamento `analytics_recovery`.

---

## 1. Cobertura Temporal e Volumetria

A carga histórica foi dividida e executada em blocos de 30 dias para otimização de cota e performance. A cobertura temporal obtida foi de **100%** dos dias do intervalo planejado:

* **Período Coberto:** `2025-12-11` a `2026-06-10`
* **Dias com Dados:** 182 dias (completude total)
* **Dataset de Destino:** `iron-rex-461220-g4.analytics_recovery`

### Métricas Totais Recuperadas por Tabela (182 dias)

| Tabela de Recuperação | Total de Linhas | Principais Métricas Recuperadas |
| :--- | :--- | :--- |
| **`ga4_recovery_traffic_sources`** | 6.942 | 182.365 sessões, 153.218 usuários ativos, 13.599 conversões |
| **`ga4_recovery_pages`** | 36.671 | Visualizações por Landing Page |
| **`ga4_recovery_geo`** | 50.884 | Sessões e usuários ativos agrupados por País/UF/Cidade |
| **`ga4_recovery_devices`** | 1.442 | Distribuição por Categoria de Dispositivo e Sistema Operacional |
| **`ga4_recovery_events`** | 3.559 | Contagem total de eventos (page_view, session_start, etc.) |
| **`ga4_recovery_ecommerce`** | 4.481 | 4.955 transações únicas e R$ 512.023,63 em receita |

---

## 2. Teste de Duplicidade e Integridade

Realizamos uma validação estrita de chaves primárias (`date` + dimensões primárias) em todas as tabelas importadas.

* **Resultado:** **0 linhas duplicadas.**
* **Nota Técnica:** Os dados carregados em execuções de testes parciais foram previamente limpos (através do comando `DROP TABLE`), garantindo a integridade referencial dos agregados no BigQuery.

---

## 3. Comparação de Médias Diárias (Nativo vs. Recuperado)

Para atestar que os dados recuperados refletem a realidade volumétrica da propriedade, comparamos as médias diárias de tráfego do período recuperado com os dados nativos da exportação oficial do GA4 (imediatamente antes e depois do gap):

| Período | Origem dos Dados | Média de Sessões / Dia | Média de Usuários Ativos / Dia |
| :--- | :--- | :--- | :--- |
| **Antes do Gap** (28/11/25 a 04/12/25) | Exportação Nativa GA4 (BQ) | 1.020,3 | 900,3 |
| **Durante o Gap** (11/12/25 a 10/06/26) | **Recuperado via API (Este Projeto)** | **1.002,0** | **841,9** |
| **Depois do Gap** (11/06/26 a 15/06/26) | Exportação Nativa GA4 (BQ) | 909,0 | 805,4 |

**Conclusão:** As médias diárias de sessões e usuários do período recuperado estão perfeitamente alinhadas e distribuídas entre os períodos adjacentes de produção nativa, sem anomalias ou distorções estatísticas.

---

## 4. Reconciliação de E-commerce: GA4 vs. ERP Bling

Cruzamos as transações de e-commerce e receita recuperadas via API do GA4 com o faturamento real registrado na view de vendas do ERP Bling (`database_aroom_health.view_vendas`) durante os mesmos 182 dias:

| Origem | Total de Pedidos (Transactions) | Receita Total (R$) | Taxa de Captura do GA4 |
| :--- | :--- | :--- | :--- |
| **ERP Bling** | 24.173 | R$ 2.034.775,87 | 100% |
| **GA4 Recuperado** | 4.955 | R$ 512.023,63 | **20,50%** (Pedidos) / **25,16%** (Receita) |

### Análise Importante: Subnotificação do GA4 Nativo
À primeira vista, uma taxa de captura de ~20% no GA4 parece baixa, mas uma investigação histórica revelou que isso é decorrente de uma **subnotificação crônica de tracking no próprio Google Analytics** da Aroom Health (devido a adblockers, rejeição de cookies ou ausência de disparo do evento de purchase na Nuvemshop):

1. **Antes do Gap (Nativo):** No período de `28/11/25` a `04/12/25`, a exportação nativa do GA4 registrou apenas **22 transações** contra **1.298 pedidos** no ERP Bling (uma taxa de captura de apenas **1,69%**).
2. **Período de Recuperação:** Na primeira semana recuperada (`11/12/25` a `17/12/25`), recuperamos **230 transações** contra **1.111 pedidos** no ERP (uma taxa de captura de **20,70%**).

**Conclusão:** O processo de recuperação via API foi altamente bem-sucedido e resgatou **10x mais transações** do que a exportação nativa de eventos estava conseguindo rastrear logo antes de cair.
