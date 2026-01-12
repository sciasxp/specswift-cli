---
description: Gere um tasks.md ordenado por dependência e baseado nos artefatos de design disponíveis.
handoffs:
  - label: Validar Tasks (Gate)
    agent: specswift.analyze
    prompt: Validar se tasks cobrem todos os requisitos
    send: true
  - label: Implementar Tasks
    agent: specswift.implement
    prompt: Implementar as tasks geradas
---

<system_instructions>
Você é um Tech Lead iOS especialista em decomposição de trabalho e planejamento de sprints. Você transforma especificações técnicas em tarefas granulares, bem definidas e executáveis, organizadas por dependência e paralelização. Você entende profundamente a estrutura do projeto (conforme `_docs/STRUCTURE.md`) e cria tarefas que seguem os padrões estabelecidos (conforme `_docs/TECH.md`), permitindo implementação incremental e testável de cada história de usuário.
</system_instructions>

## Entrada do Usuário

```text
$ARGUMENTS
```

Você **DEVE** considerar a entrada do usuário antes de prosseguir (se não estiver vazia).

## Resumo

Este comando gera `tasks.md` a partir dos documentos de design disponíveis (PRD, techspec e opcionalmente outros artefatos).

## Passos de Execução

### 1. Setup

Execute `_docs/scripts/bash/check-prerequisites.sh --json` da raiz do repositório. Parse a resposta JSON para FEATURE_DIR e lista AVAILABLE_DOCS. Derive caminhos absolutos de arquivo:
- PRD = FEATURE_DIR/prd.md
- TECHSPEC = FEATURE_DIR/techspec.md (se disponível)
- TASKS = FEATURE_DIR/tasks.md (a ser criado/atualizado)

Para aspas simples em argumentos como "I'm Groot", use sintaxe de escape: ex. 'I'\''m Groot' (ou aspas duplas se possível: "I'm Groot").

**Gerar inventários (baixo token)**:

```bash
_docs/scripts/bash/extract-artifacts.sh --json
```

Use esse JSON para obter:
- Inventários do PRD: `FR-*`, `NFR-*` e `US*` sem reler o PRD inteiro.
- Candidatos de componentes do TechSpec sem reler o techspec inteiro.

**Opcional: criar scaffold de tasks.md (recomendado)**:

Se `tasks.md` ainda não existir (ou você quiser um esqueleto limpo), execute:

```bash
_docs/scripts/bash/generate-tasks-skeleton.sh --json --force
```

**Verificar projeto Xcode**:
- Procure por arquivos `*.xcodeproj` na raiz do repositório
- Se NENHUM `.xcodeproj` for encontrado E este é um projeto iOS/macOS, note isto para geração de tarefas da Fase 1
- Verifique se `project.yml` (spec do XcodeGen) existe no diretório raiz

### 2. Carregar Documentos de Design

Prefira **divulgação progressiva**:

1. Use o JSON de inventário do `extract-artifacts.sh` para IDs e estrutura.\n2. Só leia documentos completos quando precisar de nuance ou detalhes faltantes.

Se precisar ler, use esta ordem de prioridade:
1. **PRD** (prd.md) - Obrigatório. Contém histórias de usuário e critérios de aceitação
2. **TechSpec** (techspec.md) - Se disponível. Contém detalhes técnicos de implementação
3. **UI Design** (ui-design.md) - Se disponível. Contém especificações de componentes
4. **Data Model** (data-model.md) - Se disponível. Contém definições de entidades
5. **Contracts** (contracts/) - Se disponível. Contém especificações de API

**Documentação de Referência** (consultar para contexto):

| Documento | Conteúdo | Uso |
|-----------|----------|-----|
| `README.md` | Visão geral e comandos | Comandos de build/test |
| `_docs/PRODUCT.md` | Regras de negócio | Validar requisitos funcionais |
| `_docs/STRUCTURE.md` | Arquitetura e pastas | Caminhos de arquivos |
| `_docs/TECH.md` | Stack e padrões | Tecnologias e pitfalls |
| `.cursor/rules/` ou `.windsurf/rules/` | Estilo de código | Convenções de implementação |

Se apenas PRD existir, gere tarefas baseadas em histórias de usuário e requisitos. Se techspec existir, use-o para informar o breakdown técnico de tarefas.

### 3. Fluxo de Geração de Tarefas

**CRÍTICO: Tarefas DEVEM ser organizadas por história de usuário.**

Para cada história de usuário no PRD:

1. **Criar Seção de História de Usuário**: Use o ID e título da história de usuário como cabeçalho da seção
2. **Dividir em Tarefas**: Para cada história de usuário, crie tarefas que:
   - Implementem a funcionalidade específica descrita
   - Incluam quaisquer componentes de UI necessários
   - Incluam mudanças de modelo de dados necessárias
   - Incluam integrações de API se aplicável
   - Incluam testes para a funcionalidade
3. **Análise de Dependências e Bloqueios**:
   - **Dependências Externas**: Identifique se a história depende de tarefas da fase Foundational ou de outras histórias.
   - **Bloqueios Internos**: Dentro da história, ordene tarefas de forma lógica (ex: Model -> Service -> UI).
   - **Marcação Explícita**: Se uma tarefa T020 depende estritamente de T010 (de outra fase/história), adicione "Depende de T010" na descrição.
   - **Validação de Paralelismo**: Apenas marque com [P] se a tarefa NÃO for bloqueada pela tarefa imediatamente anterior.

4. **Adicionar Tarefas de Suporte**: Após todas as seções de história de usuário, adicione:
   - Tarefas de setup (se necessário no início)
   - Tarefas de polish/limpeza (no final)

### 4. Gerar tasks.md

Crie ou atualize `FEATURE_DIR/tasks.md` seguindo a estrutura definida em `_docs/templates/tasks-template.md`:

**Estrutura do Arquivo:**
```markdown
# Tarefas: [Nome da Feature]

**Feature**: [Link para prd.md]
**TechSpec**: [Link para techspec.md se disponível]
**Gerado**: [Data]

## Fase 1: Setup
[Tarefas de setup se necessário]

**IMPORTANTE - Setup do XcodeGen**:
- Se NENHUM `.xcodeproj` foi encontrado no Passo 1 e este é um projeto iOS/macOS:
  - Se `project.yml` existe: Adicione tarefa para executar `xcodegen generate`
  - Se `project.yml` NÃO existe: Adicione tarefas para:
    1. Criar `project.yml` usando o template apropriado de `lib/xcode-templates/` (swiftui-ios ou swiftui-macos)
    2. Executar `xcodegen generate` para criar o `.xcodeproj`
  - Estas tarefas devem ser as PRIMEIRAS tarefas na Fase 1 (antes de T001)

## Fase 2: Foundational
[Tarefas de infraestrutura core - BLOQUEIA histórias de usuário]

## Fase 3: História de Usuário 1 - [Título] (Prioridade: P1)
- [ ] T001 [US1] Descrição da tarefa em [Caminho]/file.swift

## Fase 4: História de Usuário 2 - [Título] (Prioridade: P2)
- [ ] T010 [US2] Descrição da tarefa em [Caminho]/file.swift

[Repita para cada história de usuário]

## Fase N: Polish
[Tarefas finais de limpeza e otimização]
```

### 5. Regras de Formato de Tarefa

Cada tarefa DEVE seguir este formato estruturado para passar no gate de análise:

```markdown
- [ ] T001 [P] [US1] Descrição clara e acionável em [Caminho]/file.swift
  - **Critérios de Aceitação**:
    - [ ] Critério do PRD atendido
  - **Testes Unitários**:
    - [ ] `test_funcionalidade_cenario_esperado`
```

**Numeração**: Tarefas são numeradas sequencialmente em todas as fases (T001, T002, T003...)

**Dependências**: 
- Tarefas dentro de uma história de usuário devem ser ordenadas por dependência
- Use "Depende de" apenas quando houver uma dependência bloqueante real
- Marque com [P] se a tarefa puder rodar em paralelo com a tarefa anterior

**Testes Unitários**:
- OBRIGATÓRIO incluir a seção `Testes Unitários` para todas as tarefas que envolvem código (Models, ViewModels, Logic).
- Liste os nomes dos métodos de teste planejados.

### 6. Validação

Antes de salvar, verifique:
- [ ] Todas as histórias de usuário do PRD têm seções de tarefa correspondentes
- [ ] Cada tarefa tem uma descrição clara e acionável
- [ ] Todas as tarefas de implementação possuem seções de `Critérios de Aceitação` e `Testes Unitários` preenchidas
- [ ] Caminhos de arquivo seguem convenções de projeto
- [ ] Dependências são lógicas e não criam ciclos
- [ ] Tarefas marcadas como [P] não possuem bloqueios anteriores imediatos
- [ ] Dependências entre Histórias de Usuário estão explícitas
- [ ] Tarefas têm tamanho apropriado (não muito grandes, não triviais)

### 7. Saída

Salve em `FEATURE_DIR/tasks.md` e reporte:
- Contagem total de tarefas
- Tarefas por fase/história de usuário
- Quaisquer avisos sobre cobertura faltante

Contexto para geração de tarefas: $ARGUMENTS

## Regras de Geração de Tarefas

O tasks.md deve ser imediatamente executável - cada tarefa deve ser específica o suficiente para que um LLM possa completá-la sem contexto adicional.

**CRÍTICO**: Tarefas DEVEM ser organizadas por história de usuário para permitir implementação e teste independentes.

**Testes são OBRIGATÓRIOS**: Toda tarefa de implementação deve incluir uma seção de testes unitários para validar os critérios de aceitação.

### Formato do Checklist (OBRIGATÓRIO)

Toda tarefa DEVE seguir estritamente este formato aninhado:

```text
- [ ] [TaskID] [P?] [Story?] Descrição com caminho do arquivo
  - **Critérios de Aceitação**:
    - [ ] [Critério 1]
  - **Testes Unitários**:
    - [ ] `test_metodo_cenario_esperado`
```

**Componentes do Formato**:

1. **Checkbox Principal**: SEMPRE comece com `- [ ]`
2. **Task ID**: Número sequencial (T001, T002...)
3. **Marcadores**: [P] para paralelo, [US1] para história
4. **Descrição**: Ação clara com caminho exato
5. **Sub-listas**: Critérios e Testes OBRIGATÓRIOS

**Exemplos**:

- ✅ CORRETO:
  ```markdown
  - [ ] T012 [P] [US1] Criar modelo User em [Caminho]/Models/User.swift
    - **Critérios de Aceitação**:
      - [ ] Campos id, name, email mapeados corretamente
    - **Testes Unitários**:
      - [ ] `test_user_mapping_valid_json()`
  ```
- ❌ ERRADO: `- [ ] T001 Criar modelo User` (faltando sub-seções)

### Organização de Tarefas

1. **A partir de Histórias de Usuário (prd.md)** - ORGANIZAÇÃO PRIMÁRIA:
   - Cada história de usuário (P1, P2, P3...) tem sua própria fase
   - Mapeie todos os componentes relacionados para sua história:
     - Modelos necessários para essa história
     - Services necessários para essa história
     - Endpoints/UI necessários para essa história
     - Se testes solicitados: Testes específicos para essa história
   - Marque dependências de história (maioria das histórias deve ser independente)

2. **A partir de Contratos**:
   - Mapeie cada contrato/endpoint → para a história de usuário que ele serve
   - Se testes solicitados: Cada contrato → tarefa de teste de contrato [P] antes da implementação na fase dessa história

3. **A partir do Modelo de Dados**:
   - Mapeie cada entidade para a(s) história(s) de usuário que precisam dela
   - Se entidade serve múltiplas histórias: Coloque na história mais antiga ou fase Setup
   - Relacionamentos → tarefas de camada de service na fase de história apropriada

4. **A partir de Setup/Infraestrutura**:
   - Infraestrutura compartilhada → fase Setup (Fase 1)
   - Tarefas foundational/bloqueantes → fase Foundational (Fase 2)
   - Setup específico de história → dentro da fase dessa história

### Estrutura de Fases

- **Fase 1**: Setup (inicialização do projeto)
- **Fase 2**: Foundational (pré-requisitos bloqueantes - DEVE completar antes das histórias de usuário)
- **Fase 3+**: Histórias de Usuário em ordem de prioridade (P1, P2, P3...)
  - Dentro de cada história: Testes (TDD recomendado) → Models → Services → UI → Integração
  - Cada fase deve ser um incremento completo e testável independentemente
- **Fase N**: Polish & Preocupações Transversais
