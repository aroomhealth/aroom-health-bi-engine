# PROMPT — NotebookLM: Apresentação de Negócios Aroom Health
## Data de Referência: Maio de 2026

---

## INSTRUÇÕES PARA O NOTEBOOKLM

Você é um **Diretor de Analytics e Estratégia de Dados** apresentando para o board executivo da **Aroom Health**.

Crie uma apresentação de negócios profissional em formato de **10 slides**, mostrando o impacto das correções de dados aplicadas na Phase 2.

O tom deve ser: executivo, orientado a resultado financeiro, com linguagem de negócio (não técnica). Use os dados reais abaixo como fonte única de verdade.

---

## DADOS REAIS — MAIO DE 2026

### 📦 Performance Geral (Maio/2026)
- Total de pedidos: **3.986 pedidos**
- Clientes únicos: **3.842 clientes**
- Receita bruta: **R$ 348.034**
- Ticket médio: **R$ 87,31**
- Canais ativos: **15 canais de venda**

### 📊 Distribuição de Receita por Canal (Maio/2026)
| Canal ID | Pedidos | Receita | % da Receita | Ticket Médio |
|:---|:---:|:---:|:---:|:---:|
| Canal 205956810 | 695 | R$ 106.514 | 30.6% | R$ 153,26 |
| Canal 204690454 | 777 | R$ 62.317 | 17.9% | R$ 80,20 |
| Canal 205999827 | 588 | R$ 41.969 | 12.1% | R$ 71,38 |
| Canal 204966758 | 672 | R$ 41.649 | 12.0% | R$ 61,98 |
| Canal 204665789 | 529 | R$ 35.441 | 10.2% | R$ 67,00 |
| Canal 204429796 | 322 | R$ 20.422 | 5.9% | R$ 63,43 |
| Canal 205304103 | 185 | R$ 19.119 | 5.5% | R$ 103,35 |
| Outros 7 canais | 218 | R$ 20.601 | 6.0% | — |

### 🎯 Atribuição de Marketing (Maio/2026)
| Situação | Pedidos | Receita | % Receita |
|:---|:---:|:---:|:---:|
| **Sem atribuição de campanha** | 3.951 | R$ 342.927 | **98.3%** |
| Com atribuição GA4 | 38 | R$ 5.900 | 1.7% |

### 🚚 Status de Entrega (Maio/2026)
| Status | Pedidos | Receita | % |
|:---|:---:|:---:|:---:|
| NF Vinculada (em processo) | 2.384 | R$ 222.526 | 59.8% |
| NF Autorizada (entregue) | 1.602 | R$ 125.507 | 40.2% |

### 🔎 SKUs sem Cadastro Ativos em Maio/2026
| SKU | Tipo | Pedidos | Receita sem Margem |
|:---|:---|:---:|:---:|
| 5503full | Variante Volume (óleo Ojon 100ml) | 34 | R$ 3.136 |
| 5565FULL | Variante Volume (óleo Ojon 30ml) | 37 | R$ 1.499 |
| 5459full | Variante Volume (óleo Ojon 50ml) | 20 | R$ 1.108 |
| 5565full | Variante Volume (óleo Ojon 30ml) | 3 | R$ 122 |
| **Total** | | **94** | **R$ 5.866** |

---

## CONTEXTO ANTES DAS CORREÇÕES

### Estado ANTES (Phase 1 — Diagnóstico)
| Problema | Situação Antes | Impacto Financeiro |
|:---|:---|:---:|
| Atribuição de campanha | 5.4% da receita total atribuível | R$ 9.0M "cegos" |
| Identity resolution | 0% de join pedido→cliente por ID | CRM sem segmentação |
| Taxa de conversão checkout | Aparente: 12.5% | Funil de conversão irreal |
| SKUs sem margem | 510 SKUs = R$ 95.170 sem custo | Margem bruta subestimada |
| Status de entrega | 0% de rastreio (campo vazio) | Sem KPI operacional |
| Emails inválidos/ausentes | 35.3% dos clientes sem email | 42k clientes inacessíveis |

### Estado DEPOIS (Phase 2 — Correções Aplicadas)
| Problema | Situação Depois | Melhoria |
|:---|:---|:---:|
| Atribuição de campanha | View de atribuição criada; SST especificado | Base para escalar para 100% |
| Identity resolution | Bridge CPF: 45.522 pedidos ligados ao cliente | +35% de pedidos linkados |
| Taxa de conversão checkout | Real: **58.5%** via email bridge | +46pp de visibilidade |
| SKUs sem margem | 27 SKUs `full` mapeados para produto base | Correção imediata disponível |
| Status de entrega | Proxy via NF: 100% dos pedidos cobertos | 52.3% NF autorizada |
| Emails para CRM | 82 emails recuperáveis identificados (Nuvemshop) | Ação imediata de enriquecimento |

---

## ESTRUTURA DE SLIDES SUGERIDA

### Slide 1 — Capa
**Título:** "Aroom Health — Data Intelligence Report"
**Subtítulo:** "Diagnóstico e Correções Phase 2 | Maio de 2026"

### Slide 2 — Resumo Executivo
**Título:** "O Problema: Dados Não Conectados = Decisões no Escuro"
**Conteúdo:**
- R$ 9.5M de faturamento anual sem visibilidade de qual campanha gerou cada venda
- 42.000 clientes sem email = impossível fazer CRM eficiente
- Taxa de conversão aparente de 12.5% escondia a realidade de 58.5%
- 510 SKUs vendidos sem custo cadastrado = margem bruta calculada errada
**Mensagem:** "Corrigir esses 6 problemas é pré-requisito para crescimento escalável"

### Slide 3 — Performance de Maio 2026 (Números Reais)
**Título:** "Aroom Health em Maio de 2026"
**Gráfico tipo:** 4 KPI cards grandes
- 💰 R$ 348.034 de receita bruta
- 📦 3.986 pedidos
- 👥 3.842 clientes únicos
- 🎫 R$ 87,31 ticket médio
**Gráfico secundário:** Pizza de receita por canal

### Slide 4 — O Maior Gap: Atribuição de Marketing
**Título:** "98.3% da Receita de Maio Sem Saber de Onde Veio"
**Gráfico tipo:** Donut chart (grande visual de impacto)
- 🔴 Sem atribuição: R$ 342.927 (98.3%)
- 🟢 Com atribuição GA4: R$ 5.900 (1.7%)
**Mensagem:** "Estamos investindo em campanhas sem saber qual funciona. A solução (Server-Side Tagging) foi especificada e está pronta para implementação."

### Slide 5 — Identidade do Cliente: Antes vs. Depois
**Título:** "De 0% para 35%: Ligando Pedidos a Clientes"
**Gráfico tipo:** Horizontal bar chart "antes vs. depois"
- ANTES: 0 pedidos com identidade de cliente por ID
- DEPOIS: 45.522 pedidos linkados ao cliente via CPF bridge
**Insight adicional:** "Com Server-Side Tagging + CPF bridge = visão 360° do cliente possível"

### Slide 6 — A Surpresa do Funil de Conversão
**Título:** "Taxa de Conversão Real: 58.5%, Não 12.5%"
**Gráfico tipo:** Funil antes/depois lado a lado
- ANTES (só token): 320 conversões rastreadas = 12.5%
- DEPOIS (com email+CPF bridge): 2.073 conversões rastreadas = 58.5%
**Breakdown:** TOKEN 9% | EMAIL 47.3% | CPF 2.2% | Abandono real 41.5%
**Mensagem:** "O funil não estava quebrado. A medição estava. 58.5% é uma taxa saudável para e-commerce de saúde/beleza."

### Slide 7 — SKUs sem Margem: Oportunidade de Correção Rápida
**Título:** "R$ 5.866 Vendidos em Maio sem Custo Registrado"
**Gráfico tipo:** Tabela visual com produto + receita + ação
- 5503full → Óleo Ojon 100ml → R$ 3.136 → CADASTRAR VARIANTE
- 5565FULL → Óleo Ojon 30ml → R$ 1.499 → CADASTRAR VARIANTE
- 5459full → Óleo Ojon 50ml → R$ 1.108 → CADASTRAR VARIANTE
**Mensagem:** "Ação: 27 SKUs 'full' já têm produto base cadastrado. Basta vincular a variante no Bling — 2 horas de trabalho operacional."

### Slide 8 — Operacional: Status de Entrega
**Título:** "100% dos Pedidos com Status Rastreável via NF"
**Gráfico tipo:** Stacked bar
- NF Autorizada: 1.602 pedidos — R$ 125.507 (40.2%)
- NF Vinculada: 2.384 pedidos — R$ 222.526 (59.8%)
**Antes:** Campo fulfillment_status = 0% preenchido, sem visibilidade
**Depois:** Proxy via Nota Fiscal cobre 100% dos pedidos

### Slide 9 — Roadmap: O Que Vem a Seguir
**Título:** "Phase 3: Do Diagnóstico ao Crescimento"
**Timeline visual (3 sprints):**
Sprint 1 (Julho): Server-Side Tagging → de 1.7% para 100% de atribuição
Sprint 2 (Agosto): Cadastro de 27 SKUs `full` + enriquecimento de 82 emails
Sprint 3 (Setembro): Customer 360 completo + dashboards de ROAS por canal
**KPI alvo Phase 3:** 80% da receita atribuível por campanha

### Slide 10 — Impacto Financeiro Esperado
**Título:** "O Retorno do Investimento em Dados"
**Tabela de impacto:**
| Ação | Custo Estimado | Receita/Benefício Liberado |
|:---|:---:|:---:|
| Server-Side Tagging | 40h dev | R$ 342.927/mês rastreável |
| Cadastro 27 SKUs full | 2h ops | R$ 5.866/mês com margem |
| Email recovery 82 clientes | 1h ops | 82 clientes p/ CRM |
| CRM segmentado (bridge CPF) | 20h data | 45.522 pedidos com perfil |
**Mensagem final:** "Infraestrutura de dados bem construída é vantagem competitiva. Cada R$1 investido em dados libera dezenas em decisões melhores."

---

## FORMATAÇÃO PARA NOTEBOOKLM

Ao gerar a apresentação, use:
- Tom: executivo, direto, orientado a impacto financeiro
- Linguagem: português BR, sem jargão técnico
- Números: sempre com R$ e separadores de milhar
- Insights: sempre com "ANTES → DEPOIS"
- Conclusão de cada slide: sempre com uma linha de "Próxima ação"
- Não use termos como BigQuery, SQL, Python, ETL, VIEW ou dataset

---

## DADOS PARA GRÁFICOS

### Gráfico 1 — Pizza Receita por Canal (Maio/2026)
```
Canal A (205956810): 30.6% — R$ 106.514 — Ticket R$ 153
Canal B (204690454): 17.9% — R$ 62.317 — Ticket R$ 80
Canal C (205999827): 12.1% — R$ 41.969 — Ticket R$ 71
Canal D (204966758): 12.0% — R$ 41.649 — Ticket R$ 62
Canal E (204665789): 10.2% — R$ 35.441 — Ticket R$ 67
Canal F (204429796):  5.9% — R$ 20.422 — Ticket R$ 63
Canal G (205304103):  5.5% — R$ 19.119 — Ticket R$ 103
Outros:               6.0% — R$ 20.601
```

### Gráfico 2 — Donut Atribuição (Maio/2026)
```
SEM ATRIBUIÇÃO: 98.3% — R$ 342.927
COM ATRIBUIÇÃO: 1.7%  — R$ 5.900
```

### Gráfico 3 — Funil Antes/Depois
```
ANTES (só token match):
  session → checkout → pedido → rastreado: 12.5%

DEPOIS (com bridge email + CPF):
  session → checkout → pedido → rastreado: 58.5%
    - Via token:  9.0%
    - Via email: 47.3%
    - Via CPF:    2.2%
  Abandono real: 41.5%
```

### Gráfico 4 — Identidade Antes/Depois
```
ANTES: 0 pedidos com cliente identificado por ID
DEPOIS: 45.522 pedidos linkados ao cliente (35% do total)
  - Via CPF:   45.522 pedidos — R$ 3.93M
  - Via email:     25 pedidos — R$ 1.9k
```

### Gráfico 5 — SKUs sem Margem (Maio/2026)
```
5503full: R$ 3.136 — Óleo Ojon 100ml — VARIANTE_VOLUME
5565FULL: R$ 1.499 — Óleo Ojon 30ml — VARIANTE_VOLUME
5459full: R$ 1.108 — Óleo Ojon 50ml — VARIANTE_VOLUME
5565full: R$   122 — Óleo Ojon 30ml — VARIANTE_VOLUME
TOTAL:    R$ 5.866 em Maio sem margem calculável
```

### Gráfico 6 — Status de Entrega (Maio/2026)
```
NF Vinculada (em processo): 2.384 pedidos — R$ 222.526 — 59.8%
NF Autorizada (concluída):  1.602 pedidos — R$ 125.507 — 40.2%
```

### Gráfico 7 — Roadmap Phase 3 (Timeline)
```
Julho 2026:    Server-Side Tagging → 100% atribuição
Agosto 2026:   SKU fix + email recovery
Setembro 2026: Customer 360 + dashboards ROAS
Meta Q3 2026:  80% receita atribuível por campanha
```
