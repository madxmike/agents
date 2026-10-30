# software-factory

A goal becomes a ledger; the ledger becomes slices; each slice is one small diff and one check.

```mermaid
sequenceDiagram
    actor You
    participant P as Planner
    participant L as .factory ledger
    participant I as Implementer
    participant V as Verifier

    You->>P: goal
    P->>L: properties and witnesses
    P->>L: scenarios
    P->>L: slices with scopes and frames
    loop one property
        P->>I: slice N
        I->>V: diff
        V-->>I: pass or fail
        I->>L: evidence class
    end
    L-->>You: what is proven, assumed, unknown
```

## Artifacts

```mermaid
flowchart LR
    L[ledger.yaml] --> S[scenarios.md]
    L --> P[slices.md]
    P --> D[one diff]
    D --> C[check]
    C --> E[evidence.md]
    E --> L
```

## Phases

| Phase | Output | Gate |
|---|---|---|
| 1. Ledger | properties, witnesses, evidence classes | every property can fail |
| 2. Plan | slices, scopes, frames | one property per slice |
| 3. Execute | one diff, one check | full suite stays green |
| 4. Audit | evidence report | claimed equals actual |
| 5. Escalate | model or proof | assumptions named |

## Rules that matter most

- A property without a witness cannot fail.
- A diff that closes five properties and then fails tells you nothing.
- The frame is the whole suite, not the package you touched.
- An obligation whose locus is not code is refused, not faked.
