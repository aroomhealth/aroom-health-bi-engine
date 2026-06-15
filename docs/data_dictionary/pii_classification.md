# Classificação de PII e Dados Sensíveis (PII Classification)

Este documento classifica os campos do ecossistema de BI da **Aroom Health** em conformidade com as diretrizes de privacidade de dados (LGPD) e segurança corporativa, definindo regras para manuseio de Informações Pessoais Identificáveis (PII).

---

## 🔒 Níveis de Sensibilidade de Dados

Classificamos os campos em três níveis de risco:
*   **Alta (High):** Dados de identificação direta (PII Direta). Acesso restrito e criptografado. Nunca devem ser expostos em dashboards Looker Studio sem mascaramento.
*   **Média (Medium):** Informações de localização detalhada ou dados comerciais estratégicos (PII Indireta). Acesso controlado.
*   **Baixa (Low):** Dados agregados, categorias de produtos e métricas transacionais sem associação a indivíduos. Acesso público interno.

---

## 🏷️ Matriz de Classificação de Campos

### 1. Dados Pessoais Identificáveis Diretos (Sensibilidade: ALTA)

Estes campos expõem a identidade direta do consumidor. Devem ser excluídos de views de modelagem semântica ampla e restringidos na camada de ingestão (`Raw`):

| Tabela de Origem | Campo | Tipo de Dado | Categoria LGPD | Risco | Recomendação de Governança |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `database_aroom_health.contato` | `nome` | STRING | Nome Completo | Alta | Mascarar no BI; acessar apenas via Hash |
| `database_aroom_health.contato` | `email` | STRING | E-mail | Alta | Proibir exibição em painéis de BI |
| `database_aroom_health.contato` | `telefone` | STRING | Telefone Celular | Alta | Criptografar ou tokenizar na carga |
| `database_aroom_health.contato` | `cnpj` / `cpf` | STRING | Documento ID | Alta | Restringir ao faturamento contábil contido no ERP |

### 2. Dados de Localização e Geolocalização (Sensibilidade: MÉDIA)

Podem permitir a reidentificação de indivíduos se cruzados com dados externos:

| Tabela de Origem | Campo | Tipo de Dado | Categoria LGPD | Risco | Recomendação de Governança |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `customer_profile_enriched` | `cep` | STRING | Endereçamento | Média | Utilizar apenas o prefixo de 5 dígitos no BI |
| `customer_profile_enriched` | `latitude` | FLOAT64 | Coordenada | Média | Arredondar para 3 casas decimais (precisão de bairro) |
| `customer_profile_enriched` | `longitude`| FLOAT64 | Coordenada | Média | Arredondar para 3 casas decimais (precisão de bairro) |
| `pedidos_vendas` | `observacoes`| STRING | Texto Livre | Média | Limpar via Regex para remover telefones ou nomes |

### 3. Dados Comerciais Sensíveis (Sensibilidade: MÉDIA)

Não são PII, mas expõem segredos comerciais e margens de lucro concorrenciais da empresa:

| Tabela de Origem | Campo | Tipo de Dado | Categoria | Risco | Recomendação de Governança |
| :--- | :--- | :--- | :--- | :--- | :--- |
| `produtos` | `preco_custo`| FLOAT64 | Cost (COGS) | Média | Acesso restrito a perfis de CFO, Controladoria e Growth |
| `pedidos_vendas_itens` | `comissao_valor`| NUMERIC | Cost | Média | Acesso restrito a perfis financeiros |

---

## 🚫 Regras Práticas para Analistas de BI

1.  **Exclusão por Padrão:** As tabelas de produção de CRM e Growth (como `growth_engine_vendas_detalhado`) **não devem** conter campos como e-mail, telefone ou nome completo. As associações de clientes devem ser feitas exclusivamente pelo ID técnico anônimo (`contato_id` ou `customer_id`).
2.  **Mascaramento de CEP:** Ao expor dados geográficos, use sempre a coluna agrupada `estado` (UF) ou converta o CEP para máscara regional (ex: `01311-XXX`), garantindo o anonimato residencial dos clientes da Aroom Health.
