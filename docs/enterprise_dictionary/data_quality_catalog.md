# Catálogo de Qualidade de Dados e SLAs (Data Quality Catalog)
## Aroom Health BI Engine - Matriz de Qualidade de Ingestão e Monitoramento de Anomalias

Este catálogo consolida os indicadores de integridade física dos dados identificados no BigQuery da **Aroom Health**, definindo limites admissíveis de falhas, regras automatizadas de qualidade e acordos de nível de serviço de atualização (SLAs de Freshness).

---

## 1. Scorecard de Saúde das Tabelas Críticas

Compilamos as métricas de qualidade obtidas via profiling nas colunas cruciais da camada staging e analítica:

| Tabela de Origem | Campo | Tipo de Teste | Métrica de Qualidade Real | Limite Admissível | Status de Integridade |
| :--- | :--- | :--- | :---: | :---: | :---: |
| `database_aroom_health.pedidos_vendas` | `identificador` | Unicidade | **2 Duplicados** (127.511 distintos em 127.513 linhas) | 0 duplicados | `🔴 CRÍTICO` |
| `database_aroom_health.pedidos_vendas_itens` | `identificador` | Unicidade | **895 Duplicados** (182.795 distintos em 183.719 linhas) | 0 duplicados | `🔴 CRÍTICO` |
| `database_aroom_health.produtos` | `preco_custo` | Completude | **91,1% Nulos/Zerados** (8.883 produtos sem custo) | < 5% zerados | `🔴 CRÍTICO` |
| `database_aroom_health.pedidos_vendas` | `observacoes_internas`| Completude | **93,4% Nulos/Vazios** (sem UTMs transacionais) | < 10% nulos | `🟡 ALERTA` |
| `database_aroom_health.produtos` | `codigo` (SKU) | Completude | **51,7% Nulos/Vazios** (5.042 produtos sem SKU) | < 1% nulos | `🔴 CRÍTICO` |
| `database_aroom_health.pedidos_vendas_itens` | `codigo` (SKU) | Completude | **4,2% Nulos** (7.841 linhas de vendas sem SKU) | < 1% nulos | `🟡 ALERTA` |
| `database_aroom_health.produtos` | `estoque` | Regra de Faixa | **1.684 itens com saldo < 0** (Estoque Negativo) | 0 itens < 0 | `🟡 ALERTA` |
| `database_aroom_health.pedidos_vendas_itens` | `valor` | Regra de Faixa | **4.960 itens com valor <= R$ 0** | 0 itens <= 0 | `🔴 CRÍTICO` |
| `database_aroom_health.pedidos_vendas_itens` | `quantidade` | Regra de Faixa | **67 itens com quantidade <= 0** | 0 itens <= 0 | `🟡 ALERTA` |
| `database_aroom_health.pedidos_vendas_itens` | `comissao_valor` | Completude | **100% Zerado/Vazio** (taxas não imputadas) | < 5% zerados | `🟡 ALERTA` |

---

## 2. Acordos de Nível de Serviço (SLA de Freshness)

Mapeamos a frequência máxima aceitável de atraso na ingestão e atualização das bases físicas de dados (frescor dos dados):

### 2.1 Tabela: `database_aroom_health.pedidos_vendas` (Faturamento ERP)
*   **Frequência Esperada:** Atualização incremental a cada 1 hora via webhook Bling ERP.
*   **SLA de Limite Crítico:** D-0 (Atraso máximo aceitável de 2 horas).
*   **Impacto no Negócio:** Atualização em tempo real das metas de faturamento intradia no Looker Studio.
*   **Status Atual:** **Admitido / Em conformidade (D-0)**.

### 2.2 Tabela: `google_ads_campaign_performance` (Custos de Ads)
*   **Frequência Esperada:** Atualização diária (D-1) às 04h00 da manhã via Google Ads Data Transfer Service.
*   **SLA de Limite Crítico:** D-1 (Atraso máximo de 24 horas).
*   **Impacto no Negócio:** Otimizações diárias de lances de campanhas digitais e verificação de ROAS do CMO.
*   **Status Atual:** `🔴 QUEBRADO` (Sem dados novos desde **12/12/2025** - Atraso de mais de 180 dias).

### 2.3 Tabela: `customer_intelligence.customer_profile_enriched` (Marts Analíticos)
*   **Frequência Esperada:** Execução programada diária às 05h00 da manhã.
*   **SLA de Limite Crítico:** D-1 (Atraso máximo de 24 horas).
*   **Impacto no Negócio:** Sincronização diária de segmentações de CRM para o ActiveCampaign.
*   **Status Atual:** **Em conformidade (D-4, atualizado em 12/06/2026)**.

---

## 3. Catálogo de Regras de Testes Automatizados de Qualidade

Para blindar a camada semântica e impedir a propagação de anomalias, recomendamos a implementação dos seguintes testes de integridade automatizados (via dbt, Dataform ou Views de Auditoria no BigQuery):

### Regra 1: Validação de Chave Primária de Itens (Unicidade)
*   **Objetivo:** Impedir o faturamento inflado por duplicidade de webhooks.
*   **Query de Auditoria:**
    ```sql
    SELECT 
        pedidos_vendas_identificador, 
        identificador AS item_id, 
        COUNT(*) AS duplicidades
    FROM `database_aroom_health.pedidos_vendas_itens`
    GROUP BY 1, 2
    HAVING COUNT(*) > 1;
    ```
*   **Ação:** Disparar alerta crítico ao Slack/Email se retornar mais de 0 registros.

### Regra 2: Verificação de Custos Nulos (Completude)
*   **Objetivo:** Alertar sobre novos SKUs cadastrados no Bling com custo zerado antes de afetar o DRE.
*   **Query de Auditoria:**
    ```sql
    SELECT 
        identificador AS produto_id, 
        codigo AS sku, 
        nome
    FROM `database_aroom_health.produtos`
    WHERE preco_custo = 0.00 AND situacao = 'A';
    ```
*   **Ação:** Gerar relatório de alerta diário para o time de Operações/Compras carregar a planilha corretiva.

### Regra 3: Teste de Consistência Temporal (Anacronismo)
*   **Objetivo:** Garantir que a data física de faturamento/saída do produto não seja anterior à data de criação do pedido.
*   **Query de Auditoria:**
    ```sql
    SELECT 
        identificador AS pedido_id, 
        data AS data_pedido, 
        data_saida
    FROM `database_aroom_health.pedidos_vendas`
    WHERE data_saida < data;
    ```
*   **Ação:** Alerta de média gravidade para auditoria no ERP.
