WORKDIR=/srv/workspace
export PATH=~/bin:$PATH

# vi mode is cool
set -o vi

# checkwinsize makes resizing windows work
shopt -s checkwinsize

# global aliases
alias ll='ls -la'
alias cw="cd $WORKDIR"
alias gba="git branch -a"
alias gca="git commit -a -m"
alias vi='vim'

# strip ansi escape sequences from an input stream
alias stresc='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g"'

if [ -x /usr/bin/vim ]; then
  alias vi='vim'
fi

# RVM if RVM exists
[[ -s "$HOME/.rvm/scripts/rvm" ]] && . "$HOME/.rvm/scripts/rvm" 

# rbenv if rbenv exists
[[ -d ~/.rbenv ]] && export PATH="$HOME/.rbenv/bin:$PATH"; eval "$(rbenv init -)"

# ssh management
if [ -f ~/.keychain/${HOSTNAME}-sh  ]; then
  source ~/.keychain/${HOSTNAME}-sh
fi
unset SSH_ASKPASS

if [ -f ~/.git-prompt.sh ]; then
  source ~/.git-prompt.sh
fi

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
  && type -P dircolors >/dev/null \
  && match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

__repo () {
  branch=$(type __git_ps1 &>/dev/null && __git_ps1 | sed -e "s/^ (//" -e "s/)$//")
  if [ "$branch" != "" ]; then
        vcs=git
  else
    branch=$(type -P hg &>/dev/null && hg branch 2>/dev/null)
    if [ "$branch" != "" ]; then
      vcs=hg
    elif [ -e .bzr ]; then
      vcs=bzr
    elif [ -e .svn ]; then
      vcs=svn
    else
      vcs=
    fi
  fi
  if [ "$vcs" != "" ]; then
    if [ "$branch" != "" ]; then
      repo=$vcs:$branch
    else
      repo=$vcs
    fi
    echo -n "($repo)"
  fi
  return 0
}

if ${use_color} ; then
  # Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
  if type -P dircolors >/dev/null ; then
    if [[ -f ~/.dir_colors ]] ; then
      eval $(dircolors -b ~/.dir_colors)
    elif [[ -f /etc/DIR_COLORS ]] ; then
      eval $(dircolors -b /etc/DIR_COLORS)
    fi
  fi

  PS1='\[\e[01;32m\]\u@\H\[\e[00m\]:\[\e[01;34m\]\w\[\e[33m\]$(__repo)\[\e[00m\]\$ '

  alias ls='ls --color=auto'
  alias grep='grep --colour=auto'
else
  PS1='\u@\h:\w$(__repo)\$ '
fi
