#!/bin/bash

is_running=$(pidof -x hyprpaper)

wallpaper=$(find /home/$(whoami)/Pictures/Wallpapers/ -type f | shuf -n 1)

if [ -n "$1" ];then
	wallpaper=$(readlink -f "$1")
	echo "$wallpaper"
fi


if [ -z "$is_running" ];then
	echo "$wallpaper"
	hyprpaper &
	sleep 1

	hyprctl hyprpaper preload "$wallpaper"
	hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
	sleep 1
	hyprctl hyprpaper unload all; 

else 
	hyprctl hyprpaper preload "$wallpaper"
	hyprctl hyprpaper wallpaper "$monitor,$wallpaper"
	sleep 1
	hyprctl hyprpaper unload all; 
fi

ln -sf $wallpaper /home/$(whoami)/Pictures/Wallpapers/curr_wall

wal -i $wallpaper
