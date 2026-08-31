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
ln -sf $PWD/.config/.zshrc ~/.zshrc

# Pi Coding Agent
mkdir -p ~/.pi/agent
ln -sf $PWD/.config/pi/settings.json ~/.pi/agent/settings.json
ln -sf $PWD/.config/pi/APPEND_SYSTEM.md ~/.pi/agent/APPEND_SYSTEM.md
ln -sf $PWD/.config/pi/extensions ~/.pi/agent/extensions
ln -sf $PWD/.config/pi/skills ~/.pi/agent/skills

# Claude Code
mkdir -p ~/.claude
ln -sf $PWD/.config/claude/settings.json ~/.claude/settings.json
ln -sf $PWD/.config/claude/skills ~/.claude/skills

# Shared Agent Skills (Pi, Claude Code, etc.)
mkdir -p ~/.agents
ln -sf $PWD/skills ~/.agents/skills

# CLI Tools
mkdir -p ~/bin
ln -sf $PWD/bin/gh-open ~/bin/gh-open
ln -sf $PWD/bin/meta ~/bin/meta
```

### 3. Agent Skills Architecture

Skills follow the Agent Skills standard (`SKILL.md`) with a tiered discovery layout:

- **Shared Skills (`skills/` -> `~/.agents/skills`):** Standard skills available to all agents (Pi, Claude Code, Codex, etc.), such as `code-navigator` and `herdr`.
- **Pi-Only Skills (`.config/pi/skills/` -> `~/.pi/agent/skills`):** Skills specific to Pi features or extensions.
- **Claude-Only Skills (`.config/claude/skills/` -> `~/.claude/skills`):** Skills specific to Claude Code hooks/subagents.

### 4. Remove Dock (macOS)

```bash
defaults write com.apple.dock autohide-delay -float 1000 && killall Dock
```
