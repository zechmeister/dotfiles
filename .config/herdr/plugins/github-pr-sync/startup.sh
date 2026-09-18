#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/bin:$PATH"

STATE_DIR="${HERDR_PLUGIN_STATE_DIR:-/tmp}"
PID_FILE="$STATE_DIR/github-pr-sync.pid"

# Immediate one-shot sync
bash "$SCRIPT_DIR/sync.sh" >/dev/null 2>&1 || true

# Avoid duplicate background loops
if [[ -f "$PID_FILE" ]]; then
  pid=$(cat "$PID_FILE" 2>/dev/null || true)
  if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
    exit 0
  fi
fi

# Spawn background daemon
nohup bash "$SCRIPT_DIR/daemon.sh" >/dev/null 2>&1 &
