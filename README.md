# Dotfiles

Central source of truth for configuration files. Files live here and are symlinked to their expected locations.

## Setup

### Install Homebrew packages

```bash
brew bundle
```

### Create symlinks

**Note**: `-sf` will overwrite existing files.

```bash
ln -sf $PWD/Brewfile ~/Brewfile
ln -sf $PWD/.config/ghostty ~/.config/ghostty
ln -sf $PWD/.config/tmux ~/.config/tmux
ln -sf $PWD/.config/scripts ~/.config/scripts
```

**Note**: Symlinking the Brewfile to `~/Brewfile` allows you to run `brew bundle` from anywhere without specifying the file path.
