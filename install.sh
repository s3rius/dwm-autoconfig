#!/bin/bash

function cleanup(){
  rm -rfv $(find -name "build_*" -type d)
}

function build_from_git(){
  build_dir="$(mktemp -d build_XXXX)"
  pushd "$build_dir"
  git clone $1 repo
  pushd repo
  eval "$2"
  popd
  popd
}

function build_libs_from_sources(){
  build_from_git "https://github.com/robbyrussell/oh-my-zsh.git" "sh ./tools/install.sh"
  build_from_git "https://github.com/actionless/pikaur.git" "makepkg -fsri"
  build_from_git "https://gitlab.le-memese.com/s3rius/music_bg.git" "makepkg -fsri"
  build_from_git "https://gitlab.le-memese.com/s3rius/awatch.git" "makepkg -fsri"
}



function copy_dotfiles(){
  sed "s#{{dwm_dir}}#$(pwd)/dwm#g" ./update_desktop.sh > "$HOME/.local/bin/update_desktop"
  chmod 777 "$HOME/.local/bin/update_desktop"
  cp -v ./dotfiles/.zshrc      "$HOME"
  cp -v ./dotfiles/.zshrc      "$HOME"
  cp -v ./dotfiles/.picom.conf "$HOME"

  git_flow_dir="$HOME/.oh-my-zsh/custom/plugins/git-flow-completion"
  if [[ -d "$git_flow_dir" ]]; then
    rm -rf "$git_flow_dir"
  fi
  git clone https://github.com/bobthecow/git-flow-completion ~/.oh-my-zsh/custom/plugins/git-flow-completion
}

enable_services()
{
  systemctl --user enable music_bg.service
}

function main(){
  sudo pacman -Syu --needed $(cat ./pacman.deps)
  pikaur -Syu --needed --noconfirm --noedit $(cat ./pikaur.deps)
  build_libs_from_sources
  enable_services
  copy_dotfiles
}

trap cleanup EXIT

main
