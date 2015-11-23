#######################################################################
# OS
if [ "$(uname)" == 'Darwin' ]; then
  OS='Mac'
elif [ "$(expr substr $(uname -s) 1 5)" == 'Linux' ]; then
  OS='Linux'
else
  OS='Unknown'
fi

which plenv > /dev/null 2>&1
PLENV_BOOL=$?
which rbenv > /dev/null 2>&1
RBENV_BOOL=$?
which peco > /dev/null 2>&1
PECO_BOOL=$?

# Unknownだったら何もしない
if [ $OS == 'Unknown' ]; then
  echo "unknown" >> /dev/null
  # Unknown以外用
else
  #######################################################################
  # set var
  export PATH="/usr/local/bin:$HOME/bin:/usr/bin:/bin:/usr/sbin:/sbin"
  export PATH="$HOME/.plenv/bin:$PATH"
  export PATH="$HOME/.rbenv/bin:$PATH"
  if [ $PLENV_BOOL -eq 0 ]; then
    eval "$(plenv init -)"
  fi
  if [ $RBENV_BOOL -eq 0 ]; then
    eval "$(rbenv init -)"
  fi
  #export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"
  #export PS1='\[\e[1;32m\][\u]\[\e[00m\]-\[\e[1;36m\]\W\[\e[00m\] > '
  WORKING_DIRECTORY='\[\e[$[COLUMNS-$(echo -n " ($(date +%H:%M:%S)" | wc -c)]C\e[1;31m($(date +%H:%M:%S))\e[0m\e[$[COLUMNS]D\]'
  export PS1=${WORKING_DIRECTORY}'\[\e[1;32m\]\u\[\e[00m\] \[\e[1;36m\][\W]\[\e[00m\]-> '
  export TERM="xterm-256color"
  export EDIOTR=vim

  ######################################################################
  # aliases
  if [ $OS == "Linux" ]; then
    alias ls='ls --color=auto'
  elif [ $OS == "Mac" ]; then
    alias ls='ls -G'
  fi
  alias ll='ls -la'
  alias grep='grep --color=auto'
  alias egrep='egrep --color=auto'
  alias cdp='peco-cd'

  ######################################################################
  ## settings for peco
  if [ $PECO_BOOL -eq 0 ]; then
    if [ $OS == "Linux" ]; then
    # For Linux?
      peco-select-history() {
      declare l=$(HISTTIMEFORMAT= history | sort -k1,1nr | perl -ne 'BEGIN { my @lines = (); } s/^\s*\d+\s*//; $in=$_; if (!(grep {$in eq $_} @lines)) { push(@lines, $in); print $in; }' | peco --query "$READLINE_LINE")
      READLINE_LINE="$l"
      READLINE_POINT=${#l}
      }
      bind -x '"\C-r": peco-select-history'
    elif [ $OS == "Mac" ];then
    # For Mac
      export HISTCONTROL="ignoredups"
      peco-history() {
      local NUM=$(history | wc -l)
      local FIRST=$((-1*(NUM-1)))

      if [ $FIRST -eq 0 ] ; then
        # Remove the last entry, "peco-history"
        history -d $((HISTCMD-1))
        echo "No history" >&2
        return
      fi

      local CMD=$(fc -l $FIRST | sort -k 2 -k 1nr | uniq -f 1 | sort -nr | sed -E 's/^[0-9]+[[:blank:]]+//' | peco | head -n 1)

      if [ -n "$CMD" ] ; then
        # Replace the last entry, "peco-history", with $CMD
        history -s $CMD

        if type osascript > /dev/null 2>&1 ; then
          # Send UP keystroke to console
          (osascript -e 'tell application "System Events" to keystroke (ASCII character 30)' &)
        fi

        # Uncomment below to execute it here directly
        # echo $CMD >&2
        # eval $CMD
      else
        # Remove the last entry, "peco-history"
        history -d $((HISTCMD-1))
      fi
      }
      bind -x '"\C-r": peco-history'
    fi
  fi
fi
