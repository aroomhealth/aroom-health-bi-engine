# Fase 1: Lock de Controle de Versão & Fonte de Verdade

## 🎯 Objetivo
Estabelecer o controle de versão como fonte única da verdade para todas as consultas do BigQuery e impedir edições ad-hoc no ambiente de produção.

---

## 📋 Entregáveis & Ações

### 1. Inicializar Repositório Git
* Commit da estrutura recomendada de governança no repositório GitHub da Aroom Health.
* Bloquear commits diretos nas branches `main` e `dev` no GitHub.

### 2. Configurar a View de Staging
* Executar o script de criação da view `growth_engine_vendas_detalhado_staging`.
* Certificar-se de que a conta do desenvolvedor tenha permissões adequadas em staging e produções.

### 3. Implementar Testes Automatizados Locais
* Configurar testes locais na máquina de desenvolvimento rodando os scripts de validação de faturamento antes de abrir pull requests.
