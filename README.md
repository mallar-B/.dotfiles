# Most minimal [ags](https://aylur.github.io/ags-docs/) setup for pc (Hyprland)
## Dependencies
  - hypridle
  - hyprlock
  - bluez (optional)
  - networkmanager

## Installation
  - follow the instructions [here](https://aylur.github.io/ags-docs/config/installation/)

  - `git clone https://github.com/mallar-B/ags_personal.git`

  - `cp ./ags_personal/. ~/.config/ags`

*NOTE: To get the blur effects add the configuration of `variable.conf` and `rules.conf` from `./ags_personal/hypr/hyprland` to your `~/.config/hypr/hyprland.conf`*

## App Launcher
  To use the applauncher you have to bind it to you hyprland config. e.g.-
  > `bind = ALT, SPACE, exec, ags -t applauncher`

  *I could not figure out the right syntax to put the keybind in ags config. If you can help, let me know.*

## TODOs

  - [x] power menu
    - [x] enhancements 
  - [x] applauncher
    - [X] enhancements   
  - [X] quick tools
    - [X] idle inhibitor
    - [X] wallpaper change
    - [x] resource usage
    - [ ] dnd
  - [ ] notification center
  - [X] notification bug fix
  - [X] volume indicator

## Screenshots

![screenshot 1](https://github.com/mallar-B/ags_personal/blob/main/.Screenshots/2024-04-25-151357_hyprshot.png)
![screenshot 2](https://github.com/mallar-B/ags_personal/blob/main/.Screenshots/powermenu.png)
