# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
zinit ice depth=1; zinit light romkatv/powerlevel10k

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

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Keybinds -> vim
bindkey -v
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

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

# Aliases
alias ls='ls -CF --color'
alias poweroff='systemctl poweroff'
alias reboot='systemctl reboot'
# alias suspend='i3lock && systemctl suspend'
# alias i3lock=~/.local/bin/i3_lock.sh
alias ll='ls -l';
alias cp='cp -r';
alias cd='z';

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
