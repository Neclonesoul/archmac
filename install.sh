#!/usr/bin/env bash

set -u

REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.local/state/archmac/backups/$(date +%Y%m%d-%H%M%S)"

echo "========================================"
echo " ARCHMAC — SAFE INSTALLER"
echo "========================================"

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "STOP — ARCHMAC requires Linux."
    exit 1
fi

if ! command -v pacman >/dev/null 2>&1; then
    echo "STOP — ARCHMAC expects an Arch Linux system."
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
    config/waybar/config.jsonc \
    config/waybar/style.css \
    config/kitty/kitty.conf
do
    if [[ ! -f "$REPO/$path" ]]; then
        echo "STOP — repository incomplete: $path"
        exit 1
    fi
done

echo "PASS — repository structure"

echo
echo "=== BACKUP EXISTING CONFIG ==="

mkdir -p "$BACKUP"

for d in hypr waybar kitty gtk-3.0 gtk-4.0; do
    if [[ -e "$HOME/.config/$d" ]]; then
        cp -a "$HOME/.config/$d" "$BACKUP/"
        echo "BACKUP — ~/.config/$d"
    fi
done

mkdir -p "$BACKUP/local-bin"

for src in "$REPO"/bin/*; do
    name="$(basename "$src")"

    if [[ -e "$HOME/.local/bin/$name" ]]; then
        cp -a "$HOME/.local/bin/$name" "$BACKUP/local-bin/"
        echo "BACKUP — ~/.local/bin/$name"
    fi
done

echo
echo "=== INSTALL CONFIG ==="

mkdir -p \
    "$HOME/.config/hypr" \
    "$HOME/.config/waybar" \
    "$HOME/.config/kitty" \
    "$HOME/.config/gtk-3.0" \
    "$HOME/.config/gtk-4.0" \
    "$HOME/.config/archmac/wallpapers" \
    "$HOME/.local/bin"

cp -a "$REPO/config/hypr/."   "$HOME/.config/hypr/"
cp -a "$REPO/config/waybar/." "$HOME/.config/waybar/"
cp -a "$REPO/config/kitty/."  "$HOME/.config/kitty/"
cp -a "$REPO/config/gtk-3.0/." "$HOME/.config/gtk-3.0/"
cp -a "$REPO/config/gtk-4.0/." "$HOME/.config/gtk-4.0/"

cp "$REPO/assets/wallpapers/archmac.png" \
   "$HOME/.config/archmac/wallpapers/archmac.png"

cp "$REPO"/bin/* "$HOME/.local/bin/"
chmod +x "$HOME"/.local/bin/{archmac-cliphist,mac-*,waybar-volume-menu}

echo "PASS — configuration installed"
echo "PASS — helper scripts installed"

echo
echo "=== VERIFY ==="

MISSING=0

for cmd in \
    Hyprland \
    waybar \
    kitty \
    brightnessctl \
    wpctl \
    playerctl \
    grim \
    slurp \
    wl-copy \
    cliphist
do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "PASS — $cmd"
    else
        echo "MISSING — $cmd"
        MISSING=1
    fi
done

echo
echo "Backup preserved at:"
echo "$BACKUP"

if [[ "$MISSING" -ne 0 ]]; then
    echo
    echo "WARNING — configuration installed, but dependencies are missing."
    echo "Install the missing packages before starting ARCHMAC."
    exit 2
fi

echo
echo "========================================"
echo " ARCHMAC INSTALL COMPLETE"
echo " Log out and start a fresh Hyprland session."
echo "========================================"
