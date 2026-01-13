# Como Funciona a Cópia e Instalação de Skills

Este documento explica como funciona a cópia e instalação de skills do Windsurf em conjunto com os comandos `specswift init` e `specswift install`.

## Fluxo Atual de Instalação

### `specswift init`

Quando você executa `specswift init`, o seguinte fluxo acontece:

1. **Verificação de dependências** (se `--no-deps` não for usado)
2. **Criação do diretório do projeto**
3. **Cópia de recursos** (na ordem):
   - `_copy_workflows()` - Copia workflows para `.windsurf/workflows/` ou `.cursor/commands/`
   - `_copy_rules()` - Copia rules para `.windsurf/rules/` ou `.cursor/rules/`
   - `_copy_templates()` - Copia templates para `_docs/templates/`
   - `_copy_scripts()` - Copia scripts para `_docs/scripts/bash/`
   - `_copy_documentation()` - Copia documentação para `_docs/`
4. **Criação do Makefile** (se não existir)
5. **Inicialização do Git** (se `--no-git` não for usado)

### `specswift install`

Quando você executa `specswift install`, o fluxo é similar, mas:

1. **Verifica se já está instalado** (a menos que `--force` seja usado)
2. **Copia recursos** (mesma ordem que `init`)
3. **Não sobrescreve Makefile existente**

### `specswift update`

Quando você executa `specswift update`:

1. **Detecta o editor** (Cursor ou Windsurf) baseado nos diretórios existentes
2. **Atualiza workflows** (sempre sobrescreve)
3. **Atualiza templates** (sempre sobrescreve)
4. **Atualiza documentação**

## Onde Skills se Encairam

Skills devem ser copiadas **apenas para projetos Windsurf**, já que são uma feature específica do Windsurf. O fluxo seria:

### Para `specswift init`:

```bash
# Fluxo atual
_copy_workflows "$target_dir" "$editor" "$verbose"
_copy_rules "$target_dir" "$editor" "$ios_mode" "$verbose"
_copy_templates "$target_dir" "$verbose"
_copy_scripts "$target_dir" "$verbose"
_copy_documentation "$target_dir" "$ios_mode" "$verbose"

# NOVO: Adicionar cópia de skills (apenas para Windsurf)
if [[ "$editor" == "windsurf" ]]; then
    _copy_skills "$target_dir" "$verbose"
fi
```

### Para `specswift install`:

```bash
# Fluxo atual
_copy_workflows "$target_dir" "$editor" "$verbose"
_copy_rules "$target_dir" "$editor" "$ios_mode" "$verbose"
_copy_templates "$target_dir" "$verbose"
_copy_scripts "$target_dir" "$verbose"
_copy_documentation "$target_dir" "$ios_mode" "$verbose"

# NOVO: Adicionar cópia de skills (apenas para Windsurf)
if [[ "$editor" == "windsurf" ]]; then
    _copy_skills "$target_dir" "$verbose"
fi
```

### Para `specswift update`:

```bash
# Fluxo atual
_copy_workflows "$target_dir" "$editor" "$verbose" true
_copy_templates "$target_dir" "$verbose" true

# NOVO: Adicionar atualização de skills (apenas para Windsurf)
if [[ "$editor" == "windsurf" ]]; then
    _copy_skills "$target_dir" "$verbose" true
fi
```

## Estrutura de Diretórios

### No CLI (lib/)

```
lib/
├── skills/
│   ├── en/
│   │   ├── prd-quality-validation/
│   │   │   ├── SKILL.md
│   │   │   └── checklists/
│   │   │       └── prd-quality-checklist.md
│   │   └── feature-setup/
│   │       ├── SKILL.md
│   │       └── scripts/
│   └── pt/
│       ├── prd-quality-validation/
│       │   ├── SKILL.md
│       │   └── checklists/
│       │       └── prd-quality-checklist.md
│       └── feature-setup/
│           ├── SKILL.md
│           └── scripts/
```

### No Projeto (após instalação)

```
projeto/
├── .windsurf/
│   ├── workflows/          # Workflows (já existe)
│   ├── rules/             # Rules (já existe)
│   └── skills/             # NOVO: Skills
│       ├── prd-quality-validation/
│       │   ├── SKILL.md
│       │   └── checklists/
│       │       └── prd-quality-checklist.md
│       └── feature-setup/
│           ├── SKILL.md
│           └── scripts/
```

## Implementação da Função `_copy_skills()`

A função `_copy_skills()` deve seguir o mesmo padrão das outras funções de cópia:

```bash
_copy_skills() {
    local target="$1"
    local verbose="${2:-false}"
    local overwrite="${3:-false}"

    print_header "🎯 Skills"
    
    # Skills são apenas para Windsurf
    local editor_dir=".windsurf"
    mkdir -p "$target/$editor_dir/skills"

    # Use skills from the selected language folder
    local skills_src="$LIB_DIR/skills/$LANG_CODE"
    # Fallback to English if the specific language folder doesn't exist
    if [[ ! -d "$skills_src" ]]; then
        skills_src="$LIB_DIR/skills/en"
    fi

    local count=0
    if [[ -d "$skills_src" ]]; then
        # Iterate through each skill directory
        for skill_dir in "$skills_src"/*/; do
            if [[ -d "$skill_dir" ]]; then
                local skill_name=$(basename "$skill_dir")
                local target_skill_dir="$target/$editor_dir/skills/$skill_name"
                
                # Check if skill already exists
                if [[ "$overwrite" == true || ! -d "$target_skill_dir" ]]; then
                    # Copy entire skill directory recursively
                    cp -R "$skill_dir" "$target/$editor_dir/skills/"
                    [[ "$verbose" == true ]] && print_success "$skill_name"
                    ((count++))
                else
                    [[ "$verbose" == true ]] && print_dim "  $skill_name (já existe, use --force para sobrescrever)"
                fi
            fi
        done
    fi
    
    if [[ $count -gt 0 ]]; then
        print_info "$count skills copiadas"
    else
        print_dim "Nenhuma skill encontrada ou todas já existem"
    fi
}
```

## Considerações Importantes

### 1. Skills são apenas para Windsurf

Skills são uma feature específica do Windsurf, então:
- **Não devem ser copiadas para projetos Cursor**
- Devem ser copiadas apenas quando `$editor == "windsurf"`

### 2. Estrutura de Skills

Cada skill é um diretório completo que deve ser copiado recursivamente:
- `SKILL.md` (obrigatório)
- Subdiretórios opcionais: `scripts/`, `templates/`, `checklists/`, `references/`

### 3. Idioma (LANG_CODE)

Skills seguem o mesmo padrão de localização:
- Primeiro tenta usar `$LANG_CODE` (en ou pt)
- Se não existir, usa `en` como fallback

### 4. Sobrescrita

- **`specswift init`**: Sempre copia (não verifica existência)
- **`specswift install`**: Não sobrescreve skills existentes (a menos que `--force`)
- **`specswift update`**: Sempre sobrescreve (comportamento padrão de update)

### 5. Verificação de Existência

Para `specswift install`, devemos verificar se skills já existem:

```bash
# Check if skills already exist
if [[ -d "$target_dir/.windsurf/skills" && "$force" != true ]]; then
    local existing_skills=$(ls -1 "$target_dir/.windsurf/skills" 2>/dev/null | wc -l | tr -d ' ')
    if [[ "$existing_skills" -gt 0 ]]; then
        print_warning "Skills já instaladas ($existing_skills skills)"
        echo ""
        echo "Use --force para sobrescrever ou 'specswift update' para atualizar"
        # Não sair com erro, apenas avisar
    fi
fi
```

## Exemplo de Fluxo Completo

### Cenário 1: `specswift init` com Windsurf

```bash
$ specswift init ~/Projects/my-app --editor windsurf --lang pt

📦 Criando Novo Projeto
✓ Diretório: /Users/user/Projects/my-app

📋 Workflows
→ 11 workflows copiados

📏 Rules
→ 5 rules copiadas

📄 Templates
→ 4 templates copiados

🔧 Scripts
→ 9 scripts copiados

🎯 Skills          # NOVO
→ prd-quality-validation
→ feature-setup
→ 2 skills copiadas

📚 Documentação
✓ SPECSWIFT-WORKFLOWS.md

✅ Projeto Criado!
```

### Cenário 2: `specswift install` em projeto existente

```bash
$ cd ~/Projects/existing-project
$ specswift install --editor windsurf

📥 Instalando SpecSwift
→ Diretório: /Users/user/Projects/existing-project

📋 Workflows
→ 11 workflows copiados

📏 Rules
→ 5 rules copiadas

📄 Templates
→ 4 templates copiados

🔧 Scripts
→ 9 scripts copiados

🎯 Skills          # NOVO
⚠️  Skills já instaladas (2 skills)
Use --force para sobrescrever ou 'specswift update' para atualizar

📚 Documentação
✓ SPECSWIFT-WORKFLOWS.md

✅ SpecSwift Instalado!
```

### Cenário 3: `specswift update` para atualizar skills

```bash
$ cd ~/Projects/my-project
$ specswift update

🔄 Atualizando SpecSwift

📋 Workflows
→ 11 workflows copiados

📄 Templates
→ 4 templates copiados

🎯 Skills          # NOVO
→ prd-quality-validation (atualizado)
→ feature-setup (atualizado)
→ 2 skills atualizadas

✅ SpecSwift atualizado para v1.0.0
```

## Modificações Necessárias no Código

### 1. Adicionar função `_copy_skills()` (após `_copy_scripts()`)

```bash
# Linha ~1653 em bin/specswift
_copy_skills() {
    # ... implementação acima ...
}
```

### 2. Modificar `cmd_init_internal()` (linha ~833)

```bash
# Adicionar após _copy_scripts
_copy_workflows "$target_dir" "$editor" "$verbose"
_copy_rules "$target_dir" "$editor" "$ios_mode" "$verbose"
_copy_templates "$target_dir" "$verbose"
_copy_scripts "$target_dir" "$verbose"
_copy_documentation "$target_dir" "$ios_mode" "$verbose"

# NOVO: Copiar skills apenas para Windsurf
if [[ "$editor" == "windsurf" ]]; then
    _copy_skills "$target_dir" "$verbose"
fi
```

### 3. Modificar `cmd_install_internal()` (linha ~967)

```bash
# Adicionar após _copy_scripts
_copy_workflows "$target_dir" "$editor" "$verbose"
_copy_rules "$target_dir" "$editor" "$ios_mode" "$verbose"
_copy_templates "$target_dir" "$verbose"
_copy_scripts "$target_dir" "$verbose"
_copy_documentation "$target_dir" "$ios_mode" "$verbose"

# NOVO: Copiar skills apenas para Windsurf
if [[ "$editor" == "windsurf" ]]; then
    _copy_skills "$target_dir" "$verbose"
fi
```

### 4. Modificar `cmd_update()` (linha ~1047)

```bash
# Adicionar após _copy_templates
_copy_workflows "$target_dir" "$editor" "$verbose" true
_copy_templates "$target_dir" "$verbose" true

# NOVO: Atualizar skills apenas para Windsurf
if [[ "$editor" == "windsurf" ]]; then
    _copy_skills "$target_dir" "$verbose" true
fi
```

### 5. Adicionar strings de localização

No início do arquivo, na função `L()`, adicionar:

```bash
# Português
"skills") echo "Skills" ;;
"skills_copied") echo "skills copiadas" ;;
"skills_updated") echo "skills atualizadas" ;;

# Inglês
"skills") echo "Skills" ;;
"skills_copied") echo "skills copied" ;;
"skills_updated") echo "skills updated" ;;
```

## Testes

Após implementar, testar:

1. **`specswift init` com Windsurf**: Skills devem ser copiadas
2. **`specswift init` com Cursor**: Skills NÃO devem ser copiadas
3. **`specswift install` com skills existentes**: Deve avisar mas não falhar
4. **`specswift install --force`**: Deve sobrescrever skills existentes
5. **`specswift update`**: Deve atualizar skills existentes

## Conclusão

A integração de skills no fluxo de instalação é direta e segue o mesmo padrão dos outros recursos (workflows, rules, templates, scripts). A principal diferença é que skills são copiadas apenas para projetos Windsurf, já que são uma feature específica desse editor.
