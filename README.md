<div align="center">

# SpecSwift CLI

**AI-powered feature specification and implementation toolkit for iOS/Swift projects**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-macOS-lightgrey.svg)]()
[![Swift](https://img.shields.io/badge/Swift-6.2+-orange.svg)]()

[English](#english) | [Português](#português)

</div>

---

# English

Command line tool for feature specification and implementation using the SpecSwift workflow system.

## 🚀 Installation

### Quick Install

```bash
# Clone the repository
git clone https://github.com/sciasxp/specswift-cli.git
cd specswift-cli

# Install
./install.sh
```

### One-liner Install (recommended)

```bash
curl -fsSL https://raw.githubusercontent.com/sciasxp/specswift-cli/main/install.sh | bash
```

### Manual Install

```bash
# Clone the repository
git clone https://github.com/sciasxp/specswift-cli.git

# Add to PATH (in ~/.zshrc or ~/.bashrc)
export PATH="$HOME/path/to/specswift-cli/bin:$PATH"
```

### Verify Installation

```bash
specswift doctor
```

## 📖 Commands

### `specswift init` - Create New Project

Creates a new project with complete SpecSwift structure.

```bash
# Basic project (English by default)
specswift init ~/Projects/my-app

# iOS/Swift project in Portuguese
specswift init ~/Projects/my-ios-app --ios --lang pt

# Without Git initialization
specswift init ~/Projects/my-app --no-git

# Interactive mode (no arguments)
specswift init
# You'll be prompted to select all configuration options
```

**What gets created:**
```
my-app/
├── .cursor/ or .windsurf/  # IDE-specific directory (selected during init)
│   ├── workflows/     # Localized SpecSwift workflows
│   └── rules/         # Localized code rules
├── _docs/
│   ├── templates/     # Localized document templates
│   ├── scripts/       # Automation scripts
│   │   └── bash/      # Bash scripts
│   └── specs/         # Feature specs directory
├── Makefile           # Build/test commands
└── .gitignore
```

### `specswift install` - Install in Existing Project

Adds SpecSwift to an existing project.

```bash
cd ~/Projects/existing-project

# Basic installation (English)
specswift install

# With iOS configurations in Portuguese
specswift install --ios --lang pt

# Force overwrite
specswift install --force

# Interactive mode (no arguments)
specswift install
# Interactive menu will guide you through installation options
```

### `specswift update` - Update Workflows

Updates workflows and templates to the latest version.

```bash
cd ~/Projects/my-project
specswift update
```

### `specswift doctor` - Check Installation

Verifies installation and available dependencies.

```bash
specswift doctor
```

## 🎯 Interactive Mode

Both `init` and `install` commands support an interactive mode that guides you through all configuration options via menus. Interactive mode is automatically activated when no command-line options are provided.

**When Interactive Mode is Activated:**
- `specswift init` - When run without any arguments
- `specswift install` - When run without any options (except `--lang` which is global)

**When CLI Mode is Used:**
- If you provide any CLI options (like `--ios`, `--editor`, `--no-git`, etc.), the command will use CLI mode instead of interactive mode
- For `init`, if you provide a directory path, it will use CLI mode

**Example - Interactive Init:**
```bash
specswift init
# You'll be prompted to select:
# - Project directory
# - Editor (Cursor/Windsurf)
# - Language (en/pt)
# - iOS mode
# - Xcode template (if iOS)
# - Bundle ID prefix (if template selected)
# - Git initialization
# - Dependency checking
# - Verbose mode
# - Force overwrite
# - Confirmation before creating
```

**Example - Interactive Install:**
```bash
cd ~/Projects/my-project
specswift install
# Interactive menu will guide you through:
# - Editor selection (Cursor/Windsurf)
# - Language (en/pt)
# - iOS mode
# - Dependency checking
# - Verbose mode
# - Force overwrite
# - Confirmation before installing
```

**Note**: If you provide any CLI options, the command will use CLI mode instead of interactive mode. This allows you to use interactive mode for guided setup or CLI mode for automation and scripts.

## 🔄 Usage Flow

### New Project

```bash
# 1. Create project (you'll be prompted to select Cursor or Windsurf)
specswift init ~/Projects/new-app --ios

# Or specify the editor directly:
specswift init ~/Projects/new-app --ios --editor cursor
# or
specswift init ~/Projects/new-app --ios --editor windsurf

# 2. Open in your selected editor
cd ~/Projects/new-app
cursor .    # if you selected Cursor
# or
windsurf .  # if you selected Windsurf

# 3. In your editor, run workflows:
#    /specswift.constitution     → Configure base documentation
#    /specswift.create-prd       → Create feature PRD
#    /specswift.create-techspec  → Create technical specification
#    /specswift.tasks            → Generate tasks
#    /specswift.implement        → Implement
```

### Existing Project

```bash
# 1. Navigate to project
cd ~/Projects/my-existing-project

# 2. Install SpecSwift (you'll be prompted to select Cursor or Windsurf)
specswift install --ios

# Or specify the editor directly:
specswift install --ios --editor cursor
# or
specswift install --ios --editor windsurf

# 3. Open in your selected editor and follow the flow
cursor .    # if you selected Cursor
# or
windsurf .  # if you selected Windsurf
```

## 📋 Available Workflows

| Workflow | Description |
|----------|-------------|
| `/specswift.constitution` | Create project base documentation |
| `/specswift.create-prd` | Create PRD (Product Requirements Document) |
| `/specswift.clarify` | Clarify PRD ambiguities |
| `/specswift.create-techspec` | Create technical specification |
| `/specswift.tasks` | Generate task list |
| `/specswift.analyze` | Validate coverage before implementing |
| `/specswift.implement` | Execute implementation |
| `/specswift.yolo` | Automatic mode (PRD → TechSpec → Tasks) |
| `/specswift.taskstoissues` | Convert tasks to GitHub Issues |
| `/specswift.bug-investigation` | Structured workflow for investigating and fixing bugs |

## 📁 Project Structure

```
specswift-cli/
├── bin/
│   └── specswift          # Main CLI
├── lib/
│   ├── workflows/         # Localized Windsurf workflows (en/pt)
│   ├── templates/         # Localized document templates (en/pt)
│   ├── rules/             # Localized code rules (en/pt)
│   └── scripts/           # Helper scripts
├── docs/
│   └── SPECSWIFT-WORKFLOWS.md
├── install.sh             # Installer
└── README.md
```

## ⚙️ Options

### Global Options

| Option | Description |
|--------|-------------|
| `--ios` | Apply iOS/Swift configurations |
| `--editor <cursor\|windsurf>` | Select IDE editor (default: prompt) |
| `--no-git` | Don't initialize Git repository |
| `--no-deps` | Skip dependency check/installation |
| `--force` | Overwrite existing files |
| `--lang <en\|pt>` | Set language (en/pt) |
| `-v, --verbose` | Detailed output |
| `-q, --quiet` | Errors only |
| `-h, --help` | Show help |

## 🛠️ Uninstall

```bash
./install.sh --uninstall
```

Or manually:

```bash
rm -rf ~/.specswift
rm ~/.local/bin/specswift
```

## 📚 Additional Documentation

After installing in a project, see:
- `docs/SPECSWIFT-WORKFLOWS.md` - Complete workflows guide (in this repository)
- `_docs/SPECSWIFT-WORKFLOWS.md` - Complete workflows guide (after installing into a project)
- `.cursor/workflows/` or `.windsurf/workflows/` - Detailed workflow definitions (depending on selected editor)

## 🤝 Contributing

1. Fork the repository
2. Create a branch for your feature
3. Make your changes
4. Submit a Pull Request

## 📄 License

MIT License

---

# Português

Ferramenta de linha de comando para especificação e implementação de features usando o sistema de workflows SpecSwift.

## 🚀 Instalação

### Instalação Rápida

```bash
# Clone o repositório
git clone https://github.com/sciasxp/specswift-cli.git
cd specswift-cli

# Instale
./install.sh
```

### Instalação em uma linha (recomendado)

```bash
curl -fsSL https://raw.githubusercontent.com/sciasxp/specswift-cli/main/install.sh | bash
```

### Instalação Manual

```bash
# Clone o repositório
git clone https://github.com/sciasxp/specswift-cli.git

# Adicione ao PATH (no ~/.zshrc ou ~/.bashrc)
export PATH="$HOME/path/to/specswift-cli/bin:$PATH"
```

### Verificar Instalação

```bash
specswift doctor
```

## 📖 Comandos

### `specswift init` - Criar Novo Projeto

Cria um novo projeto com toda a estrutura SpecSwift configurada.

```bash
# Projeto básico (Inglês por padrão)
specswift init ~/Projetos/meu-app

# Projeto iOS/Swift em Português
specswift init ~/Projetos/meu-app-ios --ios --lang pt

# Sem inicialização Git
specswift init ~/Projetos/meu-app --no-git

# Modo interativo (sem argumentos)
specswift init
# Você será solicitado a selecionar todas as opções de configuração
```

**O que é criado:**
```
meu-app/
├── .cursor/ ou .windsurf/  # Diretório específico do IDE (selecionado durante init)
│   ├── workflows/     # Workflows SpecSwift localizados
│   └── rules/         # Rules de código localizadas
├── _docs/
│   ├── templates/     # Templates de documentos localizados
│   ├── scripts/       # Scripts de automação
│   │   └── bash/      # Scripts bash
│   └── specs/         # Diretório para features
├── Makefile           # Comandos de build/test
└── .gitignore
```

### `specswift install` - Instalar em Projeto Existente

Adiciona SpecSwift a um projeto que já existe.

```bash
cd ~/Projetos/projeto-existente

# Instalação básica (Inglês)
specswift install

# Com configurações iOS em Português
specswift install --ios --lang pt

# Forçar sobrescrita
specswift install --force

# Modo interativo (sem argumentos)
specswift install
# Menu interativo guiará você pelas opções de instalação
```

### `specswift update` - Atualizar Workflows

Atualiza os workflows e templates para a versão mais recente.

```bash
cd ~/Projetos/meu-projeto
specswift update
```

### `specswift doctor` - Verificar Instalação

Verifica se a instalação está correta e todas as dependências estão disponíveis.

```bash
specswift doctor
```

## 🎯 Modo Interativo

Os comandos `init` e `install` suportam um modo interativo que guia você através de todas as opções de configuração via menus. O modo interativo é ativado automaticamente quando nenhuma opção de linha de comando é fornecida.

**Quando o Modo Interativo é Ativado:**
- `specswift init` - Quando executado sem argumentos
- `specswift install` - Quando executado sem opções (exceto `--lang` que é global)

**Quando o Modo CLI é Usado:**
- Se você fornecer qualquer opção CLI (como `--ios`, `--editor`, `--no-git`, etc.), o comando usará o modo CLI em vez do modo interativo
- Para `init`, se você fornecer um caminho de diretório, usará o modo CLI

**Exemplo - Init Interativo:**
```bash
specswift init
# Você será solicitado a selecionar:
# - Diretório do projeto
# - Editor (Cursor/Windsurf)
# - Idioma (en/pt)
# - Modo iOS
# - Template Xcode (se iOS)
# - Prefixo do Bundle ID (se template selecionado)
# - Inicialização Git
# - Verificação de dependências
# - Modo verbose
# - Forçar sobrescrita
# - Confirmação antes de criar
```

**Exemplo - Install Interativo:**
```bash
cd ~/Projetos/meu-projeto
specswift install
# Menu interativo guiará você através de:
# - Seleção de editor (Cursor/Windsurf)
# - Idioma (en/pt)
# - Modo iOS
# - Verificação de dependências
# - Modo verbose
# - Forçar sobrescrita
# - Confirmação antes de instalar
```

**Nota**: Se você fornecer qualquer opção CLI, o comando usará o modo CLI em vez do modo interativo. Isso permite usar o modo interativo para configuração guiada ou o modo CLI para automação e scripts.

## 🔄 Fluxo de Uso

### Novo Projeto

```bash
# 1. Criar projeto (será solicitado para selecionar Cursor ou Windsurf)
specswift init ~/Projetos/novo-app --ios --lang pt

# Ou especificar o editor diretamente:
specswift init ~/Projetos/novo-app --ios --lang pt --editor cursor
# ou
specswift init ~/Projetos/novo-app --ios --lang pt --editor windsurf

# 2. Abrir no editor selecionado
cd ~/Projetos/novo-app
cursor .    # se selecionou Cursor
# ou
windsurf .  # se selecionou Windsurf

# 3. No editor, executar workflows:
#    /specswift.constitution     → Configurar documentação base
#    /specswift.create-prd       → Criar PRD da feature
#    /specswift.create-techspec  → Criar especificação técnica
#    /specswift.tasks            → Gerar tarefas
#    /specswift.implement        → Implementar
```

### Projeto Existente

```bash
# 1. Navegar até o projeto
cd ~/Projetos/meu-projeto-existente

# 2. Instalar SpecSwift (será solicitado para selecionar Cursor ou Windsurf)
specswift install --ios --lang pt

# Ou especificar o editor diretamente:
specswift install --ios --lang pt --editor cursor
# ou
specswift install --ios --lang pt --editor windsurf

# 3. Abrir no editor selecionado e seguir o fluxo
cursor .    # se selecionou Cursor
# ou
windsurf .  # se selecionou Windsurf
```

## 📋 Workflows Disponíveis

| Workflow | Descrição |
|----------|-----------|
| `/specswift.constitution` | Criar documentação base do projeto |
| `/specswift.create-prd` | Criar PRD (Product Requirements Document) |
| `/specswift.clarify` | Esclarecer ambiguidades no PRD |
| `/specswift.create-techspec` | Criar especificação técnica |
| `/specswift.tasks` | Gerar lista de tarefas |
| `/specswift.analyze` | Validar cobertura antes de implementar |
| `/specswift.implement` | Executar implementação |
| `/specswift.yolo` | Modo automático (PRD → TechSpec → Tasks) |
| `/specswift.taskstoissues` | Converter tasks em GitHub Issues |
| `/specswift.bug-investigation` | Fluxo estruturado para investigar e corrigir bugs |

## 📁 Estrutura do Projeto

```
specswift-cli/
├── bin/
│   └── specswift          # CLI principal
├── lib/
│   ├── workflows/         # Workflows do Windsurf localizados (en/pt)
│   ├── templates/         # Templates de documentos localizados (en/pt)
│   ├── rules/             # Rules de código localizadas (en/pt)
│   └── scripts/           # Scripts auxiliares
├── docs/
│   └── SPECSWIFT-WORKFLOWS.md
├── install.sh             # Instalador
└── README.md
```

## ⚙️ Opções

### Opções Globais

| Opção | Descrição |
|-------|-----------|
| `--ios` | Aplicar configurações para iOS/Swift |
| `--editor <cursor\|windsurf>` | Selecionar editor IDE (padrão: solicitar) |
| `--no-git` | Não inicializar repositório Git |
| `--no-deps` | Pular verificação/instalação de dependências |
| `--force` | Sobrescrever arquivos existentes |
| `--lang <en\|pt>` | Definir idioma (en/pt) |
| `-v, --verbose` | Output detalhado |
| `-q, --quiet` | Apenas erros |
| `-h, --help` | Mostrar ajuda |

## 🛠️ Desinstalação

```bash
./install.sh --uninstall
```

Ou manualmente:

```bash
rm -rf ~/.specswift
rm ~/.local/bin/specswift
```

## 📚 Documentação Adicional

Após instalar em um projeto, veja:
- `docs/SPECSWIFT-WORKFLOWS.md` - Guia completo dos workflows (neste repositório)
- `_docs/SPECSWIFT-WORKFLOWS.md` - Guia completo dos workflows (após instalar no projeto)
- `.cursor/workflows/` ou `.windsurf/workflows/` - Definição detalhada de cada workflow (dependendo do editor selecionado)

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça suas alterações
4. Envie um Pull Request

## 📄 Licença

MIT License
