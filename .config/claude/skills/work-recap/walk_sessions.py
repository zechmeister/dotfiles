#!/usr/bin/env python3
"""Extract user prompts from Claude Code sessions since a cutoff date, grouped by day.

Filters by each message's own timestamp (not session start), so long-running
sessions that were edited within the window still surface their recent activity.

Usage: walk_sessions.py <YYYY-MM-DD> [project-glob]
  project-glob defaults to '*ffy*' (matches encoded project dirs under ~/.claude/projects)
"""
import json, glob, os, sys
from collections import defaultdict

cutoff = sys.argv[1]
pattern = sys.argv[2] if len(sys.argv) > 2 else '*ffy*'
root = os.path.expanduser('~/.claude/projects')

files = [f for d in glob.glob(os.path.join(root, pattern))
         for f in glob.glob(os.path.join(d, '*.jsonl')) if '/subagents/' not in f]

NOISE = {'.', 'run !', 'run', 'ok', 'yes', 'y', 'continue', 'go', 'apply', 'next',
         'again', 'try again', 'do it', 'pbcopy', 'show again', 'apply again'}


def user_text(o):
    if o.get('type') != 'user':
        return None
    m = o.get('message') or {}
    if m.get('role') != 'user':
        return None
    c = m.get('content')
    t = None
    if isinstance(c, str):
        t = c
    elif isinstance(c, list):
        for p in c:
            if isinstance(p, dict) and p.get('type') == 'text':
                t = p.get('text')
                break
            if isinstance(p, dict) and p.get('type') == 'tool_result':
                return None
    if not t:
        return None
    t = t.strip()
    if not t or t.startswith('<') or t.startswith('[Request interrupted'):
        return None
    if t.startswith('This session is being continued'):
        return None
    if t.lower() in NOISE:
        return None
    return t


byday = defaultdict(list)
for f in files:
    proj = (f.split('/projects/')[1].split('/')[0]
            .replace('-Users-flo-ffy-', '')
            .replace('--claude-worktrees-', '/cwt:')
            .replace('-worktrees-', '/wt:'))
    with open(f, errors='ignore') as fh:
        for line in fh:
            try:
                o = json.loads(line)
            except ValueError:
                continue
            ts = o.get('timestamp') or ''
            if ts[:10] < cutoff:
                continue
            tx = user_text(o)
            if tx:
                byday[ts[:10]].append((ts[11:16], proj, ' '.join(tx.split())[:170]))

for day in sorted(byday):
    print(f"\n########## {day}   ({len(byday[day])} prompts)")
    for hm, proj, tx in sorted(byday[day]):
        print(f"  [{hm}] {proj:34s} {tx}")

if not byday:
    print(f"No sessions with activity since {cutoff} for glob '{pattern}'.")
