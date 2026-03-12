# Dotfiles

Vim/Neovim, tmux/WezTerm, zsh, and git configuration for Linux, macOS, and Windows.

## Requirements

Setup is driven by **[just](https://github.com/casey/just)** — a command runner. Install it first.

### Install `just`

The recommended way on all platforms is via **cargo** (Rust's package manager):

```bash
cargo install just
```

If you don't have Rust/cargo installed, get it from [rustup.rs](https://rustup.rs/) — works on Linux, macOS, and Windows.

> **Windows only:** `cargo install` requires the MSVC linker (`link.exe`). If you get a
> `linker not found` error, either:
> - Install **Build Tools for Visual Studio 2022** with the **"Desktop development with C++"**
>   workload from [visualstudio.microsoft.com/downloads](https://visualstudio.microsoft.com/downloads/),
>   then re-run `cargo install just`
> - Or skip cargo entirely and use winget: `winget install Casey.Just`

Verify: `just --version`

---

## Quick Start

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
just setup        # auto-detects Linux or macOS
```

For Windows, open PowerShell after installing `just`:

```powershell
cd ~/dotfiles

# Windows x64 (Neovim + WezTerm)
just setup-windows

# Windows ARM64 (Vim + WezTerm — Neovim has no official ARM64 build)
just setup-windows-arm64
```

> The setup scripts check for each tool before configuring it.
> If a tool is already installed and configured (e.g. Oh My Posh), that step is skipped automatically.

---

## What Gets Installed

| Component | Linux | macOS | Windows x64 | Windows ARM64 |
|---|:---:|:---:|:---:|:---:|
| Neovim config | ✓ | ✓ | ✓ | — |
| Vim config | ✓ | ✓ | ✓ | ✓ |
| tmux config + TPM | ✓ | ✓ | — | — |
| PSReadLine vi mode | — | — | ✓ | ✓ |
| zsh / Prezto | ✓ | ✓ | — | — |
| Oh My Posh | — | — | ✓ (if missing) | ✓ (if missing) |
| git config | ✓ | ✓ | ✓ | ✓ |
| `vim` → `nvim` alias | ✓ | ✓ | ✓ | — |

---

## All `just` Recipes

```
just setup              # auto-detect OS and run setup (Linux/macOS)
just setup-linux        # Linux setup
just setup-macos        # macOS setup
just setup-windows      # print Windows x64 instructions
just setup-windows-arm64 # print Windows ARM64 instructions

just install-nvim       # install neovim config only
just install-vim        # install vim config only
just install-tmux       # install tmux config + TPM only
just install-zsh        # install zsh / Prezto config only
just install-git        # install git config only
just install-plugins    # run :PlugInstall in nvim/vim

just backup             # back up existing config with timestamp
just check              # show which tools are installed
```

---

## Platform Notes

### Linux / macOS — tmux

tmux is the multiplexer. TPM plugins install on first launch with `prefix + I`.

| Key | Action |
|---|---|
| `Ctrl+a` | Prefix |
| `prefix \|` | Split right |
| `prefix -` | Split below |
| `prefix h/j/k/l` | Navigate panes |
| `prefix H/J/K/L` | Resize panes (repeatable) |
| `prefix Ctrl+h/l` | Cycle windows |
| `prefix Escape` | Enter copy mode (vi) |
| `v` in copy mode | Begin selection |
| `y` in copy mode | Yank to clipboard |

### Windows — PSReadLine vi mode

No extra tools needed — PSReadLine ships with PowerShell. The setup adds two lines to your `$PROFILE`:

```powershell
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Cursor  # block = normal mode, line = insert mode
```

| Key (normal mode) | Action |
|---|---|
| `Esc` | Enter normal mode |
| `i / a / A / I` | Return to insert mode |
| `h / j / k / l` | Move cursor / navigate history |
| `w / b / e` | Word motions |
| `0 / $` | Line start / end |
| `dd` | Clear line |
| `u` | Undo |
| `/` | Search history |
| `n / N` | Next / prev history match |
| `yy / p` | Copy / paste line |

For pane splitting use Windows Terminal's built-in shortcuts (`Alt+Shift+D`, `Alt+Shift+-`, `Alt+Shift++`).

### Windows — Shell prompt

PowerShell with Oh My Posh. If Oh My Posh is already installed and configured in your `$PROFILE`, the setup skips it.

---

## Vim / Neovim Key Mappings

Leader key: `,`

| Key | Action |
|---|---|
| `,t` | Toggle NERDTree |
| `F8` | Toggle Tagbar |
| `,n / ,m` | Previous / next tab |
| `F2` | Quick save |
| `Ctrl+n` | Clear search highlight |
| `Ctrl+c` (visual) | Copy to system clipboard |
| `Ctrl+p` | Paste from system clipboard |
| `,a` | Open ack search |
| `,3` | Toggle relative line numbers |
| `< / >` (visual) | Indent / dedent with reselection |

### Neovim only

| Key | Action |
|---|---|
| `Esc` (terminal) | Exit terminal mode |
| `Ctrl+h/j/k/l` (terminal) | Navigate to editor pane |

---

## Directory Structure

```
dotfiles/
├── justfile                    # Task runner (just setup, just check, etc.)
├── .vimrc                      # Vim entry point
├── vim/
│   ├── config/
│   │   ├── init.vimrc          # Plugin declarations (vim-plug)
│   │   ├── general.vimrc       # General settings
│   │   ├── plugins.vimrc       # Plugin configuration
│   │   ├── keys.vimrc          # Key mappings
│   │   └── line.vimrc          # Statusline / airline
│   ├── autoload/
│   │   └── plug.vim            # vim-plug
│   └── ftplugin/
│       └── c.vim               # C-specific settings
├── nvim/
│   └── init.vim                # Neovim entry point (sources vim/config/)
├── tmux.conf                   # tmux config with TPM plugins
├── zshrc                       # zsh config (sources Prezto)
├── zpreztorc                   # Prezto config
├── aliases                     # Shell aliases (sourced by zshrc)
├── gitconfig                   # git config
├── redshift/
│   └── redshift.conf           # Redshift (screen color temperature)
└── scripts/
    ├── common.sh               # Shared helpers for Unix scripts
    ├── setup-linux.sh          # Linux installer
    ├── setup-macos.sh          # macOS installer
    ├── setup-windows.ps1       # Windows x64 installer (PowerShell)
    └── setup-windows-arm64.ps1 # Windows ARM64 installer (PowerShell)
```

---

## Customization

### Change colorscheme

Edit `vim/config/plugins.vimrc`:
```vim
colorscheme gruvbox   " options: onedark, molokai, palenight, ayu, minimalist
```


---

## Troubleshooting

**Plugins not loading**
```bash
nvim +PlugClean +PlugInstall +qall
```

**Check neovim health**
```bash
nvim +checkhealth
```

**Python provider not working**
```bash
pip3 install --user --upgrade pynvim
nvim +checkhealth provider
```

**Icons / powerline symbols not showing**
Install a Nerd Font from [nerdfonts.com](https://www.nerdfonts.com/) and set it as your terminal font.

**PSReadLine vi mode not active after restart**
Check your `$PROFILE` contains `Set-PSReadLineOption -EditMode Vi`.
Run `just setup-windows-arm64` (or `setup-windows`) again to re-apply.
