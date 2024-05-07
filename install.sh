#!/bin/bash

# check if yay is installed

installed=$(which yay)
if [[ $installed != "/usr/bin/yay" ]]; then 
	sudo pacman -S --needed git
	git clone https://aur.archlinux.org/yay
	wait
	cd yay 
	makepkg -si
	wait
fi
