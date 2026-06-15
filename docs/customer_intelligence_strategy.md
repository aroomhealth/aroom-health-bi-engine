# Estratégia de Inteligência de Clientes (Customer Intelligence)

Este documento detalha o plano para explorar a camada de inteligência socioeconômica, demográfica e logística a partir da tabela `customer_profile_enriched` e dos modelos preditivos de machine learning.

---

## 🎯 Pilares da Inteligência de Clientes

### 1. Otimização Logística (Eficiência e Frete)
* **Cruzamento de Distância e Custos:** Analisar a correlação entre `distancia_cd_km` e `custo_frete` real cobrado para calibrar as tabelas de frete contratadas.
* **Margem Logística:** Deduzir o frete real da receita de cada item para calcular o lucro bruto logístico por região.

### 2. Segmentação Socioeconômica & Marketing
* **Targeting por Renda:** Direcionar campanhas de tráfego pago para localizações censitárias com `renda_media_setor` elevada.
* **Indicador de Expansão:** Cruzar o IDH (`idh_municipio`) e densidade demográfica para identificar cidades com alto potencial de abertura de novos mercados ou parcerias físicas.

### 3. Modelagem Preditiva de LTV e Churn
* **Integração RFM:** Integrar os resultados do modelo `customer_rfm` para enviar e-mails automatizados segmentados por recência, frequência e valor monetário.
* **Churn Preditivo:** Acionar alertas de remarketing no CRM para clientes classificados com alto risco na tabela `growth_engine_churn_risco`.
