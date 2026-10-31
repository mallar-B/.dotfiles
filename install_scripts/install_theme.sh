#!/usr/bin/env bash

set -e

# Everforest GTK Theme repository
EVERFOREST_REPO_URL="https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme.git"
EVERFOREST_CLONE_DIR="/tmp/Everforest-GTK-Theme"

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

# Options may be given as "value|description". Only the value is returned,
# while "value  -  description" is shown in the menu.
option_value() {
    echo "${1%%|*}"
}

option_label() {
    local opt="$1"
    if [ "$opt" = "${opt%%|*}" ]; then
        echo "$opt"
    else
        echo "${opt%%|*}  -  ${opt#*|}"
    fi
}

# Single choice menu. Prints the selected value to stdout.
select_one() {
    local prompt="$1"
    shift
    local options=("$@")

    echo "$prompt" >&2
    local i=1
    for opt in "${options[@]}"; do
        echo "  $i) $(option_label "$opt")" >&2
        i=$((i + 1))
    done

    while true; do
        read -p "Select [1-${#options[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            option_value "${options[$((choice - 1))]}"
            return 0
        fi
        echo "Invalid selection. Try again." >&2
    done
}

# Multiple choice menu. Prints each selected option on its own line to stdout.
select_many() {
    local prompt="$1"
    shift
    local options=("$@")

    echo "$prompt" >&2
    echo "  (comma-separated numbers, 'a' for all, or leave empty for none)" >&2
    local i=1
    for opt in "${options[@]}"; do
        echo "  $i) $(option_label "$opt")" >&2
        i=$((i + 1))
    done

    while true; do
        read -p "Select: " input
        if [ -z "$input" ]; then
            return 0
        fi
        if [ "$input" = "a" ] || [ "$input" = "A" ]; then
            for opt in "${options[@]}"; do
                option_value "$opt"
            done
            return 0
        fi

        local valid=true
        local -a selected=()
        IFS=',' read -ra nums <<< "$input"
        for n in "${nums[@]}"; do
            n="$(echo "$n" | tr -d ' ')"
            if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#options[@]}" ]; then
                selected+=("$(option_value "${options[$((n - 1))]}")")
            else
                valid=false
                break
            fi
        done

        if [ "$valid" = true ]; then
            printf '%s\n' "${selected[@]}"
            return 0
        fi
        echo "Invalid selection. Try again." >&2
    done
}

detect_pkg_manager() {
    if command -v yay >/dev/null 2>&1; then
        echo "yay"
    elif command -v paru >/dev/null 2>&1; then
        echo "paru"
    elif command -v pacman >/dev/null 2>&1; then
        echo "pacman"
    elif command -v dnf >/dev/null 2>&1; then
        echo "dnf"
    elif command -v apt-get >/dev/null 2>&1; then
        echo "apt"
    else
        echo ""
    fi
}

install_dependencies() {
    local pm
    pm="$(detect_pkg_manager)"

    case "$pm" in
        yay|paru)
            echo "[DEP] Installing dependencies with $pm..."
            "$pm" -S --needed --noconfirm sassc gtk-engine-murrine gnome-themes-extra
            ;;
        pacman)
            echo "[DEP] Installing dependencies with pacman..."
            sudo pacman -S --needed --noconfirm sassc gtk-engine-murrine gnome-themes-extra
            ;;
        dnf)
            echo "[DEP] Installing dependencies with dnf..."
            sudo dnf install -y sassc gtk-murrine-engine gnome-themes-extra
            ;;
        apt)
            echo "[DEP] Installing dependencies with apt..."
            sudo apt-get update
            sudo apt-get install -y sassc gtk2-engines-murrine gnome-themes-extra
            ;;
        *)
            echo "[WARN] No supported package manager found (pacman/dnf/apt)."
            echo "       Install manually: sassc, murrine engine and gnome-themes-extra."
            return 1
            ;;
    esac
}

# Apply the GTK, icon and color-scheme settings via gsettings.
apply_theme() {
    local gtk_theme="$1"
    local icon_theme="$2"
    local dark="$3"

    if ! command -v gsettings >/dev/null 2>&1; then
        echo "[WARN] gsettings not found. Apply manually:"
        echo "       gtk-theme=$gtk_theme icon-theme=$icon_theme"
        return 0
    fi

    echo "[APPLY] gsettings set org.gnome.desktop.interface gtk-theme '$gtk_theme'"
    gsettings set org.gnome.desktop.interface gtk-theme "$gtk_theme"

    echo "[APPLY] gsettings set org.gnome.desktop.interface icon-theme '$icon_theme'"
    gsettings set org.gnome.desktop.interface icon-theme "$icon_theme"

    if [ "$dark" = "true" ]; then
        echo "[APPLY] gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'"
        gsettings set org.gnome.desktop.interface color-scheme "prefer-dark"
    fi
}

# Link the installed GTK4 theme into the current user's gtk-4.0 config.
link_libadwaita() {
    local theme_dir="$1"
    local gtk4_dir="$HOME/.config/gtk-4.0"

    rm -rf "${gtk4_dir}/assets" "${gtk4_dir}/gtk.css" "${gtk4_dir}/gtk-dark.css"
    mkdir -p "$gtk4_dir"
    ln -sf "${theme_dir}/gtk-4.0/assets" "${gtk4_dir}/assets"
    ln -sf "${theme_dir}/gtk-4.0/gtk.css" "${gtk4_dir}/gtk.css"
    ln -sf "${theme_dir}/gtk-4.0/gtk-dark.css" "${gtk4_dir}/gtk-dark.css"
    echo "[LINK] Linked $theme_dir/gtk-4.0 -> $gtk4_dir"
}

install_everforest() {
    echo ""
    echo "--- Everforest GTK Theme ---"

    local scope
    scope="$(select_one "Select install scope:" \
        "user|Current user only (~/.local/share, no sudo)" \
        "global|All users (/usr/share, requires sudo)")"

    local themes_dest icons_dest
    local -a root=()
    if [ "$scope" = "global" ]; then
        if ! command -v sudo >/dev/null 2>&1; then
            echo "[ERROR] sudo is required for a global install."
            return 1
        fi
        themes_dest="/usr/share/themes"
        icons_dest="/usr/share/icons"
        root=(sudo)
    else
        themes_dest="${XDG_DATA_HOME:-$HOME/.local/share}/themes"
        icons_dest="${XDG_DATA_HOME:-$HOME/.local/share}/icons"
    fi

    local accent
    accent="$(select_one "Select accent color variant:" \
        "default|Everforest green accent (default)" \
        "green" \
        "grey" \
        "orange" \
        "pink" \
        "purple" \
        "red" \
        "teal" \
        "yellow" \
        "all")"

    local color
    color="$(select_one "Select color variant:" \
        "light" \
        "dark" \
        "all|Both light and dark versions")"

    local size
    size="$(select_one "Select size variant:" \
        "standard|Standard size (default padding)" \
        "compact|Compact size (tighter padding, fits more content)")"

    local -a tweaks=()
    mapfile -t tweaks < <(select_many "Select tweaks (optional):" \
        "medium|Medium color scheme" \
        "soft|Soft color scheme" \
        "black|Blackness color version" \
        "outline|Windows with 2px outline style" \
        "float|Floating gnome-shell panel" \
        "macos|macOS-style window buttons")

    local libadwaita="false"
    if prompt_confirm "Link GTK4 theme for libadwaita apps (~/.config/gtk-4.0)?"; then
        libadwaita="true"
    fi

    # Build the arguments for the upstream installer
    local -a args=()

    if [ "$accent" = "all" ]; then
        args+=(-t all)
    elif [ "$accent" != "default" ]; then
        args+=(-t "$accent")
    fi

    if [ "$color" != "all" ]; then
        args+=(-c "$color")
    fi

    if [ "$size" != "standard" ]; then
        args+=(-s "$size")
    fi

    if [ "${#tweaks[@]}" -gt 0 ]; then
        args+=(--tweaks "${tweaks[@]}")
    fi

    install_dependencies || return 1

    echo ""
    echo "[CLONE] Cloning Everforest GTK Theme to $EVERFOREST_CLONE_DIR..."
    rm -rf "$EVERFOREST_CLONE_DIR"
    git clone --depth 1 "$EVERFOREST_REPO_URL" "$EVERFOREST_CLONE_DIR"

    # Build into a temporary destination, then copy with the right privileges.
    local build_dest="$EVERFOREST_CLONE_DIR/out"
    echo "[BUILD] Building Everforest theme (${args[*]})..."
    "$EVERFOREST_CLONE_DIR/themes/install.sh" -d "$build_dest" "${args[@]}"

    # Install generated GTK themes
    "${root[@]}" mkdir -p "$themes_dest"
    local dir name
    for dir in "$build_dest"/*; do
        [ -d "$dir" ] || continue
        name="$(basename "$dir")"
        echo "[THEME] Installing $name to $themes_dest..."
        "${root[@]}" rm -rf "$themes_dest/$name"
        "${root[@]}" cp -r "$dir" "$themes_dest/$name"
    done

    # Install icon themes
    local -a icon_variants=()
    case "$color" in
        light) icon_variants=("Light") ;;
        dark)  icon_variants=("Dark") ;;
        all)   icon_variants=("Light" "Dark") ;;
    esac
    "${root[@]}" mkdir -p "$icons_dest"
    local variant
    for variant in "${icon_variants[@]}"; do
        echo "[ICON] Installing Everforest-$variant icons to $icons_dest..."
        "${root[@]}" rm -rf "$icons_dest/Everforest-$variant"
        "${root[@]}" cp -r "$EVERFOREST_CLONE_DIR/icons/Everforest-$variant" "$icons_dest/Everforest-$variant"
    done

    # Determine which installed variants to apply.
    local accent_suffix=""
    case "$accent" in
        green)  accent_suffix="-Green" ;;
        grey)   accent_suffix="-Grey" ;;
        orange) accent_suffix="-Orange" ;;
        pink)   accent_suffix="-Pink" ;;
        purple) accent_suffix="-Purple" ;;
        red)    accent_suffix="-Red" ;;
        teal)   accent_suffix="-Teal" ;;
        yellow) accent_suffix="-Yellow" ;;
    esac

    local color_suffix="-Dark"
    local applied_icon="Everforest-Dark"
    local dark="true"
    if [ "$color" = "light" ]; then
        color_suffix="-Light"
        applied_icon="Everforest-Light"
        dark="false"
    fi

    local size_suffix=""
    if [ "$size" = "compact" ]; then
        size_suffix="-Compact"
    fi

    local ctype=""
    local window=""
    local t
    for t in "${tweaks[@]}"; do
        case "$t" in
            medium) ctype="-Medium" ;;
            soft)   ctype="-Soft" ;;
            macos)  window="-Macos" ;;
        esac
    done

    local applied_theme="Everforest${accent_suffix}${color_suffix}${size_suffix}${ctype}${window}"
    local applied_theme_dir="$themes_dest/$applied_theme"

    if [ -d "$applied_theme_dir" ]; then
        apply_theme "$applied_theme" "$applied_icon" "$dark"
        if [ "$libadwaita" = "true" ]; then
            link_libadwaita "$applied_theme_dir"
        fi
    else
        echo "[WARN] Expected theme directory not found: $applied_theme_dir"
    fi

    echo "[DONE] Everforest GTK Theme installed (scope: $scope)."
}

install_theme() {
    echo ""
    echo "--- Theme Selection ---"
    local theme
    theme="$(select_one "Select a theme to install:" "Everforest")"

    case "$theme" in
        Everforest)
            install_everforest
            ;;
        *)
            echo "Unknown theme: $theme"
            return 1
            ;;
    esac
}

echo "=== Starting Theme Installation ==="
install_theme
echo ""
echo "=== Theme installation completed successfully! ==="
