# Slice plan

Order the ledger into slices. A slice is the smallest diff that establishes exactly one property and can be verified on its own.

## Slice schema

```yaml
- id: S03
  property: isbn.canonical
  diff_scope:
    - internal/isbn/**
  frame:
    - cmd/**
    - internal/httpapi/**
  verify: go test ./internal/isbn/...
  evidence_gained: tested
  stop_if: |
    The checksum rules require a product decision about 977 prefixes.
```

- **diff_scope** — files the slice is permitted to modify. Anything else is out of frame.
- **frame** — code that must remain unchanged and must still pass after the slice. The frame check is the full existing suite, not the slice's own command.
- **verify** — the command that decides the slice. If it cannot be written, the slice is not ready.
- **stop_if** — the condition that should halt the slice and return to planning.

## Ordering

Use this order unless the repository dictates otherwise:

1. **Harness.** CI running the existing test command. No behaviour. This proves the loop works before there is anything to protect.
2. **Pure functions with high evidence value.** Identity, parsing, validation, money arithmetic. These are cheap to exhaust and expensive to get wrong later.
3. **Contract against provisional storage.** Get the observable interface correct before the real dependency is wired.
4. **Real dependency.** Replace the provisional implementation; confirm the same contract holds against the real engine.
5. **Boundary properties.** Restart, second instance, process death. These invalidate fake persistence.
6. **Concurrency.** Parallel writes, duplicate suppression, lost updates.
7. **Failure modes.** Dependency down, timeout, partial failure.
8. **Hardening.** Body limits, content types, unknown fields, error disclosure.
9. **Operability.** Logs, metrics, health versus readiness.
10. **Packaging.** Compose or container configuration so the contract tests run against the composed system.

## Rules

1. Do not schedule a property whose check depends on a property that is not yet satisfied.
2. Test-only slices are valid and often the highest value. A slice that only adds a restart test may change no production code.
3. If a slice requires a design decision that the ledger does not cover, stop and return to Phase 1. Do not decide implicitly in code.
4. If two properties must be satisfied by one diff, split the diff into enabling and achieving slices, and record the dependency.
5. Order by evidence gained per unit of diff. The first three slices should establish the harness, the pure core, and the observable contract.
6. Do not schedule "refactor" slices. Refactoring is applied when a property requires it, or recorded as a separate property with its own check.
7. Estimate the diff in files and lines. If a slice exceeds roughly 200 changed lines, it is probably closing more than one property.

## Frame

The frame is the set of properties the slice promises not to break. It is not rhetorical: run the full suite after the slice. A slice that passes its own check and breaks an existing property is a regression, not progress.

If the slice cannot preserve the frame, it is too large or it needs an enabling slice first.

## Output

Write `.factory/slices.md` containing the ordered list, the property each slice closes, its verification command, and the frame. Report the total number of slices and the first three.

## Slices are outcomes

A slice states what becomes true, not what files change.

Bad: "add `Store.Delete` using `DELETE FROM books`".

Good: "a repeated DELETE succeeds and leaves no row".

`diff_scope` is a conflict boundary between parallel workers, not an instruction to the implementer. If no conflict is possible, omit it. Never put implementation steps, signatures, or SQL in a slice.
