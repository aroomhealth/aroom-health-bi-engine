# Matriz de Responsabilidade & Governança (RACI)

Este documento define os proprietários de dados, revisores e quem deve ser consultado antes de alterar as regras de negócio analíticas da **Aroom Health**.

---

## 📋 Matriz RACI

* **R (Responsible):** Quem executa a tarefa/implementa a alteração.
* **A (Accountable):** Quem tem a palavra final e é o responsável final pelo resultado.
* **C (Consulted):** Quem precisa ser consultado antes de realizar a alteração.
* **I (Informed):** Quem precisa ser informado após a alteração ter sido efetuada.

| Ativo de Dados / Processo | Proprietário Primário | R | A | C | I |
| :--- | :--- | :---: | :---: | :---: | :---: |
| **View `growth_engine_vendas_detalhado`** | Analytics Engineer | R | A | C | I |
| **SmartMetrics Engine Dimensions** | Sócios / BI Lead | C | A | R | I |
| **Ingestão Bling (Tabelas Transacionais)** | Data Engineer | R | A | I | C |
| **Dados Google Ads / Facebook Ads** | Mkt Ops / Sócios | R | C | A | I |
| **Painel Looker Studio** | BI Analyst | R | A | C | I |

---

## 🔑 Contatos Chave de Decisão

* **Responsável Técnico (GCP/BigQuery Admin):** Renan Strano de Oliveira
* **Proprietários de Regras de Negócio (SmartMetrics):** Sócios Fundadores
* **Gestão de Tráfego & Marketing Digital (Google Ads):** Marketing Operations Team
