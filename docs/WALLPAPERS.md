# Wallpapers

ARCHMAC uses Hyprpaper for desktop wallpapers.

## Thunar integration

Supported image files can be selected directly from Thunar:

1. Right-click a PNG, JPG, JPEG, or WebP image.
2. Choose **Set as ARCHMAC Wallpaper**.
3. ARCHMAC copies the image into its managed wallpaper directory.
4. Hyprpaper reloads with the new image.
5. The selection persists across sessions.

The original image does not need to remain in Downloads or its original
directory after the wallpaper has been set.

## Command line

The same operation is available from the terminal:

    archmac-wallpaper /path/to/image.jpg

Supported formats:

- PNG
- JPG / JPEG
- WebP

## Managed wallpaper

The selected image is copied to:

    ~/.config/archmac/wallpapers/

The Hyprpaper configuration is updated to reference the managed copy rather
than the original source file.

This prevents deleting or moving the original image from breaking the
desktop wallpaper.

## Display

The MacBookPro9,2 reference configuration uses the internal display:

    LVDS-1

The wallpaper uses Hyprpaper's `cover` fit mode.
