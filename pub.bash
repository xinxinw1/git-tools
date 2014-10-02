#!/bin/bash

function pub {
  local orig="$PWD"
  local d="${PWD##*/}"   # original directory
  # b = current branch
  local b="$(git rev-parse --abbrev-ref HEAD)"
  
  local nomet=
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
      -n|--no-meta)
        nomet="true"
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
  
  local bran="${arr[0]}"
  [ -z "$bran" ] && bran="$b"
  
  if [ "$debug" == "true" ]; then
    echo "Output is $out"
    echo "Treeish is $bran"
  fi
  
  # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
  # if git show-ref --verify --quiet "refs/heads/$bran"; then
  if git ls-tree "$bran" 1>/dev/null 2>&1; then
    if [ "$out" != "/dev/null" ]; then
      if [ -d "$out" ]; then
        while true; do
          read -p "Output dir $out exists? Delete and replace it? [Yn] " yn
          case $yn in
            [Yy]* | "")
              rm -rf "$out"
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
      
      if [ -z "$nomet" ]; then
        echo "$(date)" >> "$out/pub"
        echo "Source is $orig" >> "$out/pub"
        echo "Output is $out" >> "$out/pub"
        echo "Treeish is $bran" >> "$out/pub"
      fi
      
      if [ "$bran" == "$b" ]; then
        [ "$debug" == "true" ] && echo "Publishing current branch"
        [ -z "$nomet" ] && echo "Publishing current branch" >> "$out/pub"
        find . -mindepth 1 -maxdepth 1 ! -name .git -exec cp -r -t "$out" {} +
      else
        [ "$debug" == "true" ] && echo "Publishing non-current branch"
        [ -z "$nomet" ] && echo "Publishing non-current branch" >> "$out/pub"
        git archive "$bran" | tar -xC "$out"
      fi
      
    fi
  else
    echo "Error: no treeish $bran" >&2
  fi
}

pub "$@"
