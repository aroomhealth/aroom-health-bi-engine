# Dicionário de Dados - growth_engine_vendas_detalhado

Este dicionário descreve os campos contidos na view `customer_intelligence.growth_engine_vendas_detalhado`.

---

## 📋 Lista de Campos

| Campo | Tipo | Descrição | Origem / Regra |
| :--- | :--- | :--- | :--- |
| **`data`** | DATE | Data de emissão/lançamento do pedido. | `p.data` |
| **`data_venda`** | DATE | Data oficial da venda. | `p.data` (Duplicado para conveniência histórica) |
| **`data_compra`** | DATE | Data oficial da compra realizada. | `p.data` (Duplicado para conveniência histórica) |
| **`pedido_id`** | INTEGER | Identificador único do pedido no Bling. | `p.identificador` |
| **`item_id`** | INTEGER | Identificador único do item dentro do pedido. | `i.identificador` |
| **`uf`** | STRING | Sigla do estado do cliente. | `pe.estado` via `customer_profile_unique` |
| **`id_da_loja_origem`** | INTEGER | ID da loja ou canal de vendas de origem no Bling. | `p.loja_id` |
| **`origem_da_venda`** | STRING | Nome descritivo do canal de venda. | `c.canal_edit` ou `c.canal` |
| **`origem_agrupada`** | STRING | Canal agrupado por Regexp para simplificação no BI. | Regexp condicional de origem da venda |
| **`produto`** | STRING | Nome oficial do produto cadastrado. | `prod.nome` |
| **`categoria_produto`** | STRING | Categoria principal do produto. | `categorias_antigas` com fallback inteligente |
| **`subcategoria_produto`** | STRING | Subcategoria do produto. | `categorias_antigas` com fallback inteligente |
| **`quantidade_comprada`** | INTEGER | Quantidade de itens comprados no registro. | `i.quantidade` |
| **`receita_total`** | NUMERIC | Faturamento bruto gerado pelo item (Qtd x Valor Unitário). | `i.valor * i.quantidade` |
| **`custo_unitario`** | FLOAT | Custo de aquisição/produção unitário do produto. | `prod.preco_custo` |
| **`custo_total_produto`** | FLOAT | Custo total do produto no registro (Qtd x Custo Unitário). | `custo_unitario * i.quantidade` |
| **`lucro_bruto`** | FLOAT | Lucro bruto calculado para o item. | `receita_total - custo_total_produto` |
| **`custo_frete`** | NUMERIC | Frete do pedido rateado proporcionalmente para o item. | Rateio do frete com base na participação do item |
| **`familia_produto`** | STRING | Agrupamento de subcategorias (SmartMetrics 1). | Regra SmartMetrics |
| **`objetivo_produto`** | STRING | Objetivo terapêutico/uso do produto (SmartMetrics 2). | Regra SmartMetrics |
| **`etapa_jornada_produto`**| STRING | Fase do produto na jornada do consumidor (SmartMetrics 3). | Regra SmartMetrics |
| **`nivel_especializacao`**| STRING | Complexidade de uso requerida pelo produto (SmartMetrics 4).| Regra SmartMetrics |
| **`faixa_valor_produto`** | STRING | Classificação por tíquete unitário (SmartMetrics 5). | Regra SmartMetrics |
| **`potencial_recorrencia`**| STRING | Classificação de recorrência esperada (SmartMetrics 6). | Regra SmartMetrics |
