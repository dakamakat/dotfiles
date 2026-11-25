#!/usr/bin/env bash
# Symlink these dotfiles into $HOME.
# Anything already in the way is moved to ~/.dotfiles-backup/<timestamp>/.
#
#   ./install.sh          link everything
#   ./install.sh -n       dry run (show what would happen)
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY=0
[[ "${1:-}" == "-n" ]] && DRY=1

# Single files in $HOME
FILES=(
  .bashrc
  .profile
  .zshrc
  .zshenv
  .zprofile
  .gitconfig
  .ideavimrc
)

# Whole directories under ~/.config (linked as a directory so tools that
# rewrite files in place, e.g. lazy.nvim or kitty's theme kitten, keep working)
CONFIG_DIRS=(
  nvim
  kitty
  alacritty
  git
)

run() {
  if ((DRY)); then echo "  would: $*"; else "$@"; fi
}

link() {
  local src="$DOTFILES/$1" dst="$HOME/$1"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    echo "ok      $1"
    return
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    echo "backup  $1 -> $BACKUP/$1"
    run mkdir -p "$(dirname "$BACKUP/$1")"
    run mv "$dst" "$BACKUP/$1"
  fi
  echo "link    $1"
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
}

for f in "${FILES[@]}"; do link "$f"; done
for d in "${CONFIG_DIRS[@]}"; do link ".config/$d"; done

# oh-my-zsh + the external plugin .zshrc expects
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
  echo "note    oh-my-zsh not installed: https://ohmyz.sh/#install"
else
  plugin="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
  if [[ ! -d "$plugin" ]]; then
    echo "clone   zsh-syntax-highlighting"
    run git clone --depth 1 https://github.com/zsh-users/zsh-syntax-highlighting.git "$plugin"
  fi
fi

echo "done."
