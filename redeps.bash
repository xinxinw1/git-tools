#!/bin/bash

function redeps {
  # http://stackoverflow.com/questions/5724513/in-git-how-do-i-figure-out-what-my-current-revision-is
  local b="$(git rev-parse HEAD)"
  local bran="$1"
  
  # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
  if git show-ref --verify --quiet "refs/heads/$bran"; then
    git checkout "$bran"
    git deps -c
    git push origin "$bran"
    git checkout "$b"
  else
    echo "Error: no branch $bran" >&2
  fi
}

redeps "$@"
