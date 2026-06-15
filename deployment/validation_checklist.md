# Checklist de Validação Pré-Deploy (BigQuery Views)

Este checklist deve ser seguido rigorosamente para qualquer alteração na view `growth_engine_vendas_detalhado`.

---

## 🟩 Fase 1: Validação em Staging

- [ ] **1. Implantação em Staging:**
  Implante o novo código SQL na view de homologação:
  `iron-rex-461220-g4.customer_intelligence.growth_engine_vendas_detalhado_staging`.

- [ ] **2. Teste de Receita Auditada:**
  Execute o script `sql/tests/revenue_validation.sql` (apontando para a view de staging) e certifique-se de que o faturamento retornado seja exatamente **R$ 9.540.041,07** (Diferença = 0.00).

- [ ] **3. Teste de Duplicidade (Fan-out):**
  Execute `sql/tests/duplicate_check.sql` na view de staging. O resultado deve retornar `total_duplicados = 0` e `status = ✅ PASS`.

- [ ] **4. Teste de Categorias Nulas:**
  Execute `sql/tests/null_category_check.sql` e verifique se novos produtos criados sem categoria foram cobertos pelas regras de fallback ou se há alertas a serem tratados.

- [ ] **5. Teste de Consistência Matemática:**
  Execute `sql/tests/item_granularity_check.sql` para garantir que o faturamento de itens bata com os dados transacionais brutos (`total_raw` vs `total_view`).

---

## 🟨 Fase 2: Impacto em Dashboard e Esquema

- [ ] **6. Schema Check (Quebra de Campo):**
  Verifique se algum campo foi renomeado, removido ou teve seu tipo alterado (ex: `receita_total` mudou de `NUMERIC` para `FLOAT`). Qualquer mudança desse tipo quebrará o Looker Studio.
- [ ] **7. SmartMetrics Preservation:**
  Confirme no código que as 6 dimensões SmartMetrics calculadas continuam presentes e funcionais:
  * `familia_produto`
  * `objetivo_produto`
  * `etapa_jornada_produto`
  * `nivel_especializacao`
  * `faixa_valor_produto`
  * `potencial_recorrencia`

---

## 🟦 Fase 3: Implantação e Monitoramento

- [ ] **8. Aprovação do PR:**
  Garanta que o Pull Request no GitHub recebeu aprovação de pelo menos um par (Peer Review) e passou no checklist do PR.
- [ ] **9. Deploy em Produção:**
  Execute o script `deployment/deploy_view.sql` no Console do BigQuery para atualizar a visão principal de Produção.
- [ ] **10. Re-teste em Produção:**
  Rode os testes da pasta `/sql/tests/` diretamente contra a view de Produção para homologação final.
- [ ] **11. Atualização do Log:**
  Adicione um registro na pasta `governance/change_log.md` detalhando a alteração, autor e os resultados de validação.
