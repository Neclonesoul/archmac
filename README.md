# ARCHMAC

ARCHMAC is a reproducible Arch Linux desktop environment built around
Hyprland and the ARCHMAC Galaxy Quickshell shell.

The reference platform is the Apple MacBookPro9,2. The architecture is
intended to remain inspectable, repairable, portable, and extensible to
additional hardware profiles.

> Beautiful. Repairable. Yours.

## Status

ARCHMAC Galaxy is the current development baseline.

Galaxy replaces the previous Waybar/Mako-centred desktop with a unified
Quickshell shell using centralized services for system state, telemetry,
workspaces, notifications, launching, system controls, OSD, session controls,
and ARCHMAC modes.

Galaxy is currently undergoing release verification before promotion to
the canonical main branch.

## Hardware target

Reference hardware:

- Apple MacBookPro9,2 (13-inch, Mid 2012)
- Intel Core i5-3210M
- Intel HD Graphics 4000
- Broadcom Wi-Fi
- Apple SMC keyboard backlight
- Kingston A400 SSD

ARCHMAC configuration must remain free of private machine identifiers and
hard-coded user home paths.

## Desktop architecture

Primary runtime:

- Arch Linux
- Hyprland
- Quickshell / ARCHMAC Galaxy
- Kitty
- PipeWire / WirePlumber
- NetworkManager
- BlueZ
- Hyprpaper
- Hypridle / Hyprlock
- GTK 3 / GTK 4
- Qt 6 Wayland

Galaxy currently provides:

- top bar
- workspace state and navigation
- native system tray
- Control Centre
- Wi-Fi and Bluetooth integration
- audio, brightness, battery and power state
- hardware telemetry and hardware monitor
- system OSD
- notification server, toasts and history
- application launcher
- calculator
- searchable clipboard history
- spatial workspace overview
- Galaxy Command Centre
- lock/session integration
- power/session menu
- ARCHMAC mode integration
- Material Symbols shell icon system

Waybar and Mako are no longer active primary shell components.

Legacy utilities may remain available as deliberate compatibility or
recovery fallbacks until their replacements have completed release
verification.

## Engineering doctrine

ARCHMAC follows these rules:

1. Inspect before modifying.
2. Preserve working behaviour until its replacement is proven.
3. Maintain one authoritative state owner per subsystem.
4. Prefer event-driven native interfaces over duplicated polling.
5. Hyprland owns composition and workspace behaviour.
6. Quickshell owns shell presentation and interaction.
7. Services own system state.
8. Hardware-specific behaviour must remain explicit.
9. Configuration must remain portable.
10. Verify live behaviour before declaring work complete.

Development flow:

Inspect -> Understand -> Change -> Verify -> Diff -> Commit

## ARCHMAC modes

Current modes:

- Fancy — full desktop effects with balanced power
- Performance — reduced compositor overhead
- Battery — reduced visual overhead and power-saving behaviour

Mode state is shared with Galaxy rather than independently inferred by shell
components.

## Installation

ARCHMAC intentionally does not modify EFI, NVRAM, partition tables,
filesystems, or bootloaders.

Desktop installation and boot recovery are separate concerns.

From a checked-out repository run:

    ./install.sh

The installer backs up managed configuration, installs Hyprland and Galaxy,
installs ARCHMAC helpers, and verifies required runtime dependencies.

Start a fresh Hyprland session after installation.

## Galaxy recovery

Galaxy can be inspected or restarted independently of Hyprland:

    archmac-shell status
    archmac-shell restart
    archmac-shell log

If Galaxy fails, Hyprland and terminal access should remain usable.

See docs/RECOVERY.md.

## Repository layout

- config/ — canonical desktop configuration
- config/quickshell/archmac-galaxy/ — Galaxy shell
- bin/ — ARCHMAC helper commands
- manifests/ — package manifests
- docs/ — operational documentation
- state/ — known-good reference state

## Wallpaper workflow

ARCHMAC integrates Hyprpaper with Thunar.

Right-click a supported image and select Set as ARCHMAC Wallpaper, or use:

    archmac-wallpaper /path/to/image.jpg

See docs/WALLPAPERS.md.

## Release verification

Galaxy is release-ready only after verification that:

- Galaxy autostarts correctly
- exactly one intended Galaxy shell runs
- Hyprland remains usable if Galaxy stops
- Galaxy can restart without restarting Hyprland
- workspaces and gestures work
- launcher and clipboard work
- notifications and OSD work
- audio and brightness work
- tray and Control Centre work
- lock and session controls work
- ARCHMAC modes work
- wallpaper persists
- expected keybindings are registered
- external monitor behaviour is correct
- suspend/resume is reliable
- logout/login is reliable
- cold reboot is reliable
- fresh installation is reproducible
- CI is green
