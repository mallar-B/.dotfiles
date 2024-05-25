#!/bin/bash

sddm_setup(){
  #install sddm
  yay -S --needed sddm-theme-mountain-git --noconfirm
  
  #copy sddm config
  sudo cp ./scripts/theme.conf /usr/share/sddm/themes/mountain/
  
  #change sddm theme
  file_path="/usr/lib/sddm/sddm.conf.d/default.conf"
  content=$(<"$file_path")
    
    # Check if the line containing "Current=" is empty
    if [[ $content == *"Current="* && ! "$content" =~ ^Current=.* ]]; then
        # Replace the line with "Current=mountain"
        sudo sed -i 's/^Current=.*/Current=mountain/' "$file_path"
    fi
}


read -p "Set up SDDM configuration (y/n): " yn

case $yn in 
	y ) sddm_setup;;
	n ) echo exiting...;;
	* ) echo invalid response;;
esac

