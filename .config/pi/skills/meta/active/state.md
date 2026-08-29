# Active State Snapshot

Last updated: 2026-08-29

## Workspaces

| ID | Label | CWD | Agent | Status |
|----|-------|-----|-------|--------|
| w5 | `~` | ? | — | `unknown` |
| w6 | `meta` | `~/projects/dotfiles` | **Pi** (`name: meta`) | `working` |
| w7 | `RW_NEW` | `~/projects/ffy/RW_NEW` | **Claude Code** | `idle` |

## Integrations (via Herdr)

```
pi:      current (v8)
claude:  current (v8)
omp:     not installed
codex:   not installed
copilot: not installed
devin:   not installed
droid:   not installed
kimi:    not installed
opencode: not installed
kilo:    not installed
hermes:  not installed
qodercli: not installed
qwen:    not installed
cursor:  not installed
mastracode: not installed
antigravity-cli: not installed
grok:    not installed
```

## Tool Versions

| Tool | Version |
|------|---------|
| Pi | `0.84.4` |
| Herdr | `0.8.2` |
| Claude Code | installed at `~/.local/bin/claude` |

## Open Loops / Recent Changes

- [x] Installed Claude Code Herdr integration (`herdr integration install claude`)
- [ ] Re-evaluate whether `pi-herdr` extension package is needed (installed then reverted)
- [ ] System prompt / context architecture for meta agent (in progress)

## Shorthand Commands

| Command | Effect |
|---------|--------|
| `! meta` | Jump to meta workspace in Pi |
| `meta` (shell) | Jump to or create meta workspace |
| `herdr config check` | Validate Herdr config |
| `herdr server reload-config` | Reload Herdr without restart |
