# Tarefas: [NOME DA FEATURE]

**Feature**: [SHORT_NAME]  
**Branch**: `feature/[SHORT_NAME]`  
**Status**: Rascunho | Em Revisão | Aprovado  
**PRD**: `_docs/specs/[SHORT_NAME]/prd.md`  
**TechSpec**: `_docs/specs/[SHORT_NAME]/techspec.md`

---

### 📍 Fluxo de Trabalho

```
✅ PRD → ✅ TechSpec → ✅ Tasks (atual) → ⭕ Implementação
```

**Próximo passo**: Após aprovação, execute `/specswift.implement` ou `/specswift.analyze` para validar

---

**Pré-requisitos**: techspec.md (obrigatório), prd.md (obrigatório para histórias de usuário)

**Organização**: Tarefas são agrupadas por história de usuário (US1, US2, US3...) para permitir implementação e teste independentes.

## Formato da Tarefa

Cada tarefa deve seguir a estrutura abaixo para garantir conformidade com o gate de análise (`/specswift.analyze`):

```markdown
- [ ] [ID] [P?] [Story] Descrição da tarefa com caminho de arquivo
  - **Critérios de Aceitação**:
    - [ ] [Critério 1 do PRD/Techspec]
  - **Testes Unitários**:
    - [ ] `test_<funcionalidade>_<cenário>_<resultado_esperado>`
```

- **[P]**: Pode rodar em paralelo
- **[Story]**: ID da História de Usuário (ex: US1)
- **Testes Unitários**: OBRIGATÓRIO para todas as tasks de lógica/UI.

## Documentação de Referência

Antes de criar tarefas, consulte a documentação do projeto:

| Documento | Conteúdo | Uso |
|-----------|----------|-----|
| `README.md` | Visão geral e comandos | Comandos de build/test |
| `_docs/PRODUCT.md` | Regras de negócio | Validar requisitos funcionais |
| `_docs/STRUCTURE.md` | Arquitetura e pastas | Caminhos de arquivos |
| `_docs/TECH.md` | Stack e padrões | Tecnologias e pitfalls |
| `.windsurf/rules/` | Estilo de código | Convenções de implementação |

<!-- 
  ============================================================================
  IMPORTANTE: As tarefas abaixo são TAREFAS DE EXEMPLO apenas para ilustração.
  
  O comando /specswift.tasks DEVE substituir estas com tarefas reais baseadas em:
  - Histórias de usuário do prd.md (com suas prioridades P1, P2, P3...)
  - Requisitos de feature do techspec.md
  - Entidades do data-model.md
  - Endpoints do contracts/
  
  Tarefas DEVEM ser organizadas por história de usuário para que cada história possa ser:
  - Implementada independentemente
  - Testada independentemente
  - Entregue como um incremento MVP
  
  NÃO mantenha estas tarefas de exemplo no arquivo tasks.md gerado.
  ============================================================================
-->

## Fase 1: Setup (Infraestrutura Compartilhada)

**Propósito**: Inicialização do projeto e estrutura básica

- [ ] T001 Criar estrutura do projeto conforme plano de implementação em techspec.md
- [ ] T002 Garantir que o projeto compila e dependências resolvem
- [ ] T003 [P] Configurar ferramentas de linting e formatação

---

## Fase 2: Foundational (Pré-requisitos Bloqueantes)

**Propósito**: Infraestrutura core que DEVE estar completa antes de QUALQUER história de usuário ser implementada

**⚠️ CRÍTICO**: Nenhum trabalho de história de usuário pode começar até esta fase estar completa

Exemplos de tarefas foundational (ajuste baseado no seu projeto):

- [ ] T004 Configurar persistência + pontos de entrada de migração
- [ ] T005 [P] Implementar fundações de autenticação/token (armazenamento seguro, verificações de expiração)
- [ ] T006 [P] Confirmar convenções de networking (endpoints, uso compartilhado de services)
- [ ] T007 Criar/confirmar modelos/entidades base usados entre histórias
- [ ] T008 Configurar convenções de error reporting/logging
- [ ] T009 Configurar toggles de ambiente/config (debug, feature flags)

**Checkpoint**: Fundação pronta - implementação de história de usuário pode começar em paralelo

---

## Fase 3: US1 - [Título] (Prioridade: P1) 🎯 MVP

**Objetivo**: [Breve descrição do que esta história entrega]

**Teste Independente**: [Como verificar se esta história funciona sozinha]

### Testes para US1

> **NOTA: Escreva estes testes PRIMEIRO, garanta que FALHAM antes da implementação**

- [ ] T010 [P] [US1] Testes unitários para [ViewModel/Model]
  - **Critérios de Aceitação**:
    - [ ] Testes falham inicialmente
    - [ ] Cobertura de cenários de sucesso e erro
  - **Testes Unitários**:
    - [ ] `test_init_state()`
    - [ ] `test_load_success()`

### Implementação para História de Usuário 1

- [ ] T012 [P] [US1] Criar/atualizar modelo(s)
  - **Critérios de Aceitação**:
    - [ ] Entidade mapeada corretamente
    - [ ] Campos obrigatórios definidos
  - **Testes Unitários**:
    - [ ] `test_entity_mapping()`
    - [ ] `test_primary_key()`

- [ ] T013 [P] [US1] Criar/atualizar repository/manager
  - **Critérios de Aceitação**:
    - [ ] CRUD básico implementado
    - [ ] Tratamento de erros de banco
  - **Testes Unitários**:
    - [ ] `test_save_success()`
    - [ ] `test_fetch_returns_data()`

- [ ] T014 [US1] Implementar lógica de negócio (depende de T012, T013)
  - **Critérios de Aceitação**:
    - [ ] Regras de negócio X e Y validadas
  - **Testes Unitários**:
    - [ ] `test_business_logic_rule_x()`

- [ ] T015 [US1] Implementar fluxo de UI e wiring de navegação
  - **Critérios de Aceitação**:
    - [ ] Tela segue design system
    - [ ] Navegação funciona corretamente
  - **Testes Unitários**:
    - [ ] `test_view_loading()`
    - [ ] `test_button_action()`

- [ ] T016 [US1] Adicionar validação e tratamento de erros
  - **Critérios de Aceitação**:
    - [ ] Erros amigáveis ao usuário
  - **Testes Unitários**:
    - [ ] `test_error_presentation()`

- [ ] T017 [US1] Adicionar diagnósticos (breadcrumbs, eventos de monitoramento se aplicável)
  - **Critérios de Aceitação**:
    - [ ] Eventos de analytics disparados
  - **Testes Unitários**:
    - [ ] `test_analytics_event_trigger()`

**Checkpoint**: Neste ponto, US1 deve estar completamente funcional e testável independentemente

---

## Fase 4: US2 - [Título] (Prioridade: P2)

**Objetivo**: [Breve descrição do que esta história entrega]

**Teste Independente**: [Como verificar se esta história funciona sozinha]

### Testes para US2

- [ ] T018 [P] [US2] Testes unitários para [componente]
  - **Critérios de Aceitação**:
    - [ ] Cobertura de novos casos de uso
  - **Testes Unitários**:
    - [ ] `test_new_feature_behavior()`

### Implementação para US2

- [ ] T020 [P] [US2] Crie/atualize o modelo
  - **Critérios de Aceitação**:
    - [ ] Novos campos/entidades adicionados
  - **Testes Unitários**:
    - [ ] `test_model_update()`

- [ ] T021 [US2] Implemente alterações no repositório/manager e lógica de negócio
  - **Critérios de Aceitação**:
    - [ ] Lógica de persistência atualizada
  - **Testes Unitários**:
    - [ ] `test_repo_update()`

- [ ] T022 [US2] Implemente alterações de UI + navegação
  - **Critérios de Aceitação**:
    - [ ] Nova tela/componente integrado
  - **Testes Unitários**:
    - [ ] `test_ui_update()`

- [ ] T023 [US2] Integre com componentes de US1 (se necessário)
  - **Critérios de Aceitação**:
    - [ ] Sem regressão em US1
  - **Testes Unitários**:
    - [ ] `test_integration_us1_us2()`

**Checkpoint**: Neste ponto, US1 e US2 devem funcionar independentemente

---

## Fase 5: US3 - [Título] (Prioridade: P3)

**Objetivo**: [Breve descrição do que esta história entrega]

**Teste Independente**: [Como verificar se esta história funciona sozinha]

### Testes para US3

- [ ] T024 [P] [US3] Testes unitários para [componente]
  - **Critérios de Aceitação**:
    - [ ] Lógica complexa validada
  - **Testes Unitários**:
    - [ ] `test_complex_logic()`

### Implementação para US3

- [ ] T026 [P] [US3] Crie/atualize o modelo
  - **Critérios de Aceitação**:
    - [ ] Modelo finalizado
  - **Testes Unitários**:
    - [ ] `test_final_model_state()`

- [ ] T027 [US3] Implemente alterações no repositório/manager e lógica de negócio
  - **Critérios de Aceitação**:
    - [ ] Persistência completa
  - **Testes Unitários**:
    - [ ] `test_full_persistence()`

- [ ] T028 [US3] Implemente alterações de UI + navegação
  - **Critérios de Aceitação**:
    - [ ] UI polida e funcional
  - **Testes Unitários**:
    - [ ] `test_final_ui_state()`

**Checkpoint**: Todas as histórias de usuário agora devem ser independentemente funcionais

---

[Adicione mais fases de história de usuário conforme necessário, seguindo o mesmo padrão]

---

## Fase N: Polish & Preocupações Transversais

**Propósito**: Melhorias que afetam múltiplas histórias de usuário

- [ ] TXXX [P] Atualizações de documentação em `_docs/`
- [ ] TXXX Limpeza e refatoração de código
- [ ] TXXX Otimização de desempenho em todas as histórias
- [ ] TXXX [P] Testes unitários adicionais
- [ ] TXXX Segurança reforçada
- [ ] TXXX Execute `make test` para targets relevantes

---

## Dependências & Ordem de Execução

### Dependências de Fase

- **Setup (Fase 1)**: Sem dependências - pode começar imediatamente
- **Foundational (Fase 2)**: Dependente da conclusão do Setup - BLOQUEIA todas as histórias de usuário
- **Histórias de Usuário (Fase 3+)**: Todas dependem da conclusão da fase Foundational
  - Histórias de usuário podem então prosseguir em paralelo (se estiverem equipadas)
  - Ou sequencialmente em ordem de prioridade (P1 → P2 → P3)
- **Polish (Fase Final)**: Dependente da conclusão de todas as histórias de usuário desejadas

### Dependências de História de Usuário

- **História de Usuário 1 (P1)**: Pode começar após Foundational (Fase 2) - Sem dependências de outras histórias
- **História de Usuário 2 (P2)**: Pode começar após Foundational (Fase 2) - Pode integrar com US1 mas deve ser testável independentemente
- **História de Usuário 3 (P3)**: Pode começar após Foundational (Fase 2) - Pode integrar com US1/US2 mas deve ser testável independentemente

### Dentro de Cada História de Usuário

- Testes DEVEM ser escritos e FALHAR antes da implementação
- Models/Repositories antes de ViewModels/ViewControllers
- Repositories antes de mudanças de networking (endpoints)
- Implementação core antes de integração
- História completa antes de mover para próxima prioridade

### Oportunidades Paralelas

- Todas as tarefas de Setup marcadas [P] podem rodar em paralelo
- Todas as tarefas Foundational marcadas [P] podem rodar em paralelo (dentro da Fase 2)
- Uma vez que fase Foundational complete, todas as histórias de usuário podem começar em paralelo (se capacidade do time permitir)
- Todos os testes para uma história de usuário marcados [P] podem rodar em paralelo
- Models dentro de uma história marcados [P] podem rodar em paralelo
- Diferentes histórias de usuário podem ser trabalhadas em paralelo por diferentes membros do time

---

## Estratégia de Implementação

### MVP Primeiro (Apenas História de Usuário 1)

1. Complete Fase 1: Setup
2. Complete Fase 2: Foundational (CRÍTICO - bloqueia todas as histórias)
3. Complete Fase 3: História de Usuário 1
4. **PARE e VALIDE**: Teste História de Usuário 1 independentemente
5. Deploy/demo se pronto

### Entrega Incremental

1. Complete Setup + Foundational → Fundação pronta
2. Adicione História de Usuário 1 → Teste independentemente → Deploy/Demo (MVP!)
3. Adicione História de Usuário 2 → Teste independentemente → Deploy/Demo
4. Adicione História de Usuário 3 → Teste independentemente → Deploy/Demo
5. Cada história adiciona valor sem quebrar histórias anteriores

### Estratégia de Time Paralelo

Com múltiplos desenvolvedores:

1. Time completa Setup + Foundational juntos
2. Uma vez que Foundational esteja feito:
   - Desenvolvedor A: História de Usuário 1
   - Desenvolvedor B: História de Usuário 2
   - Desenvolvedor C: História de Usuário 3
3. Histórias completam e integram independentemente

---

## Notas

- Tarefas [P] = arquivos diferentes, sem dependências
- Rótulo [Story] mapeia tarefa para história de usuário específica para rastreabilidade
- Cada história de usuário deve ser completável e testável independentemente
- Verifique que testes falham antes de implementar
- Commit após cada tarefa ou grupo lógico
- Pare em qualquer checkpoint para validar história independentemente
- Evite: tarefas vagas, conflitos de mesmo arquivo, dependências entre histórias que quebram independência

---

## Tarefas de Integração e Verificação *(obrigatório)*

<!--
  CRÍTICO: Estas tarefas devem ser adaptadas para os padrões descritos em _docs/TECH.md.
  Adicione na Fase N (Polish) ou onde apropriado.
-->

### Verificações Obrigatórias

- [ ] TXXX Verificar impacto na persistência e migrações
- [ ] TXXX Adicionar diagnósticos/logging para debugging
- [ ] TXXX Verificar comportamento em diferentes estados de rede (online/offline)
- [ ] TXXX Testar em todos os ambientes configurados

### Verificações de Padrões

- [ ] TXXX Seguir padrões de navegação do projeto
- [ ] TXXX Acesso a dados via camada de persistência (não direto em Views)
- [ ] TXXX Lógica de negócio em Models/Services (não em UI)
- [ ] TXXX Dados sensíveis em armazenamento seguro (ex: Keychain)

### Documentação

- [ ] TXXX Atualizar documentação técnica se novos módulos criados
- [ ] TXXX Atualizar CHANGELOG se feature significativa
