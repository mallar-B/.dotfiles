#!/bin/bash

terminal_setup(){
  # create Github directory if it does not exitst
  mkdir -p ~/GitHub/
  #setup chris titus bash terminal
  git clone https://github.com/christitustech/mybash ~/GitHub/mybash
  cd ~/GitHub/mybash
  ./setup.sh
  # add gruvbox theme 
  rm $userConfDir/starship.toml
  ln -s $currDir/.config/starship.toml $userConfDir/starship.toml
cd
}


  read -p "Set up terminal configuration (y/n): " yn

case $yn in 
	y ) terminal_setup;;
	n ) echo exiting...;;
	* ) echo invalid response;;
esac
