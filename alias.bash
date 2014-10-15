#!/bin/bash

function galias {
  local opts=
  local arr=()
  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    
    case $key in
      -g|--global)
        opts="$opts --global"
      ;;
      -u|-d|--unset)
        opts="$opts --unset"
      ;;
      *)
        arr+=("$key")
      ;;
    esac
  done
  if [ "${#arr[@]}" == "0" ]; then
    git config $opts --list | grep alias
  else
    git config $opts alias.${arr[0]} "${arr[1]}"
  fi
}

galias "$@"
