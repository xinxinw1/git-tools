#!/bin/bash

function git-rstat {
  local orig="$PWD"   # original directory
  
  local base="$1"
  [ -z "$base" ] && base="/srv/git"
  
  cd "$base"
  if [ "$(echo */)" != "*/" ]; then
    for dir in */; do
      cd "$dir"
      local str="$(git status -b --porcelain | head -n 1 | cut -d' ' -f 3- 2>&1)"
      if [ -n "$str" ]; then
        echo "$dir"
        git status -b --porcelain | head -n 1
      fi
      cd ../
    done
  else
    local str="$(git status -b --porcelain | head -n 1 | cut -d' ' -f 3- 2>&1)"
    if [ -n "$str" ]; then
      echo "./"
      git status -b --porcelain | head -n 1
    fi
  fi
  
  cd "$orig"
}

git-rstat "$@"
