#!/usr/bin/env bash
# setup-linux.sh — dotfiles installer for Linux
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ── Dependency installer ─────────────────────────────────────────────────────

install_system_deps() {
    header "Installing system dependencies"

    if command_exists apt-get; then
        info "Using apt-get..."
        sudo apt-get update -qq
        sudo apt-get install -y neovim vim tmux zsh git python3 python3-pip \
            nodejs npm xclip xsel silversearcher-ag exuberant-ctags curl
    elif command_exists dnf; then
        info "Using dnf..."
        sudo dnf install -y neovim vim tmux zsh git python3 python3-pip \
            nodejs npm xclip xsel the_silver_searcher ctags curl
    elif command_exists pacman; then
        info "Using pacman..."
        sudo pacman -S --noconfirm neovim vim tmux zsh git python python-pip \
            nodejs npm xclip xsel the_silver_searcher ctags curl
    elif command_exists zypper; then
        info "Using zypper..."
        sudo zypper install -y neovim vim tmux zsh git python3 python3-pip \
            nodejs npm xclip xsel the_silver_searcher ctags curl
    else
        warning "No recognised package manager found. Install dependencies manually:"
        echo "  neovim, vim, tmux, zsh, git, python3, nodejs, xclip, ag, ctags"
        return 1
    fi
    success "System dependencies installed"
}

install_python_provider() {
    header "Installing Python provider for neovim"
    if command_exists pip3; then
        pip3 install --user pynvim && success "pynvim installed"
    else
        warning "pip3 not found — install pynvim manually: pip3 install --user pynvim"
    fi
}

install_node_provider() {
    header "Installing Node.js provider for neovim"
    if command_exists npm; then
        npm install -g neovim --prefix ~/.local 2>/dev/null || npm install -g neovim
        success "neovim node package installed"
    else
        warning "npm not found — install manually: npm install -g neovim"
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
    header "Dotfiles — Linux Setup"

    # ── Prerequisite checks ───────────────────────────────────────────────
    header "Checking prerequisites"
    NVIM_OK=false; VIM_OK=false; TMUX_OK=false; ZSH_OK=false; GIT_OK=false

    check_neovim && NVIM_OK=true || true
    check_vim    && VIM_OK=true  || true
    check_tmux   && TMUX_OK=true || true
    check_zsh    && ZSH_OK=true  || true
    check_git    && GIT_OK=true  || true

    if ! $GIT_OK; then
        error "git is required. Install it and re-run."
        exit 1
    fi

    if ! $NVIM_OK && ! $VIM_OK; then
        warning "Neither neovim nor vim found."
        prompt_yn "Install system dependencies now? (requires sudo)" "y" && install_system_deps || true
        check_neovim && NVIM_OK=true || true
        check_vim    && VIM_OK=true  || true
    fi

    # ── Backup ────────────────────────────────────────────────────────────
    prompt_yn "Back up existing config before overwriting?" "y" && backup_existing || true

    # ── Install configs ───────────────────────────────────────────────────
    $NVIM_OK && install_nvim_config || true
    ($VIM_OK || $NVIM_OK) && install_vim_config || true

    if $TMUX_OK; then
        install_tmux_config
    else
        warning "tmux not found — skipping tmux config. Install tmux and re-run 'just install-tmux'."
    fi

    if $ZSH_OK; then
        install_zsh_config
    else
        warning "zsh not found — skipping zsh config. Install zsh and re-run 'just install-zsh'."
    fi

    install_git_config

    # ── Optional providers ────────────────────────────────────────────────
    prompt_yn "Install Python/Node providers for neovim?" "y" && {
        install_python_provider
        install_node_provider
    } || true

    # ── Plugins ───────────────────────────────────────────────────────────
    prompt_yn "Install vim-plug plugins now?" "y" && install_plugins || true

    # ── Done ──────────────────────────────────────────────────────────────
    header "Setup complete!"
    success "Dotfiles installed on Linux."
    echo ""
    info "Next steps:"
    echo "  1. Restart your terminal (or run: exec zsh)"
    echo "  2. Open tmux and press prefix+I to install tmux plugins"
    echo "  3. Run ':checkhealth' inside neovim to verify the setup"
    echo "  4. See README.md for keybindings and tips"
}

main "$@"
