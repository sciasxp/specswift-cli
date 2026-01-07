---
description: Imponha isolamento explícito de concorrência Swift para serviços para garantir segurança de thread e compatibilidade com Swift 6.2 e ViewModels @Observable.
trigger: always_on
---

# Regra Arquitetural: Concorrência Swift e Isolamento de Serviço

## Status
**Proposta**

## Contexto
O projeto usa Swift 6.2 com verificações estritas de concorrência habilitadas. O Swift 6.2 introduz a "Approachable Concurrency", que simplifica a segurança contra data-races mantendo o código em thread única por padrão até que seja explicitamente enviado para background. Precisamos de uma estratégia consistente para isolamento de serviços e trabalho em background.

## Regra
Todas as classes/structs de Serviço devem definir explicitamente seu nível de isolamento para garantir segurança de thread e performance ideal.

### 1. Serviços Isolados no MainActor (Padrão)
Serviços que interagem com a UI, `ModelContext` (SwiftData) ou outros componentes `@MainActor` devem ser marcados com `@MainActor`.
- **Quando usar:** Serviços que realizam operações de banco de dados ou disparam atualizações de UI.
- **Nota:** O Swift 6.2 permite **conformidades isoladas** (ex: `extension MeuModelo: @MainActor MeuProtocolo`), garantindo que protocolos sejam usados com segurança no actor principal.

```swift
@MainActor
final class DatabaseService {
    let context: ModelContext
    
    func save(item: MeuModelo) {
        context.insert(item)
    }
}
```

### 2. Serviços Não-isolados & Trabalho em Background
Serviços que não possuem estado ou contêm apenas estado imutável devem ser `nonisolated`. Para realizar trabalho intenso de CPU sem bloquear quem chama, use o atributo `@concurrent`.
- **Quando usar:** Lógica pura, serviços utilitários (ex: `FileManagerService`) e processadores pesados.
- **Benefício:** `@concurrent` garante que a função rode no pool de threads concorrentes.

```swift
nonisolated struct ProcessadorFoto {
    @concurrent
    func process(data: Data) async -> FotoProcessada? {
        // Processamento pesado de imagem aqui
    }
}
```

### 3. Serviços com Actor Dedicado
Use `actor` para serviços que gerenciam seu próprio estado mutável que deve ser protegido contra acesso concorrente.
- **Quando usar:** Caches, processadores com estado (ex: `ImageCache`).

```swift
actor ImageCache {
    private var cache: [URL: UIImage] = [:]
    
    func image(for url: URL) -> UIImage? {
        cache[url]
    }
}
```

## Execução
- Novos serviços devem incluir um atributo de isolamento (`@MainActor`, `nonisolated`, ou `actor`).
- Use `@concurrent` para trabalho assíncrono pesado para manter o app responsivo.
- ViewModels devem usar `@ObservationIgnored` para instâncias de serviço para evitar overhead desnecessário de observação.
- Prefira conformidades isoladas para protocolos que requerem estado específico de actor.
