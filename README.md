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
| `.local/bin/kb`, `.config/kb` | Obsidian knowledge base: capture hotkeys, Telegram Saved Messages import, vault template (see below) |

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

## Knowledge base (Obsidian + `kb`)

`install.sh` installs Obsidian (snap) and runs `kb setup`, which creates the vault at
`~/Documents/Knowledge` from `.config/kb/vault-template`, adds it to Obsidian's vault list and
binds the GNOME hotkeys. Claude Code (`claude -p`, your normal login) writes each note's
title, type, tags and summary; the original content is kept untouched below the properties.

| Hotkey / command | Does |
| --- | --- |
| `Super+N` | Quick capture, prefilled from the clipboard: a URL becomes an article note with the full text, anything else a note; copied files are offered as attachments |
| `Super+F` | Pick files to add (PDFs and text files are read for the summary) |
| `Super+O` | Open the vault in Obsidian |
| `kb add URL\|FILE\|TEXT`, `… \| kb add -` | The same from a terminal |
| `kb telegram [EXPORT]` | Import Saved Messages from a Telegram Desktop JSON export (newest one in `~/Downloads/Telegram Desktop` by default). Re-run on a newer export to pick up only new messages; junk goes to `Telegram/_Skipped.md` |
| `kb save-config` | Copy the vault's `.obsidian` settings back here to commit (plugin `data.json` left out: this repo is public) |

Telegram export: Telegram Desktop → Saved Messages → ⋮ → *Export chat history* → format
**JSON**, tick photos/files if you want them → `kb telegram`. Try `kb telegram --limit 30` first.

The notes themselves are **not** in this repo; only the tooling and settings are. Per-machine
overrides (vault path, model) go in `~/.config/kb/local.env`, see `local.env.example`.

## Dependencies

- zsh, [oh-my-zsh](https://ohmyz.sh/) (`zsh-syntax-highlighting` is cloned by `install.sh`)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [Neovim](https://neovim.io/) ≥ 0.11, git, a C compiler (treesitter), ripgrep, fd
- a [Nerd Font](https://www.nerdfonts.com/): CaskaydiaMono / Cascadia Mono
- [Git Credential Manager](https://github.com/git-ecosystem/git-credential-manager), git-lfs
- .NET SDK, Rust (cargo), Node / npm
- kb: [Obsidian](https://obsidian.md), [uv](https://docs.astral.sh/uv/), [Claude Code](https://claude.com/claude-code), `zenity wl-clipboard libnotify-bin poppler-utils`
