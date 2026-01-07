---
description: Diretrizes para build, execução e testes do projeto usando o Makefile fornecido.
trigger: model_decision
---

# Diretrizes de Uso do Makefile
O projeto usa um `Makefile` no diretório raiz para padronizar tarefas comuns de desenvolvimento. Sempre prefira estes comandos em vez de invocações manuais de `xcodebuild` ou `simctl`.

## Pré-requisitos

Antes de usar o Makefile, garanta que:
- **Xcode 16+** esteja instalado com o SDK do iOS 18+
- **Git LFS** esteja configurado para arquivos binários de modelos:
  ```bash
  git lfs pull
  ```
- **xcbeautify** esteja instalado (para saída de build formatada):
  ```bash
  brew install xcbeautify
  ```

## Comandos Padrão

### 1. Build e Run (Padrão)
Compila o app e inicia no simulador do iPhone 17:
```bash
make
```
Equivalente a `make run`. Este comando:
- Compila o projeto para o simulador
- Inicia o simulador se necessário
- Instala o app
- Inicia o app com o bundle ID configurado

**Quando usar**: Fluxo de desenvolvimento principal — compilar, testar e verificar mudanças imediatamente.

### 2. Compilar para Simulador
Compila o projeto para o simulador sem executá-lo:
```bash
make build
```

**Quando usar**: 
- Verificar compilação antes de rodar
- Checar erros de build sem iniciar o app
- Preparar para integração com outras ferramentas

### 3. Executar Testes Unitários
Executa todos os testes unitários no scheme configurado no simulador:
```bash
make test
```

**Quando usar**: 
- Validar mudanças de código com testes automatizados
- Garantir que não haja regressões antes de commitar
- Parte do ciclo padrão de desenvolvimento (build → test → run)

### 4. Compilar para Dispositivo Físico
Compila o app para um dispositivo físico conectado:
```bash
make device
```

**Quando usar**: 
- Testar em hardware real antes do lançamento
- Verificar performance e comportamento específico do dispositivo
- Nota: Rodar no dispositivo físico geralmente requer interação manual no Xcode ou ferramentas adicionais como `ios-deploy`

### 5. Limpar Projeto
Remove artefatos de build e DerivedData associados ao projeto:
```bash
make clean
```

**Quando usar**: 
- Resolver problemas persistentes de build
- Liberar espaço em disco
- Resetar o estado do build antes de mudanças maiores

### 6. Build com Saída Bruta (Debugging)
Compila sem a formatação do `xcbeautify` para ver erros brutos do Xcode:
```bash
make build-raw
```

**Quando usar**: 
- Diagnosticar falhas de build com detalhes completos de erro
- Debugar warnings e erros do compilador
- Quando a saída do `xcbeautify` não estiver clara

### 7. Mostrar Ajuda
Mostra todos os comandos disponíveis e suas descrições:
```bash
make help
```

## Configuração

O Makefile usa a configuração definida no topo do arquivo. Para modificar o Scheme, Projeto ou Destino, edite a seção de configuração no `Makefile`.

## Fluxos Comuns

### Ciclo de Desenvolvimento
```bash
make build          # Compilar mudanças
make test           # Rodar testes unitários
make                # Compilar e rodar no simulador
```

### Testar Antes de Commitar
```bash
make clean          # Resetar estado do build
make test           # Rodar todos os testes
make                # Verificar se o app inicia
```

### Debugar Problemas de Build
```bash
make build-raw      # Ver saída completa do compilador
make clean          # Limpar artefatos em cache
make build          # Recompilar do zero
```
