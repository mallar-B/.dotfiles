#!/usr/bin/env bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

prompt_confirm() {
    local prompt="$1"
    while true; do
        read -p "$prompt [y/N]: " yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]* | "" ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

echo "========================================"
echo "      Dotfiles Installation Guide       "
echo "========================================"

# Step 1: Create Symlinks
echo ""
if prompt_confirm ">> Step 1/1: Create and setup symlinks (configs, scripts, dotfiles)?"; then
    echo "Running make_symlinks.sh..."
    "$SCRIPT_DIR/make_symlinks.sh"
else
    echo "Skipping symlink creation."
fi

echo ""
echo "========================================"
echo "    Dotfiles Installation Finished!     "
echo "========================================"
