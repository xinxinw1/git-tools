#!/bin/bash

function run {
  local d="${PWD##*/}"   # original directory
  # b = current branch
  local b="$(git rev-parse --abbrev-ref HEAD)"
  
  local cur=
  local sta=
  local out="/srv/http/git-preview/$d"
  local arr=()
  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    
    case $key in
      -c|--current)
        cur="true"
      ;;
      -s|--stable)
        sta="true"
      ;;
      -o|--output)
        if [ -z "$1" ]; then
          echo "Warning: empty output param; sending to /dev/null" 1>&2
          out="/dev/null"
        else
          out="$(realpath -m "$1")"
        fi
        shift
      ;;
      -d|--debug)
        debug="true"
      ;;
      -*)
        echo "Warning: unknown option $key" 1>&2
      ;;
      *)
        arr+=("$1")
      ;;
    esac
  done
  
  local bran="${arr[1]}"
  [ -z "$bran" ] && bran="$b"
  
  if [ "$debug" == "true" ]; then
    echo "Output is $out"
    echo "Branch is $bran"
  fi
  
  # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
  if git show-ref --verify --quiet "refs/heads/$bran"; then
    if [ "$out" != "/dev/null" ]; then
      rm -rf "$out" 2>/dev/null
      mkdir "$out"
      
      if [ "$bran" == "$b" ]; then
        [ "$debug" == "true" ] && echo "Running current branch"
        cp -r * "$out"
      else
        [ "$debug" == "true" ] && echo "Running non-current branch"
        git archive "$bran" | tar -xC "$out"
      fi
      
      local dflag=""
      [ "$debug" == "true" ] && dflag="-d"
      
      if [ "$cur" != "true" ]; then
        if [ "$sta" == "true" ]; then
          git deps -f "$out/deps" -o "$out" $dflag
        else
          git deps -l -f "$out/deps" -o "$out" $dflag
        fi
      fi
    fi
  else
    echo "Error: no branch $bran" >&2
  fi
}

run "$@"
