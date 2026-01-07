---
trigger: always_on
---

# Diretrizes de Acessibilidade SwiftUI

## Fundamentos
- **Acessibilidade não é algo para depois.** Projete e implemente pensando em VoiceOver, Switch Control e outras tecnologias assistivas desde o início.
- **Clareza e Contexto:** Forneça descrições claras e concisas para elementos de interface que não possuem texto intrínseco (como ícones).

## Requisitos para Views
### 1. Rótulos de Acessibilidade Obrigatórios
Todos os elementos interativos (Botões, Toggles, Steppers) e imagens informativas DEVEM ter um rótulo de acessibilidade explícito se não contiverem texto.
- **Bom:** `Button { ... } label: { Image(systemName: "plus") }.accessibilityLabel("Adicionar Nova Publicação")`
- **Evite:** `Button { ... } label: { Image(systemName: "plus") }` (O VoiceOver dirá apenas "mais, botão").

### 2. Elementos Decorativos
Elementos que são puramente visuais e não fornecem informação devem ser ocultados da acessibilidade.
- **Uso:** `.accessibilityHidden(true)` ou `Image(decorative: "background")`.

### 3. Dicas de Acessibilidade (Hints)
Use dicas com parcimônia para interações complexas onde o resultado de uma ação não é óbvio apenas pelo rótulo.
- **Uso:** `.accessibilityHint("Toque duas vezes para abrir o leitor de capítulos.")`

### 4. Agrupamento de Elementos Relacionados
Use `accessibilityElement(children: .combine)` para agrupar informações relacionadas que devem ser lidas juntas.
- **Exemplo:** Uma célula com título e subtítulo deve frequentemente ser lida como um único elemento.

### 5. Suporte a Dynamic Type
- Garanta que o texto use estilos de fonte padrão (`.body`, `.headline`, `.title`) ou esteja configurado para escalar com as configurações do sistema.
- Evite alturas/larguras fixas para containers que contêm texto.

### 6. Traits e Estados
Garanta que elementos interativos tenham os traits corretos.
- **Uso:** `.accessibilityAddTraits(.isButton)`, `.accessibilityRemoveTraits(.isImage)`.
- **Valor/Estado:** Use `.accessibilityValue()` para descrever o estado atual de controles customizados (ex: "75% concluído").

## Convenções de Nomenclatura
- **Rótulos:** Use fragmentos de frase, comece com letra maiúscula e não termine com ponto final.
- **Verbos de Ação:** Rótulos de botões devem descrever a ação, não o nome do ícone.
  - **Preferido:** "Fechar", "Buscar", "Próxima Página".
  - **Evite:** "xmark", "magnifyingglass", "chevron.right".

## Testes
- Use o **Accessibility Inspector** no Xcode para verificar a árvore de acessibilidade e rótulos.
- Teste com **VoiceOver** em um dispositivo físico sempre que possível.
