#Requires -Version 5.1
<#
.SYNOPSIS
    Dotfiles installer for Windows ARM64.
.DESCRIPTION
    ARM64-specific setup: uses Vim instead of Neovim (Neovim does not have
    an official ARM64 Windows build). Installs PSReadLine vi mode, Oh My Posh,
    and git config alongside the Vim config.
.NOTES
    Run from PowerShell:
      Set-ExecutionPolicy Bypass -Scope Process -Force
      .\scripts\setup-windows-arm64.ps1

    For Windows x64, use setup-windows.ps1 instead.
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# ── Paths ─────────────────────────────────────────────────────────────────────

$DotfilesDir = Split-Path -Parent $PSScriptRoot

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

function Add-VimToPath {
    $vimExe = Get-ChildItem "C:\Program Files\Vim" -Recurse -Filter "vim.exe" -ErrorAction SilentlyContinue | Select-Object -First 1
    if (-not $vimExe) { Write-Warn "vim.exe not found under C:\Program Files\Vim — PATH not updated."; return }
    $vimDir = $vimExe.DirectoryName
    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    if ($userPath -notlike "*$vimDir*") {
        [System.Environment]::SetEnvironmentVariable("PATH", "$userPath;$vimDir", "User")
        $env:PATH += ";$vimDir"
        Write-Ok "Added $vimDir to user PATH"
    } else {
        Write-Ok "$vimDir already in PATH"
    }
}

function Install-Dependencies {
    Write-Header "Installing dependencies via winget"

    if (-not (Check-Winget)) {
        Write-Warn "Skipping automatic install. Install these manually:"
        Write-Host "  - Vim (ARM64): https://github.com/vim/vim-win32-installer/releases"
        Write-Host "  - Git:         https://git-scm.com/download/win"
        Write-Host "  - Oh My Posh:  winget install JanDeDobbeleer.OhMyPosh"
        Write-Host "  - Nerd Font:   https://www.nerdfonts.com/"
        return
    }

    if (-not (Check-Vim))      { Install-WithWinget "vim.vim" "Vim"; Add-VimToPath }
    if (-not (Check-OhMyPosh)) { Install-WithWinget "JanDeDobbeleer.OhMyPosh"  "OhMyPosh" }
}

# ── Config installers ─────────────────────────────────────────────────────────

function Install-VimConfig {
    Write-Header "Installing Vim config (ARM64)"

    $VimDir = "$env:USERPROFILE\.vim"
    New-Item -ItemType Directory -Force -Path "$VimDir\config"   | Out-Null
    New-Item -ItemType Directory -Force -Path "$VimDir\autoload" | Out-Null
    New-Item -ItemType Directory -Force -Path "$VimDir\ftplugin" | Out-Null

    Copy-Item "$DotfilesDir\.vimrc"                "$env:USERPROFILE\_vimrc"   -Force
    Copy-Item "$DotfilesDir\vim\config\*"          "$VimDir\config\"           -Force -Recurse
    Copy-Item "$DotfilesDir\vim\autoload\plug.vim" "$VimDir\autoload\plug.vim" -Force
    if (Test-Path "$DotfilesDir\vim\ftplugin") {
        Copy-Item "$DotfilesDir\vim\ftplugin\*"    "$VimDir\ftplugin\"         -Force -Recurse
    }

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

function Install-Plugins {
    Write-Header "Installing vim-plug plugins"
    if (Command-Exists vim) {
        Write-Info "Installing vim plugins..."
        vim +PlugInstall +qall
        Write-Ok "Vim plugins installed"
    } else {
        Write-Warn "vim not found — run ':PlugInstall' manually after installing vim"
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
    Write-Header "Dotfiles — Windows ARM64 Setup"
    Write-Info "Note: Neovim has no official ARM64 Windows build — using Vim instead."

    Write-Header "Checking prerequisites"
    $vimOk = Check-Vim
    $gitOk = Check-Git
    $ompOk = Check-OhMyPosh

    if (-not $gitOk) {
        Write-Err "git is required. Install Git for Windows and re-run."
        exit 1
    }

    if (-not $vimOk) {
        Write-Warn "Vim not found."
        if (Prompt-YN "Install dependencies via winget?") {
            Install-Dependencies
            $vimOk = Check-Vim
            $ompOk = Check-OhMyPosh
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

    if ($vimOk) { Install-VimConfig } else { Write-Warn "Vim not found — skipping vim config." }

    Install-GitConfig
    Install-PSReadLineVi

    if ($ompOk) { Install-OhMyPoshProfile }

    if (Prompt-YN "Install vim-plug plugins now?") { Install-Plugins }

    Write-Header "Setup complete!"
    Write-Ok "Dotfiles installed on Windows ARM64."
    Write-Host ""
    Write-Info "Next steps:"
    Write-Host "  1. Restart PowerShell for all profile changes to take effect"
    Write-Host "  2. In the shell: Esc enters vi normal mode, i/a returns to insert"
    Write-Host "  3. See README.md for keybindings and tips"
    Write-Host ""
    Write-Info "When Neovim releases an official ARM64 Windows build, switch to setup-windows.ps1 to get the full neovim config."
}

Main
