$ErrorActionPreference = "Stop"

$MiniforgeUrl = "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe"
$InstallerPath = "$env:TEMP\miniforge.exe"
$InstallDir = "$env:UserProfile\miniforge3"
$NvimConfigDir = "$env:LOCALAPPDATA\nvim"

Write-Host ">>> Starting Vim Deployment (Global/Base)..."

# 1. Install Miniforge if not found
if (!(Get-Command "conda" -ErrorAction SilentlyContinue)) {
    Write-Host ">>> Conda not found. Downloading Miniforge..."
    Invoke-WebRequest -Uri $MiniforgeUrl -OutFile $InstallerPath
    
    Write-Host ">>> Installing Miniforge..."
    Start-Process -FilePath $InstallerPath -ArgumentList "/InstallationType=JustMe /RegisterPython=0 /S /D=$InstallDir" -Wait
    
    $Env:Path += ";$InstallDir\Scripts;$InstallDir\condabin"
} else {
    Write-Host ">>> Conda detected."
}

# 2. Update Base Environment
Write-Host ">>> Installing Neovim and Tools into 'base' environment..."
mamba env update -n base -f environment.yml
if (!$?) { conda env update -n base -f environment.yml }

# 3. Deploy init.lua
Write-Host ">>> Deploying init.lua..."
if (!(Test-Path $NvimConfigDir)) {
    New-Item -ItemType Directory -Force -Path $NvimConfigDir | Out-Null
}

if (Test-Path "$NvimConfigDir\init.lua") {
    Rename-Item -Path "$NvimConfigDir\init.lua" -NewName "init.lua.bak" -Force
}

Copy-Item -Path ".\init.lua" -Destination "$NvimConfigDir\init.lua" -Force

# 4. Deploy .gitconfig
$GitConfigDest = "$env:UserProfile\.gitconfig"

if (Test-Path $GitConfigDest) {
    Write-Host "Backing up existing .gitconfig..."
    Rename-Item -Path $GitConfigDest -NewName ".gitconfig.bak" -Force
}

Write-Host "Deploying .gitconfig..."
Copy-Item -Path ".\.gitconfig" -Destination $GitConfigDest -Force

Write-Host ">>> Deployment Complete!"
Write-Host "Please restart your terminal."
