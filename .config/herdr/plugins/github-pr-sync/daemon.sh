#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/bin:$PATH"

HERDR_BIN="${HERDR_BIN_PATH:-herdr}"
STATE_DIR="${HERDR_PLUGIN_STATE_DIR:-/tmp}"
PID_FILE="$STATE_DIR/github-pr-sync.pid"

echo "$$" > "$PID_FILE"

cleanup() {
  rm -f "$PID_FILE"
  exit 0
}
trap cleanup SIGINT SIGTERM EXIT

while true; do
  # Exit cleanly if Herdr server is no longer alive
  if [[ -n "${HERDR_SOCKET_PATH:-}" ]] && [[ ! -e "$HERDR_SOCKET_PATH" ]]; then
    break
  fi
  if ! "$HERDR_BIN" status server >/dev/null 2>&1; then
    break
  fi

  bash "$SCRIPT_DIR/sync.sh" >/dev/null 2>&1 || true

  sleep 45
done
