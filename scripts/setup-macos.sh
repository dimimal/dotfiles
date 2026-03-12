#!/usr/bin/env bash
# setup-macos.sh — dotfiles installer for macOS
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

# ── Dependency installer ─────────────────────────────────────────────────────

install_homebrew() {
    if ! command_exists brew; then
        info "Homebrew not found. Installing..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        # Add brew to PATH for Apple Silicon Macs
        if [ -f /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        success "Homebrew installed"
    else
        success "Homebrew already installed: $(brew --version | head -1)"
    fi
}

install_system_deps() {
    header "Installing system dependencies via Homebrew"
    brew install neovim vim tmux zsh git python3 node the_silver_searcher ctags curl
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
        npm install -g neovim && success "neovim node package installed"
    else
        warning "npm not found — install manually: npm install -g neovim"
    fi
}

# ── Main ─────────────────────────────────────────────────────────────────────

main() {
    header "Dotfiles — macOS Setup"

    # ── Prerequisite checks ───────────────────────────────────────────────
    header "Checking prerequisites"
    NVIM_OK=false; VIM_OK=false; TMUX_OK=false; ZSH_OK=false; GIT_OK=false

    check_neovim && NVIM_OK=true || true
    check_vim    && VIM_OK=true  || true
    check_tmux   && TMUX_OK=true || true
    check_zsh    && ZSH_OK=true  || true
    check_git    && GIT_OK=true  || true

    if ! $GIT_OK; then
        # macOS ships with git via Xcode CLT
        error "git not found. Run: xcode-select --install"
        exit 1
    fi

    if ! $NVIM_OK && ! $VIM_OK; then
        warning "Neither neovim nor vim found."
        prompt_yn "Install via Homebrew now?" "y" && {
            install_homebrew
            install_system_deps
        } || true
        check_neovim && NVIM_OK=true || true
        check_vim    && VIM_OK=true  || true
    fi

    if ! $TMUX_OK || ! $ZSH_OK; then
        warning "tmux or zsh not found."
        prompt_yn "Install missing tools via Homebrew?" "y" && {
            install_homebrew
            $TMUX_OK || brew install tmux && check_tmux && TMUX_OK=true || true
            $ZSH_OK  || brew install zsh  && check_zsh  && ZSH_OK=true  || true
        } || true
    fi

    # ── Backup ────────────────────────────────────────────────────────────
    prompt_yn "Back up existing config before overwriting?" "y" && backup_existing || true

    # ── Install configs ───────────────────────────────────────────────────
    $NVIM_OK && install_nvim_config || true
    ($VIM_OK || $NVIM_OK) && install_vim_config || true

    if $TMUX_OK; then
        install_tmux_config
    else
        warning "tmux not found — skipping. Install via 'brew install tmux' and re-run 'just install-tmux'."
    fi

    if $ZSH_OK; then
        install_zsh_config
        # Make zsh the default shell if it isn't already
        if [ "$SHELL" != "$(command -v zsh)" ]; then
            prompt_yn "Set zsh as the default shell?" "y" && {
                ZSH_PATH="$(command -v zsh)"
                grep -qF "$ZSH_PATH" /etc/shells || sudo sh -c "echo $ZSH_PATH >> /etc/shells"
                chsh -s "$ZSH_PATH"
                success "Default shell set to zsh"
            } || true
        fi
    else
        warning "zsh not found — skipping zsh config."
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
    success "Dotfiles installed on macOS."
    echo ""
    info "Next steps:"
    echo "  1. Restart your terminal (or run: exec zsh)"
    echo "  2. Open tmux and press prefix+I to install tmux plugins"
    echo "  3. Run ':checkhealth' inside neovim to verify the setup"
    echo "  4. See README.md for keybindings and tips"
}

main "$@"
