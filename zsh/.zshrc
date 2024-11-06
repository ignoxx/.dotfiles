export ZSH="$HOME/.oh-my-zsh"

ZVM_CURSOR_STYLE_ENABLED=false
ZVM_INIT_MODE=sourcing
DISABLE_AUTO_UPDATE=true
HISTSIZE=10000
SAVEHIST=10000
zstyle ':omz:update' mode disabled  # disable automatic updates

ZSH_THEME="robbyrussell"
plugins=(z fzf zsh-vi-mode)

# Load brew autocompletions
if type brew &>/dev/null
then
  export FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

source $ZSH/oh-my-zsh.sh

export VISUAL=nvim
export EDITOR=nvim

# bins
GOBIN=$HOME/go/bin/
BUNBIN=$HOME/.bun/bin
SSTBIN=$HOME/.sst/bin
export PATH=$GOBIN:$BUNBIN:$SSTBIN:$PATH
export PATH=/usr/local/bin/:$HOME/.local/bin/:$PATH

# alias
alias vim='nvim'
alias vi='nvim'
alias gs='git status'
alias gc='git checkout $(git branch | fzf)'

# keybindings
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search
bindkey -s ^s "~/tmux-sessionizer\n"

if [ -f "$HOME/.env" ]; then
    source "$HOME/.env"
fi

