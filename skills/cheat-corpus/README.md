# cheat-corpus

Tests the checks, not the code.

```mermaid
sequenceDiagram
    participant Author
    participant C as cheat-corpus
    participant G as Gate
    participant P as Property

    Author->>C: property and check
    C->>C: invent a bypass
    C->>G: apply the bypass
    G-->>C: rejected or accepted
    alt rejected
        C->>C: keep the cheat
    else accepted
        C->>P: amend the definition or check
        C->>C: keep the cheat
    end
```

```mermaid
flowchart TD
    A[Cheat accepted] --> B{Why}
    B -->|single indicator| C[Add a second indicator]
    B -->|test double decides| D[Use the real dependency]
    B -->|no negative case| E[Add a must-reject input]
    B -->|cannot be observed| F[Record as assumed]
    C --> R[Re-run the corpus]
    D --> R
    E --> R
    F --> R
```

## Rules

- Minimal, compiling, plausible.
- Never delete a cheat after fixing it.
- A cheat that passes means the check is too weak, not that the cheat is wrong.
- If no cheat can be written, the property is not testable; record that.
