#!/bin/bash

function git-stat {
  for dir in */; do
    echo "$dir"
    cd "$dir"
    git status --porcelain
    cd ../
  done
}

git-stat
