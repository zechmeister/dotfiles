---
name: grill-with-docs
description: Relentless engineering interview to sharpen a plan or design while building living documentation (CONTEXT.md domain glossary and docs/adr/ ADRs) directly in the repo.
---

# Grill With Docs (Stateful Engineering Plan & Architecture Grilling)

Conduct a relentless grilling interview on a proposed software change or system architecture, while actively recording domain vocabulary into `CONTEXT.md` and high-stakes decisions into Architectural Decision Records (`docs/adr/`).

---

## Workflow

1. **Reconnaissance:** Inspect the existing codebase (schemas, types, directory structure) to understand established idioms and bounded contexts.
2. **Interview Frontier:** Ask questions in rounds of frontier decisions (see [Round Format](#round-format)).
3. **Inline Domain Modeling:**
   - When a domain concept or term crystallizes, record or update it immediately in `CONTEXT.md` following [CONTEXT-FORMAT.md](references/CONTEXT-FORMAT.md).
   - Challenge ambiguous or overloaded terms against existing terminology.
4. **ADR Capture on 3 Gates:**
   - When a decision is settled that is:
     1. **Hard to reverse**,
     2. **Surprising without context**, and
     3. **A real trade-off**,
     immediately generate an ADR in `docs/adr/NNNN-slug.md` following [ADR-FORMAT.md](references/ADR-FORMAT.md).

---

## Round Format

```markdown
❓ **Q1** - **<Question Title>**: <Detailed question explaining context, trade-offs, or multiple choices (A, B, C)>

➡️ **Recommendation:** <Your recommended answer and why>

---

❓ **Q2** - **<Question Title>**: <Detailed question explaining context, trade-offs, or multiple choices (A, B, C)>

➡️ **Recommendation:** <Your recommended answer and why>
```

---

## Session Wrap-up
When all frontier questions are answered:
- Confirm `CONTEXT.md` and any new `docs/adr/` records are clean and committed to the workspace.
- Provide a concise summary of the settled architecture ready to pass to implementation or spec writing.
