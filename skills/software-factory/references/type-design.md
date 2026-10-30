# Type design

A step between the ledger and the slices. Its job is to move invariants from tests into the type system, and to name the ones that cannot go there.

## Why

A test says the invariant held on the inputs it tried. A type says the invariant cannot be violated in the first place. The strongest property is one the program cannot express a violation of.

A type system is not a theorem prover. It enforces structure and values, not time, IO, distribution, or intent. The output is therefore two lists: what the compiler now prevents, and what still needs a check.

## Procedure

For each property, answer:

1. What is the invariant? For example, "an ISBN is canonical and valid."
2. Can a value that violates it be constructed?
3. If not, what type makes it unrepresentable?
4. If yes, why? External system, time, concurrency, intent, or language limit.
5. What check covers it instead?

## Type moves

| Move | Encodes | Example |
|---|---|---|
| Opaque value | validity at construction | `type ISBN struct{ value string }`, only `Parse` constructs |
| Smart constructor | normalization and validation | `Parse` returns the canonical form or an error |
| Closed set | no ad-hoc values | `failure` with unexported fields and named constructors |
| Sum type | one of N states | sealed interface with an unexported method |
| State machine | legal transitions | a distinct type per state, or a phantom type parameter |
| Capability | authority to act | a token the method requires |
| Non-empty | absence impossible | constructor rejects empty; the type carries the proof |
| Boundary type | cross-cutting response rules | `*response` instead of `http.ResponseWriter` |
| Registration table | no unknown members | the route table is the only route constructor |

## Fall-out test

For each type, ask: given only these types and the contract, what can an implementer still get wrong? List it. That list is the escape list. If it is empty, either the types are perfect or the analysis is shallow.

## Output: `.factory/types.md`

- **Invariant table**: property, invariant, encodable, type or constructor, what the compiler prevents, residual.
- **Type sketches**: names, constructors, methods, visibility. Design, not code.
- **Escape list**: property, why it is not encodable, the check that covers it.
- **Fall-out analysis**: decisions the compiler still leaves open.
- **Migration notes**: what existing code changes.

## Rules

1. Prefer an opaque value over a validated string passed around.
2. A constructor that can fail is better than a type that can be wrong.
3. Do not invent a type that adds no invariant. A wrapper that does not validate is noise.
4. Do not claim a property is type-enforced unless constructing a violating value is impossible from outside the package.
5. Record language limits honestly. Go has no sum types, no exhaustiveness checking, no linear types, and no refinement types.
6. The escape list is part of the deliverable. A type design with no escape list is fiction.
