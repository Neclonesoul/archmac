# ARCHMAC

A reproducible Arch Linux + Hyprland workstation configuration for the
Apple MacBookPro9,2.

## Status

Known-good workstation baseline captured from a functioning installation.

## Hardware target

- Apple MacBookPro9,2 (13-inch, Mid 2012)
- Intel Core i5-3210M
- Intel HD Graphics 4000
- Broadcom Wi-Fi
- Apple SMC keyboard backlight
- Kingston A400 SSD

## Desktop

- Arch Linux
- Hyprland
- Waybar
- Kitty
- PipeWire / WirePlumber
- NetworkManager
- Mako
- Hypridle / Hyprlock
- GTK 3 / GTK 4
- Qt 5 / Qt 6 Wayland

## ARCHMAC modes

- Fancy — full desktop effects, balanced power
- Performance — reduced compositor overhead
- Battery — reduced compositor overhead, power-saver

## Important

ARCHMAC does not automate EFI or bootloader modification.

Boot recovery is intentionally documented separately from desktop
installation so a working EFI configuration is never casually replaced.

## Repository layout

- `config/` — canonical desktop configuration
- `bin/` — ARCHMAC helper scripts
- `manifests/` — package manifests
- `docs/` — operational documentation
- `state/` — known-good reference state

## Release

The first release will be tagged `v1.0.0` only after repository validation.

## Wallpaper workflow

ARCHMAC integrates Hyprpaper with Thunar.

Right-click a PNG, JPG, JPEG, or WebP image and select
**Set as ARCHMAC Wallpaper** to apply it and persist the selection.

The same operation is available from the terminal:

    archmac-wallpaper /path/to/image.jpg

See `docs/WALLPAPERS.md` for details.
