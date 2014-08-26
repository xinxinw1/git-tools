#!/bin/bash

function run {
  local bran="$1"
  [ -z "$1" ] && bran="gh-pages"
  
  # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
  if git show-ref --verify --quiet "refs/heads/$bran"; then
    rm -r /srv/http/git-preview/* 2>/dev/null
    
    local b="$(git rev-parse --abbrev-ref HEAD)"
    if [ "$b" == "$bran" ]; then
      cp -r * /srv/http/git-preview
    else
      git archive "$bran" | tar -xC /srv/http/git-preview
    fi
    
    git deps -l -f /srv/http/git-preview/deps -o /srv/http/git-preview
  else
    echo "Error: no branch $bran" >&2
  fi
}

run "$@"
