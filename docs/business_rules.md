# Regras de Negócio & SmartMetrics BI Engine

Este documento detalha as regras de negócio consolidadas na view de produção `growth_engine_vendas_detalhado`, destinadas a manter o faturamento auditado de **R$ 9.540.041,07** e garantir a consistência das dimensões da **SmartMetrics**.

---

## ⚖️ Prevenção de Duplicações (Fan-out)

A causa da inflação de receita no dashboard anterior (que exibia ~R$ 9.6M em vez do valor correto de R$ 9.540.041,07) era o join direto de tabelas com granularidades distintas. A view atual corrige isso com as seguintes regras de agrupamento:

### 1. Agrupamento de Frete (CTE `frete_pedido`)
O frete é registrado a nível de pedido. Se juntado diretamente aos itens, o frete seria somado múltiplas vezes ou inflaria os registros.
* **Solução:** O frete é rateado proporcionalmente ao valor de cada item no total de produtos do pedido:
  ```sql
  CASE 
      WHEN vt.soma_valor_produtos > 0 THEN COALESCE(f.frete_total, 0) * ((i.valor * i.quantidade) / vt.soma_valor_produtos)
      ELSE 0 
  END as custo_frete
  ```

### 2. Unicidade de Estados do Cliente (CTE `customer_profile_unique`)
Evita duplicar itens caso o mesmo cliente possua mais de um endereço ou registro de estado.
* **Solução:** Utiliza a função `ANY_VALUE(estado)` agrupando por `customer_id`.

### 3. Unicidade de Canais de Venda (CTE `canais_unique`)
Consolida canais duplicados a nível de ID.
* **Solução:** Agrupa por `id_canal` com `ANY_VALUE`.

---

## 🏷️ Regra de Categorização Inteligente de Produtos (Fallback)

Para evitar produtos sem categoria ("Sem Categoria" ou "Outros") causados por preenchimento incompleto no ERP, a view realiza uma limpeza usando palavras-chave no nome do produto:
* **Óleos Vegetais:** Identificado se o nome contém `óleo vegetal`, `oleo vegetal`, `semente de uva`, `rícino`, `ricino` ou `jojoba`.
* **Tintura Mãe:** Identificado se contém `tintura` ou `maca peruana`.
* **Blends Fórmulas Exclusivas:** Identificado se contém `blend`.
* **Kits De Óleos Vegetais:** Identificado se contém `kit`.
* **Óleos Essenciais:** Identificado se contém `óleo essencial` ou `oleo essencial`.
* **Argila:** Identificado se contém `argila`.

---

## 🧠 SmartMetrics BI Engine - Dimensões Calculadas

> [!IMPORTANT]
> As dimensões abaixo são essenciais para a segmentação de clientes e análise de recorrência. Elas **não devem ser modificadas** sem autorização explícita da diretoria de negócios.

### 1. `familia_produto`
Categorização macro para relatórios de portfólio.
* **Tratamento Capilar:** Óleos Capilares, Óleos Para Terapia Capilar, Tônicos Capilares, Shampoos, Condicionadores, Tônicos, Shampoo.
* **Óleos Naturais:** Óleos Vegetais, Óleos Essenciais, Blends Fórmulas Exclusivas.
* **Estética e Beleza:** Óleos Para Cílios E Sobrancelhas, Cílios, Sobrancelha, Estética.
* **Terapias Naturais:** Seivas Naturais, Tintura Mãe, Argila, Argilas, Hidrolatos, Hidrolatos Florais, Gel Aloe Vera, Géis De Aloe Vera.
* **Coloração Natural:** Tinturas Vegetais, Coloração.
* **Kits:** Kits De Óleos Vegetais, Kits De Óleos Capilares, Kits De Óleos, Kits.

### 2. `objetivo_produto`
Finalidade de uso indicada ao cliente.
* **Crescimento e Tratamento:** Óleos Capilares, Tônicos Capilares, Óleos Para Terapia Capilar.
* **Limpeza:** Shampoos, Condicionadores, Sabonetes.
* **Bem-estar e Aromaterapia:** Óleos Essenciais, Hidrolatos, Hidrolatos Florais, Blends Fórmulas Exclusivas.
* **Nutrição:** Óleos Vegetais, Seivas Naturais, Gel Aloe Vera, Géis De Aloe Vera.
* **Coloração e Terapia Profunda:** Tinturas Vegetais, Tintura Mãe, Argila, Argilas.
* **Estética:** Óleos Para Cílios E Sobrancelhas.
* **Uso Geral:** Qualquer outra subcategoria não mapeada.

### 3. `etapa_jornada_produto`
Nível de engajamento e maturidade do produto na jornada do consumidor.
* **1. Entrada:** Shampoos, Condicionadores, Argila, Argilas, Gel Aloe Vera.
* **2. Tratamento:** Óleos Capilares, Óleos Vegetais, Hidrolatos, Hidrolatos Florais.
* **3. Intensificação:** Tônicos Capilares, Óleos Essenciais, Tintura Mãe, Seivas Naturais.
* **4. Manutenção:** Subcategorias contendo "Kit" ou similares.

### 4. `nivel_especializacao`
Complexidade de aplicação e instrução necessária de uso do produto.
* **1. Básico:** Shampoos, Condicionadores, Kits, Kits De Óleos Vegetais, Kits De Óleos Capilares, Kits De Óleos, Gel Aloe Vera.
* **2. Intermediário:** Óleos Vegetais, Óleos Capilares, Argila, Argilas, Hidrolatos.
* **3. Avançado:** Óleos Essenciais, Blends Fórmulas Exclusivas.
* **4. Especialista:** Tintura Mãe, Tônicos Capilares, Seivas Naturais, Tinturas Vegetais.

### 5. `faixa_valor_produto`
Segmentação por tíquete médio do item individual (Receita Total / Quantidade):
* **1. Entrada (< R$50)**
* **2. Médio (R$50-100)**
* **3. Premium (R$100-200)**
* **4. High Ticket (> R$200)**

### 6. `potencial_recorrencia`
Estimativa de consumo/esgotamento do produto para campanhas de remarketing.
* **1. Alto:** Shampoos, Condicionadores, Tônicos Capilares, Tintura Mãe, Seivas Naturais, Gel Aloe Vera, Géis De Aloe Vera.
* **2. Médio:** Óleos Capilares, Óleos Para Terapia Capilar, Tinturas Vegetais, Blends Fórmulas Exclusivas, Argila, Argilas, Hidrolatos, Hidrolatos Florais, Cremes Base, Óleos De Massagem, Extratos Oleosos, Óleos Para Cílios E Sobrancelhas.
* **3. Baixo:** Óleos Essenciais, Óleos Vegetais, Óleos Naturais, Kits, Cartão Presente, Toalhas.
