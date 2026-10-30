# Agents

Skills for building software from observable properties, one small verifiable diff at a time.

## The loop

```mermaid
sequenceDiagram
    actor You
    participant SF as software-factory
    participant L as Property ledger
    participant EX as Executor agents
    participant CC as cheat-corpus
    participant EA as evidence-audit

    You->>SF: goal or one property
    SF->>L: properties, scenarios, slices
    loop each slice
        SF->>EX: dispatch one property
        EX->>L: diff plus evidence
        SF->>CC: test the checks
        CC-->>SF: accepted or rejected cheats
    end
    SF->>EA: audit claimed evidence
    EA-->>You: gaps, assumptions, trust level
```

## Which skill when

```mermaid
flowchart TD
    G([Goal]) --> SF[software-factory]
    SF --> L[(Ledger)]
    L --> SL[Slices]
    SL --> EX[Execute and verify]
    EX --> CC[cheat-corpus]
    CC --> EA[evidence-audit]
    EA -->|gap found| SF
    EA -->|evidence holds| D([Done])
    EX -.->|tests cannot settle it| FE[formal-escalation]
    FE -.-> EX
```

## Skills

| Skill | Job |
|---|---|
| `software-factory` | Turn a goal into a ledger, plan slices, run the loop |
| `cheat-corpus` | Prove the checks can actually fail |
| `evidence-audit` | Separate claimed evidence from real evidence |
| `formal-escalation` | Use models and proofs when tests are not enough |
| `code-writing-principals` | Compaction and small batches |
