#!/usr/bin/env bash

set -e

# Dotfiles root directory (parent of install_scripts/)
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

link_item() {
    local src="$1"
    local target="$2"

    if [ ! -e "$src" ]; then
        echo "Source does not exist: $src"
        return 1
    fi

    # Ensure parent directory exists
    mkdir -p "$(dirname "$target")"

    # Check if target is already the correct symlink
    if [ -L "$target" ]; then
        local current_link
        current_link="$(readlink "$target")"
        if [ "$current_link" = "$src" ]; then
            echo "[SKIP] $target is already correctly symlinked."
            return 0
        fi
    fi

    # If target exists (file, directory, or incorrect symlink), backup it
    if [ -e "$target" ] || [ -L "$target" ]; then
        local backup="${target}.bak"
        if [ -e "$backup" ] || [ -L "$backup" ]; then
            rm -rf "$backup"
        fi
        mv "$target" "$backup"
        echo "[BACKUP] Moved existing $target to $backup"
    fi

    # Create symlink
    ln -s "$src" "$target"
    echo "[LINK] Created symlink: $target -> "$src""
}

echo "=== Starting Symlink Creation ==="

# 1. Link config contents to ~/.config
echo ""
echo "--- Linking config/ to ~/.config ---"
if [ -d "$DOTFILES_DIR/config" ]; then
    for src in "$DOTFILES_DIR/config/"*; do
        [ -e "$src" ] || continue
        name=$(basename "$src")
        target="$HOME/.config/$name"
        link_item "$src" "$target"
    done
else
    echo "No config/ directory found in $DOTFILES_DIR"
fi

# 2. Link scripts contents to ~/.local/bin
echo ""
echo "--- Linking scripts/ to ~/.local/bin ---"
if [ -d "$DOTFILES_DIR/scripts" ]; then
    for src in "$DOTFILES_DIR/scripts/"*; do
        [ -e "$src" ] || continue
        name=$(basename "$src")
        target="$HOME/.local/bin/$name"
        link_item "$src" "$target"
        # Ensure script is executable
        chmod +x "$src"
    done
else
    echo "No scripts/ directory found in $DOTFILES_DIR"
fi

# 3. Link root dotfiles (.bashrc, .zshrc, .zsh_profile, etc.) to ~
echo ""
echo "--- Linking root dotfiles to ~ ---"
for src in "$DOTFILES_DIR"/.*; do
    [ -e "$src" ] || continue
    name=$(basename "$src")
    
    # Skip special entries and git files
    case "$name" in
        .|..|.git|.gitignore) continue ;;
    esac
    
    target="$HOME/$name"
    link_item "$src" "$target"
done

echo ""
echo "=== Symlink creation completed successfully! ==="
