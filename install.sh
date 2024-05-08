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

user=$(whoami)
while IFS= read -r package #IFS is special variable to fine whitespaces
do
	#Skip emty lines and comments in package.txt
	if [[ -z "$package" || "$package" == "#"* ]]; then
		continue
	fi
	
	yay -S --needed --noconfirm "$package"
done < "./packages/dependencies.txt"
