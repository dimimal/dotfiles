# Dotfiles Task Runner
# Usage: just <recipe>
# Requires: https://github.com/casey/just

dotfiles_dir := justfile_directory()

# Use PowerShell on Windows, default sh on Linux/macOS
set windows-shell := ["pwsh", "-NoLogo", "-Command"]

# Default: list available recipes
default:
    @just --list

# ── Setup ─────────────────────────────────────────────────────────────────────

# Auto-detect OS and architecture, then run the right setup
setup:
    @just {{ if os() == "windows" { if arch() == "aarch64" { "setup-windows-arm64" } else { "setup-windows" } } else { "setup-" + os() } }}

[unix]
setup-linux:
    @echo "Running Linux setup..."
    @bash {{dotfiles_dir}}/scripts/setup-linux.sh

[unix]
setup-macos:
    @echo "Running macOS setup..."
    @bash {{dotfiles_dir}}/scripts/setup-macos.sh

# Runs the x64 PowerShell installer directly
[windows]
setup-windows:
    pwsh -ExecutionPolicy Bypass -File "{{dotfiles_dir}}/scripts/setup-windows.ps1"

# Runs the ARM64 PowerShell installer directly (vim instead of neovim)
[windows]
setup-windows-arm64:
    pwsh -ExecutionPolicy Bypass -File "{{dotfiles_dir}}/scripts/setup-windows-arm64.ps1"

# ── Individual install recipes ────────────────────────────────────────────────

[unix]
install-nvim:
    #!/usr/bin/env bash
    set -euo pipefail
    DOTFILES="{{dotfiles_dir}}"
    mkdir -p "$HOME/.config/nvim" "$HOME/.local/share/nvim/site/autoload" "$HOME/.config/nvim/undo"
    cp "$DOTFILES/nvim/init.vim"         "$HOME/.config/nvim/init.vim"
    cp "$DOTFILES/vim/autoload/plug.vim" "$HOME/.local/share/nvim/site/autoload/plug.vim"
    mkdir -p "$HOME/.vim/config" "$HOME/.vim/autoload" "$HOME/.vim/ftplugin"
    cp -r "$DOTFILES/vim/config/."   "$HOME/.vim/config/"
    cp -r "$DOTFILES/vim/ftplugin/." "$HOME/.vim/ftplugin/"
    echo "[✓] Neovim config installed"

[unix]
install-vim:
    #!/usr/bin/env bash
    set -euo pipefail
    DOTFILES="{{dotfiles_dir}}"
    mkdir -p "$HOME/.vim/config" "$HOME/.vim/autoload" "$HOME/.vim/ftplugin"
    cp "$DOTFILES/.vimrc"                    "$HOME/.vimrc"
    cp -r "$DOTFILES/vim/config/."           "$HOME/.vim/config/"
    cp    "$DOTFILES/vim/autoload/plug.vim"  "$HOME/.vim/autoload/plug.vim"
    cp -r "$DOTFILES/vim/ftplugin/."         "$HOME/.vim/ftplugin/"
    echo "[✓] Vim config installed"

[unix]
install-tmux:
    #!/usr/bin/env bash
    set -euo pipefail
    DOTFILES="{{dotfiles_dir}}"
    cp "$DOTFILES/tmux.conf" "$HOME/.tmux.conf"
    if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
        git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
        echo "[✓] TPM installed"
    fi
    echo "[✓] tmux config installed"

[unix]
install-zsh:
    #!/usr/bin/env bash
    set -euo pipefail
    DOTFILES="{{dotfiles_dir}}"
    cp "$DOTFILES/zshrc"     "$HOME/.zshrc"
    cp "$DOTFILES/zpreztorc" "$HOME/.zpreztorc"
    cp "$DOTFILES/aliases"   "$HOME/.aliases"
    echo "[✓] zsh config installed"

[unix]
install-git:
    #!/usr/bin/env bash
    set -euo pipefail
    cp "{{dotfiles_dir}}/gitconfig" "$HOME/.gitconfig"
    echo "[✓] git config installed"


[unix]
install-plugins:
    #!/usr/bin/env bash
    set -euo pipefail
    if command -v nvim &>/dev/null; then
        echo "Installing plugins for neovim..."
        nvim +PlugInstall +qall
        echo "[✓] Neovim plugins installed"
    fi
    if command -v vim &>/dev/null; then
        echo "Installing plugins for vim..."
        vim +PlugInstall +qall
        echo "[✓] Vim plugins installed"
    fi

[windows]
install-plugins:
    if (Get-Command nvim -ErrorAction SilentlyContinue) { nvim +PlugInstall +qall; Write-Host "[OK] Neovim plugins installed" }
    if (Get-Command vim  -ErrorAction SilentlyContinue) { vim  +PlugInstall +qall; Write-Host "[OK] Vim plugins installed"   }

# ── Backup ────────────────────────────────────────────────────────────────────

[unix]
backup:
    #!/usr/bin/env bash
    set -euo pipefail
    BACKUP_DIR="$HOME/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    for f in .vimrc .vim .config/nvim .tmux.conf .zshrc .zpreztorc .aliases .gitconfig; do
        [ -e "$HOME/$f" ] && cp -r "$HOME/$f" "$BACKUP_DIR/" && echo "  backed up $f"
    done
    echo "[✓] Backup saved to $BACKUP_DIR"

# Everything on one line so PowerShell variables persist across the recipe
[windows]
backup:
    $d="$env:USERPROFILE\.dotfiles-backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"; New-Item -ItemType Directory -Force -Path $d | Out-Null; foreach ($f in @('_vimrc','.vim','.config\nvim','.gitconfig')) { $p="$env:USERPROFILE\$f"; if (Test-Path $p) { Copy-Item $p $d -Recurse -Force; Write-Host "  backed up $f" } }; Write-Host "[OK] Backup saved to $d"

# ── Check ─────────────────────────────────────────────────────────────────────

[unix]
check:
    #!/usr/bin/env bash
    ok()      { echo "[✓] $1 found"; }
    missing() { echo "[✗] $1 NOT found"; }
    for cmd in nvim vim tmux zsh git; do
        command -v "$cmd" &>/dev/null && ok "$cmd" || missing "$cmd"
    done

[windows]
check:
    foreach ($cmd in @('nvim','vim','git','oh-my-posh')) { if (Get-Command $cmd -ErrorAction SilentlyContinue) { Write-Host "[OK] $cmd found" -ForegroundColor Green } else { Write-Host "[X]  $cmd NOT found" -ForegroundColor Red } }
