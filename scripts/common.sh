#!/usr/bin/env bash
# common.sh — shared helpers sourced by platform setup scripts

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

info()    { echo -e "${BLUE}[INFO]${NC}    $*"; }
success() { echo -e "${GREEN}[✓]${NC}      $*"; }
warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC}   $*"; }
header()  { echo -e "\n${BLUE}══════════════════════════════════════${NC}"; echo -e "${BLUE}  $*${NC}"; echo -e "${BLUE}══════════════════════════════════════${NC}\n"; }

command_exists() { command -v "$1" >/dev/null 2>&1; }

# Resolve the dotfiles root regardless of where the script is called from
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── Prerequisite checks ──────────────────────────────────────────────────────

check_neovim() {
    if command_exists nvim; then
        success "neovim found: $(nvim --version | head -1)"
        return 0
    else
        warning "neovim not found. Install it first or run the dependency installer."
        return 1
    fi
}

check_vim() {
    if command_exists vim; then
        success "vim found: $(vim --version | head -1 | cut -c1-40)"
        return 0
    else
        warning "vim not found."
        return 1
    fi
}

check_tmux() {
    if command_exists tmux; then
        success "tmux found: $(tmux -V)"
        return 0
    else
        warning "tmux not found."
        return 1
    fi
}

check_zsh() {
    if command_exists zsh; then
        success "zsh found: $(zsh --version)"
        return 0
    else
        warning "zsh not found."
        return 1
    fi
}

check_git() {
    if command_exists git; then
        success "git found: $(git --version)"
        return 0
    else
        error "git not found. git is required to clone plugin managers."
        return 1
    fi
}

# ── Backup ───────────────────────────────────────────────────────────────────

backup_existing() {
    header "Backing up existing config"
    BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"

    for target in .vimrc .vim .config/nvim .tmux.conf .zshrc .zpreztorc .aliases .gitconfig; do
        if [ -e "$HOME/$target" ]; then
            cp -r "$HOME/$target" "$BACKUP_DIR/"
            success "Backed up ~/$target"
        fi
    done

    if [ -z "$(ls -A "$BACKUP_DIR")" ]; then
        rmdir "$BACKUP_DIR"
        info "Nothing to back up."
    else
        info "Backup saved to $BACKUP_DIR"
    fi
}

# ── Config installers ────────────────────────────────────────────────────────

install_vim_config() {
    header "Installing Vim config"
    mkdir -p "$HOME/.vim/config" "$HOME/.vim/autoload" "$HOME/.vim/ftplugin"
    cp "$DOTFILES_DIR/.vimrc"                        "$HOME/.vimrc"
    cp -r "$DOTFILES_DIR/vim/config/."               "$HOME/.vim/config/"
    cp    "$DOTFILES_DIR/vim/autoload/plug.vim"      "$HOME/.vim/autoload/plug.vim"
    [ -d "$DOTFILES_DIR/vim/ftplugin" ] && cp -r "$DOTFILES_DIR/vim/ftplugin/." "$HOME/.vim/ftplugin/"
    success "Vim config installed"
}

install_nvim_config() {
    header "Installing Neovim config"
    mkdir -p "$HOME/.config/nvim" "$HOME/.local/share/nvim/site/autoload" "$HOME/.config/nvim/undo"
    cp "$DOTFILES_DIR/nvim/init.vim"            "$HOME/.config/nvim/init.vim"
    cp "$DOTFILES_DIR/vim/autoload/plug.vim"    "$HOME/.local/share/nvim/site/autoload/plug.vim"

    # Also install shared vim config files (sourced by init.vim)
    mkdir -p "$HOME/.vim/config" "$HOME/.vim/autoload" "$HOME/.vim/ftplugin"
    cp -r "$DOTFILES_DIR/vim/config/." "$HOME/.vim/config/"
    [ -d "$DOTFILES_DIR/vim/ftplugin" ] && cp -r "$DOTFILES_DIR/vim/ftplugin/." "$HOME/.vim/ftplugin/"

    success "Neovim config installed"
}

install_tmux_config() {
    header "Installing tmux config"
    cp "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf"
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        info "Installing Tmux Plugin Manager (TPM)..."
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        success "TPM installed"
    else
        info "TPM already present, skipping clone."
    fi
    success "tmux config installed — run prefix+I inside tmux to install plugins"
}

install_zsh_config() {
    header "Installing zsh config"
    cp "$DOTFILES_DIR/zshrc"     "$HOME/.zshrc"
    cp "$DOTFILES_DIR/zpreztorc" "$HOME/.zpreztorc"
    cp "$DOTFILES_DIR/aliases"   "$HOME/.aliases"

    if [ ! -d "$HOME/.zprezto" ]; then
        info "Installing Prezto..."
        git clone --recursive https://github.com/sorin-ionescu/prezto.git "$HOME/.zprezto"
        success "Prezto installed"
    else
        info "Prezto already present, skipping clone."
    fi
    success "zsh config installed"
}

install_git_config() {
    header "Installing git config"
    cp "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig"
    success "git config installed"
}

install_plugins() {
    header "Installing vim-plug plugins"
    if command_exists nvim; then
        info "Installing neovim plugins..."
        nvim +PlugInstall +qall && success "Neovim plugins installed" || warning "Plugin install had issues — run :PlugInstall manually"
    fi
    if command_exists vim; then
        info "Installing vim plugins..."
        vim +PlugInstall +qall && success "Vim plugins installed" || warning "Plugin install had issues — run :PlugInstall manually"
    fi
}

prompt_yn() {
    # prompt_yn "Question" && do_thing
    local msg="$1"
    local default="${2:-n}"
    local prompt
    [ "$default" = "y" ] && prompt="[Y/n]" || prompt="[y/N]"
    read -rp "$msg $prompt " reply
    reply="${reply:-$default}"
    [[ "$reply" =~ ^[Yy]$ ]]
}
