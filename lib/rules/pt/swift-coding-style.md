---
description: Padrões de codificação Swift — formatação, nomenclatura, documentação. Estilo K&R, limite de 120 caracteres, diretrizes da Apple. Suporta Swift 6.2+ Approachable Concurrency.
trigger: glob
globs: .swift
---

# Guia de Estilo Swift

<critical_rules>

## 🚨 Regras Críticas
1. **Limite de 120 caracteres por linha**
2. **Indentação de 4 espaços, nunca tabs**
3. **Sem pontos e vírgulas**
4. **Braces estilo K&R** (sem quebra antes de `{`)
5. **Trailing closures** para argumentos únicos de closure
6. **Sem parênteses** em condições de controle de fluxo
7. **Uma declaração por linha**
8. **Vírgulas finais** em coleções multilinha
9. **Use `guard`** para saídas antecipadas
10. **Use `Optional`** em vez de valores sentinela
11. **Documente todas as APIs públicas** com `///`

</critical_rules>

<source_files>

## 📁 Arquivos Fonte

**Nomenclatura:** `MeuTipo.swift`, `MyType+Protocolo.swift`, `MyType+Adicoes.swift`
**Codificação:** UTF-8, indentação de 4 espaços, sem espaços em branco no final da linha
**Imports:** Ordenar por (1) Módulos, (2) Declarações, (3) `@testable`. Linhas em branco entre grupos.
**Organização:** Um tipo primário por arquivo. Use `// MARK: - Seção` para agrupamento.

</source_files>

<formatting>

## 🎨 Formatação

**Braces (K&R):**
```swift
if condicao {
  fazAlgo()
} else {
  outraCoisa()
}
```
**Quebra de Linha:** Tudo horizontal ou tudo vertical para listas. Indente continuação com **+4**. `{` de abertura na mesma linha da continuação final.
**Espaçamento:** Espaço após `if`/`guard`/`while`/`switch`, ambos os lados de operadores, após dois pontos (não antes). Sem espaço ao redor de `.` ou intervalos (ranges).
**Parênteses:** Nunca ao redor de condições de controle de fluxo, a menos que necessário para clareza.

</formatting>

<programming_practices>

## 🛠️ Práticas de Programação

**Optionals & Erros:**
- Nunca use `try!`
- Evite force unwrapping (`!`); adicione comentário se necessário
- Use `guard let` ou `if let`
- Prefira `throws` para múltiplos estados de erro
**Controle de Acesso:** Omita `internal` (padrão). Especifique em membros de extensão, não na extensão em si.
**Inicializadores:** Use `init` membro a membro sintetizado. Omita `.init` em chamadas diretas. Nunca chame `ExpressibleBy*Literal` diretamente.
**Propriedades:** Uma por declaração. Omita `get` para propriedades computadas apenas de leitura.
**Enums:** Um case por linha. Delimitado por vírgula apenas se não houver valores associados e for autoexplicativo.
**Trailing Closures:** Sempre use para argumento único de closure. Sem `()` vazios.
**Switch:** `case` no mesmo nível que o `switch`. Declarações internas indentadas **+4**.

</programming_practices>

<concurrency_swift_6_2_plus>

## ⚡ Concorrência Swift 6.2+ (Approachable Concurrency)

O Swift 6.2 introduz a "Approachable Concurrency", que mantém o código em thread única por padrão até que você escolha explicitamente introduzir concorrência.

**Isolamento de Actor:**
- Marque classes relacionadas à UI e código apenas de thread principal com `@MainActor`
- Use `nonisolated` para serviços sem estado ou imutáveis
- Use `actor` para tipos que gerenciam estado mutável que deve ser protegido de acesso concorrente
- Prefira conformidades isoladas: `extension MeuTipo: @MainActor MeuProtocolo { ... }`
**Trabalho em Background:**
- Use o atributo `@concurrent` em funções async que realizam trabalho intenso de CPU
- Garanta que o tipo contêiner seja `nonisolated` ao usar `@concurrent`
- Adicione `await` nos locais de chamada de funções `@concurrent`
- Exemplo:
```swift
nonisolated struct ProcessadorImagem {
  @concurrent
  func process(data: Data) async -> ImagemProcessada? { ... }
}
```
**Estado Global & Estático:**
- Proteja variáveis globais/estáticas mutáveis com `@MainActor`
- Prefira `@MainActor static let shared` para singletons
- Evite estado global mutável desprotegido

</concurrency_swift_6_2_plus>

<naming>

## 📛 Nomenclatura

**Siga as Diretrizes de Design de API da Apple:** Clareza > brevidade. Nomeie pelo papel, não pelo tipo.
**Propriedades Estáticas/de Classe:** Não sufixadas com o nome do tipo. Use `shared` ou `default` para singletons.
**Constantes Globais:** `lowerCamelCase`, sem notação húngara.

</naming>

<documentation>

## 📝 Documentação

**Formato:** Use `///` (não `/** */`). Resumo primeiro, depois parágrafos.
**Tags:** `Parameter(s)`, `Returns`, `Throws` (nesta ordem). Nunca descrições vazias.
**Markup:** Backticks para código, `*itálico*`, `**negrito**`. Blocos de código com três backticks.

</documentation>
