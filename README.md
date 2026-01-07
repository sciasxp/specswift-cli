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
git clone https://github.com/user/specswift-cli.git
cd specswift-cli

# Install
./install.sh
```

### Manual Install

```bash
# Clone the repository
git clone https://github.com/user/specswift-cli.git

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
# Basic project
specswift init ~/Projects/my-app

# iOS/Swift project
specswift init ~/Projects/my-ios-app --ios

# Without Git initialization
specswift init ~/Projects/my-app --no-git
```

**What gets created:**
```
my-app/
├── .windsurf/
│   ├── workflows/     # SpecSwift workflows
│   └── rules/         # Code rules
├── _docs/
│   ├── templates/     # PRD, TechSpec, Tasks templates
│   ├── scripts/       # Automation scripts
│   └── specs/         # Feature specs directory
├── Makefile           # Build/test commands
└── .gitignore
```

### `specswift install` - Install in Existing Project

Adds SpecSwift to an existing project.

```bash
cd ~/Projects/existing-project

# Basic installation
specswift install

# With iOS configurations
specswift install --ios

# Force overwrite
specswift install --force
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

## 🔄 Usage Flow

### New Project

```bash
# 1. Create project
specswift init ~/Projects/new-app --ios

# 2. Open in Windsurf
cd ~/Projects/new-app
windsurf .

# 3. In Windsurf, run workflows:
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

# 2. Install SpecSwift
specswift install --ios

# 3. Open in Windsurf and follow the flow
windsurf .
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

## 📁 Project Structure

```
specswift-cli/
├── bin/
│   └── specswift          # Main CLI
├── lib/
│   ├── workflows/         # Windsurf workflows
│   ├── templates/         # Document templates
│   ├── rules/             # Code rules
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
| `--no-git` | Don't initialize Git repository |
| `--force` | Overwrite existing files |
| `--lang <en\|pt>` | Set language (en/pt) |
| `-v, --verbose` | Detailed output |
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
- `_docs/SPECSWIFT-WORKFLOWS.md` - Complete workflows guide
- `.windsurf/workflows/` - Detailed workflow definitions

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
git clone https://github.com/user/specswift-cli.git
cd specswift-cli

# Instale
./install.sh
```

### Instalação Manual

```bash
# Clone o repositório
git clone https://github.com/user/specswift-cli.git

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
# Projeto básico
specswift init ~/Projetos/meu-app

# Projeto iOS/Swift
specswift init ~/Projetos/meu-app-ios --ios

# Sem inicialização Git
specswift init ~/Projetos/meu-app --no-git
```

**O que é criado:**
```
meu-app/
├── .windsurf/
│   ├── workflows/     # Workflows SpecSwift
│   └── rules/         # Rules de código
├── _docs/
│   ├── templates/     # Templates PRD, TechSpec, Tasks
│   ├── scripts/       # Scripts de automação
│   └── specs/         # Diretório para features
├── Makefile           # Comandos de build/test
└── .gitignore
```

### `specswift install` - Instalar em Projeto Existente

Adiciona SpecSwift a um projeto que já existe.

```bash
cd ~/Projetos/projeto-existente

# Instalação básica
specswift install

# Com configurações iOS
specswift install --ios

# Forçar sobrescrita
specswift install --force
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

## 🔄 Fluxo de Uso

### Novo Projeto

```bash
# 1. Criar projeto
specswift init ~/Projetos/novo-app --ios

# 2. Abrir no Windsurf
cd ~/Projetos/novo-app
windsurf .

# 3. No Windsurf, executar workflows:
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

# 2. Instalar SpecSwift
specswift install --ios

# 3. Abrir no Windsurf e seguir o fluxo
windsurf .
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

## 📁 Estrutura do Projeto

```
specswift-cli/
├── bin/
│   └── specswift          # CLI principal
├── lib/
│   ├── workflows/         # Workflows do Windsurf
│   ├── templates/         # Templates de documentos
│   ├── rules/             # Rules de código
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
| `--no-git` | Não inicializar repositório Git |
| `--force` | Sobrescrever arquivos existentes |
| `--lang <en\|pt>` | Definir idioma (en/pt) |
| `-v, --verbose` | Output detalhado |
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
- `_docs/SPECSWIFT-WORKFLOWS.md` - Guia completo dos workflows
- `.windsurf/workflows/` - Definição detalhada de cada workflow

## 🤝 Contribuindo

1. Fork o repositório
2. Crie uma branch para sua feature
3. Faça suas alterações
4. Envie um Pull Request

## 📄 Licença

MIT License
