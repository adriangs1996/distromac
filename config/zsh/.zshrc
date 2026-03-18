export DISTROMAC_PATH="${DISTROMAC_PATH:-$HOME/.distromac}"
export PATH="$DISTROMAC_PATH/bin:$PATH"

export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH
eval "$(starship init zsh)"
export ZSH="$HOME/.oh-my-zsh"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
plugins+=(zsh-vi-mode)

source $ZSH/oh-my-zsh.sh
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

alias vim=nvim

alias ls="lsd"

[[ -f "$HOME/.config/distromac/current/theme/zsh-theme.zsh" ]] && source "$HOME/.config/distromac/current/theme/zsh-theme.zsh"
