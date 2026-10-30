# Ledger schema

The ledger is the single source of truth for what the system must do. Properties omitted from the ledger are outside the frame and are not assumed to hold.

## Schema

```yaml
version: 1
system: book-api

scope:
  decisions:
    - id: D1
      decision: Canonical identifier is ISBN-13.
      rationale: One record per book; ISBN-10 input is normalized.
    - id: D2
      decision: PUT is the only write verb.
      rationale: A natural key makes PUT idempotent; create-only semantics are not required yet.

properties:
  - id: isbn.canonical
    kind: derived              # primitive | derived
    scope: repo                # repo | pkg | file | symbol | instance
    locus: code                # code | config | infra | data
    polarity: require          # require | forbid
    statement: Any valid ISBN-10 or ISBN-13 maps to exactly one ISBN-13, and invalid checksums are rejected.
    witness: Two stored rows for one book, or a 200 response for an invalid checksum.
    check:
      kind: test               # test | analysis | metric | judged | manual
      command: go test ./internal/isbn/...
    definition:                # derived only
      version: 1
      indicators:
        - {name: fixed_table_pass, weight: 0.5}
        - {name: fuzz_roundtrip_pass, weight: 0.5}
      aggregator: all indicators pass
    evidence: tested           # tested | bounded-proved | proved | assumed
    assumes: []
    conflicts: []
    waivers: []

non_goals:
  - authentication
  - pagination
```

## Field rules

**statement** — one sentence. It must be observable without reading the implementation. If the sentence requires the word "clean", "cohesive", or "maintainable", it is not yet a property.

**check** — the command proves the property, not a package layout. Prefer `go test ./...` over a package-specific path; the layout is the implementer's choice.

**witness** — the concrete observation that would prove the statement false. A property without a witness is not usable: it cannot fail, so it cannot gate anything. Write the witness before the check.

**locus** — the layer permitted to satisfy the property. If a property can only be satisfied outside the code, the implementation must refuse it rather than emit a plausible code diff. Latency, availability under provider failure, and data correctness across systems usually have `locus` of `config`, `infra`, or `data`.

**kind** — `primitive` is checked directly. `derived` is defined over indicators; the definition is a decision, not a discovery, and it must be versioned.

**polarity** — `forbid` properties ("never double-charge", "never ship after cancel") are usually more valuable than `require` properties, because the witness is unambiguous.

**evidence**:

| class | meaning |
|---|---|
| `tested` | executed against inputs. A failure is proof; a pass is a sample. |
| `bounded-proved` | exhaustive over a stated finite model or bound. State the bound. |
| `proved` | holds for all executions of a stated model. State the model and premises. |
| `judged` | a pinned, calibrated probabilistic model. A failure is a signal, not proof. Never promotes a property above `tested` on its own. |
| `assumed` | depends on an external premise that was not demonstrated here. |

**judged fields** — for `check.kind: judged`, also record:

```yaml
    check:
      kind: judged
      rule: comments-describe-behavior
      model: opencode/jev-1.13
      threshold: 0.8
      artifact: .factory/evidence/S03.gallant.json
```

The model and rule are pinned because a model update changes the probabilities. See `judged-checks.md`.

**assumes** — every premise the evidence depends on: database engine semantics, clock behaviour, provider deduplication, network failure model. A property is only as strong as its weakest assumption.

**waivers** — scoped exceptions with a reason and an expiry date. An expired waiver is a failed property.

## Derived properties

1. At least two indicators, partially independent. A single indicator is a proxy and will be satisfied without the construct.
2. State the aggregation and threshold explicitly.
3. Version the definition. Changing a definition is a ledger change, not a code change.
4. Generate a cheat corpus for the definition before relying on it.
5. Do not use an indicator that is a function of git history, deploy metrics, or review outcomes as a search gradient. Those are only observable after the change, and the system's own commits move them.

## Conflicts

Record known conflicts rather than resolving them silently:

```yaml
conflicts: [pkg.max_files]
```

A conflict is either ordered (one property has priority) or unresolved. Unresolved conflicts are reported to the user for a decision. Do not emit a diff that oscillates between two conflicting properties.
