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
source /usr/share/nvm/init-nvm.sh
export GTK_THEME=Everblush
export PATH="$HOME/.cargo/bin:$PATH"
