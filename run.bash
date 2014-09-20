#!/bin/bash

function run {
  local d="${PWD##*/}"   # original directory
  # b = current branch
  local b="$(git rev-parse --abbrev-ref HEAD)"
  
  local upd=
  local lat=
  local sta=
  local out="/srv/http/git-preview/$d"
  local arr=()
  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    
    case $key in
      -u|--update)
        upd="true"
      ;;
      -l|--latest)
        lat="true"
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
        arr+=("$key")
      ;;
    esac
  done
  
  [ "$debug" == "true" ] && echo "${arr[@]}"
  
  local bran="${arr[0]}"
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
      
      local dflag=""
      [ "$debug" == "true" ] && dflag="-d"
      
      if [ "$bran" == "$b" ]; then
        [ "$debug" == "true" ] && echo "Running current branch"
        [ "$upd" == "true" ] && git deps $dflag
        cp -r * "$out"
      else
        [ "$debug" == "true" ] && echo "Running non-current branch"
        git archive "$bran" | tar -xC "$out"
      fi
      
      if [ "$sta" == "true" ]; then
        git deps -f "$out/deps" -o "$out" $dflag
      elif [ "$lat" == "true" ]; then
        git deps -l -f "$out/deps" -o "$out" $dflag
      fi
    fi
  else
    echo "Error: no branch $bran" >&2
  fi
}

run "$@"
