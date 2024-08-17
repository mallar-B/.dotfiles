#!/bin/bash

running=$(pidof hyprlock)

if [ -z "$running" ]; then
  rm -f /tmp/screenshot.png
  grim /tmp/screenshot.png
  magick /tmp/screenshot.png -blur 0x13 /tmp/screenshot_blur.png

  sleep 0.5
  hyprlock &
else
  exit 0
fi
