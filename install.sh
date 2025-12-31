#!/bin/bash
set -e

MINIFORGE_DIR="$HOME/miniforge3"
CONFIG_DIR="$HOME/.config/nvim"

echo ">>> Starting Vim Deployment..."

# 1. Install Miniforge if not found
if ! command -v conda &> /dev/null; then
    echo ">>> Conda not found. Installing Miniforge..."
    OS="$(uname)"
    ARCH="$(uname -m)"
    
    # Map Architecture names if necessary
    if [ "$OS" = "Linux" ]; then
        URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-$ARCH.sh"
    elif [ "$OS" = "Darwin" ]; then
        URL="https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-MacOSX-$ARCH.sh"
    fi

    wget "$URL" -O miniforge.sh
    bash miniforge.sh -b -p "$MINIFORGE_DIR"
    rm miniforge.sh
    
    # Initialize conda for this shell session
    eval "$($MINIFORGE_DIR/bin/conda shell.bash hook)"
else
    echo ">>> Conda/Mamba detected."
fi

# 2. Update Environment
echo ">>> Updating/Creating Conda Environment ($ENV_NAME)..."
mamba env update -n base -f environment.yml

# 3. Deploy init.lua
echo ">>> Deploying init.lua..."
mkdir -p "$CONFIG_DIR"

# Backup existing init.lua
if [ -f "$CONFIG_DIR/init.lua" ]; then
    echo "Backing up existing init.lua to init.lua.bak"
    mv "$CONFIG_DIR/init.lua" "$CONFIG_DIR/init.lua.bak"
fi

# Create Symlink (Better than copying so git updates reflect immediately)
# Resolve absolute path of current directory
REPO_DIR=$(pwd)
ln -s "$REPO_DIR/init.lua" "$CONFIG_DIR/init.lua"

# 4. Linking .gitconfig
if [ -f "$HOME/.gitconfig" ]; then
    echo "Backing up existing init.lua to init.lua.bak"
    mv "$HOME/.gitconfig" "$HOME/.gitconfig.bak"
fi
ln -s "$REPO_DIR/.gitconfig" "$HOME/.gitconfig"

echo ">>> Deployment Complete!"
