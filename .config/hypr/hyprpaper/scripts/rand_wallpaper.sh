#!/bin/bash

monitors=$(~/.config/hypr/hyprpaper/scripts/monitor_name.sh)

is_running=$(pidof -x hyprpaper)

if [ -z "$is_running" ]; 
	then
 
	hyprpaper &
	sleep 1
	wallpaper=$(find /home/$(whoami)/Pictures/Wallpapers/ -type f | shuf -n 1)

	for monitor in $monitors;do
		hyprctl hyprpaper preload "$wallpaper"
		hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
    sleep 1
		hyprctl hyprpaper unload all; 
	done	


else 
	
	wallpaper=$(find /home/$(whoami)/Pictures/Wallpapers/ -type f | shuf -n 1)

	for monitor in $monitors;do
		hyprctl hyprpaper preload "$wallpaper"
		hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
    sleep 1
		hyprctl hyprpaper unload all; 
	done

fi
