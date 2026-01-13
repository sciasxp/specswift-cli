---
name: prd-quality-validation
description: Valida qualidade e completude de PRDs (Product Requirements Documents) antes de prosseguir para especificação técnica. Verifica se o PRD está completo, testável e livre de ambiguidades críticas.
---

# Validação de Qualidade de PRD

Esta skill valida a qualidade e completude de PRDs seguindo os padrões do SpecSwift.

## Quando usar esta skill

Esta skill é automaticamente invocada após a criação de um PRD, mas também pode ser usada manualmente via `@prd-quality-validation` para validar PRDs existentes.

## Processo de Validação

### 1. Carregar PRD e Checklist

1. Execute o script de verificação de pré-requisitos:
   ```bash
   _docs/scripts/bash/check-prerequisites.sh --json --require-prd
   ```

2. Parse o JSON para obter:
   - `FEATURE_DIR`: Diretório da feature
   - `PRD`: Caminho do arquivo PRD
   - `FEATURE_SPEC`: Caminho do spec (pode ser PRD ou spec legado)

3. Carregue o PRD e o checklist de qualidade (se existir):
   - PRD: `$FEATURE_DIR/prd.md`
   - Checklist: `$FEATURE_DIR/checklists/requirements.md`

### 2. Executar Validações

Use o checklist em `checklists/prd-quality-checklist.md` como referência para validar:

#### Validações Obrigatórias

1. **Completude de Seções**:
   - [ ] Objetivo da feature definido
   - [ ] Critérios de sucesso mensuráveis
   - [ ] Requisitos funcionais numerados
   - [ ] Cenários de usuário descritos
   - [ ] Fluxo crítico documentado (texto ou diagrama)

2. **Qualidade do Conteúdo**:
   - [ ] Sem detalhes de implementação (linguagens, frameworks, APIs)
   - [ ] Focado em valor do usuário e necessidades de negócio
   - [ ] Escrito para stakeholders não-técnicos
   - [ ] Documento com menos de 1.000 palavras (conteúdo principal)

3. **Completude de Requisitos**:
   - [ ] Nenhum marcador `[PRECISA ESCLARECIMENTO]` restante (ou máx 3 se crítico)
   - [ ] Requisitos são testáveis e não-ambíguos
   - [ ] Critérios de sucesso são mensuráveis
   - [ ] Critérios de sucesso são agnósticos de tecnologia
   - [ ] Todos os cenários de aceitação estão definidos
   - [ ] Casos de borda estão identificados
   - [ ] Escopo está claramente delimitado

4. **Prontidão para TechSpec**:
   - [ ] Todos os requisitos funcionais têm critérios de aceitação claros
   - [ ] Cenários de usuário cobrem fluxos principais
   - [ ] Feature atende resultados mensuráveis definidos em Critérios de Sucesso

### 3. Gerar Relatório de Validação

Crie um relatório estruturado:

```markdown
## Relatório de Validação do PRD

**Feature**: [SHORT_NAME]
**PRD**: `_docs/specs/[SHORT_NAME]/prd.md`
**Data**: [DATA]

### Status Geral
- ✅ Aprovado | ⚠️ Requer Ajustes | ❌ Bloqueado

### Resumo
- Total de validações: X
- Passou: Y
- Falhou: Z

### Problemas Encontrados

| Item | Severidade | Descrição | Ação Recomendada |
|------|------------|-----------|------------------|
| [Item 1] | Alta/Média/Baixa | [Descrição] | [Ação] |

### Recomendações

1. [Recomendação 1]
2. [Recomendação 2]

### Próximos Passos

- Se aprovado: Prosseguir para `/specswift.create-techspec`
- Se requer ajustes: Atualizar PRD e revalidar
- Se bloqueado: Resolver problemas críticos antes de continuar
```

### 4. Atualizar Checklist

Se o checklist não existir, crie-o em `$FEATURE_DIR/checklists/requirements.md` usando o template em `checklists/prd-quality-checklist.md`.

Atualize o checklist com os resultados da validação, marcando itens como completos (`[x]`) ou incompletos (`[ ]`).

## Critérios de Aprovação

O PRD é considerado **aprovado** se:

1. Todas as validações obrigatórias passam
2. Máximo de 3 marcadores `[PRECISA ESCLARECIMENTO]` (apenas para decisões críticas)
3. Nenhum problema de alta severidade encontrado
4. Critérios de sucesso são mensuráveis e agnósticos de tecnologia

## Integração com Workflows

Esta skill é automaticamente invocada por:

- `/specswift.create-prd` - Após criação do PRD
- `/specswift.clarify` - Após esclarecimentos
- `/specswift.analyze` - Durante análise de cobertura

## Recursos de Suporte

- **Checklist**: `checklists/prd-quality-checklist.md` - Checklist completo de validação
- **Template**: Use o template de checklist como referência para criar novos checklists

## Notas Importantes

- Validações são baseadas nos padrões do SpecSwift definidos em `docs/SPECSWIFT-WORKFLOWS.md`
- Problemas de alta severidade devem ser resolvidos antes de prosseguir
- Problemas de média/baixa severidade podem ser documentados como melhorias futuras
