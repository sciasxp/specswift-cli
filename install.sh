#!/usr/bin/env bash
#
# SpecSwift CLI Installer
#
# Uso:
#   curl -fsSL https://raw.githubusercontent.com/sciasxp/specswift-cli/main/install.sh | bash
#   ou
#   ./install.sh [--prefix /usr/local]
#

set -e

# =============================================================================
# Configurações
# =============================================================================
VERSION_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/VERSION"
VERSION="$(cat "$VERSION_FILE" 2>/dev/null || echo "1.0.0")"
INSTALL_PREFIX="${HOME}/.local"
SPECSWIFT_HOME="${HOME}/.specswift"
REPO_URL="https://github.com/sciasxp/specswift-cli"

# =============================================================================
# Cores
# =============================================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1" >&2; }
print_info() { echo -e "${BLUE}→${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# =============================================================================
# Parse argumentos
# =============================================================================
UNINSTALL=false
LOCAL_INSTALL=false
SOURCE_DIR=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prefix)
            INSTALL_PREFIX="$2"
            shift 2
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        --local)
            LOCAL_INSTALL=true
            SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            shift
            ;;
        --help|-h)
            cat << 'EOF'
SpecSwift CLI Installer

USO:
    ./install.sh [opções]

OPÇÕES:
    --prefix <dir>   Diretório de instalação (default: ~/.local)
    --local          Instalar a partir do diretório local (não baixar)
    --uninstall      Remover instalação do SpecSwift
    --help, -h       Mostrar ajuda

EXEMPLOS:
    # Instalação padrão
    ./install.sh

    # Instalação em diretório customizado
    ./install.sh --prefix /usr/local

    # Remover instalação
    ./install.sh --uninstall

EOF
            exit 0
            ;;
        *)
            print_error "Opção desconhecida: $1"
            exit 1
            ;;
    esac
done

# =============================================================================
# Uninstall
# =============================================================================
do_uninstall() {
    echo -e "${BOLD}${BLUE}Removendo SpecSwift CLI...${NC}"
    
    if [[ -f "$INSTALL_PREFIX/bin/specswift" ]]; then
        rm "$INSTALL_PREFIX/bin/specswift"
        print_success "Removido: $INSTALL_PREFIX/bin/specswift"
    fi
    
    if [[ -d "$SPECSWIFT_HOME" ]]; then
        rm -rf "$SPECSWIFT_HOME"
        print_success "Removido: $SPECSWIFT_HOME"
    fi
    
    echo ""
    print_success "SpecSwift CLI removido!"
}

# =============================================================================
# Install
# =============================================================================
do_install() {
    echo -e "${BOLD}${BLUE}"
    cat << 'BANNER'
   ____                  ____          _  __ _   
  / ___| _ __   ___  ___/ ___|_      _(_)/ _| |_ 
  \___ \| '_ \ / _ \/ __\___ \ \ /\ / / | |_| __|
   ___) | |_) |  __/ (__ ___) \ V  V /| |  _| |_ 
  |____/| .__/ \___|\___|____/ \_/\_/ |_|_|  \__|
        |_|                                      
BANNER
    echo -e "${NC}"
    echo -e "  Installing SpecSwift CLI v$VERSION"
    echo ""

    # Criar diretórios
    mkdir -p "$INSTALL_PREFIX/bin"
    mkdir -p "$SPECSWIFT_HOME"

    # Determinar fonte
    if [[ "$LOCAL_INSTALL" == true && -n "$SOURCE_DIR" ]]; then
        print_info "Instalando a partir de: $SOURCE_DIR"
        
        # Copiar estrutura (incluindo subpastas de idiomas)
        cp -r "$SOURCE_DIR/lib" "$SPECSWIFT_HOME/"
        cp -r "$SOURCE_DIR/docs" "$SPECSWIFT_HOME/"
        mkdir -p "$SPECSWIFT_HOME/bin"
        cp "$SOURCE_DIR/bin/specswift" "$SPECSWIFT_HOME/bin/"
    else
        print_info "Baixando de $REPO_URL..."
        
        # Criar estrutura temporária
        local tmp_dir=$(mktemp -d)
        trap "rm -rf $tmp_dir" EXIT
        
        # Clone ou download
        if command -v git &> /dev/null; then
            git clone --depth 1 "$REPO_URL" "$tmp_dir/specswift-cli" 2>/dev/null || {
                print_error "Falha ao clonar repositório"
                print_info "Tentando instalação local..."
                LOCAL_INSTALL=true
                SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
                do_install
                return
            }
            # Copiar estrutura completa (incluindo subpastas de idiomas)
            cp -r "$tmp_dir/specswift-cli/lib" "$SPECSWIFT_HOME/"
            cp -r "$tmp_dir/specswift-cli/docs" "$SPECSWIFT_HOME/"
            mkdir -p "$SPECSWIFT_HOME/bin"
            cp "$tmp_dir/specswift-cli/bin/specswift" "$SPECSWIFT_HOME/bin/"
        else
            print_warning "Git não encontrado, tentando instalação local..."
            LOCAL_INSTALL=true
            SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
            do_install
            return
        fi
    fi

    # Criar link simbólico
    chmod +x "$SPECSWIFT_HOME/bin/specswift"
    ln -sf "$SPECSWIFT_HOME/bin/specswift" "$INSTALL_PREFIX/bin/specswift"
    print_success "Comando instalado: $INSTALL_PREFIX/bin/specswift"

    # Verificar PATH
    echo ""
    if [[ ":$PATH:" != *":$INSTALL_PREFIX/bin:"* ]]; then
        print_warning "Adicione ao seu PATH:"
        echo ""
        echo -e "  ${BOLD}# Adicione ao ~/.zshrc ou ~/.bashrc:${NC}"
        echo "  export PATH=\"$INSTALL_PREFIX/bin:\$PATH\""
        echo ""
        echo "  Depois execute: source ~/.zshrc"
    else
        print_success "Diretório já está no PATH"
    fi

    # Verificar instalação
    echo ""
    print_success "SpecSwift CLI instalado com sucesso!"
    echo ""
    echo -e "${BOLD}Comandos disponíveis:${NC}"
    echo "  specswift init <dir>   - Criar novo projeto"
    echo "  specswift install      - Instalar em projeto existente"
    echo "  specswift doctor       - Verificar instalação"
    echo "  specswift help         - Ver ajuda completa"
}

# =============================================================================
# Main
# =============================================================================
if [[ "$UNINSTALL" == true ]]; then
    do_uninstall
else
    do_install
fi
