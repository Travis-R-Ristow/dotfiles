#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias cls='clear'
alias brave='brave &'

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

__get_path() {
  if [[ $PWD == "$HOME" ]]; then
    echo -e "$(color orange "~")"
  elif [[ $PWD == "$HOME/"* ]]; then
    echo -e "$(color orange "~${PWD#$HOME}")"
  else
    echo -e "$(color orange "$PWD")"
  fi
}

__get_git() {
  local testStr=""
  if git rev-parse --is-inside-work-tree --quiet >/dev/null 2>&1; then
    testStr+=" $(color pink "-") "
    local branchName=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if [[ -n $(git log @{u}..HEAD) ]]; then
      testStr+="$(color yellow "$branchName")"
    else
      testStr+="$(color green "$branchName")"
    fi
    echo -e "$testStr"
  fi
}

PS1='$(__get_git) \[\e[1m$(color pink "-")\[\e[0m\] $(__get_path) \[\e[1m$(color pink "-")\[\e[0m\] \[\e[1m$(color pink "\]$") \[\e[0m\]'

###         ###
### HELPERS ###
###         ###

# ~ $1 Color ~ $2 Text ~ #
  color() {
    local text="$2"
    local colr=""
    case "$1" in
      "green")
        colr="38;5;41"
        ;;
      "orange")
        colr="38;5;208"
        ;;
      "pink")
        colr="38;5;204"
        ;;
      "yellow")
        colr="38;5;227"
        ;;
      *)
        colr=""
        ;;
    esac
    echo -e "\e[${colr}m${text}\e[0m"
  }
