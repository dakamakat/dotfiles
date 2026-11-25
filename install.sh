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
  .local/bin/kb
)

# Whole directories under ~/.config (linked as a directory so tools that
# rewrite files in place, e.g. lazy.nvim or kitty's theme kitten, keep working)
CONFIG_DIRS=(
  nvim
  kitty
  alacritty
  git
  kb
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

# Obsidian + kb (knowledge-base capture: hotkeys, Telegram import)
if ! command -v obsidian >/dev/null 2>&1; then
  if command -v snap >/dev/null 2>&1; then
    echo "install obsidian (snap, asks for sudo)"
    run sudo snap install obsidian --classic
  else
    echo "note    install Obsidian: https://obsidian.md/download"
  fi
fi
missing=()
for bin in zenity wl-paste notify-send pdftotext; do
  command -v "$bin" >/dev/null 2>&1 || missing+=("$bin")
done
((${#missing[@]})) && echo "note    kb wants ${missing[*]}: sudo apt install zenity wl-clipboard libnotify-bin poppler-utils"
command -v claude >/dev/null 2>&1 || echo "note    kb files notes with Claude Code: https://claude.com/claude-code (or set KB_AI=0)"
if command -v uv >/dev/null 2>&1; then
  echo "setup   kb: vault, Obsidian vault list, GNOME hotkeys"
  run "$DOTFILES/.local/bin/kb" setup
else
  echo "note    kb needs uv: curl -LsSf https://astral.sh/uv/install.sh | sh, then: kb setup"
fi

echo "done."
