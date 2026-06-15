# Registro de Anomalias de Qualidade de Dados (Data Quality Issue Register)

Este documento registra todas as falhas e anomalias de integridade identificadas nas bases de dados da **Aroom Health** durante a auditoria técnica de profiling realizada no BigQuery. A resolução destas pendências é pré-requisito obrigatório antes do desenvolvimento de modelos avançados.

---

## 🚨 Anomalias de Alta Gravidade (High Severity)

### 1. Ausência Crítica de Preço de Custo (COGS Nulo)
*   **Tabela/Coluna:** `database_aroom_health.produtos.preco_custo`
*   **Problema:** **8.883 produtos (91,1% da tabela)** possuem preço de custo cadastrado como **R$ 0,00**.
*   **Impacto de Negócio:** Na view semântica de produção, **108.442 itens de vendas (59%)** apresentam COGS zerado. Isso infla artificialmente o Lucro Bruto e a Margem de Contribuição de categorias inteiras (ex: Tintura Mãe e Sem Categoria aparecem com 100% de margem). O CFO não consegue obter o lucro líquido contábil correto.
*   **Ação Recomendada:** Realizar carga corretiva no Bling ERP com a planilha de custos de fabricação e definir valor padrão (fallback) de margem baseada em categoria.

### 2. Paralisação do Pipeline de Marketing (Google Ads Stale Data)
*   **Tabela/Coluna:** `database_aroom_health.google_ads_campaign_performance`
*   **Problema:** A tabela não recebe novos dados desde **12/12/2025**. O pipeline do Data Transfer Service está inativo ou desconectado.
*   **Impacto de Negócio:** Os relatórios de desempenho de marketing e o cálculo de ROAS Real estão desatualizados há meses, inviabilizando decisões de alocação de orçamento de mídia pelo CMO.
*   **Ação Recomendada:** Reautenticar a credencial do BigQuery Data Transfer Service para restaurar a carga diária de publicidade.

### 3. Ausência de Parâmetros UTM Transacionais
*   **Tabela/Coluna:** `database_aroom_health.pedidos_vendas.observacoes_internas`
*   **Problema:** **93,4% das linhas** estão com as observações internas nulas ou vazias. Nenhuma das linhas contém marcações no padrão `utm_source=...`.
*   **Impacto de Negócio:** Impossibilidade de extrair a campanha de origem do pedido diretamente a partir das notas do Bling por Regex. A atribuição de marketing de último clique fica cega se baseada apenas no ERP.
*   **Ação Recomendada:** Configurar o checkout do e-commerce para salvar as UTMs de sessão ativas no campo de observações internas de cada pedido enviado ao Bling.

---

## ⚠️ Anomalias de Média Gravidade (Medium Severity)

### 4. Duplicidades de Webhook na Ingestão (Fan-out)
*   **Tabela/Coluna:** `database_aroom_health.pedidos_vendas_itens`
*   **Problema:** Encontradas **895 duplicatas de itens de pedidos** (chaves compostas `pedido_id + item_id` com mais de uma linha na carga).
*   **Impacto de Negócio:** Juntar diretamente itens com vendas infla a receita líquida e o volume físico de produtos vendidos.
*   **Ação Recomendada:** Utilizar regras de deduplicação via `ROW_NUMBER() OVER(PARTITION BY pedido_id, item_id ORDER BY datastream_metadata.source_timestamp DESC)` na camada de staging.

### 5. Cadastros sem SKU (SKU Nulo)
*   **Tabela/Coluna:** `database_aroom_health.produtos.codigo`
*   **Problema:** **5.042 produtos (51,7%)** não possuem SKU (`codigo`) preenchido. Na tabela de itens de pedidos, **7.841 linhas** contêm SKU vazio.
*   **Impacto de Negócio:** Dificulta joins baseados em códigos de produtos e quebra hierarquias de relatórios de vendas de SKUs por categoria.
*   **Ação Recomendada:** Tornar o SKU um campo de preenchimento obrigatório na criação de novos produtos no Bling ERP.

### 6. Saldo de Estoque Negativo
*   **Tabela/Coluna:** `database_aroom_health.produtos.estoque`
*   **Problema:** **1.684 registros** apresentam estoque físico negativo (estoque < 0).
*   **Impacto de Negócio:** Indica falha na conciliação física e sistêmica de inventário (venda de produtos sem saldo real disponível).
*   **Ação Recomendada:** Implementar alertas de estoque e forçar auditorias de inventário semanais no CD.

### 7. Comissões Zeradas no ERP
*   **Tabela/Coluna:** `database_aroom_health.pedidos_vendas_itens.comissao_valor`
*   **Problema:** O campo comissão está **100% zerado/vazio** para todos os 183.690 registros de itens de vendas.
*   **Impacto de Negócio:** Impossibilita o desconto automático da taxa cobrada por marketplaces (Shopee, Mercado Livre, Amazon) no cálculo de rentabilidade.
*   **Ação Recomendada:** Cadastrar as alíquotas de comissão por canal no Bling ERP ou criar uma tabela estática de de-para de comissão por canal de venda no BigQuery.
