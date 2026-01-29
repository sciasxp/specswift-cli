---
name: swift-concurrency
description: Orientação especializada em Swift Concurrency para projetos SpecSwift. Use ao trabalhar com async/await, actors, tasks, Sendable, migração para Swift 6, data races ou avisos de lint de concorrência. Integra com lib/rules para isolamento de serviços e Approachable Concurrency (Swift 6.2).
---

# Swift Concurrency

## Visão geral

Esta skill oferece orientação especializada em Swift Concurrency para projetos iOS/Swift: async/await, actors, tasks, Sendable e migração para Swift 6. Use ao implementar ou revisar código que envolve concorrência, ou ao resolver diagnósticos de data race ou isolamento. Alinha-se às rules do SpecSwift (`lib/rules/.../swift-concurrency.md`) e à Approachable Concurrency da Apple (Swift 6.2).

**Fonte**: Conteúdo adaptado de [Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) (Antoine van der Lee). Use nos workflows de implementação, revisão de código e investigação de bugs.

## Contrato de comportamento do agente (siga estas regras)

1. **Descobrir configurações do projeto** – Verificar `Package.swift` ou `.pbxproj` para modo da linguagem Swift (5.x vs 6), nível de strict concurrency e isolamento padrão de actors antes de dar conselhos sensíveis à migração.
2. **Identificar isolamento primeiro** – Antes de propor correções, identificar o limite: `@MainActor`, actor customizado, isolamento de instância de actor ou nonisolated.
3. **Não usar @MainActor como curinga** – Não recomendar `@MainActor` como correção genérica; justificar por que o isolamento no main actor é correto.
4. **Preferir structured concurrency** – Preferir child tasks e task groups a `Task` não estruturado; usar `Task.detached` apenas com motivo documentado.
5. **Escapes inseguros** – Se recomendar `@preconcurrency`, `@unchecked Sendable` ou `nonisolated(unsafe)`, exigir invariante de segurança documentado e follow-up para remover ou migrar.
6. **Migração** – Preferir blast radius mínimo (mudanças pequenas e revisáveis) e adicionar passos de verificação.
7. **Alinhamento SpecSwift** – Para serviços e ViewModels, seguir as rules do projeto em `lib/rules/.../swift-concurrency.md` (ex.: `@MainActor` para UI/SwiftData, `nonisolated` + `@concurrent` para trabalho pesado).

## Configurações do projeto (avaliar antes de aconselhar)

O comportamento de concorrência depende das configurações de build. Determinar:

- **Isolamento padrão de actor** – Padrão do módulo é `@MainActor` ou `nonisolated`?
- **Strict concurrency** – minimal / targeted / complete?
- **Upcoming features** – ex.: `NonisolatedNonsendingByDefault`?
- **Swift / Xcode** – Swift 5.x vs 6; versão das ferramentas SwiftPM.

**Checagens manuais:**

- **SwiftPM**: Em `Package.swift` verificar `.defaultIsolation(MainActor.self)`, `.enableUpcomingFeature("...")`, flags de strict concurrency e `// swift-tools-version:`.
- **Xcode**: Em `.pbxproj` buscar `SWIFT_DEFAULT_ACTOR_ISOLATION`, `SWIFT_STRICT_CONCURRENCY`, `SWIFT_UPCOMING_FEATURE_`.

Se algum for desconhecido, perguntar ao desenvolvedor antes de dar orientação específica de migração.

## Árvore de decisão rápida

1. **Começando com código async?**  
   → Básicos de async/await; para trabalho paralelo usar `async let` ou task groups.

2. **Protegendo estado mutável compartilhado?**  
   → Estado em classes: actors ou `@MainActor`.  
   → Passagem de valor thread-safe: conformidade `Sendable`.

3. **Gerenciando operações async?**  
   → Trabalho estruturado: `Task`, child tasks, cancelamento.  
   → Streaming: `AsyncSequence` / `AsyncStream`.

4. **Frameworks legados?**  
   → Core Data: padrão DAO, `NSManagedObjectID`, isolamento.  
   → Geral: passos de migração, strict concurrency incremental.

5. **Performance ou debugging?**  
   → Código async lento: profiling, suspension points.  
   → Testes: XCTest async, Swift Testing, testes async determinísticos.

6. **Comportamento de threading?**  
   → Entender thread vs task, suspension points, domínios de isolamento.

7. **Memória / tasks?**  
   → Retain cycles em tasks, cancelamento, `[weak self]` quando apropriado.

## Playbook de triagem (erro comum → próxima ação)

| Sintoma / aviso | Primeiro passo | Depois |
|-----------------|----------------|--------|
| Avisos de concorrência do SwiftLint | Usar regras de lint de concorrência; evitar `await` falso como “correção”. | Preferir correção real ou supressão estreita. |
| `async_without_await` | Remover `async` se não necessário; se exigido por protocolo/override, preferir supressão estreita a awaits falsos. | — |
| “Sending value of non-Sendable type ... risks data races” | Encontrar onde o valor cruza um limite de isolamento. | Aplicar orientação Sendable/isolamento (tipo de valor, `@unchecked Sendable` com doc, ou manter no mesmo actor). |
| “Main actor-isolated ... cannot be used from a nonisolated context” | Decidir se realmente pertence a `@MainActor`. | Usar actors/global actors, `nonisolated` ou parâmetros isolados. |
| “Class property 'current' is unavailable from asynchronous contexts” (Thread) | Afastar-se das APIs de Thread. | Usar tasks e isolamento; depurar com Instruments. |
| XCTest async / “wait(...) is unavailable from async” | Usar APIs de teste async. | `await fulfillment(of:)` ou padrões Swift Testing. |
| Avisos de concorrência do Core Data | Core Data + isolamento de actors. | DAO, `NSManagedObjectID`, evitar passar managed objects entre limites. |

## Referência de padrões principais

### Quando usar cada ferramenta de concorrência

| Ferramenta | Usar para |
|------------|-----------|
| **async/await** | Operações async únicas; tornar código síncrono async. |
| **async let** | Número fixo de operações async independentes em paralelo. |
| **Task** | Fire-and-forget; ligar sync a async. |
| **Task group** | Número dinâmico de operações em paralelo. |
| **Actor** | Estado mutável compartilhado; acesso de múltiplos contextos. |
| **@MainActor** | ViewModels, UI, SwiftData `ModelContext`. |

### Exemplo: rede + atualização de UI

```swift
Task { @concurrent in
    let data = try await fetchData()  // background
    await MainActor.run {
        self.updateUI(with: data)     // main
    }
}
```

### Exemplo: requests em paralelo

```swift
async let users = fetchUsers()
async let posts = fetchPosts()
let (u, p) = try await (users, posts)
```

### Exemplo: actor para estado compartilhado

```swift
actor DataCache {
    private var cache: [String: Data] = [:]
    func get(_ key: String) -> Data? { cache[key] }
}
```

### Exemplo: serviço no estilo SpecSwift (alinhado às rules do projeto)

```swift
@MainActor
final class DatabaseService { ... }

nonisolated struct PhotoProcessor {
    @concurrent
    func process(data: Data) async -> ProcessedPhoto? { ... }
}
```

## Guia rápido de migração para Swift 6

- **Strict concurrency** ligado por padrão; **data-race safety** em tempo de compilação.
- **Sendable** exigido nas fronteiras de isolamento.
- **Isolamento** verificado em todas as fronteiras async.

Migrar em passos pequenos: ativar strict concurrency targeted, corrigir diagnósticos, depois passar para complete. Preferir tipos de valor e isolamento explícito a `@preconcurrency` ou `@unchecked Sendable` quando possível.

## Checklist de verificação (após alterar código de concorrência)

- [ ] Configurações de build (isolamento padrão, strict concurrency, upcoming features) conhecidas e consistentes com o conselho.
- [ ] Testes rodam, incluindo testes sensíveis a concorrência.
- [ ] Se for relacionado a performance, verificar com Instruments.
- [ ] Se for relacionado a lifetime, verificar comportamento de deinit e cancelamento.
- [ ] Novos serviços têm isolamento explícito (`@MainActor`, `nonisolated` ou `actor`) conforme as rules do projeto.

## Resumo de boas práticas

1. Preferir **structured concurrency** (task groups, child tasks) a `Task` não estruturado quando possível.
2. **Minimizar suspension points**; manter regiões isoladas em actors pequenas.
3. Usar **@MainActor** apenas para UI e estado vinculado ao main actor.
4. Tornar tipos **Sendable** onde cruzam fronteiras de isolamento.
5. **Tratar cancelamento** em trabalho longevo (`Task.isCancelled`).
6. **Evitar bloqueio** (sem semáforos/locks) em contextos async.
7. **Testar** código concorrente com APIs de teste async e considerar timing.

## Referências

- **Rules SpecSwift**: `lib/rules/pt/swift-concurrency.md` para isolamento de serviços e Approachable Concurrency.
- **Conjunto completo de referências**: [Swift-Concurrency-Agent-Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) (async-await-basics, tasks, sendable, actors, async-sequences, threading, memory-management, core-data, performance, testing, migration, glossary, linting).

---

*Conteúdo adaptado de [Swift Concurrency Agent Skill](https://github.com/AvdLee/Swift-Concurrency-Agent-Skill) por Antoine van der Lee.*
