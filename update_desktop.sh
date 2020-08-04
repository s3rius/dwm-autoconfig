#!/bin/bash
RED='\033[0;31m'
NC='\033[0m' # No color

function local_update(){
  rm -fv config.h && make && sudo make clean install
}

function full_update(){
  apply_branch="apply-$(uuidgen)"
  git checkout master
  git checkout -b "$apply_branch"
  apply_conf="$(mktemp /tmp/custom_patchXXXXX)"
  echo "# You can edit this file to manipulate ordering and patches to apply" > "$apply_conf"
  git branch -a | grep -Ev '^master$|remotes' | grep 'patch/' | cut -c 3- >> "$apply_conf"
  echo "$EDITOR"
  if [ -z ${EDITOR+x} ];then
    echo -e "${RED}\$EDITOR env is not found${NC}.\nTry this before running script: 'export EDITOR=/bin/vim'"
    git checkout master
    git branch -D "$apply_branch"
    exit 1
  fi
  eval "$EDITOR \"$apply_conf\""

  while IFS= read -r branch;do
    echo -e "${RED}$branch${NC}"
    if [[ $branch = \#* ]];then
      continue
    fi
    git merge "$branch" --no-edit
  done < <(cat "$apply_conf")
  
  rm -f "$apply_conf"

  local_update || exit 1
  
  git checkout master
  git branch -D "$apply_branch"
}

function apply_patch(){
  patch_name="$(basename "$1" | cut -d '.' -f1)"
  patch_path="$(readlink -f "$1")"
  pushd "{{dwm_dir}}" || exit
  git checkout -b "patch/$patch_name"
  patch < "$patch_path"
  git add .
  git commit -m "Patch \"$patch_name\" applied."
}

function show_help(){
  echo -e "Update your DWM based on your cureent config."
  echo -e "Your local config can be found in {{dwm_dir}}\n"
  echo "FLAGS:"
  echo -e "\t-h, --help\tShow this message."
  echo -e "\t-f, --full\tRun full update."
  echo -e "\t-l, --local\tRun local update."
  echo -e "\t-a, --apply\tApply a patch and create new git branch."
}

function main(){
  local show_help=0
  local full_update=0
  local local_update=0
  local patch_to_apply=""

  while [[ "$#" -gt 0 ]]; do
      case $1 in
          -f|--full) full_update=1 ;;
          -h|--help) show_help=1 ;;
          -l|--local) local_update=1 ;;
          -a|--apply) patch_to_apply="$2"; shift ;;
          -al)patch_to_apply="$2"; shift; local_update=1;;
          -af)patch_to_apply="$2"; shift; full_update=1;;
          *) echo "Unknown parameter passed: $1"; exit 1 ;;
      esac
      shift
  done
  
  if [[ show_help -eq 1 ]];then
    pushd "{{dwm_dir}}" || exit
    show_help
    exit 0
  fi

  if [[ -n "$patch_to_apply" ]];then
    apply_patch "$patch_to_apply"
    popd || exit
    if [[ $((full_update + local_update)) -eq 0 ]];then
      exit 0
    fi
  fi

  pushd "{{dwm_dir}}" || exit
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

function go_back(){
  popd || exit
}

trap go_back EXIT
main "$@"
