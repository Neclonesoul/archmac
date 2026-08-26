# Recovery Doctrine

ARCHMAC separates desktop configuration from boot recovery.

## Core rule

A desktop configuration problem is not evidence of a bootloader problem.

Do not modify EFI, NVRAM, partition tables, GRUB, systemd-boot, or other
boot infrastructure merely because Hyprland or a desktop component fails.

## Desktop recovery

1. Move to a TTY if possible.
2. Inspect the failing component.
3. Check `hyprctl configerrors`.
4. Inspect failed user services.
5. Restore the relevant configuration from the installer's timestamped
   backup.
6. Restart only the affected component or session.
7. Verify before making another change.

## Installation discipline

Use:

Inspect → Backup → Change → Verify

Avoid stacking speculative fixes.

## EFI

The MacBookPro9,2 reference machine has a known-good working boot
configuration.

ARCHMAC's installer intentionally contains no EFI, NVRAM, filesystem,
partitioning, or bootloader operations.

Boot recovery should be handled separately and only when evidence
demonstrates an actual boot problem.
