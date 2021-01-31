#!/bin/bash

function cleanup(){
  # shellcheck disable=SC2046
  rm -rf $(find . -name "build_*" -type d)
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
  build_from_git "https://git.suckless.org/wmname" "sudo make install"
  build_from_git "https://github.com/robbyrussell/oh-my-zsh.git" "sh ./tools/install.sh"
  build_from_git "https://github.com/actionless/pikaur.git" "makepkg -fsri"
  build_from_git "https://gitlab.le-memese.com/s3rius/awatch.git" "makepkg -fsri"
}

# This function can be used after firefox installation.
function update_firefox_profile(){
  firefox_dir="$HOME/.mozilla/firefox"
  fire_profile="$(grep Default "$firefox_dir"/installs.ini | cut -d '=' -f2)"
  cp -v ./dotfiles/firefox/user.js "$firefox_dir/$fire_profile"
  mkdir -vp "$firefox_dir/$fire_profile/chrome"
  cp -v ./dotfiles/firefox/userChrome.css "$firefox_dir/$fire_profile/chrome"
}

function install_python_deps(){
	curl -sSL https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py | python -
	curl https://pyenv.run | bash
}

function copy_dotfiles(){
  mkdir -p "$HOME/.local/bin/"
  sed "s#{{dwm_dir}}#$(pwd)/dwm#g" ./update_desktop.sh > "$HOME/.local/bin/update_desktop"
  chmod 777 "$HOME/.local/bin/update_desktop"
  cp -v ./dotfiles/.zshrc      "$HOME"
  cp -v ./dotfiles/.zshenv     "$HOME"
  cp -v ./dotfiles/.zshenv     "$HOME"
  cp -v ./dotfiles/.dunstrc    "$HOME"
  cp -v ./dotfiles/.xinitrc    "$HOME"
  cp -v ./dotfiles/.xprofile   "$HOME"
  cp -v ./dotfiles/.picom.conf "$HOME"

  git_flow_dir="$HOME/.oh-my-zsh/custom/plugins/git-flow-completion"
  if [[ -d "$git_flow_dir" ]]; then
    rm -rf "$git_flow_dir"
  fi
  git clone https://github.com/bobthecow/git-flow-completion ~/.oh-my-zsh/custom/plugins/git-flow-completion
}

# Update local branches.
function update_repo(){
for remote in `git branch -r | grep -v '\->'`; do
	git branch --track "${remote#origin/}" "$remote"
done
}

function main(){
  # shellcheck disable=SC2046
  sudo pacman -Syu --needed $(cat ./pacman.deps)
  # Install all fonts.
  pacman -Syu $(sudo pacman -Ssq "ttf-")
  build_libs_from_sources
  # shellcheck disable=SC2046
  pikaur -Syu --needed --noconfirm --noedit $(cat ./pikaur.deps)
  install_python_deps
  copy_dotfiles
  update_repo
  echo "######## Installation complete ########"
  echo "Now you can build your desktop."
  echo "To do so just run \`update_desktop -f\`"
  update_desktop -h
}

trap cleanup EXIT

main
