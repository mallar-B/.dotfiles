#!/bin/bash

is_running=$(pidof -x hyprpaper)
echo "$is_running"

if [ -z "$is_running" ]; 
	then
 
	hyprpaper &
	sleep 0.1
	wallpaper=$(find /home/$(whoami)/Pictures/Wallpapers/ -type f | shuf -n 1)

	hyprctl hyprpaper preload "$wallpaper"
	hyprctl hyprpaper wallpaper "HDMI-A-1,$wallpaper"
	hyprctl hyprpaper unload all; 

	hyprshot -m output -c -o ~/.config/hypr/hyprlock/ -f curr_wall.png -s

else 
	
	wallpaper=$(find /home/$(whoami)/Pictures/Wallpapers/ -type f | shuf -n 1)

	hyprctl hyprpaper preload "$wallpaper"
	hyprctl hyprpaper wallpaper "HDMI-A-1,$wallpaper"
	hyprctl hyprpaper unload all; 

	hyprshot -m output -c -o ~/.config/hypr/hyprlock/ -f curr_wall.png -s
fi
