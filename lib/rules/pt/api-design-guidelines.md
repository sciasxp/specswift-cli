---
description: Siga estas diretrizes ao escrever código Swift para garantir clareza, consistência e uma sensação "Swift-native".
trigger: always_on
---

# Diretrizes de Design de API Swift

## Fundamentos
- **Clareza no ponto de uso** é o objetivo mais importante.
- **Clareza é mais importante que brevidade.**
- Se você não consegue descrever uma API de forma simples, ela pode estar mal projetada.

## Nomenclatura
- **Promova o Uso Claro:**
  - Inclua todas as palavras necessárias para evitar ambiguidade.
  - Omita palavras desnecessárias (não repita informações de tipo).
  - Nomeie variáveis, parâmetros e tipos associados de acordo com seus **papéis**, não restrições de tipo.
  - Compense informações de tipo fracas (preceda parâmetros fracamente tipados com um substantivo descrevendo seu papel).
- **Busque um Uso Fluente:**
  - Prefira nomes de métodos/funções que façam os locais de uso formarem frases gramaticais em inglês (ou português, se for o padrão do projeto).
  - Métodos de fábrica (factory) devem começar com `make`.
  - Inicializadores e métodos de fábrica: o primeiro argumento não deve formar uma frase começando com o nome base.
  - Nomeie funções/métodos de acordo com efeitos colaterais:
    - Sem efeitos colaterais: leia como frases nominais (ex: `x.distance(to: y)`).
    - Com efeitos colaterais: leia como frases verbais imperativas (ex: `x.sort()`).
  - Pares mutáveis/não mutáveis:
    - Use o sufixo "ed" ou "ing" para variantes não mutáveis de operações baseadas em verbos (ex: `sort` -> `sorted`).
    - Use o prefixo "form" para variantes mutáveis de operações baseadas em substantivos (ex: `union` -> `formUnion`).
- **Tipos Booleanos:** Devem ser lidos como asserções (ex: `isEmpty`, `intersects`).
- **Protocolos:** 
  - Descrevem *o que algo é*: Substantivos (ex: `Collection`).
  - Descrevem uma *capacidade*: Sufixos `able`, `ible`, ou `ing` (ex: `Equatable`).
- **Convenções de Case:**
  - Tipos e Protocolos: `UpperCamelCase`.
  - Todo o resto: `lowerCamelCase`.
  - Acrônimos: Trate como palavras comuns, a menos que todas as letras maiúsculas sejam o padrão (ex: `utf8`, `ASCII`).

## Documentação
- Use o dialeto Markdown do Swift.
- Comece com um resumo (fragmento de frase terminando em ponto).
- Descreva o que uma função **faz** e **retorna**.
- Descreva o que um subscript **acessa**.
- Descreva o que um inicializador **cria**.
- Documente a complexidade se não for O(1) para propriedades computadas.

## Convenções
- **Parâmetros:**
  - Escolha nomes que sirvam à documentação.
  - Aproveite parâmetros com valor padrão para simplificar usos comuns.
  - Posicione parâmetros com padrão para o final.
- **Rótulos de Argumento (Labels):**
  - Omita rótulos quando os argumentos não puderem ser distinguidos de forma útil (ex: `min(a, b)`).
  - Omita o primeiro rótulo em conversões de tipo que preservam o valor.
  - Se o primeiro argumento fizer parte de uma frase preposicional, dê a ele um rótulo (geralmente começando com a preposição).
  - Caso contrário, se fizer parte de uma frase gramatical, omita o rótulo e anexe as palavras precedentes ao nome base (ex: `addSubview(y)`).
  - Rotule todos os outros argumentos.

## Instruções Especiais
- **Membros de tupla e parâmetros de closure:** Rotule/nomeie-os para melhor documentação e expressividade.
- **Polimorfismo não restringido:** Tome cuidado extra com `Any`, `AnyObject`, etc., para evitar ambiguidade em sobrecargas.
