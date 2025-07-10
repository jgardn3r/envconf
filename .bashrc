#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "$( realpath "${BASH_SOURCE[0]}" )" )" && pwd -P )"

source "$SCRIPT_DIR/git-prompt.sh"

function getPS1Command {
  state=$(__fastgit_ps1)
  [ "$state" ] && state=" $state"

  export PS1="\[\033]0;\W\a\]\[\e[32m\]\u@\H:\[\e[33m\]\w\[\e[0m\]\[\033[36m\]${state}\[\033[0m\]\$ "
}

export PROMPT_COMMAND='getPS1Command'

TIMEFORMAT='real: %lR | user: %lU | sys: %lS'

bind '"\t":menu-complete'
bind "set show-all-if-ambiguous on"
bind "set completion-ignore-case on"
bind "set menu-complete-display-prefix on"

export EDITOR=vim

function gcam() {
  eval "git commit -am '$*'"
}

function gcm() {
  eval "git commit -m '$*'"
}

function gl {
  local green=$(printf '\033[32m')
  local s="▕"
  git log --color=always --decorate --date=relative -n 100 "$@" \
    --pretty=format:"%C(yellow)%h$s%Cred%cd$s%Cblue%an$s%Creset%s$s%D" \
    | column --table --separator "$s" --output-separator "$s" \
    | sed -E "s/$s([^$s]+)$/\n    $green└─ \1/" \
    | sed -E "s/$s/ /g" \
    | less -R -S -# 1
}

alias gco='git checkout'
alias gcb='git checkout -b'
alias gc='git commit'
alias gca='git commit -a'
alias gbc='git bundle create'
alias gb='git branch'
alias gf='git fetch'
alias gs='git status'
alias gr='git rebase $(git status | grep "rebase in progress" >/dev/null 2>&1 || echo "--committer-date-is-author-date")'
alias gri='git rebase -i --autosquash --committer-date-is-author-date'
alias grm='gr master'
alias grim='gri master'
alias g='git'
alias ga='git add'
alias gmt='git mergetool'
alias fixup='git commit --fixup'
alias commit='git commit'
alias amend='git commit --amend'
alias noedit='git commit --amend --no-edit'
alias chp='git cherry-pick'

source $SCRIPT_DIR/git-completion.bash

__git_complete gco _git_checkout
__git_complete gcb _git_checkout
__git_complete gr _git_rebase
__git_complete gri _git_rebase
__git_complete gbc _git_bundle_create
__git_complete gb _git_branch
__git_complete gf _git_fetch
__git_complete g _git

# FZF
source $SCRIPT_DIR/completion.bash
source $SCRIPT_DIR/key-bindings-custom.bash
source $SCRIPT_DIR/fzf-custom.bash
