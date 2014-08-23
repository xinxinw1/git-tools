#!/bin/bash

function run {
  local d=${PWD##*/}   # original directory
  
  rm -r /srv/http/git-preview/* 2>/dev/null
  
  local b="$(git rev-parse --abbrev-ref HEAD)"
  if [ "$b" == "gh-pages" ]; then
    cp -r * /srv/http/git-preview
  else
    git archive gh-pages | tar -xC /srv/http/git-preview
  fi
  
  cd ../
  while read line; do
    if [ "${line:0:1}" == "#" ]; then continue; fi
    local arr=($line)
    local n=${#arr[@]}
    local cdir; local obj; local todir;
    if [ "$n" == "2" ]; then
      cdir=$d
      obj=${arr[0]}
      todir=${arr[1]}
    elif [ "$n" == "3" ]; then
      cdir=${arr[0]}
      obj=${arr[1]}
      todir=${arr[2]}
    fi
    local file=${obj##*:}
    local addnm=$todir/$file
    local dest=/srv/http/git-preview/$todir
    local loc=$dest/$file
    if [ -d "$cdir" ]; then
      cd $cdir
      if [ "$cdir" == "$d" ] && [ "$b" == "gh-pages" ]; then
        if git show $obj 1> /dev/null; then
          if [ ! -d "$dest" ]; then mkdir $dest; fi
          git show $obj > $loc
        fi
      else
        if [ -f $file ]; then
          if [ ! -d "$dest" ]; then mkdir $dest; fi
          cp $file $dest
        fi
      fi
      cd ../
    else
      echo "Directory $cdir doesn't exist"
    fi
  done < <(cat /srv/http/git-preview/deps 2>/dev/null)
  cd $d
}

run
