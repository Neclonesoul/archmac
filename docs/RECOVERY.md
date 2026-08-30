# Recovery Doctrine

ARCHMAC separates desktop recovery from boot recovery.

## Core rule

A desktop failure is not evidence of a bootloader failure.

Do not modify EFI, NVRAM, partition tables, filesystems, systemd-boot,
GRUB, or other boot infrastructure merely because Hyprland or Galaxy fails.

## Galaxy failure model

ARCHMAC Galaxy runs inside Hyprland.

A Quickshell failure must not require a reboot or Hyprland restart.
Terminal access should remain available.

## Recovery command

Inspect Galaxy:

    archmac-shell status

Restart Galaxy without restarting Hyprland:

    archmac-shell restart

Explicit control:

    archmac-shell start
    archmac-shell stop

Inspect recovery output:

    archmac-shell log

## Manual recovery

If the helper is unavailable:

    pkill -x qs
    qs -c archmac-galaxy

## Diagnostics

Useful checks:

    hyprctl configerrors
    hyprctl binds
    hyprctl monitors
    systemctl --user --failed
    pgrep -af qs

A normal session should contain one intended Galaxy process.

## Configuration recovery

Installer backups are stored beneath:

    ${XDG_STATE_HOME:-~/.local/state}/archmac/backups/

Restore only the component demonstrated to be faulty.

## Installation discipline

Inspect -> Backup -> Change -> Verify

Avoid stacking speculative fixes.

## Legacy fallbacks

Waybar, Mako and Wofi may remain installed while Galaxy completes release
verification.

They should not run concurrently merely because they remain available.

## EFI

ARCHMAC intentionally performs no EFI, NVRAM, filesystem, partitioning,
or bootloader operations.

Boot recovery is a separate procedure and should only be undertaken when
evidence demonstrates an actual boot problem.
