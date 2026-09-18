#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/bin:$PATH"

HERDR_BIN="${HERDR_BIN_PATH:-herdr}"
SOURCE_ID="github-pr"
TRACKED_FILE="$HOME/.config/herdr/github-pr-sync.json"

if ! command -v "$HERDR_BIN" >/dev/null 2>&1; then
  exit 0
fi

if ! command -v gh >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Handle manual tracking arguments: --track <branch>, --untrack
if [[ "${1:-}" == "--track" || "${1:-}" == "-t" ]]; then
  target_branch="${2:-}"
  if [[ -z "$target_branch" ]]; then
    target_branch=$(git rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null | sed 's|^origin/||' || true)
    [[ -z "$target_branch" || "$target_branch" == "@{upstream}" ]] && target_branch=$(git symbolic-ref --short HEAD 2>/dev/null || true)
  fi
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null || true)
  ws_id="${HERDR_WORKSPACE_ID:-}"
  if [[ -z "$ws_id" ]]; then
    ws_id=$("$HERDR_BIN" pane list 2>/dev/null | jq -r --arg pwd "$PWD" '
      .result.panes // [] |
      map(select(.foreground_cwd == $pwd or .cwd == $pwd)) |
      .[0].workspace_id // empty
    ' 2>/dev/null || true)
  fi
  if [[ -n "$ws_id" && -n "$repo_root" && -n "$target_branch" ]]; then
    mkdir -p "$STATE_DIR"
    current_json="{}"
    [[ -f "$TRACKED_FILE" ]] && current_json=$(cat "$TRACKED_FILE" 2>/dev/null || echo "{}")
    echo "$current_json" | jq --arg ws "$ws_id" --arg b "$target_branch" --arg r "$repo_root" '
      .[$ws] = { branch: $b, repo_root: $r, updated_at: (now | todate) }
    ' > "$TRACKED_FILE.tmp" 2>/dev/null && mv "$TRACKED_FILE.tmp" "$TRACKED_FILE"
    echo "Tracked workspace $ws_id -> $target_branch ($repo_root)"
  fi
elif [[ "${1:-}" == "--untrack" || "${1:-}" == "--clear" ]]; then
  ws_id="${HERDR_WORKSPACE_ID:-}"
  if [[ -z "$ws_id" ]]; then
    ws_id=$("$HERDR_BIN" pane list 2>/dev/null | jq -r --arg pwd "$PWD" '
      .result.panes // [] |
      map(select(.foreground_cwd == $pwd or .cwd == $pwd)) |
      .[0].workspace_id // empty
    ' 2>/dev/null || true)
  fi
  if [[ -n "$ws_id" && -f "$TRACKED_FILE" ]]; then
    jq --arg ws "$ws_id" 'del(.[$ws])' "$TRACKED_FILE" > "$TRACKED_FILE.tmp" 2>/dev/null && mv "$TRACKED_FILE.tmp" "$TRACKED_FILE"
    echo "Untracked workspace $ws_id"
  fi
fi

# Fetch workspace list and pane list from Herdr
panes_output=$("$HERDR_BIN" pane list 2>/dev/null || true)
if [[ -z "$panes_output" ]]; then
  exit 0
fi

# Load tracked workspaces if available
tracked_json="{}"
if [[ -f "$TRACKED_FILE" ]]; then
  tracked_json=$(cat "$TRACKED_FILE" 2>/dev/null || echo "{}")
fi

# Extract unique workspace IDs and their default working directories
workspaces_cwds=$(echo "$panes_output" | jq -r '
  .result.panes // [] |
  group_by(.workspace_id)[] |
  {
    workspace_id: .[0].workspace_id,
    cwd: (map(.foreground_cwd // .cwd) | map(select(. != null and . != "")) | .[0] // "")
  } |
  "\(.workspace_id)\t\(.cwd)"
')

# Clean up stale workspaces from tracked.json that are no longer active in Herdr
if [[ -f "$TRACKED_FILE" ]]; then
  active_ws_json=$(echo "$panes_output" | jq -c '[.result.panes[]?.workspace_id] | unique')
  jq --argjson active "$active_ws_json" 'with_entries(select(.key as $k | $active | index($k)))' "$TRACKED_FILE" > "$TRACKED_FILE.tmp" 2>/dev/null && mv "$TRACKED_FILE.tmp" "$TRACKED_FILE"
fi

# Temporary cache file for repo PR listings during this run
TMP_CACHE_DIR=$(mktemp -d "/tmp/herdr-pr-sync.XXXXXX")
cleanup_tmp() {
  rm -rf "$TMP_CACHE_DIR"
}
trap cleanup_tmp EXIT

while IFS=$'\t' read -r ws_id cwd; do
  [[ -z "$ws_id" ]] && continue

  branch=""
  repo_root=""

  # 1. Check if workspace has an explicitly tracked PR branch (e.g. from `pr` / `/pr-description`)
  tracked_branch=$(echo "$tracked_json" | jq -r --arg ws "$ws_id" '.[$ws].branch // empty')
  tracked_repo=$(echo "$tracked_json" | jq -r --arg ws "$ws_id" '.[$ws].repo_root // empty')

  if [[ -n "$tracked_branch" && -n "$tracked_repo" && -d "$tracked_repo" ]]; then
    branch="$tracked_branch"
    repo_root="$tracked_repo"
  fi

  # 2. Fallback to inspecting the workspace's active directory if not tracked
  if [[ -z "$branch" ]] && [[ -n "$cwd" ]] && [[ -d "$cwd" ]]; then
    if git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      upstream=$(git -C "$cwd" rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || true)
      if [[ -n "$upstream" ]] && [[ "$upstream" != "@{upstream}" ]]; then
        branch="${upstream#*/}"
      else
        branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || true)
      fi
      repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)
    fi
  fi

  # Skip default branches or empty branch
  if [[ -z "$branch" ]] || [[ "$branch" == "HEAD" ]] || [[ "$branch" == "main" ]] || [[ "$branch" == "master" ]] || [[ "$branch" == "dev" ]] || [[ -z "$repo_root" ]]; then
    "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
      --clear-token pr_open --clear-token pr_merged --clear-token pr_draft --clear-token pr_closed >/dev/null 2>&1 || true
    continue
  fi

  # Cache PR list per repo_root
  repo_hash=$(echo "$repo_root" | md5 2>/dev/null || md5sum 2>/dev/null | cut -d' ' -f1)
  cache_file="$TMP_CACHE_DIR/$repo_hash.json"

  if [[ ! -f "$cache_file" ]]; then
    (cd "$repo_root" && gh pr list --state all --limit 100 --json number,headRefName,state,isDraft > "$cache_file" 2>/dev/null || echo "[]" > "$cache_file")
  fi

  # Look for matching PR for this branch in cached repo PRs
  pr_match=$(jq -c --arg b "$branch" '.[] | select(.headRefName == $b)' "$cache_file" 2>/dev/null | head -n 1 || true)

  # Fallback to direct gh pr view if not found in top 100 list
  if [[ -z "$pr_match" ]]; then
    pr_match=$(cd "$repo_root" && gh pr view "$branch" --json number,headRefName,state,isDraft 2>/dev/null || true)
  fi

  if [[ -n "$pr_match" ]] && [[ "$pr_match" != "{}" ]]; then
    num=$(echo "$pr_match" | jq -r '.number')
    state=$(echo "$pr_match" | jq -r '.state')
    is_draft=$(echo "$pr_match" | jq -r '.isDraft')
    badge="#$num"

    if [[ "$state" == "MERGED" ]]; then
      "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
        --token "pr_merged=$badge" \
        --clear-token pr_open --clear-token pr_draft --clear-token pr_closed >/dev/null 2>&1 || true
    elif [[ "$state" == "OPEN" ]] && [[ "$is_draft" == "true" ]]; then
      "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
        --token "pr_draft=$badge" \
        --clear-token pr_open --clear-token pr_merged --clear-token pr_closed >/dev/null 2>&1 || true
    elif [[ "$state" == "OPEN" ]]; then
      "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
        --token "pr_open=$badge" \
        --clear-token pr_merged --clear-token pr_draft --clear-token pr_closed >/dev/null 2>&1 || true
    elif [[ "$state" == "CLOSED" ]]; then
      "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
        --token "pr_closed=$badge" \
        --clear-token pr_open --clear-token pr_merged --clear-token pr_draft >/dev/null 2>&1 || true
    fi
  else
    "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
      --clear-token pr_open --clear-token pr_merged --clear-token pr_draft --clear-token pr_closed >/dev/null 2>&1 || true
  fi
done <<< "$workspaces_cwds"
