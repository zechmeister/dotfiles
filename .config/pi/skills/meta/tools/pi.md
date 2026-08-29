# Pi Internals

Reference for Pi Coding Agent configuration and extension model.

## Architecture

Pi loads configuration from:
- `~/.pi/agent/settings.json`
- `~/.pi/agent/extensions/*.ts`
- `~/.pi/agent/skills/*/SKILL.md`
- `~/.pi/agent/keybindings.json`
- Project-local: `.pi/extensions/`, `.pi/skills/`

Current dotfiles repo symlinks:
```bash
ln -sf $PWD/.config/pi/settings.json ~/.pi/agent/settings.json
ln -sf $PWD/.config/pi/extensions ~/.pi/agent/extensions
ln -sf $PWD/.config/pi/skills ~/.pi/agent/skills
```

## Extensions vs Skills vs Packages

| Mechanism | What | Trigger |
|-----------|------|---------|
| **Extension** | TypeScript module (`pi.registerTool`, `pi.on(...)`) | Loaded at Pi startup. Global in `~/.pi/agent/extensions/`. |
| **Skill** | Markdown instruction pack (`SKILL.md` + assets) | Described in system prompt; loaded on-demand via `read` or `/skill:name`. |
| **Package** | npm/git installable bundle with `package.json` + `pi.extensions` | `pi install npm:@scope/pkg`. Adds to `settings.json` `packages` array. |

## Extension API (Key Patterns)

```typescript
export default function (pi: ExtensionAPI) {
  pi.registerTool({ name: "my_tool", ... });
  pi.registerCommand("my-cmd", { ... });
  pi.on("session_start", async (event, ctx) => { ... });
  pi.on("tool_call", async (event, ctx) => { ... });
}
```

- Factories run via `jiti` — no compilation needed.
- Defer background resources to `session_start`, not factory.
- Register `session_shutdown` handler for cleanup.

## Session Model

- Sessions stored as `.jsonl` files.
- `/new`, `/resume`, `/fork`, `/clone` manipulate session files.
- Context events (`context`, `before_agent_start`, etc.) let extensions modify messages.
- Tool events (`tool_call`, `tool_result`) allow blocking or result mutation.

## Commands for Meta Work

```bash
/reload                    # Hot-reload extensions, skills, themes
/settings                  # Open settings editor
/skill:meta-architect      # Force-load this skill
```

## Pi-Herdr Integration

Herdr installs a Pi extension at `~/.pi/agent/extensions/herdr-agent-state.ts` via:
```bash
herdr integration install pi
```

This extension reports Pi's lifecycle state (`idle`, `working`, `blocked`, `done`) to Herdr's socket. It makes Pi a **lifecycle authority** in Herdr — screen manifest detection is skipped for Pi panes.

## Current Config

- Pi version: `0.84.4`
- Default provider: `openrouter`
- Default model: `moonshotai/kimi-k2.6`
- Theme: `dark`
- Installed integrations via Herdr: `pi` (v8), `claude` (v8)
