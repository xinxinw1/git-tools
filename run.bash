#!/bin/bash

function run {
  local d="${PWD##*/}"   # original directory
  
  local bran="$1"
  [ -z "$1" ] && bran="gh-pages"
  
  # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
  if git show-ref --verify --quiet "refs/heads/$bran"; then
    local dir="/srv/http/git-preview/$d"
    
    rm -r "$dir" 2>/dev/null
    mkdir "$dir"
    
    local b="$(git rev-parse --abbrev-ref HEAD)"
    if [ "$b" == "$bran" ]; then
      cp -r * "$dir"
    else
      git archive "$bran" | tar -xC "$dir"
    fi
    
    git deps -l -f "$dir/deps" -o "$dir"
  else
    echo "Error: no branch $bran" >&2
  fi
}

run "$@"
