#!/bin/bash

function redeps {
  local b="$(git rev-parse --abbrev-ref HEAD)"
  # if in detached head, get current revision
  # http://stackoverflow.com/questions/5724513/in-git-how-do-i-figure-out-what-my-current-revision-is
  [ "$b" == "HEAD" ] && b="$(git rev-parse HEAD)"
  local bran="$1"
  [ -z "$bran" ] && bran="$b"
  
  # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
  if git show-ref --verify --quiet "refs/heads/$bran"; then
    if [ "$bran" == "$b" ]; then
      git deps -c
      #git push origin "$bran"
    else
      git checkout "$bran" || exit 1
      git deps -c
      #git push origin "$bran"
      git checkout "$b"
    fi
  else
    echo "Error: no branch $bran" >&2
  fi
}

redeps "$@"
