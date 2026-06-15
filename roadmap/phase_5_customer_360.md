# Fase 5: Visão Unificada do Cliente (Customer 360)

## 🎯 Objetivo
Habilitar a visão consolidada de dados socioeconômicos e logísticos por cliente para otimizar margens regionais e guiar campanhas de marketing direcionadas.

---

## 📋 Entregáveis & Ações

### 1. Enriquecimento da Camada Semântica
* Integrar a tabela `customer_profile_enriched` diretamente na view de vendas detalhadas para permitir quebras socioeconômicas (renda, IDH) no Looker Studio.
* Habilitar coordenadas geográficas para plotagem de mapas reais de vendas no painel.

### 2. Otimização de Margem Logística
* Cruzar a distância linear (`distancia_cd_km`) com o frete real rateado por item para identificar desvios de custos de frete por transportadora e região.

### 3. Integração de Modelos de IA
* Acoplar as previsões de Churn, Propensão e LTV preditivo da tabela `customer_predictions` diretamente ao perfil do cliente, gerando inteligência ativa para réguas de CRM.
