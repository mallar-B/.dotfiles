#!/bin/bash

WALLPAPER=$1
WALLPAPER_PATH=$(realpath $WALLPAPER)

wal -i $WALLPAPER
feh --bg-fill $WALLPAPER

mkdir -p ~/Pictures/Wallpapers
ln -S WALLPAPER_PATH ~/Pictures/Wallpapers/curr_wall

# chrome setup
~/GitHub/ChromiumPywal/generate-theme.sh
magick ~/GitHub/ChromiumPywal/Pywal/images/theme_ntp_background_norepeat.png /tmp/chrome_background.png
magick /tmp/chrome_background.png -blur 0x8 ~/GitHub/ChromiumPywal/Pywal/images/theme_ntp_background_norepeat.png
