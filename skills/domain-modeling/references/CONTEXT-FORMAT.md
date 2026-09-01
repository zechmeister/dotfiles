# CONTEXT.md Format

## Structure

```md
# {Context Name}

{One or two sentence description of what this context is and why it exists.}

## Language

**Order**:
{A one or two sentence description of the term}
_Avoid_: Purchase, transaction

**Invoice**:
A request for payment sent to a customer after delivery.
_Avoid_: Bill, payment request

**Customer**:
A person or organization that places orders.
_Avoid_: Client, buyer, account
```

## Rules

- **Be opinionated.** When multiple words exist for the same concept, pick the best one and list the others under `_Avoid_`.
- **Keep definitions tight.** One or two sentences max. Define what it IS, not what it does.
- **Pure vocabulary only.** No implementation details, specs, or scratch notes.
- **Only include context-specific terms.** General programming concepts (timeouts, errors) do not belong.

## Single vs Multi-Context Repos

- **Single Context (default):** One `CONTEXT.md` at repo root.
- **Multiple Contexts:** A `CONTEXT-MAP.md` at the repo root mapping bounded contexts to their paths.
