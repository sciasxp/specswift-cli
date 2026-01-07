<div align="center">

# SpecSwift Workflows

[English](#english) | [Português](#português)

</div>

---

# English

## Usage Guide

This document describes the SpecSwift workflow system for feature specification and implementation.

## Overview

SpecSwift is a set of workflows that guide the complete feature development process, from requirements specification to implementation.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            MAIN FLOW                                     │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  /specswift.create-prd ──► /specswift.create-techspec ──► /specswift.tasks │
│         │                                                    │          │
│         ▼                                                    ▼          │
│  /specswift.clarify                                    /specswift.analyze │
│   (optional)                                            (gate)          │
│                                                          │              │
│                                                          ▼              │
│                                                  /specswift.implement    │
│                                                          │              │
│                                                          ▼              │
│                                                   /specswift.retro       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                        ALTERNATIVE FLOWS                                 │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  /specswift.yolo ─────────────────────────────────────────────────────►  │
│  (Runs PRD → CLARIFY → TECHSPEC → TASKS → ANALYZE automatically)        │
│                                                                          │
│  /specswift.constitution ─► Updates project principles                   │
│                                                                          │
│  /specswift.taskstoissues ─► Converts tasks to GitHub Issues            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Main Flow (Interactive)

The main flow is ideal for features that require human review and conscious decisions.

### 1. `/specswift.create-prd` - Create PRD

**Purpose**: Create product requirements document from natural language description.

**Input**: Feature description
```
/specswift.create-prd Add text search functionality to publications
```

**Generated Artifacts**:
- `_docs/specs/[SHORT_NAME]/prd.md`
- `_docs/specs/[SHORT_NAME]/checklists/requirements.md`

**Next Steps**:
- `/specswift.clarify` - If there are ambiguities
- `/specswift.create-techspec` - If PRD is complete

---

### 2. `/specswift.clarify` - Clarify Requirements (Optional)

**Purpose**: Identify and resolve ambiguities in PRD through targeted questions.

**Features**:
- Interactive Q&A loop (max 5 questions)
- **Visual Clarification**: Generates SwiftUI previews or ASCII wireframes for UI ambiguities
- **Flow Prototyping**: Generates Mermaid/ASCII diagrams for complex logic

**Input**: None (uses PRD from current branch)
```
/specswift.clarify
```

**Updated Artifacts**:
- `prd.md` - With `## Esclarecimentos` section added

**Next Step**: `/specswift.create-techspec`

---

### 3. `/specswift.create-techspec` - Create Technical Specification

**Purpose**: Transform PRD requirements into detailed technical design.

**Input**: None (uses PRD from current branch)
```
/specswift.create-techspec
```

**Generated Artifacts**:
- `techspec.md` - Main technical specification
- `research.md` - Technology research and decisions
- `ui-design.md` - UI/UX design (if applicable)
- `data-model.md` - Data model
- `contracts/` - API contracts (if applicable)
- `quickstart.md` - Quick start guide
- `.agent.md` - Implementation context

**Next Step**: `/specswift.tasks`

---

### 4. `/specswift.tasks` - Generate Tasks

**Purpose**: Decompose technical specification into executable tasks ordered by dependency.

**Input**: None (uses PRD and TechSpec from current branch)
```
/specswift.tasks
```

**Generated Artifacts**:
- `tasks.md` - Task list with dependencies and tests

**Next Steps**:
- `/specswift.analyze` - Validate coverage (recommended)
- `/specswift.implement` - Implement directly

---

### 5. `/specswift.analyze` - Validation Gate

**Purpose**: Validate that all tasks cover PRD and TechSpec requirements before implementation.

**Input**: None (uses all artifacts from current branch)
```
/specswift.analyze
```

**Result**:
- 🟢 **APPROVED** - Ready for implementation
- 🔴 **BLOCKED** - Corrective actions needed

**Next Steps**:
- `/specswift.implement` - If approved
- `/specswift.taskstoissues` - Optional, create GitHub issues

---

### 6. `/specswift.implement` - Implement

**Purpose**: Execute tasks defined in `tasks.md`, implementing code and tests.

**Input**: None (uses tasks.md from current branch)
```
/specswift.implement
```

**Result**:
- Code implemented
- Tests executed
- Tasks marked as completed

**Next Step**: `/specswift.retro`

---

## Automatic Flow (YOLO Mode)

### `/specswift.yolo` - Full Autonomous Execution

**Purpose**: Run the entire pipeline without user intervention for **new features**.

**Prerequisites**:
- **Complete project base documentation (README.md, _docs/*.md, Makefile)**
- **Do not use for new projects (use `/specswift.constitution` first)**

**Ideal for**:
- Features with well-defined scope
- Rapid prototyping
- Exploratory spikes

**Input**: Feature description
```
/specswift.yolo Add date filter to publications
```

**Runs automatically**:
```
PRD → CLARIFY → TECHSPEC → TASKS → ANALYZE
```

**Characteristics**:
- **Zero questions to user**
- **Decisions based on best practices**
- **Auto-correction of issues**
- **Not recommended for security-critical features**

---

## Auxiliary Workflows

### `/specswift.constitution` - Create/Update Base Documentation

**Purpose**: Create or update project base documentation:
- `README.md` - Project overview
- `Makefile` - Automation commands
- `_docs/PRODUCT.md` - Product context
- `_docs/STRUCTURE.md` - Architecture and folders
- `_docs/TECH.md` - Stack and patterns

**When to use**:
- New project needing initial documentation
- Required documents are missing
- Updating architecture principles

**Characteristics**:
- Automatically detects if project is new or existing
- Up to 20 interactive questions
- Answers up to 20 words
- Recommendations based on Swift 6.2+, SwiftUI and SwiftData

```
/specswift.constitution
```

---

### `/specswift.taskstoissues` - Export to GitHub Issues

**Purpose**: Convert tasks from `tasks.md` to GitHub issues for external tracking.

**Prerequisites**:
- GitHub repository configured
- `tasks.md` exists

```
/specswift.taskstoissues
```

---

### `/specswift.retro` - Post-Implementation Retrospective

**Purpose**: Analyze completed feature against specifications to generate lessons learned.

**Input**: None (uses artifacts from current branch)

```
/specswift.retro
```

**Result**:
- `_docs/retro/[FEATURE].md` report
- Insights for constitution updates

---

## Artifacts Structure

All artifacts are stored in `_docs/specs/[SHORT_NAME]/`:

```
_docs/specs/add-search-feature/
├── prd.md                 # Product requirements
├── techspec.md            # Technical specification
├── tasks.md               # Task list
├── research.md            # Technical research
├── ui-design.md           # UI design
├── data-model.md          # Data model
├── quickstart.md          # Quick start guide
├── .agent.md              # Implementation context
├── checklists/
│   └── requirements.md    # Quality checklist
└── contracts/             # API contracts
    └── ...
```

---

## Quick Commands

| Goal | Command |
|------|---------|
| Create base documentation | `/specswift.constitution` |
| New feature (interactive) | `/specswift.create-prd [description]` |
| New feature (automatic) | `/specswift.yolo [description]` |
| Clarify requirements | `/specswift.clarify` |
| Create technical design | `/specswift.create-techspec` |
| Generate tasks | `/specswift.tasks` |
| Validate before implementing | `/specswift.analyze` |
| Implement | `/specswift.implement` |
| Export to GitHub | `/specswift.taskstoissues` |
| Retrospective | `/specswift.retro` |

---

## Recommended Flow by Feature Type

### New Project
```
constitution → create-prd → create-techspec → tasks → analyze → implement → retro
```

### Critical/Complex Feature
```
create-prd → clarify → create-techspec → tasks → analyze → implement → retro
```

### Simple/Well-Defined Feature
```
create-prd → create-techspec → tasks → implement → retro
```

### Spike/Prototyping
```
yolo → (review artifacts) → implement → retro
```

### Bug Fix
```
create-prd --type fix → create-techspec → tasks → implement → retro
```

---

## Usage Tips

1. **Always start with PRD** - Even for small features, PRD helps clarify scope

2. **Use the Gate (analyze)** - Avoid rework by validating coverage before implementing

3. **Review YOLO decisions** - Automatic mode makes conservative decisions, review if necessary

4. **Keep artifacts updated** - If scope changes, update PRD and propagate to TechSpec

5. **Use clarify when needed** - Better to ask now than rework later

---

# Português

## Guia de Uso

Este documento descreve o sistema de workflows SpecSwift para especificação e implementação de features.

## Visão Geral

O SpecSwift é um conjunto de workflows que guiam o processo completo de desenvolvimento de features, desde a especificação de requisitos até a implementação.

```
┌─────────────────────────────────────────────────────────────────────────┐
│                           FLUXO PRINCIPAL                                │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  /specswift.create-prd ──► /specswift.create-techspec ──► /specswift.tasks │
│         │                                                    │          │
│         ▼                                                    ▼          │
│  /specswift.clarify                                    /specswift.analyze │
│   (opcional)                                            (gate)          │
│                                                          │              │
│                                                          ▼              │
│                                                  /specswift.implement    │
│                                                          │              │
│                                                          ▼              │
│                                                   /specswift.retro       │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────┐
│                         FLUXOS ALTERNATIVOS                              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                          │
│  /specswift.yolo ─────────────────────────────────────────────────────►  │
│  (Executa PRD → CLARIFY → TECHSPEC → TASKS → ANALYZE automaticamente)   │
│                                                                          │
│  /specswift.constitution ─► Atualiza princípios do projeto              │
│                                                                          │
│  /specswift.taskstoissues ─► Converte tasks em GitHub Issues            │
│                                                                          │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## Fluxo Principal (Interativo)

O fluxo principal é ideal para features que requerem revisão humana e decisões conscientes.

### 1. `/specswift.create-prd` - Criar PRD

**Propósito**: Criar documento de requisitos de produto a partir de descrição em linguagem natural.

**Entrada**: Descrição da feature
```
/specswift.create-prd Adicionar funcionalidade de busca por texto nas publicações
```

**Artefatos Gerados**:
- `_docs/specs/[SHORT_NAME]/prd.md`
- `_docs/specs/[SHORT_NAME]/checklists/requirements.md`

**Próximos Passos**:
- `/specswift.clarify` - Se houver ambiguidades
- `/specswift.create-techspec` - Se PRD estiver completo

---

### 2. `/specswift.clarify` - Esclarecer Requisitos (Opcional)

**Propósito**: Identificar e resolver ambiguidades no PRD através de perguntas direcionadas.

**Funcionalidades**:
- Loop de perguntas e respostas interativas (máx 5 perguntas)
- **Esclarecimento Visual**: Gera previews SwiftUI ou wireframes ASCII para ambiguidades de UI
- **Prototipagem de Fluxo**: Gera diagramas Mermaid/ASCII para lógica complexa

**Entrada**: Nenhuma (usa PRD da branch atual)
```
/specswift.clarify
```

**Artefatos Atualizados**:
- `prd.md` - Com seção `## Esclarecimentos` adicionada

**Próximo Passo**: `/specswift.create-techspec`

---

### 3. `/specswift.create-techspec` - Criar Especificação Técnica

**Propósito**: Transformar requisitos do PRD em design técnico detalhado.

**Entrada**: Nenhuma (usa PRD da branch atual)
```
/specswift.create-techspec
```

**Artefatos Gerados**:
- `techspec.md` - Especificação técnica principal
- `research.md` - Pesquisa e decisões de tecnologia
- `ui-design.md` - Design de UI/UX (se aplicável)
- `data-model.md` - Modelo de dados
- `contracts/` - Contratos de API (se aplicável)
- `quickstart.md` - Guia de início rápido
- `.agent.md` - Contexto para implementação

**Próximo Passo**: `/specswift.tasks`

---

### 4. `/specswift.tasks` - Gerar Tarefas

**Propósito**: Decompor especificação técnica em tarefas executáveis ordenadas por dependência.

**Entrada**: Nenhuma (usa PRD e TechSpec da branch atual)
```
/specswift.tasks
```

**Artefatos Gerados**:
- `tasks.md` - Lista de tarefas com dependências e testes

**Próximos Passos**:
- `/specswift.analyze` - Validar cobertura (recomendado)
- `/specswift.implement` - Implementar diretamente

---

### 5. `/specswift.analyze` - Gate de Validação

**Propósito**: Validar que todas as tasks cobrem requisitos do PRD e TechSpec antes da implementação.

**Entrada**: Nenhuma (usa todos os artefatos da branch atual)
```
/specswift.analyze
```

**Resultado**:
- 🟢 **APROVADO** - Pronto para implementação
- 🔴 **BLOQUEADO** - Ações corretivas necessárias

**Próximos Passos**:
- `/specswift.implement` - Se aprovado
- `/specswift.taskstoissues` - Opcional, criar issues GitHub

---

### 6. `/specswift.implement` - Implementar

**Propósito**: Executar as tarefas definidas em `tasks.md`, implementando código e testes.

**Entrada**: Nenhuma (usa tasks.md da branch atual)
```
/specswift.implement
```

**Resultado**:
- Código implementado
- Testes executados
- Tasks marcadas como concluídas

**Próximo Passo**: `/specswift.retro`

---

## Fluxo Automático (YOLO Mode)

### `/specswift.yolo` - Execução Completa Autônoma

**Propósito**: Executar todo o pipeline sem intervenção do usuário para **novas features**.

**Pré-requisitos**:
- **Documentação base do projeto completa (README.md, _docs/*.md, Makefile)**
- **Não usar para projetos novos (use `/specswift.constitution` primeiro)**

**Ideal para**:
- Features com escopo bem definido
- Prototipagem rápida
- Spikes exploratórios

**Entrada**: Descrição da feature
```
/specswift.yolo Adicionar filtro por data nas publicações
```

**Executa automaticamente**:
```
PRD → CLARIFY → TECHSPEC → TASKS → ANALYZE
```

**Características**:
- **Zero perguntas ao usuário**
- **Decisões baseadas em melhores práticas**
- **Auto-correção de problemas**
- **Não recomendado para features críticas de segurança**

---

## Workflows Auxiliares

### `/specswift.constitution` - Criar/Atualizar Documentação Base

**Propósito**: Criar ou atualizar a documentação base do projeto:
- `README.md` - Visão geral do projeto
- `Makefile` - Comandos de automação
- `_docs/PRODUCT.md` - Contexto de produto
- `_docs/STRUCTURE.md` - Arquitetura e pastas
- `_docs/TECH.md` - Stack e padrões

**Quando usar**:
- Novo projeto que precisa de documentação inicial
- Documentos obrigatórios estão faltando
- Atualização de princípios de arquitetura

**Características**:
- Detecta automaticamente se é projeto novo ou existente
- Até 20 perguntas interativas
- Respostas de até 20 palavras
- Recomendações baseadas em Swift 6.2+, SwiftUI e SwiftData

```
/specswift.constitution
```

---

### `/specswift.taskstoissues` - Exportar para GitHub Issues

**Propósito**: Converter tarefas de `tasks.md` em issues GitHub para tracking externo.

**Pré-requisitos**:
- Repositório GitHub configurado
- `tasks.md` existente

```
/specswift.taskstoissues
```

---

### `/specswift.retro` - Retrospectiva Pós-Implementação

**Propósito**: Analisar feature concluída contra especificações para gerar lições aprendidas.

**Entrada**: Nenhuma (usa artefatos da branch atual)

```
/specswift.retro
```

**Resultado**:
- Relatório `_docs/retro/[FEATURE].md`
- Insights para atualização da constituição

---

## Estrutura de Artefatos

Todos os artefatos são armazenados em `_docs/specs/[SHORT_NAME]/`:

```
_docs/specs/add-search-feature/
├── prd.md                 # Requisitos de produto
├── techspec.md            # Especificação técnica
├── tasks.md               # Lista de tarefas
├── research.md            # Pesquisa técnica
├── ui-design.md           # Design de UI
├── data-model.md          # Data model
├── quickstart.md          # Guia de início rápido
├── .agent.md              # Contexto para implementação
├── checklists/
│   └── requirements.md    # Checklist de qualidade
└── contracts/             # Contratos de API
    └── ...
```

---

## Comandos Rápidos

| Objetivo | Comando |
|----------|---------|
| Criar documentação base | `/specswift.constitution` |
| Nova feature (interativo) | `/specswift.create-prd [descrição]` |
| Nova feature (automático) | `/specswift.yolo [descrição]` |
| Esclarecer requisitos | `/specswift.clarify` |
| Criar design técnico | `/specswift.create-techspec` |
| Gerar tarefas | `/specswift.tasks` |
| Validar antes de implementar | `/specswift.analyze` |
| Implementar | `/specswift.implement` |
| Exportar para GitHub | `/specswift.taskstoissues` |
| Retrospectiva | `/specswift.retro` |

---

## Fluxo Recomendado por Tipo de Feature

### Projeto Novo
```
constitution → create-prd → create-techspec → tasks → analyze → implement → retro
```

### Feature Crítica/Complexa
```
create-prd → clarify → create-techspec → tasks → analyze → implement → retro
```

### Feature Simples/Bem Definida
```
create-prd → create-techspec → tasks → implement → retro
```

### Spike/Prototipagem
```
yolo → (revisar artefatos) → implement → retro
```

### Feature de Correção de Bug
```
create-prd --type fix → create-techspec → tasks → implement → retro
```

---

## Dicas de Uso

1. **Sempre comece pelo PRD** - Mesmo para features pequenas, o PRD ajuda a esclarecer escopo

2. **Use o Gate (analyze)** - Evita retrabalho ao validar cobertura antes de implementar

3. **Revise decisões do YOLO** - O modo automático toma decisões conservadoras, revise se necessário

4. **Mantenha artefatos atualizados** - Se o escopo mudar, atualize PRD e propague para TechSpec

5. **Use clarify quando necessário** - Melhor perguntar agora do que retrabalhar depois
