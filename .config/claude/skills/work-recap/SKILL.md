---
name: work-recap
description: Summarize what the user worked on per day across their /ffy Claude Code sessions since a given date. Use when the user asks for a recap, work log, standup notes, or "what did I work on since <date>" across projects. Takes a look-back date as input.
---

# Work recap

Produce a short per-day summary of what the user worked on across all `/ffy` projects, including older sessions that were active within the window (it filters by each message's own timestamp, not the session start time).

## Steps

1. Resolve the look-back date from the user's input (the skill arg) to a `YYYY-MM-DD` cutoff, using today's date for relative phrasing ("last week", "since Monday", "June 10").

2. Gather both signals (run in parallel):

   ```
   python3 ~/.claude/skills/work-recap/walk_sessions.py <YYYY-MM-DD>   # session prompts, grouped by day
   bash   ~/.claude/skills/work-recap/git_activity.sh  <YYYY-MM-DD>   # commits (local git log --all) + authored PRs (gh)
   ```

   Session output is grouped by day, one line per prompt: `[HH:MM] project  prompt` (`wt:` = git worktree, `cwt:` = `.claude` worktree). Large output is persisted to a file path; `Read` that file fully (it may paginate) before summarizing — do not summarize from a partial page.

   `git_activity.sh` uses **local `git log --all`** for commits on purpose: it covers every locally-cloned `/ffy` repo (worktrees included) and catches unmerged feature-branch work that `gh search commits` misses (it only indexes the default branch). `gh` is used for authored PRs and, in a third section (`REVIEWS & COMMENTS authored by me`), for review submissions + issue comments + inline review-thread comments the user left on *others'* PRs. Those lines are `date | repo#num "title" | kind | snippet` (`kind` = `review(STATE)` / `comment` / `inline(file)`), attributed to the day the comment was actually made (not the PR's updatedAt). Same commit may appear in two repos (fork + upstream); that's real, keep one line.

   To scope to other projects, pass a second arg as a glob, e.g. `walk_sessions.py 2026-06-10 '*infrastructure*'`.

3. Output a **skimmable bullet list, grouped by day, one bullet per topic** — built for updating time records, not reading prose. Each bullet: the concrete feature/bug/system in a few words, with PR/commit evidence inline when it exists, e.g.:

   ```
   **Jun 17**
   - geoDataIntersection refactor: split clipTarget.ts, parallelize loadJob (intersections-refactor branch)
   - Nightly jobs one-per-sandbox fix — PR #4107 (merged)
   - captain_prod "request body too large": traced burst IPs via nginx/whois
   ```

   Merge the session topics with the commits/PRs (a commit/PR is the strongest evidence a topic was real work). Collapse the back-and-forth into 2-6 topics per day. No paragraphs. Mark PR state (merged/open) since it helps with billing.

   Fold review/comment activity in as its own kind of work — reviewing a colleague's PR is billable effort distinct from the user's own commits. Collapse a burst of inline comments on one PR into a single bullet naming the PR and the gist (e.g. `- Reviewed maxmueh's xplan error-report PR #4144: pushed for tests, zod validation at the xplanbox boundary, API-design pushback`), rather than one bullet per comment.

4. Note a fork (`HAL_Plan`) vs main-repo split only if it changes what the line means. Offer to dump the list to a file.
