# dotfiles

My Linux (Ubuntu / GNOME) setup.

| Path | What |
| --- | --- |
| `.zshrc`, `.zshenv`, `.zprofile` | zsh + oh-my-zsh (`robbyrussell`, `git`, `zsh-syntax-highlighting`), zoxide, PATH for dotnet / cargo / npm |
| `.bashrc`, `.profile` | bash + login shell environment |
| `.gitconfig`, `.config/git/ignore` | git (LFS, Git Credential Manager), global ignore |
| `.config/nvim` | Neovim, LazyVim-based (.NET / Roslyn, DAP, blink.cmp, projects picker, Claude Code) |
| `.config/kitty` | kitty: Cascadia Mono, Tokyo Night Moon, powerline tabs |
| `.config/alacritty` | alacritty: Tokyo Night |
| `.ideavimrc` | IdeaVim for JetBrains IDEs |

## Install

```sh
git clone https://github.com/dakamakat/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh -n   # dry run
./install.sh
```

`install.sh` symlinks every file / config directory into `$HOME`. Anything
already there is moved to `~/.dotfiles-backup/<timestamp>/` first, so it is
safe to re-run.

## Dependencies

- zsh, [oh-my-zsh](https://ohmyz.sh/) (`zsh-syntax-highlighting` is cloned by `install.sh`)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [Neovim](https://neovim.io/) ≥ 0.11, git, a C compiler (treesitter), ripgrep, fd
- a [Nerd Font](https://www.nerdfonts.com/): CaskaydiaMono / Cascadia Mono
- [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager), git-lfs
- .NET SDK, Rust (cargo), Node / npm
