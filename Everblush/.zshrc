# Directory for all plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Clone zinit if it does not exists
if [[ ! -d "$ZINIT_HOME" ]]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Prompt -> Powerlevel10k
# zinit ice depth=1; zinit light romkatv/powerlevel10k

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit light Aloxaf/fzf-tab

# Snippets
zinit snippet OMZP::git

# styles
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-Z}' # case insensitive search
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath' # currently not working

# Load completions
autoload -U compinit && compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION
zinit cdreplay -q

# prompt initialization
eval "$(oh-my-posh init zsh --config $HOME/.config/ohmyposh/config.toml)"

# Keybinds -> vim
bindkey -v
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^y' autosuggest-accept

# History
HISTSIZE=4000
HISTFILE="${HOME}/.zsh_history"
SAVEHIST="$HISTSIZE"
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# List Aliases
alias ls='ls -CF --color'
alias la='ls -Ah'
alias ll='ls -Al';
alias lx='ls -lXBh' # sort by extension
alias lr='ls -lRh' # recursive ls
alias lf="ls -l | egrep -v '^d'" # files only
alias lz="ls -lSh"
alias lt="ls -t"
alias llt="ls -lt"
alias ldir="ls -l | egrep '^d'" # directories only

# Quality of life Alises
alias poweroff='systemctl poweroff'
alias reboot='systemctl reboot'
alias cd='z';
alias cp='cp -i'
alias cpr='cp -ir'
alias mv='mv -i'
# alias rm='trash -v'
rm () {
  command trash -v "$@" ## autocomplete support
}
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

yay() {
  if [[ "$1" == "-S" && -n "$2" ]]; then
    command yay "$@"
    for pkg in "${@:2}"; do
      grep -qxF "$pkg" ~/.config/pkg.txt || echo "$pkg" >>~/.config/pkg.txt
    done
  elif [[ "$1" =~ ^-R(ns)?$ && -n "$2" ]]; then
    command yay "$@"
    for pkg in "${@:2}"; do
      sed -i "s/^$pkgs$/#$pkg/" ~/.config/pkg.txt
    done
  else
    command yay "$@"
  fi
}

# Shell integrations
## fzf
# source <(fzf --zsh) ## for fzf 0.48 and later
if [ -n "${commands[fzf-share]}" ]; then
  source "$(fzf-share)/key-bindings.zsh"
  source "$(fzf-share)/completion.zsh"
fi
## zoxide
# eval "$(zoxide init --cmd cd zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

eval "$(zoxide init zsh)"
export PATH="$PATH:/home/mallar/.local/bin"
# source /usr/share/nvm/init-nvm.sh
export GTK_THEME=Everblush
export PATH="$HOME/.cargo/bin:$PATH"
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export JAVA_HOME=$HOME/Android/Custom_JDKs/ms-17.0.15/
export QML2_IMPORT_PATH="/usr/lib/qt6/qml/"
