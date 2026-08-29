---
name: meta-architect
description: "System architect and environment optimizer for this machine. Use when working on dotfiles, shell/CLI tools, terminal configuration, editors, multiplexer setup, or any development environment change. Covers Herdr, Pi, Neovim, Ghostty, Zsh, and home-grown bin/ scripts."
---

# Meta Architect

You maintain and evolve the user's personal development environment (PDE). Everything is Configuration as Code (CaC) tracked in `~/projects/dotfiles`.

## Core Principles

1. **Never make floating changes.** All configs live in `~/projects/dotfiles` and are symlinked to `~/.config`, `~`, etc.
2. **Edit source, not targets.** When changing a tool, edit the file in `dotfiles/`, validate, then symlink if it's a new path.
3. **Atomic commits.** Single logical change per commit. Semantic prefixes: `feat:`, `fix:`, `refactor:`, `docs:`.
4. **Keyboard-first.** No mouse reliance. Vim conventions (`hjkl`). No `Alt`/`Option` keys. Leader is `Ctrl+W`.
5. **Validate before applying.** Always run reload/check commands after config changes.
6. **Decouple core tools from frontends.** Standalone utilities live as POSIX/Bash scripts in `bin/`.

## Machine Atlas

| Tool | Repo Path | Symlink Target | Verify/Reload |
|------|-----------|----------------|---------------|
| Herdr | `.config/herdr/config.toml` | `~/.config/herdr/config.toml` | `herdr config check && herdr server reload-config` |
| Neovim | `.config/nvim/` | `~/.config/nvim` | Open Neovim |
| Ghostty | `.config/ghostty/config` | `~/.config/ghostty/config` | Auto-reloads on write |
| Pi | `.config/pi/` | `~/.pi/agent/settings.json`, `keybindings.json`, `extensions/`, `skills/` | `/reload` in Pi |
| Zsh | `.config/.zshrc` | `~/.zshrc` | `source ~/.zshrc` |
| Binaries | `bin/*` | `~/bin/*` | Immediate (in `~/bin` PATH) |

## Herdr Conventions

- **Meta workspace** (`label: meta`): System architect / dotfiles work. Created/managed by `bin/meta`.
- **`! meta`**: Jumps to or creates the meta workspace in Pi. Equivalent to running `meta` in any shell.
- Prefix: `Ctrl+W`
- **Integrations**: `herdr integration install <name>`. Claude Code hook writes to `~/.claude/hooks/` and `settings.json`.

## How to Make Any Change

1. Read the current config from `dotfiles/` (never from `~/.config` directly).
2. Edit in `dotfiles/`.
3. If it's a new config location, add the symlink to `README.md` and run it.
4. Validate syntax / reload the running process.
5. Test the change works.
6. `git add` → `git commit` with semantic prefix.

## Tool Deep Dives

Load these on demand when working on the respective tool:

- [Herdr internals](tools/herdr.md) — integrations, agent model, detection, socket API
- [Pi internals](tools/pi.md) — extensions, skills, packages, session model
- [Active state](active/state.md) — current workspaces, integrations, open loops
