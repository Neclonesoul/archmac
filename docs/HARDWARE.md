# Hardware

ARCHMAC was developed and validated on an Apple MacBookPro9,2
(13-inch, Mid 2012).

## Reference machine

- CPU: Intel Core i5-3210M
- GPU: Intel HD Graphics 4000
- RAM: 16 GB
- Storage: Kingston A400 SSD
- Display: 1280×800
- Wi-Fi: Broadcom
- Keyboard: Apple internal keyboard
- Keyboard illumination: Apple SMC
- Camera: FaceTime HD Camera

## Linux hardware integration

The reference system uses:

- `i915` for Intel graphics
- `wl` for Broadcom Wi-Fi
- `applesmc` for Apple SMC hardware
- `hid_apple` for the Apple keyboard
- `apple_gmux`
- PipeWire + WirePlumber for audio
- BlueZ for Bluetooth

Keyboard illumination is exposed as:

`smc::kbd_backlight`

Display brightness is exposed as:

`intel_backlight`

ARCHMAC deliberately does not modify EFI or bootloader configuration.
