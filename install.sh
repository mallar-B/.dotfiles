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

userConfDir="/home/"$(whoami)"/.config"
while IFS= read -r package #IFS is special variable to fine whitespaces
do
	#Skip emty lines and comments in package.txt
	if [[ -z "$package" || "$package" == "#"* ]]; then
		continue
	fi
	
	yay -S --needed --noconfirm "$package"
done < "./packages/dependencies.txt"

cp -r hypr $userConfDir
mkdir -p $userConfDir/ags/
cp -r config.js style.css widgets $userConfDir/ags/

# set theme to adw-gtk3-dark
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3=dark"
