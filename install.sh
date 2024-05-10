#!/bin/bash

# check if yay is installed

installed=$(which yay)
if [[ $installed != "/usr/bin/yay" ]]; then 
	cd ..
	sudo pacman -S --needed git
	git clone https://aur.archlinux.org/yay
	wait
	cd yay 
	makepkg -si
	wait
	cd ..
	cd ags_personal
fi

# remove dunst as ags has built in notification service
yay -R dunst

userConfDir="/home/"$(whoami)"/.config"
function install_packages(){
	while IFS= read -r package #IFS is special variable to fine whitespaces
	do
		#Skip emty lines and comments in package.txt
		if [[ -z "$package" || "$package" == "#"* ]]; then
			continue
		fi
	
		yay -S --needed --noconfirm "$package"
	done < $1 
}

install_packages "./packages/dependencies.txt"

cp -r hypr $userConfDir
mkdir -p $userConfDir/ags/
cp -r config.js style.css widgets $userConfDir/ags/

# set theme to adw-gtk3-dark
gsettings set org.gnome.desktop.interface gtk-theme "adw-gtk3-dark"
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' # for gtk4 apps
echo "Theme is set to adw-gtk3-dark"
sleep 2

# Add Wallpaper for hyprpaper
# URL of the API endpoint to fetch random wallpapers from Wallhaven.cc
API_URL="https://wallhaven.cc/api/v1/search?sorting=random"

# Download the JSON response containing information about random wallpapers
response=$(curl -s "$API_URL")

# Parse the JSON response to extract the URL of the random wallpaper
wallpaper_url=$(echo "$response" | jq -r '.data[0].path')

# Download the wallpaper using wget
wget "$wallpaper_url" -P ~/Pictures/Wallpapers/
echo "Random wallpaper downloaded to ~/Pictures/Wallpapers"

# my personal packages install
if [[ $(whoami) == "mallarb" ]]; then
	install_packages "./packages/personal_packages.txt"
	echo "remember to update fstab, register warp-cli"
fi
