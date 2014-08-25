#!/bin/bash

function git-stat {
  for dir in */; do
    cd "$dir"
    local str="$(git status --porcelain 2>&1)"
    if [ -n "$str" ]; then
      echo "$dir"
      git status --porcelain
    fi
    cd ../
  done
}

git-stat
