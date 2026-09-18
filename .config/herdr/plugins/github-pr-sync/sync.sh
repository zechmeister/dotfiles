#!/usr/bin/env bash
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:$HOME/bin:$PATH"

HERDR_BIN="${HERDR_BIN_PATH:-herdr}"
SOURCE_ID="github-pr"

if ! command -v "$HERDR_BIN" >/dev/null 2>&1; then
  exit 0
fi

if ! command -v gh >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Fetch workspace list and pane list from Herdr
panes_output=$("$HERDR_BIN" pane list 2>/dev/null || true)
if [[ -z "$panes_output" ]]; then
  exit 0
fi

# Extract unique workspace IDs and one working directory per workspace
# Priority for working directory: foreground_cwd, then cwd
workspaces_cwds=$(echo "$panes_output" | jq -r '
  .result.panes // [] |
  group_by(.workspace_id)[] |
  {
    workspace_id: .[0].workspace_id,
    cwd: (map(.foreground_cwd // .cwd) | map(select(. != null and . != "")) | .[0] // "")
  } |
  "\(.workspace_id)\t\(.cwd)"
')

# Temporary cache file for repo PR listings during this run
TMP_CACHE_DIR=$(mktemp -d "/tmp/herdr-pr-sync.XXXXXX")
cleanup_tmp() {
  rm -rf "$TMP_CACHE_DIR"
}
trap cleanup_tmp EXIT

while IFS=$'\t' read -r ws_id cwd; do
  [[ -z "$ws_id" ]] && continue

  if [[ -z "$cwd" ]] || [[ ! -d "$cwd" ]]; then
    "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
      --clear-token pr_open --clear-token pr_merged --clear-token pr_draft --clear-token pr_closed >/dev/null 2>&1 || true
    continue
  fi

  # Check if directory is inside a git repo
  if ! git -C "$cwd" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
      --clear-token pr_open --clear-token pr_merged --clear-token pr_draft --clear-token pr_closed >/dev/null 2>&1 || true
    continue
  fi

  # Determine remote upstream branch, or fallback to local branch
  upstream=$(git -C "$cwd" rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null || true)
  if [[ -n "$upstream" ]] && [[ "$upstream" != "@{upstream}" ]]; then
    # e.g., 'origin/feature-x' -> 'feature-x'
    branch="${upstream#*/}"
  else
    branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || true)
  fi

  if [[ -z "$branch" ]] || [[ "$branch" == "HEAD" ]] || [[ "$branch" == "main" ]] || [[ "$branch" == "master" ]] || [[ "$branch" == "dev" ]]; then
    "$HERDR_BIN" workspace report-metadata "$ws_id" --source "$SOURCE_ID" \
      --clear-token pr_open --clear-token pr_merged --clear-token pr_draft --clear-token pr_closed >/dev/null 2>&1 || true
    continue
  fi

  # Find git repo root to cache PR listing
  repo_root=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null || true)
  if [[ -z "$repo_root" ]]; then
    continue
  fi

  repo_hash=$(echo "$repo_root" | md5 2>/dev/null || md5sum 2>/dev/null | cut -d' ' -f1)
  cache_file="$TMP_CACHE_DIR/$repo_hash.json"

  if [[ ! -f "$cache_file" ]]; then
    (cd "$repo_root" && gh pr list --state all --limit 100 --json number,headRefName,state,isDraft > "$cache_file" 2>/dev/null || echo "[]" > "$cache_file")
  fi

  # Look for matching PR for this branch in cached repo PRs
  pr_match=$(jq -c --arg b "$branch" '.[] | select(.headRefName == $b)' "$cache_file" 2>/dev/null | head -n 1 || true)

  # Fallback to direct gh pr view if not found in top 100 list
  if [[ -z "$pr_match" ]]; then
    pr_match=$(cd "$cwd" && gh pr view "$branch" --json number,headRefName,state,isDraft 2>/dev/null || true)
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
