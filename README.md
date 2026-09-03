<div align="center">

# ARCHMAC

### Reproducible Arch Linux workstation for the Apple MacBookPro9,2

**Arch Linux · Hyprland · ARCHMAC Galaxy · Quickshell · Wayland**

**Beautiful. Repairable. Yours.**

</div>

---

## What is ARCHMAC?

ARCHMAC is a reproducible Arch Linux desktop environment built around
**Hyprland** and the **ARCHMAC Galaxy Quickshell shell**.

The reference platform is the **Apple MacBookPro9,2 — 13-inch, Mid 2012**.

ARCHMAC is designed to remain:

- inspectable
- repairable
- reproducible
- portable
- hardware-aware
- recoverable

This repository is not merely a dotfiles archive.

It is the engineering record and canonical configuration of a real working
Linux workstation.

---

## Reference platform

| Component | ARCHMAC |
|---|---|
| Hardware | Apple MacBookPro9,2 |
| Model | 13-inch, Mid 2012 |
| CPU | Intel Core i5-3210M |
| Graphics | Intel HD Graphics 4000 |
| OS | Arch Linux |
| Kernel | Linux 7.1.11-arch1-1 |
| Session | Wayland |
| Compositor | Hyprland 0.56.2 |
| Desktop shell | ARCHMAC Galaxy |
| Shell framework | Quickshell |
| Terminal | Kitty |
| Audio | PipeWire / WirePlumber |
| Network | NetworkManager |
| Bluetooth | BlueZ |

---

## ARCHMAC Galaxy

Galaxy is the current ARCHMAC desktop shell.

It replaces the previous Waybar/Mako-centred desktop with a unified
Quickshell environment using centralized services for system state and
interaction.

Galaxy provides:

- top bar
- workspace state and navigation
- native system tray
- Control Centre
- Wi-Fi integration
- Bluetooth integration
- audio control
- brightness control
- battery and power state
- hardware telemetry
- hardware monitor
- system OSD
- notification server
- notification history
- application launcher
- calculator
- searchable clipboard history
- spatial workspace overview
- Galaxy Command Centre
- lock/session integration
- power/session menu
- ARCHMAC mode integration

---

## Engineering doctrine

ARCHMAC follows ten rules:

1. **Inspect before modifying.**
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

    Inspect → Understand → Change → Verify → Diff → Commit

---

## Operating modes

### Fancy
Full desktop effects with balanced power.

### Performance
Reduced compositor overhead for sustained workloads.

### Battery
Reduced visual overhead and power-saving behaviour.

---

## Repository layout

    archmac/
    ├── .github/
    ├── assets/
    ├── bin/
    ├── config/
    ├── docs/
    ├── manifests/
    ├── state/
    ├── install.sh
    ├── CHANGELOG.md
    └── README.md

---

## Boot and recovery discipline

Before kernel or boot changes, inspect the actual machine state:

    findmnt /boot
    findmnt /efi 2>/dev/null || true
    lsblk -f
    bootctl status
    uname -r
    pacman -Q linux

Before rebooting after kernel work, verify:

1. the actual EFI/boot filesystem is mounted;
2. the kernel image exists;
3. the initramfs exists;
4. matching kernel modules exist;
5. boot entries reference the correct paths.

Recovery takes precedence over convenience.

---

## Known-good state

ARCHMAC keeps reference state so faults can be compared against a working
machine.

The goal is to answer:

> What did the system look like when it was known to work?

---

## Project philosophy

    SOVEREIGN WORKSTATION
            │
            ├── understand the machine
            ├── reduce unnecessary software
            ├── keep configuration reproducible
            ├── preserve recovery paths
            ├── automate repeatable work
            ├── record known-good state
            └── remove friction before adding complexity

The goal is:

> **minimum friction per unit of useful work**

---

## Contributing

Useful contributions include:

- MacBookPro9,2 hardware improvements
- Arch Linux compatibility fixes
- Hyprland / Wayland improvements
- Quickshell / Galaxy fixes
- recovery improvements
- documentation improvements
- validation improvements
- simplification

---

## Security

Never commit:

- passwords
- API keys
- private keys
- tokens
- cookies
- credentials
- machine-specific secrets

---

## Maintainer

**Tyson Barnes**

Engineering · Automation · Systems · Software

---

<div align="center">

### ARCHMAC

**Old hardware. Modern workstation. Known state.**

</div>
