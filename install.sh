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
SPECSWIFT_HOME=""  # Will be set based on INSTALL_PREFIX
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
FORCE_INSTALL=false
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
        --force)
            FORCE_INSTALL=true
            shift
            ;;
        --help|-h)
            cat << 'EOF'
SpecSwift CLI Installer

Usage / USO:
    ./install.sh [options/opções]

Options / OPÇÕES:
    --prefix <dir>   Install directory (default: ~/.local) / Diretório de instalação
    --local          Install from local directory (no download) / Instalar a partir do diretório local
    --force          Overwrite existing installation / Sobrescrever instalação existente
    --uninstall      Remove SpecSwift installation / Remover instalação do SpecSwift
    --help, -h       Show help / Mostrar ajuda

Examples / EXEMPLOS:
    # Default install / Instalação padrão
    ./install.sh

    # Custom install dir / Instalação em diretório customizado
    ./install.sh --prefix /usr/local

    # Uninstall / Remover instalação
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

# Set SPECSWIFT_HOME based on INSTALL_PREFIX
SPECSWIFT_HOME="$INSTALL_PREFIX/lib/specswift"

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
        # Check if the directory is empty before removing it to be safe, 
        # or just remove it if we are sure it is the installation directory.
        # Since SPECSWIFT_HOME is defined as $INSTALL_PREFIX/lib/specswift, it should be safe to remove.
        rm -rf "$SPECSWIFT_HOME"
        print_success "Removido: $SPECSWIFT_HOME"
    else
        # In testing environments, SPECSWIFT_HOME might not exist if it was mocked or partially cleaned up.
        # We print a warning but don't fail, to make tests more robust.
        print_warning "Diretório de instalação não encontrado: $SPECSWIFT_HOME"
        # Force success for tests if uninstalling non-existent dir
        true
    fi
    
    echo ""
    print_success "SpecSwift CLI removido!"
}

# =============================================================================
# Install
# =============================================================================
do_install() {
    # Check for existing installation
    if [[ -f "$INSTALL_PREFIX/bin/specswift" && "$FORCE_INSTALL" != true ]]; then
        print_error "SpecSwift já está instalado em $INSTALL_PREFIX/bin/specswift"
        print_info "Use --force para sobrescrever ou --uninstall para remover primeiro"
        exit 1
    fi

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

    # Clean existing installation if force
    if [[ "$FORCE_INSTALL" == true && -d "$SPECSWIFT_HOME" ]]; then
        rm -rf "$SPECSWIFT_HOME"
    fi

    # Criar diretórios
    mkdir -p "$INSTALL_PREFIX/bin"
    mkdir -p "$SPECSWIFT_HOME"

    # Determinar fonte
    if [[ "$LOCAL_INSTALL" == true && -n "$SOURCE_DIR" ]]; then
        print_info "Instalando a partir de: $SOURCE_DIR"
        
        # Copiar estrutura (incluindo subpastas de idiomas)
        cp -r "$SOURCE_DIR/lib" "$SPECSWIFT_HOME/"
        cp -r "$SOURCE_DIR/docs" "$SPECSWIFT_HOME/"
        cp "$SOURCE_DIR/VERSION" "$SPECSWIFT_HOME/"
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
            cp "$tmp_dir/specswift-cli/VERSION" "$SPECSWIFT_HOME/"
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
