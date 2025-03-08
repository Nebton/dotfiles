alias ls='ls -a --color=auto'
alias ll='ls -al --color=auto'
alias grep='grep --color=auto'
alias svim='sudo -E nvim'
alias config='/usr/bin/git --git-dir=/home/aelbarro/dotfiles/.git --work-tree=/home/aelbarro/dotfiles'
alias ga='git add .'
alias gs='git status'
alias gmc='git commit -m'
alias gpsh='git push'
alias nv='nvim .'
fpath=($DOTFILES/zsh/ $fpath)
autoload -Uz prompt_purification_setup && prompt_purification_setup
autoload -Uz cursor; cursor
autoload -Uz compinit; compinit
_comp_options+=(globdots) # With hidden files
source $DOTFILES/zsh/completion.zsh
setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.
setopt SHARE_HISTORY
setopt APPEND_HISTORY
# Add Python binaries to PATH
PATH=$PATH:/home/aelbarro/.local/bin/
# Add Go binaries to PATH
#
PATH=$PATH:/home/aelbarro/.local/squashfs-root/usr/bin   # Neovim
PATH=$PATH:/home/aelbarro/.config/local/share/nvim/mason/bin # Neovim Mason Binaries
PATH=$PATH:/home/aelbarro/go/bin
alias d='dirs -v'
for index ({1..9}) alias "$index"="cd +${index}"; unset index


# Delete character forward
bindkey '^[[3~' delete-char

# Delete character backward (typically done with Ctrl+H in Bash)
bindkey '^H' backward-delete-char

# Move cursor forward and backward
bindkey '^[[C' forward-char
bindkey '^[[D' backward-char

# Move cursor to beginning and end of line
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Kill to end of line (Ctrl+K)
bindkey '^K' kill-line

# Kill to beginning of line (Ctrl+U)
bindkey '^U' unix-line-discard

# Yank (paste) (Ctrl+Y)
bindkey '^Y' yank

# Accept line (Enter)
bindkey '^M' accept-line

# Effective History Search
bindkey ^R history-incremental-search-backward



autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/bin/vault vault


