---
name: swiftui-expert
description: Orientação especializada em SwiftUI para projetos SpecSwift. Use ao construir ou revisar features SwiftUI—gerenciamento de estado, composição de views, performance, APIs modernas e Liquid Glass no iOS 26+. Alinha com Apple HIG e rules de UI/acessibilidade do SpecSwift.
---

# SwiftUI Expert

## Visão geral

Use esta skill para implementar, revisar ou melhorar SwiftUI em projetos iOS/Swift: gerenciamento de estado correto, uso de APIs modernas, composição com foco em performance e Liquid Glass no iOS 26+ com fallbacks seguros. Foca em fatos e boas práticas sem impor uma arquitetura específica. Integra com as rules do SpecSwift para acessibilidade e UI.

**Fonte**: Conteúdo adaptado de [SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) (Antoine van der Lee, Omar Elsayed). Use com os workflows create-techspec, implement e clarify (visual).

## Árvore de decisão de fluxo

### 1) Revisar código SwiftUI existente

- Property wrappers: conferir com o guia de seleção (ver State Management abaixo).
- APIs modernas: evitar modificadores e tipos deprecados (ver Modern APIs).
- Composição de views: extração, views pequenas, `body` puro (ver View Composition).
- Performance: hot paths, identidade de lista, sem atualizações redundantes (ver Performance).
- Padrões de lista: identidade estável em `ForEach`, sem `.indices` para dados dinâmicos.
- Liquid Glass (iOS 26+): uso correto e fallbacks com `#available`.
- Acessibilidade: labels, Dynamic Type, VoiceOver (ver rules do projeto).

### 2) Melhorar código SwiftUI existente

- Preferir `@Observable` a `ObservableObject`.
- Substituir APIs deprecadas por equivalentes modernos.
- Extrair views complexas em subviews.
- Minimizar atualizações de estado redundantes em hot paths.
- Garantir que `ForEach` use identidade estável.
- Sugerir downsampling de imagem quando `UIImage(data:)` for usado (opcional).
- Adotar Liquid Glass apenas quando explicitamente solicitado.

### 3) Implementar nova feature SwiftUI

- Desenhar fluxo de dados: estado owned vs injetado.
- Usar apenas APIs modernas (sem padrões deprecados).
- Usar `@Observable` para estado compartilhado; `@MainActor` quando necessário.
- Estruturar views para diffing: extrair subviews, manter views pequenas.
- Separar lógica de negócio para testabilidade.
- Aplicar efeitos de glass após layout/aparência; proteger recursos iOS 26+ com `#available`.

## Diretrizes principais

### Gerenciamento de estado

- **Preferir `@Observable` a `ObservableObject`** em código novo.
- **Marcar `@Observable` com `@MainActor`** salvo uso de isolamento padrão.
- **`@State` e `@StateObject` devem ser `private`** (dependências claras).
- **Nunca usar `@State` / `@StateObject` para valores passados** (apenas iniciais/owned).
- Usar `@State` com `@Observable` (não `@StateObject`).
- `@Binding` apenas quando o filho **modifica** estado do pai.
- `@Bindable` para `@Observable` injetado que precisa de bindings.
- `let` para somente leitura; `var` + `.onChange()` para leitura reativa.
- `ObservableObject` aninhado não funciona (passar aninhado diretamente); `@Observable` aninha bem.

### APIs modernas

| Preferir | Evitar |
|----------|--------|
| `foregroundStyle()` | `foregroundColor()` |
| `clipShape(.rect(cornerRadius:))` | `cornerRadius()` |
| API `Tab` | `tabItem()` |
| `Button` | `onTapGesture()` (salvo necessidade de location/count) |
| `NavigationStack` | `NavigationView` |
| `navigationDestination(for:)` | navegação não type-safe |
| Variante de `onChange(of:)` com dois parâmetros ou sem parâmetro | `onChange` de valor único |
| `.sheet(item:)` | `.sheet(isPresented:)` para sheets baseados em modelo |
| `.scrollIndicators(.hidden)` | `showsIndicators: false` |
| `Text(value, format: .number...)` | `String(format: ...)` |
| `localizedStandardContains()` | `contains()` para entrada do usuário |
| `containerRelativeFrame()` / `visualEffect()` | `GeometryReader` quando não necessário |
| Evitar `UIScreen.main.bounds` para dimensionamento | — |

### Composição de views

- **Preferir modificadores a views condicionais** para mudanças de estado (mantém identidade da view).
- Extrair views complexas em subviews separadas.
- Manter views pequenas; manter `body` simples e puro (sem side effects).
- Usar `@ViewBuilder` apenas para seções pequenas.
- Preferir `@ViewBuilder let content: Content` a conteúdo por closure.
- Separar lógica de negócio para testabilidade; handlers de ação chamam métodos, não lógica inline.
- Usar layout relativo; views devem funcionar em qualquer contexto (agnóstico a tamanho/apresentação).

### Performance

- Passar apenas valores necessários (sem objetos “config” grandes).
- Verificar mudança de valor antes de atribuir estado em hot paths.
- Evitar atualizações redundantes em `onReceive`, `onChange`, handlers de scroll.
- Usar `LazyVStack`/`LazyHStack` para listas grandes.
- **Identidade estável para `ForEach`** (nunca `.indices` para conteúdo dinâmico).
- Número constante de views por elemento de `ForEach`; sem filtro inline em `ForEach`.
- Evitar `AnyView` em linhas de lista.
- Sem criação de objetos em `body`; mover trabalho pesado para fora de `body`.
- Sugerir downsampling de imagem quando `UIImage(data:)` for usado (opcional).

### Liquid Glass (iOS 26+)

Usar apenas quando explicitamente solicitado. Quando usado:

- Proteger com `#available(iOS 26, *)` e fornecer fallback (ex.: `.ultraThinMaterial`).
- Envolver múltiplas views de glass em `GlassEffectContainer`.
- Aplicar `.glassEffect()` após modificadores de layout e aparência.
- Usar `.interactive()` apenas em elementos interagíveis pelo usuário.
- Usar `glassEffectID` com `@Namespace` para transições de morphing.

## Tabelas de referência rápida

### Seleção de property wrapper (moderno)

| Wrapper | Usar quando |
|---------|-------------|
| `@State` | Estado interno da view (private) ou classe `@Observable` owned |
| `@Binding` | Filho modifica estado do pai |
| `@Bindable` | `@Observable` injetado que precisa de bindings |
| `let` | Somente leitura do pai |
| `var` | Somente leitura observada via `.onChange()` |

**Legado (pré–iOS 17):** `@StateObject` para `ObservableObject` owned; `@ObservedObject` para injetado. Preferir `@Observable` + `@State` em código novo.

### Padrão Liquid Glass (com fallback)

```swift
if #available(iOS 26, *) {
    content
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    content
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
```

## Checklist de revisão

### Gerenciamento de estado

- [ ] `@Observable` em vez de `ObservableObject` em código novo
- [ ] `@Observable` marcado com `@MainActor` quando necessário
- [ ] `@State` com `@Observable` (não `@StateObject`)
- [ ] `@State` / `@StateObject` são `private`
- [ ] Valores passados não declarados como `@State` / `@StateObject`
- [ ] `@Binding` apenas onde o filho modifica o pai
- [ ] `@Bindable` para `@Observable` injetado que precisa de bindings

### APIs modernas

- [ ] `foregroundStyle()` em vez de `foregroundColor()`
- [ ] `NavigationStack` em vez de `NavigationView`
- [ ] Sem `UIScreen.main.bounds` para dimensionamento
- [ ] Alternativas a `GeometryReader` quando possível
- [ ] Imagens em botões incluem labels de texto para acessibilidade

### Sheets e navegação

- [ ] `.sheet(item:)` para sheets baseados em modelo
- [ ] Sheets donos das ações e dismiss internamente
- [ ] `navigationDestination(for:)` para navegação type-safe

### Estrutura de view e performance

- [ ] Modificadores em vez de condicionais para UI driven por estado
- [ ] Views complexas extraídas; views mantidas pequenas
- [ ] `body` simples e puro; sem side effects
- [ ] Apenas valores necessários passados; sem objetos config grandes
- [ ] Atualizações de estado verificam mudança antes de atribuir
- [ ] Sem criação de objetos em `body`

### Padrões de lista

- [ ] `ForEach` usa identidade estável (não `.indices`)
- [ ] Número constante de views por elemento de `ForEach`
- [ ] Sem filtro inline em `ForEach`; sem `AnyView` em linhas

### Liquid Glass (se usado)

- [ ] `#available(iOS 26, *)` com fallback
- [ ] `.glassEffect()` após layout/aparência
- [ ] `.interactive()` apenas em elementos tappable/focusable

## Referências

- **SpecSwift**: `lib/rules/.../accessibility-guidelines.md`, `lib/rules/.../swift-coding-style.md` e TECH.md do projeto para UI/acessibilidade.
- **Conjunto completo de referências**: [SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) (state-management, view-structure, performance-patterns, list-patterns, layout-best-practices, modern-apis, sheet-navigation-patterns, scroll-patterns, text-formatting, image-optimization, liquid-glass).

---

*Conteúdo adaptado de [SwiftUI Agent Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) por Antoine van der Lee e Omar Elsayed.*
