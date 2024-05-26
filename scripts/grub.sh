#!/bin/bash

grub_setup(){
  git clone https://github.com/vinceliuice/grub2-themes
  cd grub2-themes
  ./install.sh
  cd ..
  rm -rf grub2-themes
}


read -p "Set up GRUB2 configuration (y/n): " yn

case $yn in 
	y ) grub_setup;;
	n ) echo exiting...;;
	* ) echo invalid response;;
esac
