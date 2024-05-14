#!/bin/bash

is_running=$(pidof hyprlock)

if [ -z "is_running" ]; then
 systemctl suspend
else
  hyprlock
  systemctl suspend
fi
