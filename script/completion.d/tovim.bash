#!/usr/bin/env bash
# tovim.bash
#
# Maintainer:   Beomjoon Goh
# Last Change:  21 Feb 2020 15:46:20 +0900

function _tovim_complete() {
  local curr prev
  COMPREPLY=()
  curr=${COMP_WORDS[COMP_CWORD]}
  prev=${COMP_WORDS[COMP_CWORD - 1]}
  if [ "${COMP_CWORD}" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "cd help make set vs sp" -- "$curr") )
  elif [ "${COMP_CWORD}" -eq 2 ]; then
    local IFS=$'\n'
    case "${prev}" in
      cd)
        _cd
        COMPREPLY=( $(compgen -W '${COMPREPLY[@]}' -- "$curr") )
        ;;
      vs|sp)
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
  return 0
}

complete -F _tovim_complete tovim
