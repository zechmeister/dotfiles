#!/usr/bin/env bash
# Commits and PRs authored by the user across /ffy repos since a cutoff date.
# Usage: git_activity.sh <YYYY-MM-DD> [ffy-root] [author-regex]
set -euo pipefail

SINCE="$1"
ROOT="${2:-/Users/flo/ffy}"
AUTHOR="${3:-$(git config --global user.name)}"

echo "=== COMMITS (all branches, author ~ $AUTHOR) since $SINCE ==="
for d in "$ROOT"/*/; do
  [ -e "$d/.git" ] || continue
  out=$(git -C "$d" log --all --author="$AUTHOR" --since="$SINCE 00:00 -30 days" \
        --pretty='%ad | %s' --date=short 2>/dev/null \
        | awk -F' \\| ' -v s="$SINCE" '$1 >= s' \
        | grep -Ev '\| (WIP on |index on |On .*: autostash)' \
        | sed 's/^/  /' | sort -u || true)
  [ -n "$out" ] && printf '## %s\n%s\n' "$(basename "$d")" "$out"
done

echo
echo "=== PRs authored, created since $SINCE ==="
if command -v gh >/dev/null 2>&1; then
  gh search prs --author=@me --created=">=$SINCE" \
    --json repository,number,title,createdAt,state,url --limit 50 \
    --jq '.[] | "  \(.createdAt[0:10]) | \(.state) | \(.repository.name)#\(.number) | \(.title) | \(.url)"' \
    2>/dev/null | sort || echo "  (gh query failed)"
else
  echo "  (gh not installed)"
fi

echo
echo "=== REVIEWS & COMMENTS authored by me, since $SINCE ==="
if command -v gh >/dev/null 2>&1; then
  ME=$(gh api user --jq .login 2>/dev/null)
  # Candidate PRs I engaged with: any review/comment bumps updatedAt, so updated>=SINCE is a safe lower bound.
  PRS=$( { gh search prs --reviewed-by=@me --updated=">=$SINCE" --json repository,number --limit 100 \
             --jq '.[]|"\(.repository.nameWithOwner)#\(.number)"' 2>/dev/null
           gh search prs --commenter=@me  --updated=">=$SINCE" --json repository,number --limit 100 \
             --jq '.[]|"\(.repository.nameWithOwner)#\(.number)"' 2>/dev/null; } | sort -u )
  for pr in $PRS; do
    owner=${pr%%/*}; rest=${pr#*/}; name=${rest%%#*}; num=${rest##*#}
    gh api graphql -f query='
      query($owner:String!,$name:String!,$number:Int!){
        repository(owner:$owner,name:$name){ pullRequest(number:$number){
          title
          reviews(first:50){nodes{author{login} submittedAt state body}}
          comments(first:100){nodes{author{login} createdAt body}}
          reviewThreads(first:50){nodes{comments(first:20){nodes{author{login} createdAt body path}}}}
        }}}' -F owner="$owner" -F name="$name" -F number="$num" 2>/dev/null \
    | jq -r --arg ME "$ME" --arg C "$SINCE" --arg REPO "$name#$num" '
        .data.repository.pullRequest as $pr
        | ($pr.title[0:50]) as $title
        | ( [ $pr.reviews.nodes[] | select(.author.login==$ME and .submittedAt[0:10]>=$C and (.body|length>0)) | {t:.submittedAt, k:"review(\(.state))", b:.body} ]
          + [ $pr.comments.nodes[] | select(.author.login==$ME and .createdAt[0:10]>=$C) | {t:.createdAt, k:"comment", b:.body} ]
          + [ $pr.reviewThreads.nodes[].comments.nodes[] | select(.author.login==$ME and .createdAt[0:10]>=$C) | {t:.createdAt, k:"inline(\(.path|split("/")|last))", b:.body} ] )
        | sort_by(.t)[]
        | "  \(.t[0:10]) | \($REPO) \"\($title)\" | \(.k) | \((.b//"")|gsub("[\r\n]+";" ")[0:110])"'
  done
else
  echo "  (gh not installed)"
fi
