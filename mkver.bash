#!/bin/bash

function mkver {
  local s='!'"f(){ git tag -a \$1 -m \"$@ \$1\"; }; f"
  git config alias.ver "$s"
}

mkver "$@"
