# Dotfiles

Central source of truth for configuration files.

## Setup

### 1. Install Homebrew Packages

```bash
brew bundle
```

### 2. Create Symlinks

```bash
# Brewfile
ln -sf $PWD/Brewfile ~/Brewfile

# Configs
ln -sf $PWD/.config/ghostty ~/.config/ghostty
ln -sf $PWD/.config/herdr/config.toml ~/.config/herdr/config.toml
ln -sf $PWD/.config/nvim ~/.config/nvim
ln -sf $PWD/.config/pi/settings.json ~/.pi/agent/settings.json
ln -sf $PWD/.config/pi/APPEND_SYSTEM.md ~/.pi/agent/APPEND_SYSTEM.md
ln -sf $PWD/.config/pi/extensions ~/.pi/agent/extensions
ln -sf $PWD/.config/.zshrc ~/.zshrc

# CLI Tools
mkdir -p ~/bin
ln -sf $PWD/bin/gh-open ~/bin/gh-open
ln -sf $PWD/bin/meta ~/bin/meta
```

### 3. Remove Dock (macOS)

```bash
defaults write com.apple.dock autohide-delay -float 1000 && killall Dock
```
