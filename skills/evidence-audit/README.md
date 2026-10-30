# evidence-audit

Turns "the tests pass" into a claim about what is actually established.

```mermaid
sequenceDiagram
    participant A as Auditor
    participant L as Ledger
    participant T as Test
    participant C as Code

    A->>L: claimed evidence
    A->>T: locate the artifact
    A->>C: stub or delete the implementation
    T-->>A: does the check fail?
    A->>A: classify the evidence
    A-->>L: gaps and blocking assumptions
```

```mermaid
flowchart LR
    N[none] --> AS[assumed]
    AS --> J[judged]
    J --> T[tested]
    T --> B[bounded-proved]
    B --> P[proved]
    P --> Q[as strong as its assumptions]
```

## Red flags

- The test passes with the implementation deleted.
- The double enforces the property.
- The assertion restates the code.
- The check never runs in CI.
- A proof does not name its model.
- A waiver has no expiry.
