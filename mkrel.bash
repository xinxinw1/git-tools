#!/bin/bash

function mkrel {
  git alias rel '!'"f(){ if [ -n \"\$1\" ]; then git ver \$1; git push --tags origin $1; else git push origin $1; fi; }; f"
}

mkrel "$1"
