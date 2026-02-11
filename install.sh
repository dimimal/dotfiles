#!/bin/bash

# Vim/Neovim Dotfiles Installation Script
# This script automates the installation of vim and neovim configuration

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print functions
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "\n${BLUE}===========================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===========================================================${NC}\n"
}

# Check if running on macOS or Linux
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        OS="linux"
    else
        OS="unknown"
    fi
}

# Backup existing configuration
backup_config() {
    print_header "Backing Up Existing Configuration"

    BACKUP_DIR="$HOME/.vim-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    if [ -f "$HOME/.vimrc" ]; then
        cp "$HOME/.vimrc" "$BACKUP_DIR/"
        print_success "Backed up .vimrc to $BACKUP_DIR"
    fi

    if [ -d "$HOME/.vim" ]; then
        cp -r "$HOME/.vim" "$BACKUP_DIR/"
        print_success "Backed up .vim/ to $BACKUP_DIR"
    fi

    if [ -d "$HOME/.config/nvim" ]; then
        cp -r "$HOME/.config/nvim" "$BACKUP_DIR/"
        print_success "Backed up .config/nvim/ to $BACKUP_DIR"
    fi

    if [ "$(ls -A $BACKUP_DIR)" ]; then
        print_info "Backup created at: $BACKUP_DIR"
    else
        rmdir "$BACKUP_DIR"
        print_info "No existing configuration found, skipping backup"
    fi
}

# Install vim configuration files
install_vim_config() {
    print_header "Installing Vim Configuration"

    # Copy .vimrc
    cp .vimrc "$HOME/"
    print_success "Installed .vimrc"

    # Create .vim directory structure
    mkdir -p "$HOME/.vim/config"
    mkdir -p "$HOME/.vim/autoload"

    # Copy config files
    cp -r vim/config/* "$HOME/.vim/config/"
    print_success "Installed vim config files"

    # Copy vim-plug
    cp vim/autoload/plug.vim "$HOME/.vim/autoload/"
    print_success "Installed vim-plug"
}

# Install neovim configuration
install_nvim_config() {
    print_header "Installing Neovim Configuration"

    # Create neovim config directory
    mkdir -p "$HOME/.config/nvim"

    # Copy init.vim
    cp nvim/init.vim "$HOME/.config/nvim/"
    print_success "Installed neovim init.vim"

    # Set up vim-plug for neovim
    mkdir -p "$HOME/.local/share/nvim/site/autoload"
    cp vim/autoload/plug.vim "$HOME/.local/share/nvim/site/autoload/"
    print_success "Installed vim-plug for neovim"

    # Create undo directory
    mkdir -p "$HOME/.config/nvim/undo"
    print_success "Created persistent undo directory"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install system dependencies
install_dependencies() {
    print_header "Installing System Dependencies"

    if [ "$OS" == "macos" ]; then
        if ! command_exists brew; then
            print_error "Homebrew not found. Please install Homebrew first:"
            print_info "Visit https://brew.sh/"
            return 1
        fi

        print_info "Installing packages via Homebrew..."
        brew install neovim python3 node xclip ctags the_silver_searcher 2>/dev/null || true

    elif [ "$OS" == "linux" ]; then
        if command_exists apt-get; then
            print_info "Installing packages via apt-get..."
            print_warning "This requires sudo privileges"
            sudo apt-get update
            sudo apt-get install -y \
                neovim \
                python3 python3-pip \
                nodejs npm \
                xclip xsel \
                silversearcher-ag \
                exuberant-ctags 2>/dev/null || true

        elif command_exists dnf; then
            print_info "Installing packages via dnf..."
            print_warning "This requires sudo privileges"
            sudo dnf install -y \
                neovim \
                python3 python3-pip \
                nodejs npm \
                xclip xsel \
                the_silver_searcher \
                ctags 2>/dev/null || true

        elif command_exists pacman; then
            print_info "Installing packages via pacman..."
            print_warning "This requires sudo privileges"
            sudo pacman -S --noconfirm \
                neovim \
                python python-pip \
                nodejs npm \
                xclip xsel \
                the_silver_searcher \
                ctags 2>/dev/null || true
        else
            print_warning "Package manager not recognized. Please install dependencies manually."
            print_info "Required: neovim, python3, nodejs, xclip, ag, ctags"
            return 1
        fi
    else
        print_warning "OS not recognized. Please install dependencies manually."
        return 1
    fi

    print_success "System dependencies installed"
}

# Install Python provider
install_python_provider() {
    print_header "Installing Python Provider"

    if command_exists pip3; then
        pip3 install --user pynvim
        print_success "Installed pynvim"
    else
        print_warning "pip3 not found. Please install pynvim manually: pip3 install --user pynvim"
    fi
}

# Install Node.js provider
install_node_provider() {
    print_header "Installing Node.js Provider"

    if command_exists npm; then
        if [ "$OS" == "macos" ] || [ "$EUID" -ne 0 ]; then
            npm install -g neovim --prefix ~/.local 2>/dev/null || npm install -g neovim
        else
            npm install -g neovim
        fi
        print_success "Installed neovim (node package)"
    else
        print_warning "npm not found. Please install Node.js provider manually: npm install -g neovim"
    fi
}

# Install vim plugins
install_plugins() {
    print_header "Installing Vim Plugins"

    if command_exists nvim; then
        print_info "Installing plugins for neovim..."
        nvim +PlugInstall +qall || print_warning "Plugin installation had some issues. Run :PlugInstall manually."
        print_success "Neovim plugins installed"
    else
        print_warning "Neovim not found. Skipping plugin installation."
        print_info "After installing neovim, run: nvim +PlugInstall +qall"
    fi

    if command_exists vim; then
        print_info "Installing plugins for vim..."
        vim +PlugInstall +qall || print_warning "Plugin installation had some issues. Run :PlugInstall manually."
        print_success "Vim plugins installed"
    fi
}

# Optional dependencies
install_optional() {
    print_header "Installing Optional Dependencies"

    print_info "These are optional but recommended:"
    echo ""
    echo "1. Jupyter notebook support (vimpyter):"
    echo "   pip3 install --user notedown"
    echo ""
    echo "2. LaTeX support:"
    echo "   Ubuntu/Debian: sudo apt-get install latexmk texlive"
    echo "   macOS: brew install mactex"
    echo ""
    echo "3. Nerd Fonts (for icons):"
    echo "   Download from: https://www.nerdfonts.com/"
    echo ""

    read -p "Install notedown for Jupyter support? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        pip3 install --user notedown
        print_success "Installed notedown"
    fi
}

# Main installation
main() {
    print_header "Vim/Neovim Dotfiles Installation"

    detect_os
    print_info "Detected OS: $OS"

    # Check if we're in the right directory
    if [ ! -f ".vimrc" ] || [ ! -d "vim" ] || [ ! -d "nvim" ]; then
        print_error "Installation files not found!"
        print_info "Please run this script from the extracted vim-dotfiles directory"
        exit 1
    fi

    echo ""
    print_warning "This script will:"
    echo "  1. Backup your existing vim/neovim configuration"
    echo "  2. Install new configuration files"
    echo "  3. Install system dependencies (requires sudo)"
    echo "  4. Install Python and Node.js providers"
    echo "  5. Install vim plugins"
    echo ""
    read -p "Continue with installation? [y/N] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_info "Installation cancelled"
        exit 0
    fi

    # Run installation steps
    backup_config
    install_vim_config
    install_nvim_config

    echo ""
    read -p "Install system dependencies (requires sudo)? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_dependencies
    else
        print_info "Skipping system dependencies. Install manually if needed."
    fi

    install_python_provider
    install_node_provider

    echo ""
    read -p "Install vim plugins now? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        install_plugins
    else
        print_info "Skipping plugin installation. Run 'nvim +PlugInstall +qall' manually later."
    fi

    echo ""
    read -p "Check optional dependencies? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        install_optional
    fi

    # Final message
    print_header "Installation Complete!"

    echo ""
    print_success "Vim/Neovim configuration installed successfully!"
    echo ""
    print_info "Next steps:"
    echo "  1. Restart your terminal"
    echo "  2. Run 'nvim' to start using neovim"
    echo "  3. Press ',t' to toggle NERDTree"
    echo "  4. Press '<F8>' to toggle Tagbar"
    echo ""
    print_info "Troubleshooting:"
    echo "  - Run ':checkhealth' in neovim to diagnose issues"
    echo "  - Run ':PlugInstall' if plugins didn't install"
    echo "  - See README.md for more information"
    echo ""
    print_info "Configuration files:"
    echo "  - Vim: ~/.vimrc and ~/.vim/"
    echo "  - Neovim: ~/.config/nvim/init.vim"
    echo ""

    if [ -n "$BACKUP_DIR" ] && [ -d "$BACKUP_DIR" ]; then
        print_info "Your old configuration was backed up to:"
        echo "  $BACKUP_DIR"
    fi

    echo ""
    print_success "Happy Vimming! 🎉"
    echo ""
}

# Run main installation
main
