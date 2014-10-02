#!/bin/bash

function run {
  local orig="$PWD"
  local d="${PWD##*/}"   # original directory
  # b = current branch
  local b="$(git rev-parse --abbrev-ref HEAD)"
  
  local cur=
  local nomet=
  local debug=
  local out="/srv/http/git-preview/$d"
  local arr=()
  while [[ $# > 0 ]]; do
    local key="$1"
    shift
    
    case $key in
      -c|--current)
        cur="true"
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
      -n|--no-meta)
        nomet="true"
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
  
  local bran="${arr[0]}"
  [ -z "$bran" ] && bran="$b"
  
  if [ "$debug" == "true" ]; then
    echo "Output is $out"
    echo "Treeish is $bran"
  fi
  
  # http://stackoverflow.com/questions/5167957/is-there-a-better-way-to-find-out-if-a-local-git-branch-exists
  # if git show-ref --verify --quiet "refs/heads/$bran"; then
  if git ls-tree "$bran" 1>/dev/null 2>&1; then
    if [ "$out" != "/dev/null" ]; then
      [ -d "$out" ] && rm -rf "$out"
      mkdir "$out"
      
      local dflag=""
      [ "$debug" == "true" ] && dflag="-d"
      
      if [ -z "$nomet" ]; then
        echo "$(date)" >> "$out/run"
        echo "Source is $orig" >> "$out/run"
        echo "Output is $out" >> "$out/run"
        echo "Treeish is $bran" >> "$out/run"
      fi
      
      if [ "$bran" == "$b" ]; then
        [ "$debug" == "true" ] && echo "Running current branch"
        [ -z "$nomet" ] && echo "Running current branch" >> "$out/run"
        find . -mindepth 1 -maxdepth 1 ! -name .git -exec cp -r -t "$out" {} +
      else
        [ "$debug" == "true" ] && echo "Running non-current branch"
        [ -z "$nomet" ] && echo "Running non-current branch" >> "$out/run"
        git archive "$bran" | tar -xC "$out"
      fi
      
      if [ -z "$cur" ]; then
        git deps -l -f "$out/deps" -o "$out" $dflag
      fi
    fi
  else
    echo "Error: no treeish $bran" >&2
  fi
}

run "$@"
