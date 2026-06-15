# Diagnóstico & Plano de Recuperação - Google Ads Data Pipeline

Este documento apresenta a análise técnica sobre a interrupção da atualização dos dados de campanhas do Google Ads e o plano para restabelecer a integração de forma nativa e resiliente.

---

## 🔍 O Problema

* **Tabela Afetada:** `iron-rex-461220-g4.database_aroom_health.google_ads_campaign_performance` (ou tabela correlata no dataset `google_ads`).
* **Data da Interrupção:** **12 de dezembro de 2025**.
* **Sintoma:** Nenhum dado incremental foi inserido após essa data.
* **Causa Provável:** Falha em script customizado de ingestão (ex: expiração de tokens OAuth de longa duração, deprecriação da versão da Google Ads API utilizada no script ou falha na máquina executora/scheduler).

---

## 🛠️ Solução Recomendada: BigQuery Data Transfer Service (DTS)

Recomendamos **fortemente** a substituição de qualquer script customizado (Python, Node.js, etc.) pelo **BigQuery Data Transfer Service para Google Ads**.

### Vantagens do DTS:
1. **Nativo e Gerenciado:** O Google gerencia a autenticação, atualizações da API do Google Ads (que muda constantemente) e o pipeline de dados. Zero manutenção de código.
2. **Custo Gratuito:** O serviço de transferência de dados do Google Ads para o BigQuery é **gratuito** (aplica-se apenas o custo padrão de armazenamento e consulta do BigQuery, que é desprezível para este volume).
3. **Histórico Automático:** Permite agendar retroativos (backfills) de forma simples para recuperar os dados perdidos desde 12/12/2025.

---

## 📋 Passo a Passo para Recuperação

### Passo 1: Configurar a Transferência no GCP Console
1. Acesse o **Console do GCP** no projeto `iron-rex-461220-g4`.
2. Vá em **BigQuery** > **Data Transfer** (Transferência de dados) e clique em **Create Transfer**.
3. No campo **Source Type**, selecione **Google Ads**.
4. Defina o nome da transferência como `Google Ads Sync`.
5. Selecione o dataset de destino (sugerimos criar `google_ads_v2` para evitar conflito imediato com tabelas corrompidas antigas).
6. No ID do Cliente (Customer ID), insira o ID da conta do Google Ads da Aroom Health (formato `XXX-XXX-XXXX`).
7. Salve e autorize o acesso com a conta do Google que possui acesso de leitura à conta do Google Ads.

### Passo 2: Executar Backfill (Recuperação de Histórico)
1. Após a criação da transferência, clique em **Schedule Backfill** (Agendar preenchimento).
2. Configure o período de início como **12/12/2025** e fim como a **data atual**.
3. O BigQuery iniciará a carga dos dados históricos perdidos.

### Passo 3: Configurar Alertas de Monitoramento
1. No console da transferência, configure notificações de falha via **Pub/Sub** ou integre com o **Cloud Monitoring**.
2. Configure um alerta de email ou Slack para notificar imediatamente se uma execução diária falhar.

### Passo 4: Atualização da Camada Semântica
* Crie uma view de compatibilidade chamada `google_ads.campaign_performance_unified` que una a tabela antiga histórica com as tabelas novas do DTS (caso a estrutura seja ligeiramente diferente) ou simplesmente aponte os dashboards para as novas tabelas geradas pelo DTS.
