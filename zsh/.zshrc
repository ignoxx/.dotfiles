PROMPT='%(?:%{[01;32m%}%1{➜%} :%{[01;31m%}%1{➜%} ) %{[36m%}%c%{[00m%} '

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt incappendhistory
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups
setopt autocd
unsetopt hist_verify

# unsetopt menucomplete
unsetopt flowcontrol
setopt auto_menu
setopt complete_in_word
setopt always_to_end
setopt auto_pushd
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'


# Speed up completion init, see: https://gist.github.com/ctechols/ca1035271ad134841284
autoload -Uz compinit
for dump in ~/.zcompdump(N.mh+24); do
  compinit
done
compinit -C

# Load brew autocompletions
if type brew &>/dev/null
then
  FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
  source <(fzf --zsh)
fi

export VISUAL=nvim
export EDITOR=nvim
export TERM=xterm-ghostty
export NODE_COMPILE_CACHE=~/.cache/nodejs-compile-cache

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
bindkey -v
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
bindkey "^P" up-line-or-search
bindkey "^N" down-line-or-search
bindkey -s ^s "~/tmux-sessionizer\n"

# Make up/down arrow put the cursor at the end of the line
# instead of using the vi-mode mappings for these keys
bindkey "\eOA" up-line-or-history
bindkey "\eOB" down-line-or-history
bindkey "\eOC" forward-char
bindkey "\eOD" backward-char

# # CTRL-R to search through history
# bindkey '^R' history-incremental-search-backward
# # Accept the presented search result
# bindkey '^Y' accept-search

# Some emacs keybindings won't hurt nobody
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Use the arrow keys to search forward/backward through the history,
# using the first word of what's typed in as search word
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward

# Use the same keys as bash for history forward/backward: Ctrl+N/Ctrl+P
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

if [ -f "$HOME/.env" ]; then
    source "$HOME/.env"
fi

