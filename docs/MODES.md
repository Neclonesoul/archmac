# ARCHMAC Modes

ARCHMAC provides three workstation profiles.

## Fancy

Normal desktop mode.

- animations enabled
- blur enabled
- shadows enabled
- transparency enabled
- balanced power profile

Command:

`mac-fancy`

## Performance

Reduces compositor overhead while retaining normal CPU power behaviour.

- animations disabled
- blur disabled
- shadows disabled
- opaque windows
- tighter gaps

Command:

`mac-performance`

## Battery

Uses the low-overhead compositor configuration together with the
power-saver profile.

Command:

`mac-battery`

## Toggle

`mac-mode` toggles between Fancy and Performance.

The current session mode is recorded under the user's runtime directory.
It is intentionally ephemeral and is re-established when ARCHMAC starts.
