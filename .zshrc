# vim bindings
bindkey -v

# make sure delete key deletes
bindkey "^[[3~" delete-char

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=$HISTSIZE

setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between sessions
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.

# Key bindings, up/down arrow searches through history
bindkey "$terminfo[kcuu1]" history-beginning-search-backward
bindkey "$terminfo[kcud1]" history-beginning-search-forward

autoload -Uz up-line-or-beginning-search
autoload -Uz down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# bindkey "^[[A" history-beginning-search-backward
# bindkey "^[[B" history-beginning-search-forward

# Find and set branch name var if in git repository.
function git_branch_name()
{
  branch=$(git symbolic-ref HEAD 2> /dev/null | awk 'BEGIN{FS="/"} {print $NF}')
  if [[ $branch == "" ]];
  then
    :
  else
    echo '(%{%F{117}%}%25>…>'$branch'%>>%{%f%}%{%F{75}%})'
  fi
}

# Enable substitution in the prompt.
setopt prompt_subst


# prompt
export PS1=$'\uea9f %{%F{75}%}%1~$(git_branch_name) %{%f%}'

# nvim
export PATH="$PATH:/opt/nvim-linux-x86_64/bin"

# nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
