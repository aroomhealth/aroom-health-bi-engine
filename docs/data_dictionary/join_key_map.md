# Mapa de Chaves de Associação (Join Key Map)

Este documento descreve como associar as tabelas do BigQuery no ecossistema da **Aroom Health**, identificando os relacionamentos seguros, as chaves de ligação e os riscos de explosão de dados (fan-out) associados a junções incorretas.

---

## 🗺️ Mapa de Relacionamentos Lógicos

O fluxo relacional correto segue o diagrama físico de chaves:

```
[pedidos_vendas] 
   ├── (identificador) 1:N ──> [pedidos_vendas_itens] ── (produto_id) N:1 ──> [produtos]
   ├── (loja_id) N:1 ─────────> [bling_canais_venda]
   ├── (identificador) 1:1 ──> [pedidos_vendas_transporte]
   └── (contato_id) N:1 ──────> [customer_profile_enriched]
                                      ├── (customer_id) 1:1 ──> [customer_rfm]
                                      └── (customer_id) 1:1 ──> [customer_predictions]
```

---

## 🟢 Associações Seguras (Safe Joins)

São consideradas associações seguras aquelas que respeitam a cardinalidade e não alteram o grão transacional original da tabela da esquerda:

### 1. `pedidos_vendas_itens` para `produtos`
*   **Chave de Ligação:** `pedidos_vendas_itens.produto_id = produtos.identificador` (ou `pedidos_vendas_itens.codigo = produtos.codigo`).
*   **Regra de Ouro:** Junção tipo `LEFT JOIN` para garantir que itens de pedidos com SKUs órfãos ou não cadastrados não sejam descartados da receita.
*   **Cardinalidade:** N:1 (Múltiplos itens referenciam o mesmo cadastro de produto).

### 2. `customer_profile_enriched` para `customer_predictions` / `customer_rfm`
*   **Chave de Ligação:** `customer_profile_enriched.customer_id = customer_predictions.customer_id` (ou `customer_rfm.customer_id`).
*   **Regra de Ouro:** Junção do tipo `LEFT JOIN` ou `INNER JOIN`. Ambas as tabelas de IA são construídas na granularidade de cliente único (`customer_id`), eliminando qualquer risco de fan-out.
*   **Cardinalidade:** 1:1.

### 3. `pedidos_vendas` para `bling_canais_venda`
*   **Chave de Ligação:** `CAST(pedidos_vendas.loja_id AS STRING) = bling_canais_venda.id_canal` (Nota: O tipo do campo é INT64 no cabeçalho e STRING no canal; requer conversão `CAST` explícita).
*   **Regra de Ouro:** Garantir a deduplicação de canais (`bling_canais_venda`) agrupando por `id_canal` antes de fazer o join, conforme implementado na view de produção.

---

## 🔴 Associações Perigosas (Dangerous Joins - Fan-out Risks)

Estas associações alteram o grão ou duplicam valores se não forem tratadas com funções de agregação ou CTEs isoladas:

### 1. `pedidos_vendas` com `pedidos_vendas_transporte`
*   **Chave de Ligação:** `pedidos_vendas.identificador = pedidos_vendas_transporte.pedidos_vendas_identificador`
*   **O Risco:** O frete é registrado a nível de pedido. Se você juntar diretamente a tabela de transporte com a tabela de itens de pedido, o valor do frete será somado múltiplas vezes (para cada item do pedido), inflando artificialmente os custos logísticos no Looker Studio.
*   **Solução Correta:** Ratear proporcionalmente o valor do frete para cada item utilizando a receita líquida do item no total de produtos do pedido.

### 2. `pedidos_vendas` com `pedidos_vendas_itens`
*   **Chave de Ligação:** `pedidos_vendas.identificador = pedidos_vendas_itens.pedidos_vendas_identificador`
*   **O Risco:** Muda a granularidade do nível de Pedido (127.513 linhas) para o nível de Item (183.690 linhas). Se você somar o campo `pedidos_vendas.total` após esse join, as receitas serão massivamente multiplicadas pelo número de itens de cada pedido.
*   **Solução Correta:** Nunca realize somas de medidas de cabeçalho (`pedidos_vendas.total`) após a junção direta com a tabela de itens. Agregue os itens a nível de pedido primeiro em uma CTE antes do join, ou some exclusivamente `pedidos_vendas_itens.valor * pedidos_vendas_itens.quantidade`.

### 3. `pedidos_vendas` com `customer_profile_enriched` (sem deduplicação)
*   **Chave de Ligação:** `pedidos_vendas.contato_id = customer_profile_enriched.customer_id`
*   **O Risco:** Se a tabela de enriquecimento de clientes contiver endereços duplicados para o mesmo `customer_id` (por exemplo, múltiplos registros de endereços antigos), cada venda do cliente será duplicada no join.
*   **Solução Correta:** Garantir que a tabela do cliente passe por um agrupamento de unicidade por ID (ex: `ANY_VALUE(estado) GROUP BY customer_id`) antes de efetuar a ligação.
