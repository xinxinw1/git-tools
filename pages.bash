#!/bin/bash

function pages {
  git checkout gh-pages
  git deps -c
  git push origin gh-pages
  git checkout master
}

pages "$@"
