#!/usr/bin/env bash
# tovim.bash
#
# Maintainer:   Beomjoon Goh
# Last Change:  28 Apr 2021 17:14:31 +0900

function _tovim_exist_function() {
  declare -F "$1" > /dev/null
}

function _tovim_complete() {
  local curr prev
  COMPREPLY=()
  curr=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD - 1]}
  if [ "${COMP_CWORD}" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "cd help make set sp tab vs" -- "$curr") )
  elif [ "${COMP_CWORD}" -eq 2 ]; then
    if _tovim_exist_function _cd && _tovim_exist_function _filedir_xspec && _tovim_exist_function _make; then
      local IFS=$'\n'
      case "${prev}" in
        cd)
          _cd
          COMPREPLY=( $(compgen -W '${COMPREPLY[@]}' -- "$curr") )
          ;;
        vs|sp|tab)
          _filedir_xspec
          COMPREPLY=( $(compgen -W '${COMPREPLY[@]}' -- "$curr") )
          ;;
        make)
          _make
          COMPREPLY=( $(compgen -W '${COMPREPLY[@]}' -- "$curr") )
          ;;
        *)
          ;;
      esac
    fi
  fi
  return 0
}


complete -o default -F _tovim_complete tovim
