#!/bin/bash

monitors=$(~/.config/hypr/hyprpaper/scripts/monitor_name.sh)

is_running=$(pidof -x hyprpaper)

if [ -z "$is_running" ]; 
	then
 
	hyprpaper &
	sleep 0.1
	wallpaper=$(find /home/$(whoami)/Pictures/Wallpapers/ -type f | shuf -n 1)

	for monitor in $monitors;do
		hyprctl hyprpaper preload "$wallpaper"
		hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
		hyprctl hyprpaper unload all; 
	done	

	hyprshot -m output -c -o ~/.config/hypr/hyprlock/ -f curr_wall.png -s

else 
	
	wallpaper=$(find /home/$(whoami)/Pictures/Wallpapers/ -type f | shuf -n 1)

	for monitor in $monitors;do
		hyprctl hyprpaper preload "$wallpaper"
		hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
		hyprctl hyprpaper unload all; 
	done

	hyprshot -m output -c -o ~/.config/hypr/hyprlock/ -f curr_wall.png -s
fi
