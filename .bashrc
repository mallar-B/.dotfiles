#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias ll='ls -Al'
alias la='ls -A'
alias grep='grep --color=auto'
alias cp='cp -i'
alias cpf='cp -rf'
alias mv='mv -i'
alias mvf='mv -f'
alias mkdir='mkdir -p'
alias cd..='cd ..'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias .....='cd ../../../..'

if [[ $- == *i* ]]; then
  # Bind Ctrl+f to insert 'zi' followed by a newline
  bind '"\C-f":"zi\n"'
fi

PS1='[\u@\h \W]\$ '

alias install='~/test.sh'
export PATH="$HOME/.local/bin:$PATH"

eval "$(starship init bash)"

# apply pywal theme
cat ~/.cache/wal/sequences

eval "$(zoxide init bash)"
alias cd='z'
