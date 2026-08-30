#!/usr/bin/env bash

set -u

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
BACKUP="$STATE_HOME/archmac/backups/$(date +%Y%m%d-%H%M%S)"

echo "========================================"
echo " ARCHMAC GALAXY — SAFE INSTALLER"
echo "========================================"

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "STOP — ARCHMAC requires Linux."
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "STOP — ARCHMAC expects Arch Linux."
    exit 1
fi

echo
echo "Repository : $REPO"
echo "Backup     : $BACKUP"

echo
echo "=== PREFLIGHT ==="

for path in \
    config/hypr/hyprland.lua \
    config/hypr/hyprlock.conf \
    config/hypr/hypridle.conf \
    config/hypr/hyprpaper.conf \
    config/quickshell/archmac-galaxy/shell.qml \
    config/kitty/kitty.conf
do
    if [[ ! -f "$REPO/$path" ]]; then
        echo "STOP — repository incomplete: $path"
        exit 1
    fi
done

echo "PASS — repository structure"

echo
echo "=== BACKUP ==="

mkdir -p "$BACKUP"

for d in hypr quickshell kitty gtk-3.0 gtk-4.0 Thunar archmac waybar; do
    if [[ -e "$HOME/.config/$d" ]]; then
        cp -a "$HOME/.config/$d" "$BACKUP/"
        echo "BACKUP — ~/.config/$d"
    fi
done

mkdir -p "$BACKUP/local-bin"

for src in "$REPO"/bin/*; do
    [[ -f "$src" ]] || continue
    name="$(basename "$src")"

    if [[ -e "$HOME/.local/bin/$name" ]]; then
        cp -a "$HOME/.local/bin/$name" "$BACKUP/local-bin/"
    fi
done

echo
echo "=== INSTALL CONFIGURATION ==="

mkdir -p \
    "$HOME/.config/hypr" \
    "$HOME/.config/quickshell/archmac-galaxy" \
    "$HOME/.config/kitty" \
    "$HOME/.config/gtk-3.0" \
    "$HOME/.config/gtk-4.0" \
    "$HOME/.config/Thunar" \
    "$HOME/.config/archmac/wallpapers" \
    "$HOME/.local/bin"

cp -a "$REPO/config/hypr/." "$HOME/.config/hypr/"
cp -a "$REPO/config/quickshell/archmac-galaxy/." \
      "$HOME/.config/quickshell/archmac-galaxy/"
cp -a "$REPO/config/kitty/." "$HOME/.config/kitty/"
cp -a "$REPO/config/gtk-3.0/." "$HOME/.config/gtk-3.0/"
cp -a "$REPO/config/gtk-4.0/." "$HOME/.config/gtk-4.0/"

if [[ -d "$REPO/config/Thunar" ]]; then
    cp -a "$REPO/config/Thunar/." "$HOME/.config/Thunar/"
fi

if [[ -f "$REPO/assets/wallpapers/archmac.png" ]]; then
    cp "$REPO/assets/wallpapers/archmac.png" \
       "$HOME/.config/archmac/wallpapers/archmac.png"
fi

for src in "$REPO"/bin/*; do
    [[ -f "$src" ]] || continue
    name="$(basename "$src")"
    cp "$src" "$HOME/.local/bin/$name"

    if [[ -x "$src" ]]; then
        chmod +x "$HOME/.local/bin/$name"
    fi
done

echo "PASS — configuration installed"
echo "PASS — helper commands installed"

echo
echo "=== REQUIRED RUNTIME ==="

MISSING=0

for cmd in \
    Hyprland \
    hyprctl \
    qs \
    kitty \
    hyprpaper \
    hypridle \
    hyprlock \
    brightnessctl \
    wpctl \
    playerctl \
    grim \
    slurp \
    wl-copy \
    cliphist \
    qalc
do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "PASS — $cmd"
    else
        echo "MISSING — $cmd"
        MISSING=1
    fi
done

echo
echo "=== COMPATIBILITY / FALLBACK ==="

for cmd in nm-applet blueman-applet wofi; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "AVAILABLE — $cmd"
    else
        echo "OPTIONAL — $cmd"
    fi
done

echo
echo "Backup preserved at:"
echo "$BACKUP"

if [[ "$MISSING" -ne 0 ]]; then
    echo
    echo "WARNING — required runtime dependencies are missing."
    exit 2
fi

echo
echo "========================================"
echo " ARCHMAC GALAXY INSTALL COMPLETE"
echo " Log out and start a fresh Hyprland session."
echo "========================================"
