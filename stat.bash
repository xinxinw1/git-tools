#!/bin/bash

function git-stat {
  local orig="$PWD"   # original directory
  
  local base="$1"
  [ -z "$base" ] && base="/home/secret2008/Documents/Program/git"
  
  cd "$base"
  if [ "$(echo */)" != "*/" ]; then
    for dir in */; do
      cd "$dir"
      local str="$(git status --porcelain 2>&1)"
      if [ -n "$str" ]; then
        echo "$dir"
        git status --porcelain
      fi
      cd ../
    done
  else
    local str="$(git status --porcelain 2>&1)"
    if [ -n "$str" ]; then
      echo "./"
      git status --porcelain
    fi
  fi
  
  cd "$orig"
}

git-stat "$@"
