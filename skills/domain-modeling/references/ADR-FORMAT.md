# ADR Format

ADRs live in `docs/adr/` and use sequential numbering: `0001-slug.md`, `0002-slug.md`, etc.

Create the `docs/adr/` directory lazily: only when the first ADR is needed.

## Template

```md
# {Short title of the decision}

{1-3 sentences: what's the context, what did we decide, and why.}
```

An ADR can be a single paragraph. The value is in recording *that* a decision was made and *why*, not in filling out bureaucratic sections.

## Optional Sections (Only when needed)

- **Status** frontmatter (`proposed | accepted | deprecated | superseded by ADR-NNNN`)
- **Considered Options**: only when rejected alternatives are non-obvious
- **Consequences**: only when non-obvious downstream effects need to be highlighted

## Numbering

Scan `docs/adr/` for the highest existing number and increment by one.

## The 3 Gates (When to write an ADR)

All three must be true:

1. **Hard to reverse:** The cost of changing minds later is meaningful.
2. **Surprising without context:** A future reader will look at the code and wonder "why on earth did they do it this way?"
3. **The result of a real trade-off:** Genuine alternatives existed and one was chosen for specific reasons.
