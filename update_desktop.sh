#!/bin/bash

function local_update(){
  rm -fv config.h && make && sudo make clean install
}

function full_update(){
  apply_branch="apply-$(uuidgen)"
  git checkout -b master
  git checkout -b "$apply_branch"

  for branch in $(git branch -a | grep -Ev 'master|remotes' | cut -c 3-);do
    git merge "$branch"
  done
  
  local_update
  
  git checkout master
  git branch -D "$apply_branch"
}

function show_help(){
  echo -e "Update your DWM based on your cureent config."
  echo -e "Your local config can be found in {{dwm_dir}}\n"
  echo "FLAGS:"
  echo -e "\t-h, --help\tShow this message."
  echo -e "\t-f, --full\tRun full update."
  echo -e "\t-l, --local\tRun local update."
}

function main(){
  local show_help=0
  local full_update=0
  local local_update=0

  while [[ "$#" -gt 0 ]]; do
      case $1 in
          -f|--full) full_update=1 ;;
          -h|--help) show_help=1 ;;
          -l|--local) local_update=1 ;;
          *) echo "Unknown parameter passed: $1"; exit 1 ;;
      esac
      shift
  done

  if [[ show_help -eq 1 ]];then
    show_help
    exit 0
  fi

  if [[ full_update -eq 1 ]];then
    full_update
    exit 0
  fi

  if [[ local_update -eq 1 ]];then
    local_update
    exit 0
  fi

  show_help
  exit 0
}

pushd "{{dwm_dir}}"
trap popd EXIT

main "$@"
