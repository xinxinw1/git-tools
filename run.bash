#!/bin/bash

function run {
  rm -r /srv/http/git-preview/* 2>/dev/null
  
  local b="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$b" == "gh-pages" ]; then
    cp -r * /srv/http/git-preview
  else
    git archive gh-pages | tar -xC /srv/http/git-preview
  fi
  
  git deps -l -f /srv/http/git-preview/deps -o /srv/http/git-preview
}

run
