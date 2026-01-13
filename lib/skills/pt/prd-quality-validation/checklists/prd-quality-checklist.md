# Checklist de Qualidade da Especificação: [NOME DA FEATURE]

**Propósito**: Validar completude e qualidade da especificação antes de prosseguir para planejamento técnico  
**Criado**: [DATA]  
**Feature**: `_docs/specs/[SHORT_NAME]/prd.md`

---

## Fase de Esclarecimento Concluída

- [ ] Todas as perguntas de esclarecimento foram feitas e respondidas
- [ ] Fluxos de usuário e cenários confirmados com usuário
- [ ] Limites de escopo explicitamente definidos
- [ ] Critérios de sucesso confirmados como mensuráveis

## Qualidade do Conteúdo

- [ ] Sem detalhes de implementação (linguagens, frameworks, APIs)
- [ ] Focado em valor do usuário e necessidades de negócio
- [ ] Escrito para stakeholders não-técnicos
- [ ] Todas as seções obrigatórias completadas
- [ ] Documento com menos de 1.000 palavras (conteúdo principal)

## Completude de Requisitos

- [ ] Nenhum marcador `[PRECISA ESCLARECIMENTO]` restante (ou máx 3 se crítico)
- [ ] Requisitos são testáveis e não-ambíguos
- [ ] Critérios de sucesso são mensuráveis
- [ ] Critérios de sucesso são agnósticos de tecnologia (sem detalhes de implementação)
- [ ] Todos os cenários de aceitação estão definidos
- [ ] Casos de borda estão identificados
- [ ] Escopo está claramente delimitado
- [ ] Dependências e suposições identificadas

## Prontidão da Feature

- [ ] Todos os requisitos funcionais têm critérios de aceitação claros
- [ ] Cenários de usuário cobrem fluxos principais
- [ ] Feature atende resultados mensuráveis definidos em Critérios de Sucesso
- [ ] Nenhum detalhe de implementação vaza para a especificação

## Fluxo Crítico

- [ ] Fluxo crítico da feature está documentado (texto ou diagrama Mermaid)
- [ ] Fluxo crítico cobre o caminho feliz (happy path)
- [ ] Fluxo crítico identifica pontos de decisão importantes
- [ ] Fluxo crítico é compreensível para stakeholders não-técnicos

## UI/UX (se aplicável)

- [ ] Mockups ou wireframes das telas principais estão incluídos
- [ ] Fluxo de navegação está documentado
- [ ] Estados de erro e loading estão considerados
- [ ] Requisitos de acessibilidade estão identificados

## Notas

- Itens marcados incompletos requerem atualizações do PRD antes de `/specswift.clarify` ou `/specswift.create-techspec`
- Máximo de 3 marcadores `[PRECISA ESCLARECIMENTO]` permitidos (apenas para decisões críticas)
- Problemas de alta severidade devem ser resolvidos antes de prosseguir

---

**Status da Validação**: ⭕ Pendente | ⚠️ Requer Ajustes | ✅ Aprovado

**Última Validação**: [DATA]  
**Validador**: [Nome/AI]
