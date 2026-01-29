# TechSpec: [FEATURE]

**Feature**: [SHORT_NAME]  
**Branch**: `feature/[SHORT_NAME]`  
**Data**: [DATA]  
**Status**: Rascunho | Em Revisão | Aprovado  
**PRD**: `_docs/specs/[SHORT_NAME]/prd.md`

<!--
  CONTRATO DE SAÍDA (não remover; usado pelos workflows):
  - A ordem das seções DEVE ser preservada. Obrigatórias: Contexto Técnico, Constitution Check, HIG Compliance, Estrutura do Projeto, Artefatos da Feature.
  - Status DEVE ser exatamente um de: Rascunho | Em Revisão | Aprovado.
  - Células das tabelas Constitution Check / HIG Compliance: exatamente um de ✅ | ⚠️ | ❌ mais justificativa.
  - Quando um valor não puder ser determinado: use [NEEDS CLARIFICATION] no Contexto Técnico até respondido; depois use valor concreto ou [TBD] em Premissas; não invente.
-->

---

### 📍 Fluxo de Trabalho

```
✅ PRD → ✅ TechSpec (atual) → ⭕ Tasks → ⭕ Implementação
```

**Próximo passo**: Após aprovação, execute `/specswift.tasks`

## Resumo

[Extrair do PRD: requisito principal + abordagem técnica]

## Documentação de Referência

| Documento | Conteúdo | Uso |
|-----------|----------|-----|
| `README.md` | Visão geral e comandos | Comandos de build/test |
| `_docs/PRODUCT.md` | Regras de negócio | Validar requisitos |
| `_docs/STRUCTURE.md` | Arquitetura e pastas | Caminhos e módulos |
| `_docs/TECH.md` | Stack e padrões | Tecnologias e pitfalls |

## Contexto Técnico

<!--
  AÇÃO REQUERIDA: Substitua o conteúdo desta seção com os detalhes técnicos
  para o projeto. Referencie _docs/TECH.md para orientação sobre escolhas de tecnologia e arquitetura.
-->

**Linguagem/Versão**: Swift 6.2+
**Sistema de Build**: Xcode / Swift Package Manager (SPM)
**Arquitetura**: [Consulte _docs/STRUCTURE.md]
**Dependências Principais**: [Liste dependências externas/internas]
**Armazenamento**: [Especifique a tecnologia de persistência]
**Networking**: [Especifique a camada de rede]
**Testes**: XCTest (unitários/UI)
**Plataforma Alvo**: [iOS/macOS + Versão]
**Tipo de Projeto**: [mobile/desktop/etc]  

## Verificação da Constituição

*GATE: Deve passar antes da pesquisa Fase 0. Reverificar após design Fase 1.*

| Princípio | Status | Justificativa |
|-----------|--------|---------------|
| [Princípio 1] | ✅/⚠️/❌ | [Como este design adere ou desvia] |
| [Princípio 2] | ✅/⚠️/❌ | [Justificativa] |

## Conformidade HIG (Human Interface Guidelines)

*OBRIGATÓRIO: Verificar conformidade com Apple Human Interface Guidelines*

| Aspecto | Conformidade | Notas |
|---------|--------------|-------|
| Navegação | ✅/⚠️/❌ | [Padrões de navegação seguidos] |
| Acessibilidade | ✅/⚠️/❌ | [VoiceOver, Dynamic Type, etc] |
| Dark Mode | ✅/⚠️/❌ | [Suporte a cores adaptativas] |
| Safe Areas | ✅/⚠️/❌ | [Respeito a layout guides] |

## Estrutura do Projeto

<!--
  Onde o novo código ficará no projeto.
  Siga padrões existentes em _docs/STRUCTURE.md
-->

```
[NOME_DO_PROJETO]/
└── [Caminho]/
    └── [NomeFeature]/
        ├── Models/
        ├── Views/
        └── ViewModels/
```

## Rastreamento de Complexidade

| Componente | Esforço Estimado | Nível de Risco |
|------------|------------------|----------------|
| [Componente 1] | [Baixo/Médio/Alto] | [Baixo/Médio/Alto] |

**Esforço Total Estimado**: [X dias/story points]
**Riscos Principais**: [Liste os principais riscos técnicos]

---

## Navegação e Fluxo

<!--
  Mapeie como a navegação será gerenciada (ex: Coordinators, Router).
  Referência: _docs/STRUCTURE.md
-->

| Componente | Impacto | Responsabilidade |
|------------|---------|------------------|
| [Componente] | [Novo/Modificado] | [Responsabilidade] |

## Módulos e Integrações

<!--
  Identifique módulos existentes que serão afetados ou integrados.
  Referência: _docs/STRUCTURE.md
-->

| Módulo/Serviço | Relação | Impacto |
|----------------|---------|---------|
| [Módulo] | [Dependência/Integração] | [Descrição] |

## Impacto em Configurações Globais

<!--
  Verifique se há impacto nas configurações globais ou constantes do app.
  Referência: _docs/TECH.md
-->

| Item | Impacto | Ação Necessária |
|------|---------|-----------------|
| Persistência/Migração | [ ] Sim / [ ] Não | [Detalhes] |
| Feature Flags | [ ] Sim / [ ] Não | [Detalhes] |
| Configurações de Ambiente | [ ] Sim / [ ] Não | [Detalhes] |

## Pitfalls a Evitar

<!--
  Erros comuns a evitar neste projeto.
  Consulte _docs/TECH.md para lista completa de pitfalls do projeto.
-->

| ❌ Evitar | ✅ Fazer Corretamente |
|-----------|----------------------|
| Lógica de negócio em Views | Manter em ViewModels/Services |
| Acesso direto a persistência em UI | Usar camada de Repository |
| Dados sensíveis em UserDefaults | Usar Keychain |
| [Adicione pitfalls específicos do projeto] | [Prática recomendada] |

---

## Artefatos da Feature

```text
_docs/specs/[SHORT_NAME]/
├── prd.md               # ✅ Requisitos de Produto
├── techspec.md          # ✅ Este arquivo
├── research.md          # Pesquisa técnica
├── ui-design.md         # Design de interface (se aplicável)
├── data-model.md        # Modelo de dados
├── quickstart.md        # Guia rápido
├── tasks.md             # ⭕ Decomposição de tarefas (próximo)
└── .agent.md            # Contexto para implementação
```
