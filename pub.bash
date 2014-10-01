#!/bin/bash

function pub {
  local d="${PWD##*/}"   # original directory
  # b = current branch
  local b="$(git rev-parse --abbrev-ref HEAD)"
  
  local debug=
  local out="/srv/http/codes/$d"
  local arr=()
  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    
    case $key in
      -o|--output)
        if [ -z "$1" ]; then
          echo "Warning: empty output param; sending to /dev/null" 1>&2
          out="/dev/null"
        else
          out="$(realpath -m "$1")"
        fi
        shift
      ;;
      -d|--debug)
        debug="true"
      ;;
      -*)
        echo "Warning: unknown option $key" 1>&2
      ;;
      *)
        arr+=("$key")
      ;;
    esac
  done
  
  [ "$debug" == "true" ] && echo "${arr[@]}"
  
  local bran="${arr[0]}"
  [ -z "$bran" ] && bran="$b"
  
  if [ "$debug" == "true" ]; then
    echo "Output is $out"
    echo "Branch is $bran"
  fi
  
  # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
  if git show-ref --verify --quiet "refs/heads/$bran"; then
    if [ "$out" != "/dev/null" ]; then
      if [ -d "$out" ]; then
        while true; do
          read -p "Output dir $out exists? Delete and replace it? [Yn]" yn
          case $yn in
            [Yy]* | "")
              rm -rf "$out" 2>/dev/null
              break
            ;;
            [Nn]*)
              exit
            ;;
            *)
              echo "Unknown answer."
            ;;
          esac
        done
      fi
      mkdir "$out"
      
      local dflag=""
      [ "$debug" == "true" ] && dflag="-d"
      
      if [ "$bran" == "$b" ]; then
        [ "$debug" == "true" ] && echo "Running current branch"
        find . -mindepth 1 -maxdepth 1 ! -name .git -exec cp -r -t "$out" {} +
      else
        [ "$debug" == "true" ] && echo "Running non-current branch"
        git archive "$bran" | tar -xC "$out"
      fi
    fi
  else
    echo "Error: no branch $bran" >&2
  fi
}

pub "$@"
