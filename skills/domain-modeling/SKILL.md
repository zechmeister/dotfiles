---
name: domain-modeling
description: Build and sharpen a project's domain model, terminology, and architecture decisions. Use when editing CONTEXT.md or recording Architectural Decision Records (ADRs).
---

# Domain Modeling

Actively build and sharpen the project's domain model and architecture records.

## Files
- `CONTEXT.md`: Glossary of domain terms. Follow [CONTEXT-FORMAT.md](references/CONTEXT-FORMAT.md).
- `docs/adr/`: Architecture decision records. Follow [ADR-FORMAT.md](references/ADR-FORMAT.md).

## Rules
1. **Challenge Vocabulary:** Ensure terms in conversation match definitions in `CONTEXT.md`. Propose precise canonical terms for vague concepts.
2. **Keep Definitions Tight:** 1-2 sentences defining what the concept IS, with an `_Avoid_` list for rejected synonyms.
3. **Record ADRs on 3 Gates:** Only record when hard to reverse, surprising without context, and a genuine trade-off.
