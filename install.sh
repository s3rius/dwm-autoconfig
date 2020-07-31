#!/bin/bash

function cleanup(){
  # shellcheck disable=SC2046
  rm -rfv $(find . -name "build_*" -type d)
}

function build_from_git(){
  build_dir="$(mktemp -d build_XXXX)"
  pushd "$build_dir" || exit
  git clone "$1" repo
  pushd repo || exit
  eval "$2"
  popd || exit
  popd || exit
}

function build_libs_from_sources(){
  build_from_git "https://github.com/robbyrussell/oh-my-zsh.git" "sh ./tools/install.sh"
  build_from_git "https://github.com/actionless/pikaur.git" "makepkg -fsri"
  build_from_git "https://gitlab.le-memese.com/s3rius/music_bg.git" "makepkg -fsri"
  build_from_git "https://gitlab.le-memese.com/s3rius/awatch.git" "makepkg -fsri"
}

function update_firefox_profile(){
  firefox_dir="$HOME/.mozilla/firefox"
  fire_profile="$(grep Default "$firefox_dir"/installs.ini | cut -d '=' -f2)"
  cp -v ./dotfiles/firefox/user.js "$firefox_dir/$fire_profile"
  mkdir -vp "$firefox_dir/$fire_profile/chrome"
  cp -v ./dotfiles/firefox/userChrome.css "$firefox_dir/$fire_profile/chrome"
}

function copy_dotfiles(){
  sed "s#{{dwm_dir}}#$(pwd)/dwm#g" ./update_desktop.sh > "$HOME/.local/bin/update_desktop"
  chmod 777 "$HOME/.local/bin/update_desktop"
  cp -v ./dotfiles/.zshenv     "$HOME"
  cp -v ./dotfiles/.zshrc      "$HOME"
  cp -v ./dotfiles/.xutil      "$HOME"
  cp -v ./dotfiles/.xinitrc    "$HOME"
  cp -v ./dotfiles/.picom.conf "$HOME"

  git_flow_dir="$HOME/.oh-my-zsh/custom/plugins/git-flow-completion"
  if [[ -d "$git_flow_dir" ]]; then
    rm -rf "$git_flow_dir"
  fi
  git clone https://github.com/bobthecow/git-flow-completion ~/.oh-my-zsh/custom/plugins/git-flow-completion
}

function enable_services(){
  systemctl --user enable music_bg.service
}

function main(){
  # shellcheck disable=SC2046
  sudo pacman -Syu --needed $(cat ./pacman.deps)
  # shellcheck disable=SC2046
  pikaur -Syu --needed --noconfirm --noedit $(cat ./pikaur.deps)
  update_firefox_profile
  build_libs_from_sources
  enable_services
  copy_dotfiles
  update_desktop
}

trap cleanup EXIT

main
