# Diretrizes de Desenvolvimento: [FEATURE_NAME]

**Feature**: [SHORT_NAME]  
**Branch**: `feature/[SHORT_NAME]`  
**Gerado**: [DATA]

---

### 📍 Fluxo de Trabalho

```
✅ PRD → ✅ TechSpec → ✅ Tasks → ✅ Implementação (atual)
```

**Artefatos**: `_docs/specs/[SHORT_NAME]/`

## Documentação de Referência

| Documento | Conteúdo | Quando Consultar |
|-----------|----------|------------------|
| `README.md` | Visão geral e comandos | Build, test, run |
| `_docs/PRODUCT.md` | Regras de negócio | Validação de requisitos |
| `_docs/STRUCTURE.md` | Arquitetura e pastas | Onde criar arquivos |
| `_docs/TECH.md` | Stack e padrões | Tecnologias e pitfalls |
| `.windsurf/rules/` | Estilo de código | Convenções de implementação |

## Contexto da Feature

**Objetivo**: [Extraído do PRD - objetivo principal]

**Arquivos Principais**:
- `[Caminho]/Models/[Entidade].swift` - Modelos de dados
- `[Caminho]/ViewModels/[Feature]ViewModel.swift` - Lógica de apresentação
- `[Caminho]/Views/[Feature]View.swift` - Interface do usuário

## Comandos Úteis

```bash
# Build e teste
make build          # Compilar projeto
make test           # Executar testes
make run            # Executar no simulador

# Verificações
make lint           # Verificar estilo de código
```

## Decisões Técnicas da Feature

| Decisão | Escolha | Justificativa |
|---------|---------|---------------|
| [Decisão 1] | [Escolha] | [Por quê] |

## Notas de Implementação

- [Nota importante 1]
- [Nota importante 2]

<!-- ADIÇÕES MANUAIS INÍCIO -->
<!-- ADIÇÕES MANUAIS FIM -->
