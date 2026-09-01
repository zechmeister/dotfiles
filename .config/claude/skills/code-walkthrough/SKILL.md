---
name: code-walkthrough
description: 'Guided expert-building tour through an unfamiliar codebase area. Use when the user wants to deeply understand existing code before refactoring or judging a design: walking file by file, asking questions, building a mental model / whiteboard. Triggers: "walk me through", "I need to understand X before", "make me an expert on", "guided tour of the code".'
---

# Code walkthrough

Turn the user into an expert on a code area through short, iterative, user-paced stops. The user drives (reads in their IDE); Claude navigates. The goal is the user's mental model, not Claude's summary.

## Setup (once)

1. Agree on the goal in one sentence (e.g. "be able to draw on a whiteboard how everything until 'editor ready' is computed").
2. Create `tmp-<topic>-walkthrough.md` in the repo root: an ordered backlog of stops (file + one-line why), grouped into acts. 10-15 stops max. Mark progress: `[ ]` open, `[>]` current, `[x]` done.
3. Create `tmp-improvement-notes.md` in the repo root: observations and possible improvements collected along the way, organized by file. Seed it with anything the user already flagged.

## Per stop

1. Give a very short intro: 2-4 bullets, each anchored to a clickable `path:line`, naming only the lines worth reading. One "notice:" sentence carrying the stop's key insight.
2. Offer one whiteboard building block in chat (a box/arrow description the user can draw). Never write whiteboard content into the files unless asked.
3. Stop. The user reads and asks questions.

## Answering questions

- Quote the user's words inline (short fragment in bold or quotes) directly before each answer; never collect questions in a summary at the top - the user has a small window and cannot scroll.
- Multiple questions: number them, each with a 2-4 word topic label.
- Verify before asserting: run the grep/read that proves the claim; cite `path:line`. If the user proposes a cleanup or hypothesis, check it in the code and report "verified" or what breaks.
- Explain unfamiliar language/framework concepts from zero when asked (with a minimal runnable example), then connect back to the codebase.
- If the user's mental-model statement is almost right, confirm it and give the precision delta - never restate what they already got right.

## After every exchange

- Append new observations/improvement ideas to `tmp-improvement-notes.md` under the current file's heading. Include ideas the user voiced (attribute nothing; just record).
- Update progress markers in the backlog file only when the user says a stop is done - never declare a stop finished for them.

## Rules

- Small steps; one stop at a time; end each message with the open stop or the next one, as an offer.
- Contact points short: the user reads code, not essays.
- No edits to production code during the walkthrough; tmp files only.
- If a finding is significant enough for the project's real docs/plans, say so and where it belongs; move it only on request.
