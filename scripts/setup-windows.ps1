#Requires -Version 5.1
<#
.SYNOPSIS
    Dotfiles installer for Windows x64.
.DESCRIPTION
    Installs neovim config, vim config, PSReadLine vi mode, Oh My Posh,
    and git config. Checks for required tools before proceeding.
.NOTES
    Run from PowerShell:
      Set-ExecutionPolicy Bypass -Scope Process -Force
      .\scripts\setup-windows.ps1

    For Windows ARM64, use setup-windows-arm64.ps1 instead.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Paths ─────────────────────────────────────────────────────────────────────

$DotfilesDir = Split-Path -Parent $PSScriptRoot
$NvimConfig  = "$env:LOCALAPPDATA\nvim"
$NvimData    = "$env:LOCALAPPDATA\nvim-data"

# ── Helpers ───────────────────────────────────────────────────────────────────

function Write-Header { param($msg) Write-Host "`n══════════════════════════════════════" -ForegroundColor Cyan; Write-Host "  $msg" -ForegroundColor Cyan; Write-Host "══════════════════════════════════════`n" -ForegroundColor Cyan }
function Write-Info   { param($msg) Write-Host "[INFO]    $msg" -ForegroundColor Blue }
function Write-Ok     { param($msg) Write-Host "[OK]      $msg" -ForegroundColor Green }
function Write-Warn   { param($msg) Write-Host "[WARNING] $msg" -ForegroundColor Yellow }
function Write-Err    { param($msg) Write-Host "[ERROR]   $msg" -ForegroundColor Red }

function Command-Exists {
    param([string]$cmd)
    $null -ne (Get-Command $cmd -ErrorAction SilentlyContinue)
}

function Prompt-YN {
    param([string]$question, [bool]$default = $true)
    $hint  = if ($default) { "[Y/n]" } else { "[y/N]" }
    $reply = Read-Host "$question $hint"
    if ([string]::IsNullOrWhiteSpace($reply)) { return $default }
    return $reply -match '^[Yy]'
}

function Ensure-Profile {
    $profileDir = Split-Path $PROFILE
    if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Force -Path $profileDir | Out-Null }
    if (-not (Test-Path $PROFILE))    { New-Item -ItemType File      -Force -Path $PROFILE    | Out-Null }
}

# ── Prerequisite checks ───────────────────────────────────────────────────────

function Check-Neovim {
    if (Command-Exists nvim) { Write-Ok "neovim: $(nvim --version | Select-Object -First 1)"; return $true }
    Write-Warn "neovim NOT found."; return $false
}

function Check-Vim {
    if (Command-Exists vim) { Write-Ok "vim found"; return $true }
    Write-Warn "vim NOT found."; return $false
}

function Check-Git {
    if (Command-Exists git) { Write-Ok "git: $(git --version)"; return $true }
    Write-Err "git NOT found. Install Git for Windows: https://git-scm.com/download/win"
    return $false
}

function Check-OhMyPosh {
    if (Command-Exists oh-my-posh) { Write-Ok "Oh My Posh: $(oh-my-posh --version 2>$null)"; return $true }
    Write-Warn "Oh My Posh NOT found."; return $false
}

function Check-Winget {
    if (Command-Exists winget) { Write-Ok "winget found"; return $true }
    Write-Warn "winget NOT found. Install App Installer from the Microsoft Store."
    return $false
}

# ── Installers ────────────────────────────────────────────────────────────────

function Install-WithWinget {
    param([string]$id, [string]$name)
    Write-Info "Installing $name via winget..."
    winget install --id $id --silent --accept-package-agreements --accept-source-agreements
    Write-Ok "$name installed"
}

function Add-NeovimToPath {
    $nvimExe = Get-ChildItem "C:\Program Files\Neovim" -Recurse -Filter "nvim.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $nvimExe) { Write-Warn "nvim.exe not found under C:\Program Files\Neovim — PATH not updated."; return }
    $nvimDir = $nvimExe.DirectoryName
    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$nvimDir*") {
        [System.Environment]::SetEnvironmentVariable("PATH", "$userPath;$nvimDir", "User")
        $env:PATH += ";$nvimDir"
        Write-Ok "Added $nvimDir to user PATH"
    } else {
        Write-Ok "$nvimDir already in PATH"
    }
}

function Install-Dependencies {
    Write-Header "Installing dependencies via winget"

    if (-not (Check-Winget)) {
        Write-Warn "Skipping automatic install. Install these manually:"
        Write-Host "  - Neovim:     https://github.com/neovim/neovim/releases"
        Write-Host "  - Git:        https://git-scm.com/download/win"
        Write-Host "  - Oh My Posh: winget install JanDeDobbeleer.OhMyPosh"
        Write-Host "  - Nerd Font:  https://www.nerdfonts.com/"
        return
    }

    if (-not (Check-Neovim))   { Install-WithWinget "Neovim.Neovim" "Neovim"; Add-NeovimToPath }
    if (-not (Check-OhMyPosh)) { Install-WithWinget "JanDeDobbeleer.OhMyPosh" "OhMyPosh" }
}

# ── Config installers ─────────────────────────────────────────────────────────

function Install-NvimConfig {
    Write-Header "Installing Neovim config"

    New-Item -ItemType Directory -Force -Path $NvimConfig               | Out-Null
    New-Item -ItemType Directory -Force -Path "$NvimData\site\autoload"  | Out-Null
    New-Item -ItemType Directory -Force -Path "$NvimConfig\undo"         | Out-Null

    Copy-Item "$DotfilesDir\nvim\init.vim"         "$NvimConfig\init.vim"                  -Force
    Copy-Item "$DotfilesDir\vim\autoload\plug.vim" "$NvimData\site\autoload\plug.vim"      -Force

    $VimDir = "$env:USERPROFILE\.vim"
    New-Item -ItemType Directory -Force -Path "$VimDir\config"   | Out-Null
    New-Item -ItemType Directory -Force -Path "$VimDir\autoload" | Out-Null
    New-Item -ItemType Directory -Force -Path "$VimDir\ftplugin" | Out-Null
    Copy-Item "$DotfilesDir\vim\config\*"   "$VimDir\config\"   -Force -Recurse
    Copy-Item "$DotfilesDir\vim\autoload\*" "$VimDir\autoload\" -Force -Recurse
    if (Test-Path "$DotfilesDir\vim\ftplugin") {
        Copy-Item "$DotfilesDir\vim\ftplugin\*" "$VimDir\ftplugin\" -Force -Recurse
    }

    Write-Ok "Neovim config installed to $NvimConfig"
}

function Install-VimConfig {
    Write-Header "Installing Vim config"

    $VimDir = "$env:USERPROFILE\.vim"
    New-Item -ItemType Directory -Force -Path "$VimDir\config"   | Out-Null
    New-Item -ItemType Directory -Force -Path "$VimDir\autoload" | Out-Null

    Copy-Item "$DotfilesDir\.vimrc"                "$env:USERPROFILE\_vimrc" -Force
    Copy-Item "$DotfilesDir\vim\config\*"          "$VimDir\config\"         -Force -Recurse
    Copy-Item "$DotfilesDir\vim\autoload\plug.vim" "$VimDir\autoload\"       -Force

    Write-Ok "Vim config installed"
}

function Install-GitConfig {
    Write-Header "Installing git config"
    Copy-Item "$DotfilesDir\gitconfig" "$env:USERPROFILE\.gitconfig" -Force
    Write-Ok "git config installed"
}

function Is-OhMyPoshConfigured {
    if (-not (Test-Path $PROFILE)) { return $false }
    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
    return $content -match [regex]::Escape('oh-my-posh init')
}

function Install-OhMyPoshProfile {
    Write-Header "Configuring Oh My Posh in PowerShell profile"

    if (Is-OhMyPoshConfigured) {
        Write-Ok "Oh My Posh already configured in $PROFILE — skipping."
        return
    }

    Ensure-Profile
    Add-Content $PROFILE "`n# Oh My Posh prompt`noh-my-posh init pwsh | Invoke-Expression"
    Write-Ok "Oh My Posh added to $PROFILE"
}

function Install-PSReadLineVi {
    Write-Header "Configuring PSReadLine vi mode"

    Ensure-Profile
    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

    if ($content -match 'EditMode Vi') {
        Write-Ok "PSReadLine vi mode already configured — skipping."
        return
    }

    Add-Content $PROFILE @'

# Vi keybindings in the PowerShell prompt
Set-PSReadLineOption -EditMode Vi
Set-PSReadLineOption -ViModeIndicator Cursor   # block cursor = normal, line cursor = insert
'@
    Write-Ok "PSReadLine vi mode added to $PROFILE"
    Write-Info "Esc = normal mode, i/a = insert mode, h/j/k/l/w/b/e/0/$ all work"
}

function Install-VimAlias {
    Write-Header "Configuring vim=nvim alias"

    Ensure-Profile
    $content = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue

    if ($content -match 'Set-Alias vim nvim') {
        Write-Info "vim alias already configured — skipping."
        return
    }

    Add-Content $PROFILE @"

# Use neovim as vim
if (Get-Command nvim -ErrorAction SilentlyContinue) {
    Set-Alias vim nvim
}
"@
    Write-Ok "vim=nvim alias added to $PROFILE"
}

function Install-Plugins {
    Write-Header "Installing vim-plug plugins"
    if (Command-Exists nvim) {
        Write-Info "Installing neovim plugins..."
        nvim +PlugInstall +qall
        Write-Ok "Neovim plugins installed"
    }
    if (Command-Exists vim) {
        Write-Info "Installing vim plugins..."
        vim +PlugInstall +qall
        Write-Ok "Vim plugins installed"
    }
}

function Backup-Existing {
    Write-Header "Backing up existing config"
    $stamp     = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupDir = "$env:USERPROFILE\.dotfiles-backup-$stamp"
    New-Item -ItemType Directory -Force -Path $backupDir | Out-Null

    $targets = @(
        "$env:USERPROFILE\_vimrc",
        "$env:USERPROFILE\.vim",
        $NvimConfig,
        "$env:USERPROFILE\.gitconfig"
    )
    $backed = $false
    foreach ($t in $targets) {
        if (Test-Path $t) {
            Copy-Item $t $backupDir -Recurse -Force
            Write-Ok "Backed up $t"
            $backed = $true
        }
    }
    if (-not $backed) {
        Write-Info "Nothing to back up."
        Remove-Item $backupDir
    } else {
        Write-Info "Backup saved to $backupDir"
    }
}

# ── Main ──────────────────────────────────────────────────────────────────────

function Main {
    Write-Header "Dotfiles — Windows x64 Setup"

    Write-Header "Checking prerequisites"
    $nvimOk = Check-Neovim
    $vimOk  = Check-Vim
    $gitOk  = Check-Git
    $ompOk  = Check-OhMyPosh

    if (-not $gitOk) {
        Write-Err "git is required. Install Git for Windows and re-run."
        exit 1
    }

    if (-not $nvimOk -and -not $vimOk) {
        Write-Warn "Neither neovim nor vim found."
        if (Prompt-YN "Install dependencies via winget?") {
            Install-Dependencies
            $nvimOk = Check-Neovim
            $vimOk  = Check-Vim
            $ompOk  = Check-OhMyPosh
        }
    }

    if (-not $ompOk) {
        if (Prompt-YN "Install Oh My Posh via winget?") {
            if (Check-Winget) {
                Install-WithWinget "JanDeDobbeleer.OhMyPosh" "Oh My Posh"
                $ompOk = Check-OhMyPosh
            }
        }
    } elseif (Is-OhMyPoshConfigured) {
        Write-Ok "Oh My Posh already installed and configured — skipping."
        $ompOk = $false
    }

    if (Prompt-YN "Back up existing config before overwriting?") { Backup-Existing }

    if ($nvimOk)              { Install-NvimConfig }
    if ($nvimOk -or $vimOk)   { Install-VimConfig  }

    Install-GitConfig
    Install-PSReadLineVi

    if ($ompOk) { Install-OhMyPoshProfile }

    if ($nvimOk) { Install-VimAlias }

    if (Prompt-YN "Install vim-plug plugins now?") { Install-Plugins }

    Write-Header "Setup complete!"
    Write-Ok "Dotfiles installed on Windows x64."
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. Restart PowerShell for all profile changes to take effect"
    Write-Host "  2. Run ':checkhealth' inside neovim to verify the setup"
    Write-Host "  3. In the shell: Esc enters vi normal mode, i/a returns to insert"
    Write-Host "  4. See README.md for keybindings and tips"
}

Main
