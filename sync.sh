#!/usr/bin/env bash
# ==============================================================================
# dotfiles sync & manage script
# ==============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
BIN_DIR="$HOME/.local/bin"

CONFIG_DIRS=(
    "hypr"
    "caelestia"
    "quickshell/caelestia"
    "fish"
    "kitty"
    "foot"
    "fastfetch"
    "btop"
    "fuzzel"
    "cava"
    "fcitx5"
    "nvim"
    "micro"
    "spicetify"
    "uwsm"
    "zed"
)

CONFIG_FILES=(
    "starship.toml"
    "chromium-flags.conf"
    "code-flags.conf"
    "codium-flags.conf"
)

HOME_FILES=(
    ".bashrc"
    ".bash_profile"
)

BIN_SCRIPTS=(
    "display-switcher"
    "notify"
    "todo"
    "window-switcher"
    "xampp-control-panel"
)

export_configs() {
    echo "==> Exporting dotfiles from system to $DOTFILES_DIR..."

    # Sync ~/.config directories
    for dir in "${CONFIG_DIRS[@]}"; do
        if [[ -d "$CONFIG_DIR/$dir" ]]; then
            mkdir -p "$DOTFILES_DIR/.config/$dir"
            rsync -av --delete \
                --exclude="*.log" \
                --exclude="*.tmp" \
                --exclude="*.bak" \
                --exclude="*.save" \
                --exclude="*secrets*" \
                --exclude="*token*" \
                --exclude="fish_variables" \
                --exclude="daft_raw.jpg" \
                --exclude="daft_test54.jpg" \
                --exclude="daft_sharp.jpg" \
                --exclude="daft_head_boosted.jpg" \
                --exclude="daft_large_54.jpg" \
                --exclude="daft_helmets.jpg" \
                "$CONFIG_DIR/$dir/" "$DOTFILES_DIR/.config/$dir/"
        fi
    done

    # Sync single files in ~/.config
    for file in "${CONFIG_FILES[@]}"; do
        if [[ -f "$CONFIG_DIR/$file" ]]; then
            cp "$CONFIG_DIR/$file" "$DOTFILES_DIR/.config/$file"
        fi
    done

    # Sync home files
    for file in "${HOME_FILES[@]}"; do
        if [[ -f "$HOME/$file" ]]; then
            cp "$HOME/$file" "$DOTFILES_DIR/$file"
        fi
    done

    # Sync custom local bin scripts
    mkdir -p "$DOTFILES_DIR/.local/bin"
    for script in "${BIN_SCRIPTS[@]}"; do
        if [[ -f "$BIN_DIR/$script" ]]; then
            cp "$BIN_DIR/$script" "$DOTFILES_DIR/.local/bin/$script"
            chmod +x "$DOTFILES_DIR/.local/bin/$script"
        fi
    done

    # Sync Lotus input method dictionary/data
    if [[ -d "$HOME/.local/share/fcitx5/lotus" ]]; then
        mkdir -p "$DOTFILES_DIR/.local/share/fcitx5/lotus"
        rsync -av "$HOME/.local/share/fcitx5/lotus/" "$DOTFILES_DIR/.local/share/fcitx5/lotus/"
    fi

    echo "==> Export completed successfully!"
}

install_configs() {
    echo "==> Installing dotfiles from $DOTFILES_DIR to system..."
    mkdir -p "$CONFIG_DIR" "$BIN_DIR"

    # Install .config
    if [[ -d "$DOTFILES_DIR/.config" ]]; then
        rsync -av "$DOTFILES_DIR/.config/" "$CONFIG_DIR/"
    fi

    # Install home files
    for file in "${HOME_FILES[@]}"; do
        if [[ -f "$DOTFILES_DIR/$file" ]]; then
            cp "$DOTFILES_DIR/$file" "$HOME/$file"
        fi
    done

    # Install bin scripts
    if [[ -d "$DOTFILES_DIR/.local/bin" ]]; then
        rsync -av "$DOTFILES_DIR/.local/bin/" "$BIN_DIR/"
        chmod +x "$BIN_DIR"/* 2>/dev/null || true
    fi

    # Install Lotus data
    if [[ -d "$DOTFILES_DIR/.local/share/fcitx5/lotus" ]]; then
        mkdir -p "$HOME/.local/share/fcitx5/lotus"
        rsync -av "$DOTFILES_DIR/.local/share/fcitx5/lotus/" "$HOME/.local/share/fcitx5/lotus/"
    fi

    echo "==> Installation completed!"
}

case "${1:-export}" in
    export)
        export_configs
        ;;
    install)
        install_configs
        ;;
    push)
        export_configs
        cd "$DOTFILES_DIR"
        git add .
        msg="${2:-Update dotfiles $(date +'%Y-%m-%d %H:%M:%S')}"
        git commit -m "$msg"
        git push origin main
        ;;
    *)
        echo "Usage: $0 [export|install|push [commit-message]]"
        exit 1
        ;;
esac
