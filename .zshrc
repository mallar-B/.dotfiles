# Directory for all plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Clone zinit if it does not exists
if [[ ! -d "$ZINIT_HOME" ]]; then
	mkdir -p "$(dirname $ZINIT_HOME)"
	git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# colors and starship
# source ~/.config/zshrc.d/dots-hyprland.zsh
# eval "$(starship init zsh)"

zle-line-init() {
  emulate -L zsh

  [[ $CONTEXT == start ]] || return 0

  while true; do
    zle .recursive-edit
    local -i ret=$?
    [[ $ret == 0 && $KEYS == $'\4' ]] || break
    [[ -o ignore_eof ]] || exit 0
  done

  local saved_prompt=$PROMPT
  local saved_rprompt=$RPROMPT
  PROMPT='   '
  RPROMPT=''
  zle .reset-prompt
  PROMPT=$saved_prompt
  RPROMPT=$saved_rprompt

  if (( ret )); then
    zle .send-break
  else
    zle .accept-line
  fi
  return ret
}
zle -N zle-line-init

# Prompt -> Powerlevel10k
# zinit ice depth=1; zinit light romkatv/powerlevel10k
#

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

# Find command from history
zmodload zsh/parameter
fuzzy_history_by_prefix() {
  # get prefix typed so far (left of cursor)
  local prefix=$LBUFFER
  local selected

  # if nothing typed, show whole history; otherwise show only lines that start with prefix
  if [[ -z $prefix ]]; then
    # fc -l -n 1 => show history lines without numbers
      selected=$(
	print -rNC1 -- "${history[@]}" |
	fzf --read0 --print0 --height 40% --reverse
      ) || return
  else
    # pre-filter history to lines that start with prefix, newest first
    # fc -l -n 1 lists full history (oldest->newest); tac reverses so newest appear first
    selected=$(
      for cmd in "${history[@]}"; do
	[[ $cmd == "$prefix"* ]] && print -rn -- "$cmd"$'\0'
      done |
      fzf --read0 \
	--height 40% --reverse \
	--query="$prefix"
    ) || return
  fi

  # if chosen, replace the current buffer with the selected history entry
  BUFFER=$selected
  CURSOR=${#BUFFER}
  zle redisplay
}

zle -N fuzzy_history_by_prefix
# bind to Ctrl-R (change if you prefer another key)
bindkey '^R' fuzzy_history_by_prefix

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

nvid() {
  neovide "$@" > /dev/null 2>&1 &
  disown
  exit
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
export PATH=$PATH:/usr/local/android-studio/bin/
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH="/usr/lib64/qt6/bin:$PATH"
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk/
export QML2_IMPORT_PATH="/usr/lib/qt6/qml/"

# Load pyenv automatically by appending
# the following to
# ~/.zprofile (for login shells)
# and ~/.zshrc (for interactive shells) :

source ~/.zsh_profile

#export PYENV_ROOT="$HOME/.pyenv"
#[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
#eval "$(pyenv init - zsh)"
