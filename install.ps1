$ErrorActionPreference = "Stop"

$EnvName = "nvim-env"
$MiniforgeUrl = "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Windows-x86_64.exe"
$InstallerPath = "$env:TEMP\miniforge.exe"
$InstallDir = "$env:UserProfile\miniforge3"
$NvimConfigDir = "$env:LOCALAPPDATA\nvim"

Write-Host ">>> Starting Vim Deployment on Windows..."

# 1. Install Miniforge if not found
if (!(Get-Command "conda" -ErrorAction SilentlyContinue)) {
    Write-Host ">>> Conda not found. Downloading Miniforge..."
    Invoke-WebRequest -Uri $MiniforgeUrl -OutFile $InstallerPath
    
    Write-Host ">>> Installing Miniforge (Passive Mode)..."
    Start-Process -FilePath $InstallerPath -ArgumentList "/InstallationType=JustMe /RegisterPython=0 /S /D=$InstallDir" -Wait
    
    # Hook into current session
    $Env:Path += ";$InstallDir\Scripts;$InstallDir\condabin"
} else {
    Write-Host ">>> Conda detected."
}

# 2. Create/Update Environment
Write-Host ">>> Creating/Updating Conda Environment ($EnvName)..."
# We use 'call' logic equivalent for mamba if accessible, or fallback to conda
mamba env create -f environment.yml 
if (!$?) { mamba env update -f environment.yml }

# 3. Deploy init.lua
Write-Host ">>> Deploying init.lua..."
if (!(Test-Path $NvimConfigDir)) {
    New-Item -ItemType Directory -Force -Path $NvimConfigDir | Out-Null
}

# Backup existing
if (Test-Path "$NvimConfigDir\init.lua") {
    Write-Host "Backing up existing init.lua..."
    Rename-Item -Path "$NvimConfigDir\init.lua" -NewName "init.lua.bak" -Force
}

# Create Hard Link or Copy (Symlinks require Admin on Windows often, Copy is safer for casual scripts)
Write-Host "Copying init.lua..."
Copy-Item -Path ".\init.lua" -Destination "$NvimConfigDir\init.lua"

Write-Host ">>> Deployment Complete!"
Write-Host "Please restart your terminal."
Write-Host "To use: 'conda activate $EnvName' then 'nvim'"
