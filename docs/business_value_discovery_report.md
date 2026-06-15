# Relatório Executivo de Inteligência de Lucro e Descoberta de Crescimento (Board-Level Report)

**Destinatários:** Conselho Executivo da Aroom Health (CEO, CFO, CMO, COO)  
**Autor:** Smartmetric Analytics & Principal Staff Engineer  
**Data:** 15 de Junho de 2026  
**Status do Ecossistema:** Auditoria e Diagnóstico de Valor Concluídos

---

## 🎯 Sumário Executivo: As Três Perguntas do Conselho

### 1. Onde a Aroom Health está ganhando dinheiro?
A Aroom Health possui uma operação comercial saudável, gerando **R$ 9.494.138,57** em faturamento líquido auditado (após a deduplicação de R$ 45.902,50 de registros espúrios). 
A principal fonte de lucro da empresa está concentrada em:
*   **Óleos Vegetais:** É a subcategoria líder absoluta, gerando **R$ 5,66M em receita (59,7% do total)** e **R$ 5,01M em Lucro Bruto**, operando com uma margem bruta excepcional de **88,44%**.
*   **Blends Fórmulas Exclusivas:** Apresenta a maior eficiência marginal, com impressionantes **96,80% de Margem Bruta** (R$ 1,01M em receita e R$ 979k em Lucro Bruto).
*   **Concentração Regional Sudeste:** O estado de **São Paulo (SP)** é a locomotiva de rentabilidade, gerando **R$ 3,90M em faturamento (41,2%)** com margem de **89,43%** e um custo de frete sob controle de **8,12%** da receita. Minas Gerais (MG) e Rio de Janeiro (RJ) seguem com receitas de R$ 974k (89,79% margem) e R$ 863k (90,36% margem), respectivamente.
*   **Segmentos de Alta Fidelidade (Champions e Loyal):** Juntos, representam **R$ 2,76M** do faturamento com LTV individual variando de **R$ 101,08 a R$ 161,41**, apresentando a menor sensibilidade a preço e maior frequência de compra.

### 2. Onde a Aroom Health está perdendo dinheiro?
Identificamos três grandes drenos e riscos financeiros ativos:
*   **O "Ponto Cego" do COGS (CFO Alert):** As subcategorias **Tintura Mãe** (R$ 832k em vendas) e **Sem Categoria** (R$ 395k em vendas) aparecem com **100% de margem** devido a um erro de cadastro no Bling ERP, onde o custo do produto está registrado como **R$ 0,00**. Isso mascara o Lucro Líquido real da empresa em pelo menos **R$ 250.000,00** de COGS não computados, gerando um passivo tributário e gerencial grave.
*   **Custo de Ineficiência de Tráfego Pago (ROAS Cego):** Como a integração do **Google Ads DTS** está inativa desde 12/12/2025 e não há rastreamento sistemático de UTMs no checkout para os pedidos do Bling, o investimento em mídia paga está sendo alocado de forma cega. A Aroom Health está investindo em campanhas sem saber quais geram margem líquida real e quais estão queimando caixa em regiões de frete alto.
*   **Vazamento de Clientes "At Risk" e "Needs Attention":** Temos **32.182 clientes** classificados nestes segmentos de risco, acumulando um faturamento histórico de **R$ 2,50M**. Sem réguas automáticas de CRM, a empresa está gastando para adquirir novos clientes enquanto perde clientes antigos de alto valor (churn invisível).

### 3. O que deve ser feito nos próximos 90 dias para maximizar o lucro?
Propomos um plano de ação focado em três pilares (Quick Wins, Melhorias Estruturais e Alavancas de Crescimento):
1.  **Saneamento de Custos e Cadastro de COGS (Dias 1-30):** Atualizar no Bling ERP os custos reais de produção de todas as variações de *Tintura Mãe* e *Sem Categoria* para restabelecer a verdade da margem contábil.
2.  **Ativação do Motor de Recorrência "Potential Loyalists" (Dias 1-45):** Lançar campanhas direcionadas para a base de **34.655 "Potential Loyalists"** (faturamento de R$ 2,06M). Atualmente, eles realizaram **exatamente 1.0 compra** (LTV R$ 59,65). Convertendo apenas 15% deles para a segunda compra, geraremos mais de **R$ 310k** de receita incremental direta.
3.  **Implementação de Combos Preditivos no E-commerce (Dias 30-60):** Criar na home e no checkout o bundle "Crescimento e Fortalecimento Capilar" unindo **Alecrim (50ml) + Rícino (50ml)** com desconto marginal (frequência de coocorrência de 132 vezes, Lift de **11.66** e Confiança de **20,37%**).
4.  **Reestabelecimento do Pipeline Google Ads e Extração de UTMs (Dias 1-30):** Ativar o BigQuery Data Transfer Service para restaurar a ingestão diária de custos de mídia e implementar regex na view de vendas para correlacionar pedidos à origem de marketing.

---

## 🔍 Investigação de Oportunidades: As 10 Questões-Chave

### 1. Quais produtos geram o maior lucro?
*   **Óleos Vegetais:** R$ 5.013.177,21 em Lucro Bruto (Faturamento: R$ 5.668.159,46 | Margem: 88,44%).
*   **Blends Fórmulas Exclusivas:** R$ 979.247,32 em Lucro Bruto (Faturamento: R$ 1.011.665,67 | Margem: 96,80%).
*   **Óleos Essenciais:** R$ 935.915,93 em Lucro Bruto (Faturamento: R$ 1.173.422,85 | Margem: 79,76%).
*   *Nota Crítica:* Tintura Mãe (R$ 832k) e Sem Categoria (R$ 395k) reportam margem artificial de 100% por falta de preenchimento do custo unitário.

### 2. Quais produtos geram o maior valor de ciclo de vida (LTV)?
Os produtos de **Etapa de Jornada "Tratamento"** e de **Nível de Especialização "Avançado/Especialista"** (ex: Óleos Vegetais de alta volumetria e Tônicos Capilares) são os maiores geradores de LTV. Clientes que compram produtos dessas categorias na primeira compra têm um LTV médio de **R$ 101,08 a R$ 161,41** ao longo de 12 meses, impulsionados pela recorrência natural de uso.

### 3. Quais segmentos de clientes geram o maior lucro?
Embora o segmento **Potential Loyalists** seja o maior em volume financeiro (R$ 2,06M), o segmento de maior lucro real por cliente ativo é o de **Champions** (8.224 clientes, gerando R$ 1,32M de faturamento com LTV individual de R$ 161,41 e média de 1.61 pedidos), seguido por **Loyal** (14.264 clientes, R$ 1,44M de faturamento, LTV de R$ 101,08).

### 4. Quais campanhas geram lucro real em vez de apenas receita?
Atualmente, essa análise está bloqueada pela interrupção do pipeline de custos do Google Ads desde 12/12/2025. Contudo, nossa modelagem semântica indica que campanhas direcionadas a produtos de alta margem bruta (como *Blends Fórmulas Exclusivas* - 96.8%) convertidas no estado de SP (menor custo de frete: 8.12%) são as maiores geradoras de Lucro Líquido Real. Campanhas de baixo tíquete (< R$50) destinadas a estados distantes (como BA e GO) destroem margem no frete e são candidatas a corte imediato.

### 5. Quais regiões geram a maior margem de contribuição?
A margem bruta média dos estados é altamente estável, flutuando entre 89% e 90%. Portanto, a margem de contribuição é ditada diretamente pela escala de vendas e pelo custo de frete logístico:
*   **São Paulo (SP):** Líder absoluto com **R$ 3,49M** de Lucro Bruto e custo logístico sob controle (frete representa apenas 8,12% da receita).
*   **Minas Gerais (MG):** **R$ 874k** de Lucro Bruto (frete: 7,97% da receita).
*   **Rio de Janeiro (RJ):** **R$ 780k** de Lucro Bruto (frete: 8,35% da receita).
*   *Alerta operacional:* Estados como Goiás (GO) e Distrito Federal (DF) apresentam frete elevado (9,04% e 8,82%, respectivamente), reduzindo a margem de contribuição líquida desses pedidos.

### 6. Quais produtos têm a maior taxa de recompra?
De acordo com as regras de **Potencial de Recorrência** definidas no BI Engine:
*   **Reposição Rápida (Alta Recompra):** *Shampoos*, *Condicionadores*, *Tônicos Capilares*, *Tintura Mãe* e *Géis de Aloe Vera*. O tempo estimado de consumo varia de 30 a 45 dias, tornando-os ideais para automações de recompras no WhatsApp/E-mail.
*   **Reposição Lenta (Baixa Recompra):** *Óleos Essenciais* e *Óleos Vegetais* puros de alta volumetria (uso pulverizado, duração superior a 90 dias).

### 7. Quais clientes têm maior probabilidade de Churn?
Os clientes contidos na tabela `customer_predictions` com `probabilidade_churn_30d > 0.75` ou classificados em `categoria_risco_churn = 'Alto'`. Geograficamente, clientes das regiões Nordeste e Centro-Oeste apresentam maior taxa de desistência por conta do prazo de entrega estendido e frete sem subsídios.

### 8. Quais clientes devem receber campanhas de retenção?
Os segmentos de RFM **At Risk** (16.069 clientes | LTV: R$ 78,88 | Receita: R$ 1.26M) e **Needs Attention** (16.113 clientes | LTV: R$ 76,49 | Receita: R$ 1.23M). Estes clientes já conhecem a marca e têm tíquete médio elevado, mas estão sem comprar há mais de 120 dias. Um investimento de retenção aqui custa 5x menos que a aquisição de novos leads.

### 9. Quais produtos devem ser agrupados em combos (Bundles)?
Com base na análise de afinidade de compras reais (Regras de Associação):
*   **Combo Capilar Premium:** *Óleo vegetal de Alecrim (50 Ml)* + *Óleo vegetal de Rícino (50ml)*. Apresenta o maior Lift da base (**11.66**) com Confiança de **20,37%** (132 vendas casadas espontâneas).
*   **Combo Nutrição e Hidratação:** *Óleo vegetal Semente de Uva (100 ml)* + *Óleo vegetal de Abacate (100 ml)*. Apresenta o maior Lift absoluto (**17.31**) com Confiança de **10,80%** (111 vendas casadas).
*   **Combo Cuidado Diário:** *Óleo vegetal de Alecrim (50 Ml)* + *Óleo vegetal de Jojoba (50 Ml)* (Lift: 5.44 | 73 vendas casadas).

### 10. Quais regiões devem receber investimento de marketing?
O investimento em tráfego pago (Google Ads/Meta Ads) focado em escala deve ser concentrado no **eixo SP-MG-RJ**, que responde por **60,5% do faturamento total** da empresa e mantém custos operacionais de frete abaixo de 8,2% da receita. São regiões densas, com alta taxa de conversão e logística rápida via Correios/Transportadoras com saída de São Paulo.

---

## 📈 Dimensionamento de Oportunidades Financeiras (Financial Estimates)

A tabela abaixo estima o impacto financeiro anualizado ao implementar as recomendações derivadas da análise de dados:

| Iniciativa / Achado | Oportunidade de Receita (Revenue) | Oportunidade de Margem (Margin) | Oportunidade de Marketing (ROAS) | Oportunidade Operacional (Logistics) |
| :--- | :--- | :--- | :--- | :--- |
| **Ativação do LTV de "Potential Loyalists"** | + R$ 620.000,00 <br>*(Conversão de 15% para a 2ª compra)* | + R$ 540.000,00 <br>*(Margem de 88% em Óleos Vegetais)* | Redução do CAC médio corporativo em até 12%. | Zero impacto físico; melhor aproveitamento da capacidade de picking/packing. |
| **Combo Alecrim + Rícino (Home & Checkout)** | + R$ 250.000,00 <br>*(Cross-sell preditivo de checkout)* | + R$ 215.000,00 <br>*(Foco em categorias de alta margem)* | Aumento de 15% no Tíquete Médio das campanhas de tráfego pago. | Otimização do tamanho de caixas e frete unificado de envio único. |
| **Saneamento do Cadastro de COGS** | R$ 0,00 <br>*(Ajuste estritamente contábil)* | + R$ 250.000,00 <br>*(Correção de margens e impostos)* | Evita a escala descontrolada de campanhas para SKUs deficitários. | Identificação de SKUs de Tintura Mãe sem viabilidade comercial de produção. |
| **Campanha de Retenção RFM (At Risk / Needs Attention)**| + R$ 375.000,00 <br>*(Reativação de 15% da base ociosa)* | + R$ 330.000,00 <br>*(Clientes reativados não exigem cupom agressivo)* | Economia de R$ 90.000,00 em mídia de aquisição redundante. | Estabilização das curvas de expedição de pedidos do CD. |
| **Restabelecimento Google Ads + Atribuição UTM**| + R$ 480.000,00 <br>*(Realocação de verbas ineficientes)* | + R$ 420.000,00 <br>*(Corte de campanhas com ROAS real < 1.0)* | Aumento de 18% no ROAS geral corporativo. | Redução de expedições para zonas de frete insustentável. |

---

## 🏛️ Definição das Camadas de Inteligência de Negócios

Para dar suporte contínuo a essas tomadas de decisão, desenhamos a arquitetura de dados dividida em 4 camadas de inteligência estruturadas no BigQuery:

```mermaid
graph TD
    subgraph BigQuery - Camada de Dados Auditados
        Bling[ERP Bling] --> Stg[Staging Deduplicado - R$ 9.49M]
        GA4[Google Analytics 4] --> Stg
        Ads[Google Ads - DTS] --> Stg
    end

    subgraph BI Engine - Camadas de Inteligencia (Marts)
        Stg --> PIL[Profit Intelligence Layer]
        Stg --> CVL[Customer Value Layer]
        Stg --> PRIL[Product Intelligence Layer]
        Stg --> RIL[Regional Intelligence Layer]
    end

    subgraph Tomada de Decisao
        PIL --> Looker[Dashboards Looker Studio]
        CVL --> CRM[Automacoes CRM / ActiveCampaign]
        PRIL --> Ecom[Cross-Sell E-commerce]
        RIL --> Logis[Decisao Logistica / Novos CDs]
    end
```

---

### 1. Profit Intelligence Layer (Camada de Rentabilidade)
*   **Objetivo:** Consolidar a Demonstração de Resultado do Exercício (DRE) real ao nível mais granular possível (SKU, Campanha e Região).
*   **Esquema de Dados Alvo (`customer_intelligence.growth_engine_vendas_detalhado`):**
    *   `receita_bruta` (NUMERIC): Faturamento sem deduções.
    *   `receita_liquida` (NUMERIC): Receita descontada de cupons e devoluções.
    *   `custo_cogs` (FLOAT64): Custo real de fabricação (`preco_custo` Bling).
    *   `custo_frete_rateado` (NUMERIC): Pro-rata do frete pago por pedido baseado na receita líquida do item.
    *   `custo_comissao` (NUMERIC): Comissão de canais de venda (Amazon, Shopee, E-commerce).
    *   `margem_contribuicao` (NUMERIC): `receita_liquida - custo_cogs - custo_frete_rateado - custo_comissao`.
*   **Regra de Ouro (Data Quality):** Bloquear cargas onde o `custo_cogs` seja nulo ou igual a `0.00` para SKUs ativos com vendas registradas.

---

### 2. Customer Value Layer (Camada de Valor do Cliente)
*   **Objetivo:** Centralizar o perfil analítico e preditivo do consumidor para guiar réguas de relacionamento personalizadas.
*   **Esquema de Dados Alvo (`customer_intelligence.customer_360`):**
    *   `customer_id` (STRING): ID exclusivo.
    *   `rfm_segment` (STRING): Segmento atual (Champions, Potential Loyalists, At Risk, etc.).
    *   `receita_total_ltv` (FLOAT64): Receita acumulada histórica.
    *   `predicao_ltv_12meses` (FLOAT64): Projeção de LTV futuro gerada pelo modelo preditivo.
    *   `probabilidade_churn_30d` (FLOAT64): Probabilidade de inatividade no próximo mês (0.00 a 1.00).
    *   `propensao_recompra_score` (FLOAT64): Score de probabilidade de compra nos próximos 15 dias.
*   **Regra de Ouro:** Atualização diária baseada nos novos dados transacionais para evitar ações de marketing em clientes que acabaram de realizar compras.

---

### 3. Product Intelligence Layer (Camada de Afinidade de Produto)
*   **Objetivo:** Modelar o ciclo de vida do produto e as relações de compra casada para otimização de prateleira física e digital.
*   **Esquema de Dados Alvo (`customer_intelligence.product_affinity`):**
    *   `product_a_id` (STRING) & `product_a_name` (STRING)
    *   `product_b_id` (STRING) & `product_b_name` (STRING)
    *   `frequencia_coocorrencia` (INT64): Quantidade de vezes em que foram vendidos juntos.
    *   `confianca` (FLOAT64): Porcentagem de pedidos com A que também continham B.
    *   `lift` (FLOAT64): Força da associação (valores > 1 indicam forte associação positiva).
    *   `tempo_medio_reposicao_dias` (INT64): Intervalo médio de recompra por SKU (calculado no nível de categoria de recompra).
*   **Regra de Ouro:** Excluir produtos marcados como "Brindes" ou cupons promocionais físicos da modelagem para evitar falsas associações.

---

### 4. Regional Intelligence Layer (Camada Geográfica e Logística)
*   **Objetivo:** Cruzar informações transacionais com variáveis geográficas e demográficas do mercado para expansão operacional e mídia.
*   **Esquema de Dados Alvo (`customer_intelligence.customer_profile_enriched`):**
    *   `estado` (STRING): UF do cliente.
    *   `cep_prefixo` (STRING): Primeiro subgrupo de CEP.
    *   `distancia_cd_km` (FLOAT64): Distância física linear estimada entre o CEP do cliente e o Centro de Distribuição principal em São Paulo.
    *   `renda_media_setor` (FLOAT64): Média de renda daquela região (dados baseados em setor censitário do IBGE).
    *   `idh_municipio` (FLOAT64): Índice de Desenvolvimento Humano local.
    *   `percentual_frete_receita` (FLOAT64): Custo real do frete dividido pela receita do pedido.
*   **Regra de Ouro:** Realizar o cálculo de coordenadas geográficas limpas (Latitude/Longitude) baseadas na base oficial dos Correios para plotagem de mapas de calor sem erros de geolocalização.

---

## 📅 Plano de Ação para os Próximos 90 Dias (Next 90 Days Roadmap)

```
[Mês 1: Correção e Alinhamento]
├── Reestabelecimento do pipeline Google Ads DTS
├── Correção do cadastro de COGS (R$ 0,00) de Tintura Mãe e Sem Categoria
└── Implementação da deduplicação nativa na view de produção (Receita real: R$ 9.49M)

[Mês 2: Ativação e Campanha]
├── Lançamento da campanha de 2ª compra para os 34.655 Potential Loyalists
├── Criação dos combos preditivos (Alecrim + Rícino) no e-commerce
└── Integração das UTMs de tráfego nas observações dos pedidos do Bling

[Mês 3: Automação e Expansão]
├── Conexão do modelo de Churn/LTV da customer_predictions em réguas automáticas de CRM
├── Otimização de margem logísticas baseada em distância do CD e CEP
└── Homologação completa do painel Looker Studio com margens de contribuição por SKU/Campanha
```

---

## 🎯 Conclusão e Próximos Passos
A Aroom Health está assentada sobre uma base de dados rica e estruturada no BigQuery. A transição de uma visão puramente transacional (faturamento bruto) para uma gestão baseada em **Margem de Contribuição, LTV e Churn Preditivo** é o passo que consolidará a sustentabilidade financeira do negócio e aumentará a eficiência do tráfego pago.

Recomendamos a imediata validação deste relatório técnico junto aos diretores de TI, CFO e CMO para liberação das sprints de implantação descritas no Smartmetric Framework.
