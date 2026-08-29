# Herdr Internals

Reference for the Herdr terminal multiplexer and its agent ecosystem.

## Agent Detection Model

Herdr detects agents in two layers:

1. **Process detection**: Identifies the foreground process in each pane.
2. **State authority**: Determines who classifies `idle`/`working`/`blocked`.

### Integration Types

| Type | Agents | Effect |
|------|--------|--------|
| **Lifecycle authority** | Pi, OMP, Kimi, OpenCode, Kilo, MastraCode | When installed and actively reporting, hook/plugin events author state. Herdr skips screen manifest fallback for that pane. |
| **Session identity** | Claude Code, Codex, Copilot, Devin, Droid, Qoder, Qwen, Cursor, Hermes, Grok, Antigravity | Reports native session references for restore. State still comes from Herdr's screen manifest detection. |

### Screen Manifest Detection

For agents without lifecycle hooks, Herdr evaluates TOML manifests against the live bottom-buffer screen snapshot to classify state.

- Bundled manifests ship with Herdr.
- Remote manifest updates are fetched automatically from `herdr.dev`.
- Local overrides live at `~/.config/herdr/agent-detection/<agent>.toml` and always win.
- Reload running server after editing local overrides: `herdr server reload-agent-manifests`

### Claude Code Specifics

```bash
herdr integration install claude    # Install session hook
herdr integration uninstall claude  # Remove it
```

- Hook writes to `~/.claude/hooks/herdr-agent-state.sh`
- Updates `~/.claude/settings.json` with a `SessionStart` hook
- Reports `session_id` and `transcript_path` to Herdr's UNIX socket
- **Not a lifecycle authority** — state comes from screen manifest detection
- Claude Code must be installed at `~/.local/bin/claude` with config dir `~/.claude`

## Workspace Conventions

| Workspace | Label | Purpose |
|-----------|-------|---------|
| `w5` | `~` | Default / home |
| `w6` | `meta` | System architect / dotfiles. Pi agent named `meta`. |
| `w7` | `RW_NEW` | Active project (varies). Currently Claude Code at `~/projects/ffy/RW_NEW`. |

## Critical CLI Patterns

```bash
# Never probe with bare `herdr`; it launches TUI
herdr agent
herdr pane
herdr workspace
herdr integration status

# Layout — always preserve caller cwd and no-focus for bg work
herdr pane split --current --direction right --cwd "$PWD" --no-focus

# Agent workflow
herdr agent start <name> --kind <kind> --pane <pane-id>
herdr agent prompt <name> "..." --wait --timeout 120000
herdr agent read <name> --source recent-unwrapped --lines 120

# Safety: do not close panes you did not create
# Never run `herdr server stop` from inside an active session
```

## Environment Variables (injected by Herdr)

```bash
HERDR_ENV=1
HERDR_WORKSPACE_ID=w6
HERDR_TAB_ID=w6:t1
HERDR_PANE_ID=w6:p1
HERDR_BIN_PATH=$(which herdr)
HERDR_SOCKET_PATH=...
```

## VMs / Sandboxing

If a wrapper hides the real agent process, set:
```bash
HERDR_AGENT=claude fence -- claude           # Linux
HERDR_AGENT=claude nono run --profile claude-code -- claude  # macOS
```

Avoid exporting `HERDR_AGENT` globally.
