#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd -P )"

git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

workingDirectory() {
  repo_name=$(basename "$(git rev-parse --show-toplevel 2> /dev/null)")
  [ -z $repo_name ] && repo_name='\w' || repo_name="($repo_name)"
  echo "${repo_name@P}"
}

function get_ps1() {
  local CUSTOM_PS1='\[\033]0;$PWD `git_branch`\007\]\[\r\033'
  CUSTOM_PS1+='[32m\]\u@\h '
  CUSTOM_PS1+='\[\033[33m\]'
  CUSTOM_PS1+='$(workingDirectory)'
  CUSTOM_PS1+='\[\033[36m\]'
  CUSTOM_PS1+='$(git_branch)'
  CUSTOM_PS1+='\[\033[0m\]$ '

  echo "$CUSTOM_PS1"
}

export PS1='\[\033]0;$PWD `git_branch`\007\]\[\r\033[32m\]\u@\h:\[\033[33m\]\w\[\033[36m\]`git_branch`\[\033[0m\]$ '
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