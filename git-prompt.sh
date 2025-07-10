#! /bin/bash
# Shamelessly copied from https://gist.github.com/Ragnoroct/c4c3bf37913afb9469d8fc8cffea5b2f#gistcomment-3560622

# Very very fast __git_ps1 implementation
# 100% pure Bash (no forking) function to determine the name of the current git branch
# Modified from: https://gist.github.com/Ragnoroct/c4c3bf37913afb9469d8fc8cffea5b2f
# Which was inspired by https://gist.github.com/wolever/6525437

# ripped out of the official git-prompt.sh

# Helper function to read the first line of a file into a variable.
# __git_eread requires 2 arguments, the file path and the name of the
# variable, in that order.
__git_eread ()
{
	test -r "$1" && IFS=$'\r\n' read -r "$2" <"$1"
}

function __git_status() {
  local b=$1
  local r=$2
	local w=""
	local i=""
	local s=""
	local u=""

  git diff --no-ext-diff --quiet || w="*"
  git diff --no-ext-diff --cached --quiet || i="+"

  if [ -z "$short_sha" ] && [ -z "$i" ]; then
    i="#"
  fi

  if git rev-parse --verify --quiet refs/stash >/dev/null; then
    s="$"
  fi

  if git ls-files --others --exclude-standard --directory --no-empty-directory --error-unmatch -- ':/*' &>/dev/null; then
    u="%"
  fi

	local f="$w$i$s$u"
  __format "$b" "$f" "$r"
}

function __format() {
  local b=$1
  local f=$2
  local r=$3

	b=${b##refs/heads/}
	local z=" "
  echo "$b${f:+$z$f}$r"
}

function __git_state() {
  local g=$1
	local b=$2
	local r=""
	local step=""
	local total=""
	if [ -d "$g/rebase-merge" ]; then
		__git_eread "$g/rebase-merge/head-name" b
		__git_eread "$g/rebase-merge/msgnum" step
		__git_eread "$g/rebase-merge/end" total
		r="|REBASE"
	else
		if [ -d "$g/rebase-apply" ]; then
			__git_eread "$g/rebase-apply/next" step
			__git_eread "$g/rebase-apply/last" total
			if [ -f "$g/rebase-apply/rebasing" ]; then
				__git_eread "$g/rebase-apply/head-name" b
				r="|REBASE"
			elif [ -f "$g/rebase-apply/applying" ]; then
				r="|AM"
			else
				r="|AM/REBASE"
			fi
		elif [ -f "$g/MERGE_HEAD" ]; then
			r="|MERGING"
		elif __git_sequencer_status; then
			:
		elif [ -f "$g/BISECT_LOG" ]; then
			r="|BISECTING"
		fi
  fi


  if [ -n "$step" ] && [ -n "$total" ]; then
		r="$r $step/$total"
	fi
  echo "$r"
}

function __fastgit_ps1 () {
    local headfile="" head="" branch="" state=""
    local dir="$PWD"
    local gitdir=""

    while [ -n "$dir" ]; do
      gitdir="$dir/.git"

      # handle workspaces
      if [ -f "$gitdir" ]; then
        read -r line < "$gitdir"
        if [[ "$line" =~ gitdir: ]]; then
          gitdir="${line#gitdir: }"
        fi
      fi

      if [ -e "$gitdir/HEAD" ]; then
          headfile="$gitdir/HEAD"
          break
      fi
      dir="${dir%/*}"
    done

    if [ -e "$headfile" ]; then
      read -r head < "$headfile" || return
      case "$head" in
          ref:*) branch="${head##*/}" ;;
          "") branch="" ;;
          *) branch="${head:0:7}" ;;  #Detached head. You can change the format for this too.
      esac
    fi

    if [ -n "$branch" ]; then
      state="$(__git_state "$gitdir" "$branch")"
      state="($(__format "$branch" "" "$state"))"
    fi

		echo "$state"
}