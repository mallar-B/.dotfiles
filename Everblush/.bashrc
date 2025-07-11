#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

yay() {
  if [[ "$1" == "-S" && -n "$2" ]]; then
    command yay "$@"
    for pkg in "${@:2}"; do
      grep -qxF "$pkg" ~/pkg.txt || echo "$pkg" >>~/pkg.txt
    done
  elif [[ "$1" =~ ^-R(ns)?$ && -n "$2" ]]; then
    command yay "$@"
    for pkg in "${@:2}"; do
      sed -i "s/^$pkgs$/#$pkg/" ~/pkg.txt
    done
  else
    command yay "$@"
  fi
}

# Quality of life Alises
alias cp='cp -i'
alias cpr='cp -ir'
alias mv='mv -i'
alias rm='trash -v'
alias mkdir='mkdir -p'
alias less='less -R'
alias cls='clear'
alias yayf="yay -Slq | fzf --multi --preview 'yay -Sii {1}' --preview-window=down:75% | xargs -ro yay -S"

# Change directory aliases
alias home='cd ~'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

source /usr/share/nvm/init-nvm.sh
export GTK_THEME=Everblush
export PATH="$HOME/.cargo/bin:$PATH"
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME=$HOME/Android/Custom_JDKs/ms-17.0.15/
